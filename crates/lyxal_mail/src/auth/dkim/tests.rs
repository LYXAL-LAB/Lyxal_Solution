// SPDX-License-Identifier: AGPL-3.0-only

//! Essais DKIM : corpus de `mail-auth` 0.16.0 (copié dans `lyxal_crypto`, `Apache-2.0 OR MIT`)
//! et message signé pour Lyxal (`lyxal_crypto/tests/fixtures/dkim/`), messages signés ici par
//! les clés de `lyxal_crypto`, cas de la RFC 6376 §6.1 (inspirés de la liste de Mox
//! `dkim/dkim_test.go`, MIT, sans code repris).

#![allow(clippy::unwrap_used, clippy::expect_used)]

use super::*;
use crate::dns::{StaticRecordType, StaticResolver};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{DkimSigningKey, Ed25519SigningKey, RsaModulusBits, RsaSigningKey};

const MAIL_AUTH_001: &str =
    include_str!("../../../../lyxal_crypto/tests/fixtures/dkim/mail_auth/001.txt");
const MAIL_AUTH_002: &str =
    include_str!("../../../../lyxal_crypto/tests/fixtures/dkim/mail_auth/002.txt");
const MAIL_AUTH_003: &str =
    include_str!("../../../../lyxal_crypto/tests/fixtures/dkim/mail_auth/003.txt");
const LYXAL_SIGNED: &str =
    include_str!("../../../../lyxal_crypto/tests/fixtures/dkim/lyxal_signed_test_only.txt");

/// Heure des essais : après tous les horodatages des corpus.
const NOW: u64 = 1_800_000_000;

/// Format des corpus : enregistrements DNS, ligne vide, message en fins de ligne LF.
fn fixture(text: &str) -> (StaticResolver, Vec<u8>) {
    let (records, message) = text.split_once("\n\n").unwrap();
    let mut resolver = StaticResolver::new();
    for line in records.lines() {
        let (name, value) = line.split_once(' ').unwrap();
        resolver.set_txt(name, &[value]);
    }
    (resolver, message.replace('\n', "\r\n").into_bytes())
}

#[tokio::test]
async fn corpus_publies() {
    for (name, text, expected) in [
        (
            "001",
            MAIL_AUTH_001,
            vec![
                ("football.example.com", "brisbane"),
                ("football.example.com", "test"),
            ],
        ),
        ("002", MAIL_AUTH_002, vec![("example.com", "newengland")]),
        (
            "003",
            MAIL_AUTH_003,
            vec![("ietf.org", "ietf1"), ("ietf.org", "ietf1")],
        ),
        (
            "lyxal",
            LYXAL_SIGNED,
            vec![("example.test", "ed"), ("example.test", "rsa")],
        ),
    ] {
        let (resolver, message) = fixture(text);
        let outputs = DkimVerifier::at(&resolver, NOW).verify(&message).await;
        assert_eq!(outputs.len(), expected.len(), "{name}");
        for (output, (domain, selector)) in outputs.iter().zip(expected) {
            assert_eq!(output.result, DkimResult::Pass, "{name} {selector}");
            assert_eq!(output.domain.as_deref(), Some(domain));
            assert_eq!(output.selector.as_deref(), Some(selector));
            assert_eq!(output.signature_prefix.as_ref().map(String::len), Some(8));
        }
    }
}

#[tokio::test]
async fn corpus_alteres() {
    let (resolver, message) = fixture(MAIL_AUTH_001);
    let text = String::from_utf8(message).unwrap();
    let verifier = DkimVerifier::at(&resolver, NOW);
    // Corps modifié : empreinte fausse.
    let altered = text.replace("We lost the game.", "We won the game.");
    for output in verifier.verify(altered.as_bytes()).await {
        assert_eq!(output.result, DkimResult::Fail);
    }
    // En-tête signé modifié : signature fausse.
    let altered = text.replace("Subject: Is dinner ready?", "Subject: Is lunch ready?");
    for output in verifier.verify(altered.as_bytes()).await {
        assert_eq!(output.result, DkimResult::Fail);
    }
    // Repliement et casse changés : `relaxed/relaxed` tient.
    let altered = text.replace(
        "Subject: Is dinner ready?",
        "SUBJECT:   Is dinner\r\n  ready?",
    );
    for output in verifier.verify(altered.as_bytes()).await {
        assert_eq!(output.result, DkimResult::Pass);
    }
}

const MESSAGE: &str = "From: Joe <joe@example.org>\r\nTo: x@lyxal.test\r\nSubject: essai\r\nDate: Fri, 20 Nov 2026 10:00:00 +0000\r\n\r\nBonjour.\r\n\r\nFin.\r\n";

/// Signe `message` et place la signature en tête. `tags` : balises avant `bh=` et `b=`.
fn sign(message: &str, key: &DkimSigningKey, tags: &str, length: Option<u64>) -> String {
    let headers = MessageHeaders::parse(message.as_bytes()).unwrap();
    let tag_list = tags::parse_tag_list(tags).unwrap();
    let get = |name: &str| {
        tag_list
            .iter()
            .find(|(tag_name, _)| tag_name == name)
            .map(|(_, value)| value.clone())
    };
    let (header_c, body_c) = match get("c").as_deref() {
        Some("relaxed/relaxed") => (DkimCanonicalization::Relaxed, DkimCanonicalization::Relaxed),
        Some("relaxed/simple") | Some("relaxed") => {
            (DkimCanonicalization::Relaxed, DkimCanonicalization::Simple)
        }
        Some("simple/relaxed") => (DkimCanonicalization::Simple, DkimCanonicalization::Relaxed),
        _ => (DkimCanonicalization::Simple, DkimCanonicalization::Simple),
    };
    let mut hasher = DkimBodyHasher::new(body_c, length);
    hasher.update(headers.body);
    let body_hash = STANDARD.encode(hasher.finish().digest);
    let value = format!(" {tags} bh={body_hash};\r\n b=");
    let index = HeaderIndex::new(&headers);
    let mut canonicalizer = DkimHeaderCanonicalizer::new(header_c);
    let mut used: HashMap<String, usize> = HashMap::new();
    for name in get("h").unwrap().split(':') {
        let lower = name.trim().to_ascii_lowercase();
        let count = used.entry(lower.clone()).or_insert(0);
        if let Some(position) = index.nth_from_bottom(&lower, *count, None) {
            *count += 1;
            let field = headers.fields[position];
            canonicalizer.push_header(field.name, field.value).unwrap();
        }
    }
    let signed = canonicalizer
        .finish(b"DKIM-Signature", value.as_bytes())
        .unwrap();
    let signature = STANDARD.encode(key.sign(&signed).unwrap());
    format!("DKIM-Signature:{value}{signature}\r\n{message}")
}

fn key_record(key: &DkimSigningKey, extra: &str) -> String {
    let k = match key.algorithm() {
        DkimAlgorithm::RsaSha256 => "rsa",
        DkimAlgorithm::Ed25519Sha256 => "ed25519",
    };
    format!(
        "v=DKIM1; k={k};{extra} p={}",
        STANDARD.encode(key.public_key_record_bytes())
    )
}

fn ed25519() -> DkimSigningKey {
    DkimSigningKey::Ed25519(Ed25519SigningKey::generate().unwrap())
}

const ED_TAGS: &str =
    "v=1; a=ed25519-sha256; c=relaxed/relaxed; d=example.org; s=ed; h=from:to:subject:date;";

async fn verify_one(resolver: &StaticResolver, message: &str) -> DkimOutput {
    let mut outputs = DkimVerifier::at(resolver, NOW)
        .verify(message.as_bytes())
        .await;
    assert_eq!(outputs.len(), 1);
    outputs.remove(0)
}

#[tokio::test]
async fn signatures_produites_par_lyxal_crypto() {
    let ed = ed25519();
    let rsa = DkimSigningKey::Rsa(RsaSigningKey::generate(RsaModulusBits::Rsa2048).unwrap());
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("ed._domainkey.example.org", &[&key_record(&ed, "")])
        .set_txt(
            "rsa._domainkey.example.org",
            &[&key_record(&rsa, " h=sha256; s=email;")],
        );
    for canonicalization in [
        "simple/simple",
        "simple/relaxed",
        "relaxed/simple",
        "relaxed/relaxed",
    ] {
        let tags = format!(
            "v=1; a=rsa-sha256; c={canonicalization}; d=example.org; s=rsa; h=from:to:subject:date:from;"
        );
        let output = verify_one(&resolver, &sign(MESSAGE, &rsa, &tags, None)).await;
        assert_eq!(output.result, DkimResult::Pass, "{canonicalization}");
        let output = verify_one(
            &resolver,
            &sign(
                MESSAGE,
                &ed,
                &tags
                    .replace("rsa-sha256", "ed25519-sha256")
                    .replace("s=rsa", "s=ed"),
                None,
            ),
        )
        .await;
        assert_eq!(output.result, DkimResult::Pass, "{canonicalization}");
    }
    // Clé RSA pour une signature Ed25519 : `permerror`.
    let message = sign(MESSAGE, &ed, &ED_TAGS.replace("s=ed", "s=rsa"), None);
    assert_eq!(
        verify_one(&resolver, &message).await.result,
        DkimResult::PermError
    );
}

#[tokio::test]
async fn cas_de_la_rfc_6376() {
    let ed = ed25519();
    let other = ed25519();
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("ed._domainkey.example.org", &[&key_record(&ed, "")])
        .set_txt(
            "revoked._domainkey.example.org",
            &["v=DKIM1; k=ed25519; p="],
        )
        .set_txt("test._domainkey.example.org", &[&key_record(&ed, " t=y;")])
        .set_txt(
            "strict._domainkey.example.org",
            &[&key_record(&ed, " t=s;")],
        )
        .set_txt("web._domainkey.example.org", &[&key_record(&ed, " s=web;")])
        .set_txt(
            "two._domainkey.example.org",
            &[&key_record(&ed, ""), &key_record(&other, "")],
        )
        .set_txt("other._domainkey.example.org", &[&key_record(&other, "")])
        .set_txt("panne._domainkey.example.org", &["v=DKIM1; p=AAAA"])
        .fail(StaticRecordType::Txt, "panne._domainkey.example.org");

    let check = |tags: String, length: Option<u64>, expected: DkimResult| {
        let resolver = &resolver;
        let ed = &ed;
        async move {
            let message = sign(MESSAGE, ed, &tags, length);
            let output = verify_one(resolver, &message).await;
            assert_eq!(output.result, expected, "{tags}");
            output
        }
    };
    let output = check(ED_TAGS.to_string(), None, DkimResult::Pass).await;
    assert!(!output.testing);
    // `h=` sans `From`.
    check(
        ED_TAGS.replace("h=from:", "h="),
        None,
        DkimResult::PermError,
    )
    .await;
    // `i=` hors de `d=` ; sous-domaine permis.
    check(
        format!("{ED_TAGS} i=@example.net;"),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        format!("{ED_TAGS} i=joe@mail.example.org;"),
        None,
        DkimResult::Pass,
    )
    .await;
    // Domaine signataire d'une seule étiquette.
    check(
        ED_TAGS.replace("d=example.org", "d=org"),
        None,
        DkimResult::PermError,
    )
    .await;
    // Échéance passée, `x=` avant `t=`, horodatage dans le futur.
    check(
        format!("{ED_TAGS} x={};", NOW - 1),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        format!("{ED_TAGS} t={}; x={};", NOW - 10, NOW - 20),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        format!("{ED_TAGS} t={};", NOW + 3_600),
        None,
        DkimResult::Neutral,
    )
    .await;
    check(
        format!("{ED_TAGS} t={}; x={};", NOW - 10, NOW + 10),
        None,
        DkimResult::Pass,
    )
    .await;
    // Clé révoquée, absente, en panne, réservée à un autre service, en double, autre clé.
    check(
        ED_TAGS.replace("s=ed", "s=revoked"),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        ED_TAGS.replace("s=ed", "s=absent"),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        ED_TAGS.replace("s=ed", "s=panne"),
        None,
        DkimResult::TempError,
    )
    .await;
    check(
        ED_TAGS.replace("s=ed", "s=web"),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        ED_TAGS.replace("s=ed", "s=two"),
        None,
        DkimResult::PermError,
    )
    .await;
    check(ED_TAGS.replace("s=ed", "s=other"), None, DkimResult::Fail).await;
    // Mode d'essai : résultat rendu, signalé.
    let output = check(ED_TAGS.replace("s=ed", "s=test"), None, DkimResult::Pass).await;
    assert!(output.testing);
    // Clé stricte : `i=` doit être exactement `d=`.
    check(
        format!(
            "{} i=@mail.example.org;",
            ED_TAGS.replace("s=ed", "s=strict")
        ),
        None,
        DkimResult::PermError,
    )
    .await;
    check(
        format!("{} i=@example.org;", ED_TAGS.replace("s=ed", "s=strict")),
        None,
        DkimResult::Pass,
    )
    .await;
    // `rsa-sha1` (RFC 8301).
    check(
        ED_TAGS.replace("ed25519-sha256", "rsa-sha1"),
        None,
        DkimResult::PermError,
    )
    .await;
    // `l=` : corps entier signé (pass), plus long que le corps (permerror).
    let body_length = u64::try_from("Bonjour.\r\n\r\nFin.\r\n".len()).unwrap();
    check(
        format!("{ED_TAGS} l={body_length};"),
        Some(body_length),
        DkimResult::Pass,
    )
    .await;
    check(
        format!("{ED_TAGS} l={};", body_length + 1),
        Some(body_length + 1),
        DkimResult::PermError,
    )
    .await;
}

#[tokio::test]
async fn contenu_ajoute_et_en_tetes() {
    let ed = ed25519();
    let mut resolver = StaticResolver::new();
    resolver.set_txt("ed._domainkey.example.org", &[&key_record(&ed, "")]);

    // `l=` plus court que le corps reçu : contenu ajouté non signé, `policy`.
    let length = u64::try_from("Bonjour.\r\n\r\nFin.\r\n".len()).unwrap();
    let signed = sign(
        MESSAGE,
        &ed,
        &format!("{ED_TAGS} l={length};"),
        Some(length),
    );
    let appended = format!("{signed}Contenu ajouté après la signature.\r\n");
    assert_eq!(
        verify_one(&resolver, &appended).await.result,
        DkimResult::Policy
    );

    // Un `From` ajouté plus bas que celui signé : c'est le dernier qui est lu (§5.4.2).
    let signed = sign(MESSAGE, &ed, ED_TAGS, None);
    let added = signed.replace(
        "\r\n\r\nBonjour",
        "\r\nFrom: pirate@evil.example\r\n\r\nBonjour",
    );
    assert_eq!(verify_one(&resolver, &added).await.result, DkimResult::Fail);
    // … sauf si `From` est surnommé dans `h=` : l'ajout casse aussi la signature.
    let signed = sign(
        MESSAGE,
        &ed,
        &ED_TAGS.replace("h=from:", "h=from:from:"),
        None,
    );
    assert_eq!(
        verify_one(&resolver, &signed).await.result,
        DkimResult::Pass
    );
    let added = signed.replace(
        "\r\n\r\nBonjour",
        "\r\nFrom: pirate@evil.example\r\n\r\nBonjour",
    );
    assert_eq!(verify_one(&resolver, &added).await.result, DkimResult::Fail);
    // Un en-tête non signé ajouté ne change rien.
    let signed = sign(MESSAGE, &ed, ED_TAGS, None);
    let added = signed.replace("\r\n\r\nBonjour", "\r\nX-Ajout: 1\r\n\r\nBonjour");
    assert_eq!(verify_one(&resolver, &added).await.result, DkimResult::Pass);
}

#[tokio::test]
async fn messages_sans_signature_et_signatures_nombreuses() {
    let ed = ed25519();
    let mut resolver = StaticResolver::new();
    resolver.set_txt("ed._domainkey.example.org", &[&key_record(&ed, "")]);
    let outputs = DkimVerifier::at(&resolver, NOW)
        .verify(MESSAGE.as_bytes())
        .await;
    assert_eq!(outputs, vec![DkimOutput::bare(DkimResult::None)]);

    let mut message = MESSAGE.to_string();
    for _ in 0..7 {
        message = sign(&message, &ed, ED_TAGS, None);
    }
    let outputs = DkimVerifier::at(&resolver, NOW)
        .verify(message.as_bytes())
        .await;
    assert_eq!(outputs.len(), MAX_VERIFIED_SIGNATURES);
    assert!(outputs
        .iter()
        .all(|output| output.result == DkimResult::Pass));
    // Requêtes bornées : une par signature vérifiée.
    assert_eq!(resolver.queries(), MAX_VERIFIED_SIGNATURES);

    // Signature illisible et en-tête mal formé.
    let broken = format!("DKIM-Signature: v=1; d=example.org; s=ed; a=\r\n{MESSAGE}");
    let output = verify_one(&resolver, &broken).await;
    assert_eq!(output.result, DkimResult::PermError);
    assert_eq!(output.domain.as_deref(), Some("example.org"));
    let outputs = DkimVerifier::at(&resolver, NOW)
        .verify(b" mal\r\n\r\n")
        .await;
    assert_eq!(outputs, vec![DkimOutput::bare(DkimResult::PermError)]);
}

/// Une signature qui signe aussi `DKIM-Signature` (surnommé) ne se compte pas elle-même parmi
/// les en-têtes signés (RFC 6376 §3.5).
#[tokio::test]
async fn la_signature_verifiee_n_est_pas_un_en_tete_signe() {
    let ed = ed25519();
    let mut resolver = StaticResolver::new();
    resolver.set_txt("ed._domainkey.example.org", &[&key_record(&ed, "")]);
    let first = sign(MESSAGE, &ed, ED_TAGS, None);
    let tags = ED_TAGS.replace(
        "h=from:to:subject:date;",
        "h=from:dkim-signature:dkim-signature;",
    );
    let second = sign(&first, &ed, &tags, None);
    let outputs = DkimVerifier::at(&resolver, NOW)
        .verify(second.as_bytes())
        .await;
    assert_eq!(
        outputs
            .iter()
            .map(|output| output.result)
            .collect::<Vec<_>>(),
        vec![DkimResult::Pass, DkimResult::Pass]
    );
}
