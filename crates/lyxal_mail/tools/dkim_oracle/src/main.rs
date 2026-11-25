// SPDX-License-Identifier: AGPL-3.0-only

//! Oracle différentiel DKIM (plan du lot 5, décision S2), outil lancé à la main.
//!
//! Pour chaque message du corpus (corpus de `mail-auth` passé en argument, message signé pour
//! Lyxal de `lyxal_crypto`, messages signés ici par les clés de `lyxal_crypto` puis altérés) :
//!
//! * (a) octets canonicalisés : en-têtes et empreinte du corps, quatre canonicalisations,
//!   `lyxal_crypto::dkim` contre `mail_auth::testing` ;
//! * (b) résultats de vérification : `lyxal_mail::auth::DkimVerifier` (sur `StaticResolver`)
//!   contre `mail_auth::MessageAuthenticator::verify_dkim` (sur un cache prérempli des mêmes
//!   enregistrements : aucune requête DNS n'est faite).
//!
//! Sortie : une ligne par écart, puis un bilan. Code de sortie 1 si (a) diffère ou si le
//! verdict « réussi / non réussi » diffère ; les écarts de mot de résultat seuls (politique
//! propre à Lyxal, voir le README de `lyxal_mail`) sont listés sans faire échouer l'outil.

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    DkimBodyHasher, DkimCanonicalization, DkimHeaderCanonicalizer, DkimSigningKey,
    Ed25519SigningKey, RsaModulusBits, RsaSigningKey,
};
use lyxal_mail::auth::{DkimVerifier, MessageHeaders};
use lyxal_mail::dns::StaticResolver;
use mail_auth::dkim::record::DomainKey;
use mail_auth::dkim::Canonicalization;
use mail_auth::dns::TxtRecordParser;
use mail_auth::{
    AuthenticatedMessage, DnsCache, MessageAuthenticator, Mx, Negative, RecordSet, ResolverCache,
    TxtRecord,
};
use std::borrow::Borrow;
use std::collections::HashMap;
use std::hash::Hash;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::process::ExitCode;
use std::sync::Mutex;
use std::time::Instant;

const LYXAL_SIGNED: &str =
    include_str!("../../../../lyxal_crypto/tests/fixtures/dkim/lyxal_signed_test_only.txt");

/// Cache de `mail-auth` prérempli (aucune expiration).
struct MapCache<K, V>(Mutex<HashMap<K, V>>);

impl<K: Hash + Eq, V: Clone> MapCache<K, V> {
    fn new() -> Self {
        Self(Mutex::new(HashMap::new()))
    }
}

impl<K: Hash + Eq, V: Clone> ResolverCache<K, V> for MapCache<K, V> {
    fn get<Q>(&self, key: &Q) -> Option<V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq + ?Sized,
    {
        self.0.lock().ok()?.get(key).cloned()
    }

    fn remove<Q>(&self, key: &Q) -> Option<V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq + ?Sized,
    {
        self.0.lock().ok()?.remove(key)
    }

    fn insert(&self, key: K, value: V, _: Instant) {
        if let Ok(mut map) = self.0.lock() {
            map.insert(key, value);
        }
    }
}

type Answer<T> = Result<RecordSet<T>, Negative>;

struct Caches {
    txt: MapCache<Box<str>, TxtRecord>,
    mx: MapCache<Box<str>, Answer<Mx>>,
    ipv4: MapCache<Box<str>, Answer<Ipv4Addr>>,
    ipv6: MapCache<Box<str>, Answer<Ipv6Addr>>,
    ptr: MapCache<IpAddr, Answer<Box<str>>>,
}

impl DnsCache for Caches {
    type Txt = MapCache<Box<str>, TxtRecord>;
    type Mx = MapCache<Box<str>, Answer<Mx>>;
    type Ipv4 = MapCache<Box<str>, Answer<Ipv4Addr>>;
    type Ipv6 = MapCache<Box<str>, Answer<Ipv6Addr>>;
    type Ptr = MapCache<IpAddr, Answer<Box<str>>>;

    fn txt(&self) -> Option<&Self::Txt> {
        Some(&self.txt)
    }
    fn mx(&self) -> Option<&Self::Mx> {
        Some(&self.mx)
    }
    fn ipv4(&self) -> Option<&Self::Ipv4> {
        Some(&self.ipv4)
    }
    fn ipv6(&self) -> Option<&Self::Ipv6> {
        Some(&self.ipv6)
    }
    fn ptr(&self) -> Option<&Self::Ptr> {
        Some(&self.ptr)
    }
}

/// Message du corpus : enregistrements de clés et octets (fins de ligne CRLF).
struct Case {
    name: String,
    records: Vec<(String, String)>,
    message: Vec<u8>,
}

/// Format des corpus : enregistrements DNS, ligne vide, message en fins de ligne LF.
fn parse_fixture(name: &str, text: &str) -> Option<Case> {
    let (records, message) = text.split_once("\n\n")?;
    let records = records
        .lines()
        .filter_map(|line| line.split_once(' '))
        .map(|(name, value)| (name.to_string(), value.to_string()))
        .collect();
    Some(Case {
        name: name.to_string(),
        records,
        message: message
            .replace("\r\n", "\n")
            .replace('\n', "\r\n")
            .into_bytes(),
    })
}

const MESSAGE: &str = "From: Joe <joe@example.org>\r\nTo: x@lyxal.test\r\nSubject:  essai   de\r\n  repliement\r\nDate: Fri, 20 Nov 2026 10:00:00 +0000\r\n\r\nBonjour.  \r\n\tLigne.\r\n\r\n\r\n";

/// Signe `message` (même méthode que les essais de `lyxal_mail::auth`).
fn sign(
    message: &str,
    key: &DkimSigningKey,
    tags: &str,
    c: (DkimCanonicalization, DkimCanonicalization),
) -> Option<String> {
    let headers = MessageHeaders::parse(message.as_bytes()).ok()?;
    let mut hasher = DkimBodyHasher::new(c.1, None);
    hasher.update(headers.body);
    let body_hash = STANDARD.encode(hasher.finish().digest);
    let value = format!(" {tags} bh={body_hash};\r\n b=");
    let mut canonicalizer = DkimHeaderCanonicalizer::new(c.0);
    let h = tags.split("h=").nth(1)?.split(';').next()?;
    let mut used: HashMap<String, usize> = HashMap::new();
    for name in h.split(':') {
        let lower = name.trim().to_ascii_lowercase();
        let count = used.entry(lower.clone()).or_insert(0);
        let field = headers
            .fields
            .iter()
            .rev()
            .filter(|field| field.is(&lower))
            .nth(*count);
        if let Some(field) = field {
            *count += 1;
            canonicalizer.push_header(field.name, field.value).ok()?;
        }
    }
    let signed = canonicalizer
        .finish(b"DKIM-Signature", value.as_bytes())
        .ok()?;
    let signature = STANDARD.encode(key.sign(&signed).ok()?);
    Some(format!("DKIM-Signature:{value}{signature}\r\n{message}"))
}

fn record(key: &DkimSigningKey, k: &str) -> String {
    format!(
        "v=DKIM1; k={k}; p={}",
        STANDARD.encode(key.public_key_record_bytes())
    )
}

/// Messages signés par `lyxal_crypto`, puis altérés.
fn generated_cases() -> Vec<Case> {
    let mut cases = Vec::new();
    let (Ok(ed), Ok(rsa)) = (
        Ed25519SigningKey::generate(),
        RsaSigningKey::generate(RsaModulusBits::Rsa2048),
    ) else {
        eprintln!("génération des clés impossible");
        return cases;
    };
    let ed = DkimSigningKey::Ed25519(ed);
    let rsa = DkimSigningKey::Rsa(rsa);
    let records = vec![
        (
            "ed._domainkey.example.org".to_string(),
            record(&ed, "ed25519"),
        ),
        (
            "rsa._domainkey.example.org".to_string(),
            record(&rsa, "rsa"),
        ),
    ];
    use DkimCanonicalization::{Relaxed, Simple};
    for (header, body, word) in [
        (Simple, Simple, "simple/simple"),
        (Simple, Relaxed, "simple/relaxed"),
        (Relaxed, Simple, "relaxed/simple"),
        (Relaxed, Relaxed, "relaxed/relaxed"),
    ] {
        for (key, a, s) in [(&ed, "ed25519-sha256", "ed"), (&rsa, "rsa-sha256", "rsa")] {
            let tags =
                format!("v=1; a={a}; c={word}; d=example.org; s={s}; h=from:to:subject:date:from;");
            let Some(signed) = sign(MESSAGE, key, &tags, (header, body)) else {
                continue;
            };
            let variants = [
                ("intact", signed.clone()),
                ("corps modifié", signed.replace("Bonjour.", "Bonsoir.")),
                (
                    "espaces du corps",
                    signed.replace("Bonjour.  \r\n", "Bonjour. \r\n"),
                ),
                ("lignes vides ajoutées", format!("{signed}\r\n\r\n")),
                ("sujet modifié", signed.replace("essai", "essais")),
                ("casse du nom", signed.replace("Subject:", "SUBJECT:")),
                (
                    "From ajouté",
                    signed.replace("\r\n\r\nBonjour", "\r\nFrom: x@evil.example\r\n\r\nBonjour"),
                ),
                (
                    "en-tête non signé ajouté",
                    signed.replace("\r\n\r\nBonjour", "\r\nX-Ajout: 1\r\n\r\nBonjour"),
                ),
            ];
            for (label, message) in variants {
                cases.push(Case {
                    name: format!("lyxal {a} {word} {label}"),
                    records: records.clone(),
                    message: message.into_bytes(),
                });
            }
        }
    }
    cases
}

fn lyxal_canonicalization(c: DkimCanonicalization) -> Canonicalization {
    match c {
        DkimCanonicalization::Simple => Canonicalization::Simple,
        DkimCanonicalization::Relaxed => Canonicalization::Relaxed,
    }
}

/// (a) Octets canonicalisés : vrai si les deux bibliothèques s'accordent.
fn compare_canonicalization(case: &Case, report: &mut Vec<String>) -> bool {
    let Ok(headers) = MessageHeaders::parse(&case.message) else {
        report.push(format!(
            "{} : en-tête illisible pour lyxal_mail (comparaison (a) sautée)",
            case.name
        ));
        return true;
    };
    let mut agree = true;
    for c in [DkimCanonicalization::Simple, DkimCanonicalization::Relaxed] {
        let theirs_c = lyxal_canonicalization(c);
        // Corps.
        let mut hasher = DkimBodyHasher::new(c, None);
        hasher.update(headers.body);
        let ours = hasher.finish().digest.to_vec();
        let theirs = mail_auth::testing::whole_body_digest(theirs_c, headers.body, 0);
        if ours != theirs {
            agree = false;
            report.push(format!(
                "{} : empreinte du corps différente ({c:?})",
                case.name
            ));
        }
        // En-têtes : tous, dans l'ordre, puis un champ final sans `b=`.
        let mut canonicalizer = DkimHeaderCanonicalizer::new(c);
        let mut pushed = true;
        for field in &headers.fields {
            pushed &= canonicalizer.push_header(field.name, field.value).is_ok();
        }
        let ours = if pushed {
            canonicalizer
                .finish(b"X-Oracle", b" fin")
                .ok()
                .map(|data| data.as_bytes().to_vec())
        } else {
            None
        };
        let mut theirs = Vec::new();
        let values: Vec<(Vec<u8>, Vec<u8>)> = headers
            .fields
            .iter()
            .map(|field| {
                let value = field.raw.get(field.name.len() + 1..).unwrap_or_default();
                (field.name.to_vec(), value.to_vec())
            })
            .chain(std::iter::once((b"X-Oracle".to_vec(), b" fin".to_vec())))
            .collect();
        mail_auth::testing::canonicalize_headers(
            theirs_c,
            values
                .iter()
                .map(|(name, value)| (name.as_slice(), value.as_slice())),
            &mut theirs,
        );
        if ours.as_deref() != Some(theirs.as_slice()) {
            agree = false;
            report.push(format!(
                "{} : en-têtes canonicalisés différents ({c:?})",
                case.name
            ));
        }
    }
    agree
}

/// (b) Résultats de vérification : (même verdict, mots identiques).
async fn compare_verification(
    case: &Case,
    authenticator: &MessageAuthenticator,
    report: &mut Vec<String>,
) -> (bool, bool) {
    let mut resolver = StaticResolver::new();
    let caches = Caches {
        txt: MapCache::new(),
        mx: MapCache::new(),
        ipv4: MapCache::new(),
        ipv6: MapCache::new(),
        ptr: MapCache::new(),
    };
    for (name, value) in &case.records {
        resolver.set_txt(name, &[value.as_str()]);
        let parsed: TxtRecord = DomainKey::parse(value.as_bytes()).into();
        caches.txt.insert(
            format!("{}.", name.to_ascii_lowercase()).into_boxed_str(),
            parsed,
            Instant::now(),
        );
    }
    let ours: Vec<String> = DkimVerifier::new(&resolver)
        .verify(&case.message)
        .await
        .iter()
        .map(|output| output.result.as_str().to_string())
        .collect();
    let theirs: Vec<String> = match AuthenticatedMessage::parse(&case.message) {
        Some(message) => {
            let parameters = mail_auth::dns::Parameters::new(&message).with_cache(&caches);
            authenticator
                .verify_dkim(parameters)
                .await
                .iter()
                .map(|output| {
                    output
                        .result()
                        .to_string()
                        .split(';')
                        .next()
                        .unwrap_or_default()
                        .trim()
                        .to_string()
                })
                .collect()
        }
        None => vec!["illisible".to_string()],
    };
    let theirs = if theirs.is_empty() {
        vec!["none".to_string()]
    } else {
        theirs
    };
    let verdict = |words: &[String]| words.iter().map(|word| word == "pass").collect::<Vec<_>>();
    let same_verdict = verdict(&ours) == verdict(&theirs);
    let same_words = ours == theirs;
    if !same_words {
        report.push(format!(
            "{} : lyxal_mail {:?}, mail-auth {:?}{}",
            case.name,
            ours,
            theirs,
            if same_verdict {
                " (même verdict)"
            } else {
                " (VERDICT DIFFÉRENT)"
            }
        ));
    }
    (same_verdict, same_words)
}

#[tokio::main]
async fn main() -> ExitCode {
    let mut cases = Vec::new();
    if let Some(directory) = std::env::args().nth(1) {
        let Ok(entries) = std::fs::read_dir(&directory) else {
            eprintln!("dossier illisible : {directory}");
            return ExitCode::from(2);
        };
        let mut paths: Vec<_> = entries
            .filter_map(Result::ok)
            .map(|entry| entry.path())
            .collect();
        paths.sort();
        for path in paths {
            if path.extension().is_some_and(|extension| extension == "txt") {
                if let Ok(text) = std::fs::read_to_string(&path) {
                    let name = format!(
                        "mail-auth {}",
                        path.file_name()
                            .map(|n| n.to_string_lossy().into_owned())
                            .unwrap_or_default()
                    );
                    cases.extend(parse_fixture(&name, &text));
                }
            }
        }
    }
    cases.extend(parse_fixture(
        "lyxal_crypto lyxal_signed_test_only",
        LYXAL_SIGNED,
    ));
    cases.extend(generated_cases());

    let Ok(authenticator) = MessageAuthenticator::new_system_conf() else {
        eprintln!("résolveur de mail-auth impossible à construire");
        return ExitCode::from(2);
    };
    let mut report = Vec::new();
    let (mut canonical_ok, mut verdict_ok, mut words_ok) = (0, 0, 0);
    for case in &cases {
        canonical_ok += usize::from(compare_canonicalization(case, &mut report));
        let (verdict, words) = compare_verification(case, &authenticator, &mut report).await;
        verdict_ok += usize::from(verdict);
        words_ok += usize::from(words);
    }
    for line in &report {
        println!("{line}");
    }
    let total = cases.len();
    println!(
        "messages : {total} ; (a) canonicalisation identique : {canonical_ok}/{total} ; \
         (b) même verdict : {verdict_ok}/{total}, mêmes mots : {words_ok}/{total}"
    );
    if canonical_ok == total && verdict_ok == total {
        ExitCode::SUCCESS
    } else {
        ExitCode::FAILURE
    }
}
