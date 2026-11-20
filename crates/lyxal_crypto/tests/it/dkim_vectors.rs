//! DKIM : vecteurs publiés et propriétés (RFC 6376, 8301, 8463).
//!
//! Le découpage du message, la lecture des balises et le choix des en-têtes selon `h=` sont
//! écrits ici pour les tests seulement : ils appartiennent aux crates du courrier (C4).
//! Vecteurs : `tests/fixtures/dkim/` (provenance : `SOURCES.md`, `tests/fixtures/README.md`).
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    CryptoError, DkimAlgorithm, DkimBodyHasher, DkimCanonicalization, DkimHeaderCanonicalizer,
    DkimKeyType, DkimPublicKey, DkimSignedData, DkimSigningKey, Ed25519SigningKey, RsaSigningKey,
    SecretBytes,
};
use proptest::prelude::*;
use std::collections::HashMap;

const MAIL_AUTH_001: &str = include_str!("../fixtures/dkim/mail_auth/001.txt");
const MAIL_AUTH_002: &str = include_str!("../fixtures/dkim/mail_auth/002.txt");
const MAIL_AUTH_003: &str = include_str!("../fixtures/dkim/mail_auth/003.txt");
const LYXAL_SIGNED: &str = include_str!("../fixtures/dkim/lyxal_signed_test_only.txt");
const RSA768_SPKI_HEX: &str = include_str!("../fixtures/dkim/rsa768_test_only.spki.hex");
const RSA6144_SPKI_HEX: &str = include_str!("../fixtures/dkim/rsa6144_test_only.spki.hex");
const RSA_PKCS8_B64: &str = include_str!("../fixtures/rsa2048_test_only.pkcs8.b64");
/// Clé privée Ed25519 de la RFC 8463 annexe A.2 (graine, publiée par la RFC ; tests seulement).
const RFC8463_ED25519_SEED: &str = "nWGxne/9WmC6hEr0kuwsxERJxWl7MmkZcDusAxyuf2A=";

type Header = (Vec<u8>, Vec<u8>);

struct Fixture {
    records: HashMap<String, String>,
    headers: Vec<Header>,
    body: Vec<u8>,
}

/// Format des corpus de mail-auth : enregistrements DNS, ligne vide, message en fins de ligne LF.
fn fixture(text: &str) -> Fixture {
    let (records, message) = text.split_once("\n\n").unwrap();
    let records = records
        .lines()
        .map(|line| {
            let (name, value) = line.split_once(' ').unwrap();
            (name.to_string(), value.to_string())
        })
        .collect();
    let message = message.replace('\n', "\r\n").into_bytes();
    let (head_end, body_start) = message
        .windows(4)
        .position(|w| w == b"\r\n\r\n")
        .map(|p| (p, p + 4))
        .unwrap();
    let mut headers: Vec<Header> = Vec::new();
    for line in message[..head_end].split(|&c| c == b'\n') {
        let line = line.strip_suffix(b"\r").unwrap_or(line);
        match headers.last_mut() {
            Some((_, value)) if matches!(line.first(), Some(b' ' | b'\t')) => {
                value.extend_from_slice(b"\r\n");
                value.extend_from_slice(line);
            }
            _ => {
                let colon = line.iter().position(|&c| c == b':').unwrap();
                headers.push((line[..colon].to_vec(), line[colon + 1..].to_vec()));
            }
        }
    }
    Fixture {
        records,
        headers,
        body: message[body_start..].to_vec(),
    }
}

/// Balises d'une liste `tag=valeur` (espaces repliés retirés des valeurs).
fn tags(value: &[u8]) -> HashMap<String, String> {
    String::from_utf8_lossy(value)
        .split(';')
        .filter_map(|part| part.split_once('='))
        .map(|(name, value)| {
            let value: String = value.chars().filter(|c| !c.is_whitespace()).collect();
            (name.trim().to_string(), value)
        })
        .collect()
}

fn canonicalization(name: &str) -> DkimCanonicalization {
    match name {
        "relaxed" => DkimCanonicalization::Relaxed,
        "simple" | "" => DkimCanonicalization::Simple,
        other => panic!("unknown canonicalization {other}"),
    }
}

/// Données signées : en-têtes de `h=` choisis du bas vers le haut, un en-tête absent ne compte
/// pas, puis l'en-tête de signature.
fn signed_data(
    headers: &[Header],
    signature: &Header,
    h: &str,
    canon: DkimCanonicalization,
) -> DkimSignedData {
    let mut available: Vec<&Header> = headers.iter().collect();
    let mut canonicalizer = DkimHeaderCanonicalizer::new(canon);
    for wanted in h.split(':') {
        let found = available.iter().rposition(|(name, _)| {
            String::from_utf8_lossy(name)
                .trim()
                .eq_ignore_ascii_case(wanted)
        });
        if let Some(index) = found {
            let (name, value) = available.remove(index);
            canonicalizer.push_header(name, value).unwrap();
        }
    }
    canonicalizer.finish(&signature.0, &signature.1).unwrap()
}

struct Checked {
    algorithm: DkimAlgorithm,
    data: DkimSignedData,
    signature: Vec<u8>,
    key: DkimPublicKey,
}

/// Vérifie chaque DKIM-Signature d'un corpus : empreinte du corps (découpée en morceaux de
/// tailles variées) puis signature.
fn verify_fixture(text: &str) -> Vec<Checked> {
    let fixture = fixture(text);
    let signatures: Vec<&Header> = fixture
        .headers
        .iter()
        .filter(|(name, _)| name.eq_ignore_ascii_case(b"DKIM-Signature"))
        .collect();
    assert!(!signatures.is_empty());
    let mut checked = Vec::new();
    for signature in signatures {
        let t = tags(&signature.1);
        let (header_c, body_c) = t["c"].split_once('/').unwrap_or((t["c"].as_str(), ""));
        let algorithm = DkimAlgorithm::from_tag(&t["a"]).unwrap();
        for chunk in [1, 2, 3, 7, 64, 4096] {
            let mut hasher = DkimBodyHasher::new(canonicalization(body_c), None);
            for part in fixture.body.chunks(chunk) {
                hasher.update(part);
            }
            assert_eq!(STANDARD.encode(hasher.finish().digest), t["bh"]);
        }
        let data = signed_data(
            &fixture.headers,
            signature,
            &t["h"],
            canonicalization(header_c),
        );
        let record = tags(fixture.records[&format!("{}._domainkey.{}", t["s"], t["d"])].as_bytes());
        let key_type = match record.get("k").map(String::as_str) {
            None | Some("rsa") => DkimKeyType::Rsa,
            Some("ed25519") => DkimKeyType::Ed25519,
            Some(other) => panic!("unknown key type {other}"),
        };
        let key =
            DkimPublicKey::from_record(key_type, &STANDARD.decode(&record["p"]).unwrap()).unwrap();
        assert_eq!(key.key_type(), key_type);
        let signature = STANDARD.decode(&t["b"]).unwrap();
        assert!(key.verify(algorithm, &data, &signature).unwrap());
        checked.push(Checked {
            algorithm,
            data,
            signature,
            key,
        });
    }
    checked
}

fn ed25519_pkcs8(seed: &[u8]) -> SecretBytes {
    // PKCS#8 v1 (RFC 8410) d'une graine Ed25519
    let mut der = hex::decode("302e020100300506032b657004220420").unwrap();
    der.extend_from_slice(seed);
    SecretBytes::new(der).unwrap()
}

fn rfc8463_ed25519_key() -> DkimSigningKey {
    let seed = STANDARD.decode(RFC8463_ED25519_SEED).unwrap();
    DkimSigningKey::Ed25519(Ed25519SigningKey::import_pkcs8(ed25519_pkcs8(&seed)).unwrap())
}

fn test_rsa_key() -> DkimSigningKey {
    let der = STANDARD.decode(RSA_PKCS8_B64.trim()).unwrap();
    DkimSigningKey::Rsa(RsaSigningKey::import_pkcs8(SecretBytes::new(der).unwrap()).unwrap())
}

#[test]
fn rfc8463_appendix_a_both_signatures_verify() {
    // mail-auth 001 : message de la RFC 8463 annexe A, signé en ed25519-sha256 et en rsa-sha256
    // (clé RSA de 1024 bits, acceptée à la vérification DKIM seulement)
    let checked = verify_fixture(MAIL_AUTH_001);
    assert_eq!(checked.len(), 2);
    assert_eq!(checked[0].algorithm, DkimAlgorithm::Ed25519Sha256);
    assert_eq!(checked[1].algorithm, DkimAlgorithm::RsaSha256);
    // Ed25519 est déterministe : la clé privée de la RFC redonne exactement b=
    let key = rfc8463_ed25519_key();
    assert_eq!(key.algorithm(), DkimAlgorithm::Ed25519Sha256);
    assert_eq!(key.sign(&checked[0].data).unwrap(), checked[0].signature);
    assert_eq!(
        STANDARD.encode(key.public_key_record_bytes()),
        "11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo="
    );
    // a= qui ne correspond pas à k=
    assert_eq!(
        checked[0]
            .key
            .verify(
                DkimAlgorithm::RsaSha256,
                &checked[0].data,
                &checked[0].signature
            )
            .unwrap_err(),
        CryptoError::AlgorithmMismatch
    );
    assert_eq!(
        checked[1]
            .key
            .verify(
                DkimAlgorithm::Ed25519Sha256,
                &checked[1].data,
                &checked[0].signature
            )
            .unwrap_err(),
        CryptoError::AlgorithmMismatch
    );
}

#[test]
fn mail_auth_corpus_verifies() {
    // 002 : simple/simple, clé en RSAPublicKey nu ; 003 : relaxed/simple, liste de l'IETF
    assert_eq!(verify_fixture(MAIL_AUTH_002).len(), 1);
    assert_eq!(verify_fixture(MAIL_AUTH_003).len(), 2);
}

#[test]
fn lyxal_signatures_match_openssl() {
    // Signatures calculées par OpenSSL sur ce message ; le crate redonne les mêmes octets
    let checked = verify_fixture(LYXAL_SIGNED);
    assert_eq!(checked.len(), 2);
    let ed = rfc8463_ed25519_key();
    assert_eq!(ed.sign(&checked[0].data).unwrap(), checked[0].signature);
    let rsa = test_rsa_key();
    assert_eq!(rsa.algorithm(), DkimAlgorithm::RsaSha256);
    assert_eq!(rsa.sign(&checked[1].data).unwrap(), checked[1].signature);
    let record = tags(fixture(LYXAL_SIGNED).records["rsa._domainkey.example.test"].as_bytes());
    assert_eq!(STANDARD.encode(rsa.public_key_record_bytes()), record["p"]);
}

#[test]
fn tampering_fails_and_formats_are_errors() {
    let checked = verify_fixture(LYXAL_SIGNED);
    for item in &checked {
        // Données modifiées : Ok(false) (fail)
        let mut canonicalizer = DkimHeaderCanonicalizer::new(DkimCanonicalization::Relaxed);
        canonicalizer.push_header(b"X", b"y").unwrap();
        let other = canonicalizer.finish(b"DKIM-Signature", b" b=").unwrap();
        assert!(!item
            .key
            .verify(item.algorithm, &other, &item.signature)
            .unwrap());
        let mut flipped = item.signature.clone();
        flipped[10] ^= 1;
        assert!(!item
            .key
            .verify(item.algorithm, &item.data, &flipped)
            .unwrap());
        // Signature de mauvaise longueur : erreur de format (permerror)
        for length in [0, item.signature.len() - 1, item.signature.len() + 1] {
            let mut resized = item.signature.clone();
            resized.resize(length, 0);
            assert_eq!(
                item.key
                    .verify(item.algorithm, &item.data, &resized)
                    .unwrap_err(),
                CryptoError::InvalidSignatureEncoding
            );
        }
    }
}

#[test]
fn public_key_records() {
    let rsa768 = hex::decode(RSA768_SPKI_HEX.trim()).unwrap();
    assert_eq!(
        DkimPublicKey::from_record(DkimKeyType::Rsa, &rsa768).unwrap_err(),
        CryptoError::KeyTooWeak
    );
    let rsa6144 = hex::decode(RSA6144_SPKI_HEX.trim()).unwrap();
    assert_eq!(
        DkimPublicKey::from_record(DkimKeyType::Rsa, &rsa6144).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    let ed = STANDARD
        .decode("11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=")
        .unwrap();
    for (key_type, bad) in [
        (DkimKeyType::Rsa, Vec::new()),
        (DkimKeyType::Rsa, b"not a key".to_vec()),
        (DkimKeyType::Rsa, ed.clone()),
        (DkimKeyType::Ed25519, Vec::new()),
        (DkimKeyType::Ed25519, ed[..31].to_vec()),
        (DkimKeyType::Ed25519, rsa768.clone()),
    ] {
        assert_eq!(
            DkimPublicKey::from_record(key_type, &bad).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
    }
    assert_eq!(
        DkimPublicKey::from_record(DkimKeyType::Rsa, &vec![0x30; 4096]).unwrap_err(),
        CryptoError::InputTooLarge
    );
    // Valeur p= d'une clé générée relue telle quelle
    let key = DkimSigningKey::Ed25519(Ed25519SigningKey::generate().unwrap());
    let public =
        DkimPublicKey::from_record(DkimKeyType::Ed25519, &key.public_key_record_bytes()).unwrap();
    assert_eq!(format!("{key:?}"), "DkimSigningKey([REDACTED])");
    let data = DkimHeaderCanonicalizer::new(DkimCanonicalization::Simple)
        .finish(b"DKIM-Signature", b" a=ed25519-sha256; b=")
        .unwrap();
    let signature = key.sign(&data).unwrap();
    assert!(public
        .verify(DkimAlgorithm::Ed25519Sha256, &data, &signature)
        .unwrap());
}

fn canonicalizations() -> impl Strategy<Value = DkimCanonicalization> {
    prop_oneof![
        Just(DkimCanonicalization::Simple),
        Just(DkimCanonicalization::Relaxed)
    ]
}

proptest! {
    #![proptest_config(ProptestConfig::with_cases(64))]

    /// L'empreinte du corps ne dépend pas du découpage (CR et LF coupés entre deux morceaux).
    #[test]
    fn body_hash_is_independent_of_chunking(
        body in prop::collection::vec(prop_oneof![
            Just(b'\r'), Just(b'\n'), Just(b' '), Just(b'\t'), Just(b'a'), any::<u8>()
        ], 0..300),
        cuts in prop::collection::vec(1usize..17, 1..40),
        canon in canonicalizations(),
        limit in prop::option::of(0u64..400),
    ) {
        let mut whole = DkimBodyHasher::new(canon, limit);
        whole.update(&body);
        let whole = whole.finish();
        let mut pieces = DkimBodyHasher::new(canon, limit);
        let mut rest = body.as_slice();
        for cut in cuts.iter().cycle() {
            if rest.is_empty() {
                break;
            }
            let (head, tail) = rest.split_at((*cut).min(rest.len()));
            pieces.update(head);
            rest = tail;
        }
        prop_assert_eq!(pieces.finish(), whole);
    }

    /// Signature puis vérification, deux algorithmes, quatre combinaisons de canonicalisation.
    #[test]
    fn sign_then_verify(
        value in "[ -~\t]{0,80}",
        fold in any::<bool>(),
        header_canon in canonicalizations(),
        body_canon in canonicalizations(),
        body in prop::collection::vec(any::<u8>(), 0..200),
    ) {
        for key in [rfc8463_ed25519_key(), test_rsa_key()] {
            let mut hasher = DkimBodyHasher::new(body_canon, None);
            hasher.update(&body);
            let bh = STANDARD.encode(hasher.finish().digest);
            let raw_value = if fold { format!(" {value}\r\n\t{value}") } else { format!(" {value}") };
            let signature_value = format!(
                " v=1; a={}; bh={bh}; h=Subject;\r\n b=", key.algorithm().as_tag()
            );
            let mut canonicalizer = DkimHeaderCanonicalizer::new(header_canon);
            canonicalizer.push_header(b"Subject", raw_value.as_bytes()).unwrap();
            let data = canonicalizer.finish(b"DKIM-Signature", signature_value.as_bytes()).unwrap();
            let signature = key.sign(&data).unwrap();
            let key_type = match key.algorithm() {
                DkimAlgorithm::RsaSha256 => DkimKeyType::Rsa,
                DkimAlgorithm::Ed25519Sha256 => DkimKeyType::Ed25519,
            };
            let public = DkimPublicKey::from_record(key_type, &key.public_key_record_bytes()).unwrap();
            prop_assert!(public.verify(key.algorithm(), &data, &signature).unwrap());
            // Le b= rempli après coup ne change pas les données signées
            let filled = format!("{signature_value}{}", STANDARD.encode(&signature));
            let mut again = DkimHeaderCanonicalizer::new(header_canon);
            again.push_header(b"Subject", raw_value.as_bytes()).unwrap();
            prop_assert_eq!(again.finish(b"DKIM-Signature", filled.as_bytes()).unwrap(), data);
        }
    }
}
