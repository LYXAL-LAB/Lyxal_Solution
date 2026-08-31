use lyxal_crypto::*;
use tempfile::tempdir;

#[test]
fn test_file_key_provider_dev_policy_generates_key() {
    let dir = tempdir().unwrap();
    let provider = FileKeyProvider::default_dev(dir.path()).unwrap();

    let active_id = provider.active_key_id().unwrap();
    assert_eq!(active_id.as_str(), "main");

    let engine = CryptoEngine::new(provider);
    let ctx = SecretContext::new("booking", "setting", "rec_1", "key").unwrap();

    let enc = engine.encrypt_secret(b"test-secret", &ctx).unwrap();
    let dec = engine.decrypt_secret(&enc, &ctx).unwrap();
    assert_eq!(&*dec, b"test-secret");
}

#[test]
fn test_file_key_provider_strict_policy_prohibits_generation() {
    let dir = tempdir().unwrap();
    let provider = FileKeyProvider::default_strict(dir.path()).unwrap();

    let active_id = provider.active_key_id().unwrap();
    let res = provider.resolve(&active_id);

    assert!(res.is_err());
    assert!(matches!(res.unwrap_err(), CryptoError::GenerationProhibited));
}

#[test]
fn test_composite_key_resolver_supports_rotation() {
    let active_key = EncryptionKey::from_bytes([1u8; 32]);
    let old_key = EncryptionKey::from_bytes([2u8; 32]);

    let key_2026 = KeyId::parse("key-2026").unwrap();
    let key_2025 = KeyId::parse("key-2025").unwrap();

    let composite = CompositeKeyResolver::new(key_2026.clone(), active_key);
    composite.add_historical_key(key_2025.clone(), old_key).unwrap();

    let engine = CryptoEngine::new(composite);
    let ctx = SecretContext::new("booking", "setting", "rec_1", "secret").unwrap();

    let old_key_copy = EncryptionKey::from_bytes([2u8; 32]);
    let old_composite = CompositeKeyResolver::new(key_2025.clone(), old_key_copy);
    let old_engine = CryptoEngine::new(old_composite);

    let old_encrypted = old_engine.encrypt_secret(b"historical-secret", &ctx).unwrap();
    assert!(old_encrypted.starts_with("enc:v1:key-2025:"));

    let decrypted = engine.decrypt_secret(&old_encrypted, &ctx).unwrap();
    assert_eq!(&*decrypted, b"historical-secret");

    let reenc_res = engine.reencrypt_if_needed(&old_encrypted, &ctx).unwrap();
    if let ReencryptResult::Rotated(new_encrypted) = reenc_res {
        assert!(new_encrypted.starts_with("enc:v1:key-2026:"));
        let dec_new = engine.decrypt_secret(&new_encrypted, &ctx).unwrap();
        assert_eq!(&*dec_new, b"historical-secret");
    } else {
        panic!("Expected ReencryptResult::Rotated");
    }
}
