use lyxal_crypto::*;
use std::sync::Arc;
fn engine() -> CryptoEngine<StaticKeyResolver> {
    let mut b = KeyRingBuilder::new();
    b.insert(
        KeyId::parse("key").unwrap(),
        EncryptionKey::import(SecretBytes::new(vec![42; 32]).unwrap()).unwrap(),
        KeyUse::Active,
    )
    .unwrap();
    CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())))
}
#[test]
fn roundtrip_empty_binary_and_maximum_plaintext() {
    let engine = engine();
    let ctx = SecretContext::with_tenant("Acme", "booking", "setting", "id", "password").unwrap();
    for raw in [vec![], vec![0, 255, 128], vec![7; 1_048_576]] {
        let s = SecretBytes::new(raw).unwrap();
        let e = engine.seal(&s, &ctx).unwrap();
        assert_eq!(
            engine
                .open(&EncryptedEnvelope::parse(&e.encode()).unwrap(), &ctx)
                .unwrap()
                .expose_secret(),
            s.expose_secret()
        );
    }
}
#[test]
fn every_context_component_and_domain_is_authenticated() {
    let engine = engine();
    let ctx = SecretContext::with_tenant("Acme", "booking", "setting", "id", "password").unwrap();
    let e = engine
        .seal(&SecretBytes::new(vec![1]).unwrap(), &ctx)
        .unwrap();
    for fields in [
        ["acme", "booking", "setting", "id", "password"],
        ["Acme", "other", "setting", "id", "password"],
        ["Acme", "booking", "other", "id", "password"],
        ["Acme", "booking", "setting", "ID", "password"],
        ["Acme", "booking", "setting", "id", "other"],
    ] {
        let bad = SecretContext::with_tenant(fields[0], fields[1], fields[2], fields[3], fields[4])
            .unwrap();
        assert!(matches!(
            engine.open(&e, &bad),
            Err(CryptoError::AuthenticationFailed)
        ));
    }
    let global = SecretContext::global("smtp.password").unwrap();
    let global_other = SecretContext::global("webhook.key").unwrap();
    assert!(engine.open(&e, &global).is_err());
    let g = engine
        .seal(&SecretBytes::new(vec![1]).unwrap(), &global)
        .unwrap();
    assert!(engine.open(&g, &global).is_ok());
    assert!(engine.open(&g, &ctx).is_err());
    assert!(engine.open(&g, &global_other).is_err());
}
#[test]
fn nonce_samples_are_distinct_without_claiming_global_uniqueness() {
    let engine = engine();
    let ctx = SecretContext::global("nonce.sample").unwrap();
    let p = SecretBytes::new(vec![42]).unwrap();
    let a = engine.seal(&p, &ctx).unwrap().encode();
    let b = engine.seal(&p, &ctx).unwrap().encode();
    assert_ne!(a, b);
}
