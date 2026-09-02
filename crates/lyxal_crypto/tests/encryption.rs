use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::*;

fn setup_engine() -> CryptoEngine<EnvironmentKeyProvider> {
    let key_bytes = [42u8; 32];
    let b64 = STANDARD.encode(key_bytes);
    std::env::set_var("LYXAL_CRYPTO_TEST_KEY", b64);
    let key_id = KeyId::parse("main").unwrap();
    let provider = EnvironmentKeyProvider::new("LYXAL_CRYPTO_TEST_KEY", key_id).unwrap();
    CryptoEngine::new(provider)
}

#[test]
fn test_encrypt_decrypt_roundtrip_with_aad() {
    let engine = setup_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_123", "password").unwrap();
    let secret = b"super-secret-smtp-password";

    let encrypted = engine.encrypt_secret(secret, &ctx).unwrap();
    assert!(encrypted.starts_with("enc:v1:main:"));

    let decrypted = engine.decrypt_secret(&encrypted, &ctx).unwrap();
    assert_eq!(&*decrypted, secret);
}

#[test]
fn test_encrypt_produces_unique_nonces_for_same_plaintext() {
    let engine = setup_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_123", "password").unwrap();
    let secret = b"same-plaintext";

    let enc1 = engine.encrypt_secret(secret, &ctx).unwrap();
    let enc2 = engine.encrypt_secret(secret, &ctx).unwrap();

    assert_ne!(enc1, enc2);

    let dec1 = engine.decrypt_secret(&enc1, &ctx).unwrap();
    let dec2 = engine.decrypt_secret(&enc2, &ctx).unwrap();
    assert_eq!(&*dec1, secret);
    assert_eq!(&*dec2, secret);
}

#[test]
fn test_decrypt_fails_with_mismatched_aad() {
    let engine = setup_engine();
    let ctx1 = SecretContext::new("booking", "setting", "rec_123", "password").unwrap();
    let ctx2 = SecretContext::new("booking", "setting", "rec_456", "password").unwrap();
    let secret = b"super-secret-smtp-password";

    let encrypted = engine.encrypt_secret(secret, &ctx1).unwrap();

    let result = engine.decrypt_secret(&encrypted, &ctx2);
    assert!(result.is_err());
    assert!(matches!(result.unwrap_err(), CryptoError::AuthenticationFailed));
}

#[test]
fn test_encrypt_decrypt_unbound() {
    let engine = setup_engine();
    let secret = b"unbound-secret-data";

    let encrypted = engine.encrypt_unbound(secret).unwrap();
    let decrypted = engine.decrypt_unbound(&encrypted).unwrap();

    assert_eq!(&*decrypted, secret);
}

#[test]
fn test_tampered_ciphertext_fails() {
    let engine = setup_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_123", "password").unwrap();
    let secret = b"secret-payload";

    let encrypted = engine.encrypt_secret(secret, &ctx).unwrap();

    let mut chars: Vec<char> = encrypted.chars().collect();
    let len = chars.len();
    chars[len - 2] = if chars[len - 2] == 'A' { 'B' } else { 'A' };
    let tampered: String = chars.into_iter().collect();

    let result = engine.decrypt_secret(&tampered, &ctx);
    assert!(result.is_err());
}

#[test]
fn test_unsupported_version_error_preserved() {
    let engine = setup_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_123", "password").unwrap();
    let invalid_version_envelope = "enc:v99:main:AbCdEf12345678901234567890123456";

    let result = engine.decrypt_secret(invalid_version_envelope, &ctx);
    assert!(result.is_err());
    assert!(matches!(result.unwrap_err(), CryptoError::UnsupportedVersion { .. }));
}

#[test]
fn test_invalid_key_id_validation() {
    assert!(KeyId::parse("main").is_ok());
    assert!(KeyId::parse("main-2026.01_v1").is_ok());

    // Invalid Key IDs
    assert!(KeyId::parse("").is_err());
    assert!(KeyId::parse("key:with:colon").is_err());
    assert!(KeyId::parse("key with space").is_err());
    assert!(KeyId::parse("clé_unicode").is_err());
}
