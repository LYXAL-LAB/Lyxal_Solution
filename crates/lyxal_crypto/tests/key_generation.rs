use lyxal_crypto::{
    CompositeKeyResolver, CryptoEngine, CryptoError, EncryptionKey, KeyId, SecretContext,
};

#[test]
fn test_encryption_key_generate_produces_distinct_functional_keys() {
    let key1 = EncryptionKey::generate();
    let key2 = EncryptionKey::generate();

    let id1 = KeyId::parse("key-1").unwrap();
    let id2 = KeyId::parse("key-2").unwrap();

    let resolver1 = CompositeKeyResolver::new(id1.clone(), key1);
    let resolver2 = CompositeKeyResolver::new(id2.clone(), key2);

    let engine1 = CryptoEngine::new(resolver1);
    let engine2 = CryptoEngine::new(resolver2);

    let ctx = SecretContext::new("booking", "setting", "rec_1", "secret").unwrap();
    let plaintext = b"cryptographic-material-test";

    let encrypted1 = engine1.encrypt_secret(plaintext, &ctx).unwrap();

    // Sanity check : engine2 (avec key2) ne peut pas déchiffrer ce qui a été chiffré par engine1 (key1)
    let res = engine2.decrypt_secret(&encrypted1, &ctx);
    assert!(res.is_err());
    assert!(matches!(res.unwrap_err(), CryptoError::KeyNotFound { .. }));
}

#[test]
fn test_encryption_key_debug_redacted() {
    let key = EncryptionKey::generate();
    let debug_str = format!("{:?}", key);
    assert_eq!(debug_str, "EncryptionKey([REDACTED])");
    assert!(!debug_str.contains("0x"));
}
