use base64::Engine;
use lyxal_crypto::*;

#[test]
fn test_true_calrs_legacy_hex_plaintext_migration() {
    let key = EncryptionKey::from_bytes([7u8; 32]);
    let key_id = KeyId::parse("main").unwrap();
    let composite = CompositeKeyResolver::new(key_id, key);
    let engine = CryptoEngine::new(composite);

    let ctx = SecretContext::new("booking", "caldav_source", "rec_caldav_101", "password").unwrap();

    let raw_plaintext = b"legacy-calrs-plaintext-password";
    let stored_legacy_hex = hex::encode(raw_plaintext);

    let decoded = decode_calrs_legacy_hex(&stored_legacy_hex).unwrap();
    assert_eq!(&*decoded, raw_plaintext);

    let migrated_envelope = engine.migrate_legacy_calrs_hex(&stored_legacy_hex, &ctx).unwrap();
    assert!(migrated_envelope.starts_with("enc:v1:main:"));

    let decrypted = engine.decrypt_secret(&migrated_envelope, &ctx).unwrap();
    assert_eq!(&*decrypted, raw_plaintext);
}

#[test]
fn test_calrs_aes_base64_migration_with_legacy_key() {
    let legacy_raw = [9u8; 32];
    let legacy_key = EncryptionKey::from_bytes(legacy_raw);

    let active_key = EncryptionKey::from_bytes([1u8; 32]);
    let active_id = KeyId::parse("main").unwrap();
    let composite = CompositeKeyResolver::new(active_id, active_key);
    let engine = CryptoEngine::new(composite);

    let ctx = SecretContext::new("booking", "caldav_source", "rec_caldav_202", "password").unwrap();

    // Chiffrement direct AES-GCM sans AAD et encodage en Base64 standard (reconstruit l'ancien format Cal.rs)
    let secret = b"unprefixed-calrs-base64-secret";
    let payload = cipher::encrypt_aes_gcm(&legacy_key, secret, &[]).unwrap();
    let stored_b64 = base64::engine::general_purpose::STANDARD.encode(payload);

    // Déchiffrement et migration avec l'ancienne clé legacy_key
    let decrypted_legacy = engine.decrypt_calrs_aes_base64(&legacy_key, &stored_b64).unwrap();
    assert_eq!(&*decrypted_legacy, secret);

    let migrated_envelope = engine.migrate_calrs_aes_base64(&legacy_key, &stored_b64, &ctx).unwrap();
    assert!(migrated_envelope.starts_with("enc:v1:main:"));

    let decrypted = engine.decrypt_secret(&migrated_envelope, &ctx).unwrap();
    assert_eq!(&*decrypted, secret);
}

#[test]
fn test_invalid_legacy_hex_fails() {
    let invalid_hex = "not-a-valid-hex-string-!!!";
    let result = decode_calrs_legacy_hex(invalid_hex);
    assert!(result.is_err());
    assert!(matches!(result.unwrap_err(), CryptoError::InvalidLegacyValue));
}
