use base64::Engine;
use lyxal_crypto::*;

fn setup_test_engine() -> CryptoEngine<EnvironmentKeyProvider> {
    let key_bytes = [55u8; 32];
    let b64 = base64::engine::general_purpose::STANDARD.encode(key_bytes);
    std::env::set_var("LYXAL_CRYPTO_NEGATIVE_TEST_KEY", b64);
    let key_id = KeyId::parse("main").unwrap();
    let provider = EnvironmentKeyProvider::new("LYXAL_CRYPTO_NEGATIVE_TEST_KEY", key_id).unwrap();
    CryptoEngine::new(provider)
}

#[test]
fn test_negative_tampered_tag_fails_authentication() {
    let engine = setup_test_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_1", "password").unwrap();
    let encrypted = engine.encrypt_secret(b"secret-data", &ctx).unwrap();

    let mut envelope = EncryptedEnvelope::parse(&encrypted).unwrap();
    let len = envelope.payload.len();
    envelope.payload[len - 1] ^= 0xff; // Alter last byte of tag

    let tampered_str = envelope.encode();
    let res = engine.decrypt_secret(&tampered_str, &ctx);
    assert!(res.is_err());
    assert!(matches!(
        res.unwrap_err(),
        CryptoError::AuthenticationFailed
    ));
}

#[test]
fn test_negative_tampered_nonce_fails_authentication() {
    let engine = setup_test_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_1", "password").unwrap();
    let encrypted = engine.encrypt_secret(b"secret-data", &ctx).unwrap();

    let mut envelope = EncryptedEnvelope::parse(&encrypted).unwrap();
    envelope.payload[0] ^= 0x01; // Alter first byte of nonce

    let tampered_str = envelope.encode();
    let res = engine.decrypt_secret(&tampered_str, &ctx);
    assert!(res.is_err());
    assert!(matches!(
        res.unwrap_err(),
        CryptoError::AuthenticationFailed
    ));
}

#[test]
fn test_negative_payload_shorter_than_28_bytes() {
    let engine = setup_test_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_1", "password").unwrap();

    // Payload de seulement 10 octets encodé en base64url
    let short_payload = base64::engine::general_purpose::URL_SAFE_NO_PAD.encode([0u8; 10]);
    let invalid_envelope = format!("enc:v1:main:{}", short_payload);

    let res = engine.decrypt_secret(&invalid_envelope, &ctx);
    assert!(res.is_err());
    assert!(matches!(res.unwrap_err(), CryptoError::InvalidPayload));
}

#[test]
fn test_negative_mismatched_tenant_aad_fails() {
    let engine = setup_test_engine();
    let ctx_acme =
        SecretContext::with_tenant("acme", "booking", "setting", "rec_1", "password").unwrap();
    let ctx_globex =
        SecretContext::with_tenant("globex", "booking", "setting", "rec_1", "password").unwrap();

    let encrypted = engine.encrypt_secret(b"acme-secret", &ctx_acme).unwrap();

    let res = engine.decrypt_secret(&encrypted, &ctx_globex);
    assert!(res.is_err());
    assert!(matches!(
        res.unwrap_err(),
        CryptoError::AuthenticationFailed
    ));
}

#[test]
fn test_negative_mismatched_field_aad_fails() {
    let engine = setup_test_engine();
    let ctx1 = SecretContext::new("booking", "setting", "rec_1", "password").unwrap();
    let ctx2 = SecretContext::new("booking", "setting", "rec_1", "client_secret").unwrap();

    let encrypted = engine.encrypt_secret(b"password-secret", &ctx1).unwrap();

    let res = engine.decrypt_secret(&encrypted, &ctx2);
    assert!(res.is_err());
    assert!(matches!(
        res.unwrap_err(),
        CryptoError::AuthenticationFailed
    ));
}

#[test]
fn test_negative_invalid_envelope_strings() {
    let engine = setup_test_engine();
    let ctx = SecretContext::new("booking", "setting", "rec_1", "password").unwrap();

    // Chaîne vide
    assert!(matches!(
        engine.decrypt_secret("", &ctx).unwrap_err(),
        CryptoError::InvalidEnvelope
    ));

    // Pas de préfixe enc:
    assert!(matches!(
        engine.decrypt_secret("v1:main:abcdef", &ctx).unwrap_err(),
        CryptoError::InvalidEnvelope
    ));

    // Moins de 4 parties séparées par ':'
    assert!(matches!(
        engine.decrypt_secret("enc:v1:main", &ctx).unwrap_err(),
        CryptoError::InvalidEnvelope
    ));

    // Base64URL corrompu
    assert!(matches!(
        engine
            .decrypt_secret("enc:v1:main:invalid!base64!", &ctx)
            .unwrap_err(),
        CryptoError::InvalidPayload
    ));
}
