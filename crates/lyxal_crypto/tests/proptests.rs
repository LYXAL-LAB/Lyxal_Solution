use lyxal_crypto::*;
use proptest::prelude::*;
use std::sync::Arc;
fn key(value: u8) -> EncryptionKey {
    EncryptionKey::import(SecretBytes::new(vec![value; 32]).unwrap()).unwrap()
}
fn ring() -> Arc<KeyRing> {
    let mut b = KeyRingBuilder::new();
    b.insert(KeyId::parse("old").unwrap(), key(1), KeyUse::Active)
        .unwrap();
    Arc::new(b.build().unwrap())
}
proptest! {
    #![proptest_config(ProptestConfig::with_cases(1000))]
    #[test]
    fn roundtrip_and_canonical_encoding(data in proptest::collection::vec(any::<u8>(),0..4096),tenant in "[A-Za-z0-9_-]{1,16}",record in "[a-zA-ZéΩ0-9:_-]{1,32}") {
        let e=CryptoEngine::new(StaticKeyResolver::new(ring()));let ctx=SecretContext::with_tenant(&tenant,"module","resource",&record,"secret").unwrap();let secret=SecretBytes::new(data).unwrap();
        let env=e.seal(&secret,&ctx).unwrap();let text=env.encode();let parsed=EncryptedEnvelope::parse(&text).unwrap();prop_assert_eq!(parsed.encode(),text);let opened=e.open(&parsed,&ctx).unwrap();prop_assert_eq!(opened.expose_secret(),secret.expose_secret());
    }
    #[test]
    fn distinct_valid_contexts_reject_substitution(tenant in "[A-Za-z0-9_-]{1,16}",record in "[a-zA-ZéΩ0-9:_-]{1,32}",field in 0u8..5) {
        let e=CryptoEngine::new(StaticKeyResolver::new(ring()));let a=SecretContext::with_tenant(&tenant,"module","resource",&record,"secret").unwrap();
        let mut parts=[tenant,"module".into(),"resource".into(),record,"secret".into()];parts[field as usize].push('x');
        let b=SecretContext::with_tenant(&parts[0],&parts[1],&parts[2],&parts[3],&parts[4]).unwrap();let env=e.seal(&SecretBytes::new(vec![42]).unwrap(),&a).unwrap();prop_assert!(e.open(&env,&b).is_err());
    }
    #[test]
    fn rotation_is_authenticated_and_idempotent(data in proptest::collection::vec(any::<u8>(),0..512)) {
        let old=ring();let e1=CryptoEngine::new(StaticKeyResolver::new(old.clone()));let ctx=SecretContext::global("rotation.property").unwrap();let secret=SecretBytes::new(data).unwrap();let env=e1.seal(&secret,&ctx).unwrap();
        let mut b=KeyRingBuilder::from_snapshot(&old);b.insert(KeyId::parse("new").unwrap(),key(2),KeyUse::DecryptOnly).unwrap();b.activate(&KeyId::parse("new").unwrap()).unwrap();let next=b.build().unwrap();old.validate_successor(&next).unwrap();let e2=CryptoEngine::new(StaticKeyResolver::new(Arc::new(next)));
        let ReencryptResult::Rotated(rotated)=e2.reencrypt_if_needed(&env,&ctx).unwrap() else {panic!("rotation required")};let opened=e2.open(&rotated,&ctx).unwrap();prop_assert_eq!(opened.expose_secret(),secret.expose_secret());prop_assert!(matches!(e2.reencrypt_if_needed(&rotated,&ctx),Ok(ReencryptResult::Current)));
    }
    #[test]
    fn hmac_roundtrip(data in proptest::collection::vec(any::<u8>(),0..1024),raw in any::<[u8;32]>()) {
        let key=HmacKey::import(SecretBytes::new(raw.to_vec()).unwrap()).unwrap();let tag=sign_hmac_sha256(&key,&data).unwrap();prop_assert!(verify_hmac_sha256(&key,&data,&tag).unwrap());let mut bad=tag;bad[0]^=1;prop_assert!(!verify_hmac_sha256(&key,&data,&bad).unwrap());
    }
}
