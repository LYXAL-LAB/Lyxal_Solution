use lyxal_crypto::*;
use std::sync::Arc;
fn engine(key: EncryptionKey) -> CryptoEngine<StaticKeyResolver> {
    let mut b = KeyRingBuilder::new();
    b.insert(KeyId::parse("same-id").unwrap(), key, KeyUse::Active)
        .unwrap();
    CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())))
}
#[test]
fn different_material_with_the_same_id_fails_authentication() {
    let a = engine(EncryptionKey::generate().unwrap());
    let b = engine(EncryptionKey::generate().unwrap());
    let ctx = SecretContext::global("key.test").unwrap();
    let e = a
        .seal(&SecretBytes::new(vec![1, 2, 3]).unwrap(), &ctx)
        .unwrap();
    assert!(matches!(
        b.open(&e, &ctx),
        Err(CryptoError::AuthenticationFailed)
    ));
}
#[test]
fn key_identifier_bounds_and_identity_are_exact() {
    for s in ["", " a", "a ", "a:b", "clé", "\0"] {
        assert!(KeyId::parse(s).is_err());
    }
    assert!(KeyId::parse(&"a".repeat(64)).is_ok());
    assert!(KeyId::parse(&"a".repeat(65)).is_err());
    assert_ne!(KeyId::parse("Acme").unwrap(), KeyId::parse("acme").unwrap());
}
