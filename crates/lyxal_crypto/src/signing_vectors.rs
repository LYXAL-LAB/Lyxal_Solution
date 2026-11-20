// Tests of ES256 and RS256 (K8, now computed by aws-lc-rs: same vectors as with ring). ES256
// signatures are checked by the ECDSA verification of aws-lc-rs (the crate offers none). RS256 is
// deterministic: the test-only RSA-2048 key of `tests/fixtures/` (generated for these tests,
// never used elsewhere) and its RS256 signature were produced by OpenSSL (Python
// `cryptography`); the signature produced here must be byte-identical.
use super::*;
use aws_lc_rs::signature::ECDSA_P256_SHA256_FIXED;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;

const RSA_PKCS8_B64: &str = include_str!("../tests/fixtures/rsa2048_test_only.pkcs8.b64");
const RSA_PUBLIC_PKCS1_B64: &str =
    include_str!("../tests/fixtures/rsa2048_test_only.public_pkcs1.b64");
const RSA_SIGNATURE_HEX: &str = include_str!("../tests/fixtures/rsa2048_test_only.rs256.hex");
const RSA_MESSAGE: &[u8] = b"eyJhbGciOiJSUzI1NiJ9.bHl4YWwtdGVzdA";

fn secret(bytes: &[u8]) -> SecretBytes {
    SecretBytes::new(bytes.to_vec()).unwrap()
}

fn b64url(text: &str) -> Vec<u8> {
    URL_SAFE_NO_PAD.decode(text).unwrap()
}

fn rsa_der() -> Vec<u8> {
    STANDARD.decode(RSA_PKCS8_B64.trim()).unwrap()
}

fn pem(der: &[u8]) -> String {
    let body = STANDARD.encode(der);
    let lines: Vec<&str> = body
        .as_bytes()
        .chunks(64)
        .map(|c| std::str::from_utf8(c).unwrap())
        .collect();
    format!("{PEM_BEGIN}\n{}\n{PEM_END}\n", lines.join("\n"))
}

/// PKCS#8 (RFC 5915 ECPrivateKey with its public key) of a P-256 key given by its scalar and
/// public point: the layout written by OpenSSL and Apple.
fn p256_pkcs8(d: &[u8], public: &[u8]) -> Vec<u8> {
    let mut der = vec![
        0x30, 0x81, 0x87, 0x02, 0x01, 0x00, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d,
        0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x04, 0x6d, 0x30,
        0x6b, 0x02, 0x01, 0x01, 0x04, 0x20,
    ];
    der.extend_from_slice(d);
    der.extend_from_slice(&[0xa1, 0x44, 0x03, 0x42, 0x00]);
    der.extend_from_slice(public);
    der
}

#[test]
fn es256_signatures_verify_with_an_independent_verifier() {
    let key = EcdsaP256SigningKey::generate().unwrap();
    let public = key.public_key_uncompressed();
    assert_eq!(public[0], 0x04);
    let data = b"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwcyJ9";
    let signature = key.sign_es256(data).unwrap();
    let verifier = UnparsedPublicKey::new(&ECDSA_P256_SHA256_FIXED, public);
    assert!(verifier.verify(data, &signature).is_ok());
    assert!(verifier.verify(b"other", &signature).is_err());
    // Randomized nonce: two signatures differ, both verify
    let again = key.sign_es256(data).unwrap();
    assert_ne!(signature, again);
    assert!(verifier.verify(data, &again).is_ok());
    // Exported then imported (DER and PEM): same public key, signatures still verify
    let exported = key.export_pkcs8();
    let der = exported.expose_secret().to_vec();
    let imported = EcdsaP256SigningKey::import_pkcs8(exported).unwrap();
    assert_eq!(imported.public_key_uncompressed(), public);
    assert!(verifier
        .verify(data, &imported.sign_es256(data).unwrap())
        .is_ok());
    let from_pem = EcdsaP256SigningKey::import_pkcs8(secret(pem(&der).as_bytes())).unwrap();
    assert_eq!(from_pem.public_key_uncompressed(), public);
    assert_eq!(format!("{key:?}"), "EcdsaP256SigningKey([REDACTED])");
}

#[test]
fn es256_import_of_a_known_key_pair() {
    // RFC 8291 Appendix A: application server key pair (as_private, as_public)
    let d = b64url("yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw");
    let public = b64url(
        "BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8",
    );
    let key = EcdsaP256SigningKey::import_pkcs8(secret(&p256_pkcs8(&d, &public))).unwrap();
    assert_eq!(key.public_key_uncompressed().to_vec(), public);
    let signature = key.sign_es256(b"vector").unwrap();
    assert!(UnparsedPublicKey::new(&ECDSA_P256_SHA256_FIXED, &public)
        .verify(b"vector", &signature)
        .is_ok());
    // Public key inconsistent with the scalar: refused by AWS-LC's consistency check
    let mut wrong = public.clone();
    wrong[64] ^= 1;
    assert_eq!(
        EcdsaP256SigningKey::import_pkcs8(secret(&p256_pkcs8(&d, &wrong))).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    // Without its public key (RFC 5915 [1] absent): the public point is recomputed from the
    // scalar by AWS-LC
    let mut bare = vec![
        0x30, 0x41, 0x02, 0x01, 0x00, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x04, 0x27, 0x30, 0x25,
        0x02, 0x01, 0x01, 0x04, 0x20,
    ];
    bare.extend_from_slice(&d);
    let recomputed = EcdsaP256SigningKey::import_pkcs8(secret(&bare)).unwrap();
    assert_eq!(recomputed.public_key_uncompressed().to_vec(), public);
}

#[test]
fn signing_keys_refuse_malformed_or_foreign_keys() {
    for bad in [
        b"".to_vec(),
        b"not a key".to_vec(),
        b"-----BEGIN RSA PRIVATE KEY-----\nAAAA\n-----END RSA PRIVATE KEY-----".to_vec(),
        b"-----BEGIN PRIVATE KEY-----\n!!!\n-----END PRIVATE KEY-----".to_vec(),
        b"-----BEGIN PRIVATE KEY-----\nAAAA".to_vec(),
    ] {
        assert_eq!(
            EcdsaP256SigningKey::import_pkcs8(secret(&bad)).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
        assert_eq!(
            RsaSigningKey::import_pkcs8(secret(&bad)).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
    }
    // An RSA key is not a P-256 key and the reverse
    assert_eq!(
        EcdsaP256SigningKey::import_pkcs8(secret(&rsa_der())).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    let ec = EcdsaP256SigningKey::generate().unwrap().export_pkcs8();
    assert_eq!(
        RsaSigningKey::import_pkcs8(ec).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    assert_eq!(
        RsaSigningKey::import_pkcs8(secret(&vec![b'A'; MAX_KEY_BYTES + 1])).unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn rs256_matches_the_openssl_signature_and_verifies() {
    let expected = hex::decode(RSA_SIGNATURE_HEX.trim()).unwrap();
    let public = STANDARD.decode(RSA_PUBLIC_PKCS1_B64.trim()).unwrap();
    let verifier = RsaPublicKey::from_pkcs1_der(&public).unwrap();
    for key in [
        RsaSigningKey::import_pkcs8(secret(&rsa_der())).unwrap(),
        // Google service-account files carry the key as PEM
        RsaSigningKey::import_pkcs8(secret(pem(&rsa_der()).as_bytes())).unwrap(),
    ] {
        let signature = key.sign_rs256(RSA_MESSAGE).unwrap();
        assert_eq!(signature, expected);
        assert!(verifier.verify_rs256(RSA_MESSAGE, &signature).unwrap());
        let other = key.sign_rs256(b"other").unwrap();
        assert!(!verifier.verify_rs256(RSA_MESSAGE, &other).unwrap());
        assert_eq!(key.public_key(), verifier);
        assert_eq!(key.modulus_bits(), 2048);
        assert_eq!(format!("{key:?}"), "RsaSigningKey([REDACTED])");
    }
}
