#![no_main]
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::*;
use std::sync::{Arc, OnceLock};
fn id(s: &str) -> KeyId {
    KeyId::parse(s).unwrap()
}
fn key(x: u8) -> EncryptionKey {
    EncryptionKey::import(SecretBytes::new(vec![x; 32]).unwrap()).unwrap()
}
fn original() -> Arc<KeyRing> {
    static KEYS: OnceLock<Arc<KeyRing>> = OnceLock::new();
    KEYS.get_or_init(|| {
        let mut b = KeyRingBuilder::new();
        b.insert(id("old"), key(1), KeyUse::Active).unwrap();
        Arc::new(b.build().unwrap())
    })
    .clone()
}
fuzz_target!(|data: &[u8]| {
    if data.len() > 4096 {
        return;
    }
    let old = original();
    let source = CryptoEngine::new(StaticKeyResolver::new(old.clone()));
    let ctx = SecretContext::global("fuzz.rotation").unwrap();
    let secret = SecretBytes::new(data.to_vec()).unwrap();
    let envelope = source.seal(&secret, &ctx).unwrap();
    let flags = data.first().copied().unwrap_or(0);
    let mut b = KeyRingBuilder::from_snapshot(&old);
    b.insert(id("new"), key(2), KeyUse::DecryptOnly).unwrap();
    if flags & 1 != 0 {
        b.activate(&id("new")).unwrap();
    }
    let revoked = flags & 3 == 3;
    if revoked {
        b.revoke(&id("old")).unwrap();
    }
    b.insert_revoked(id("gone")).unwrap();
    assert!(b.activate(&id("gone")).is_err());
    assert!(b.insert(id("gone"), key(4), KeyUse::DecryptOnly).is_err());
    let ring = b.build().unwrap();
    old.validate_successor(&ring).unwrap();
    let engine = CryptoEngine::new(StaticKeyResolver::new(Arc::new(ring)));
    match engine.reencrypt_if_needed(&envelope, &ctx) {
        Err(CryptoError::KeyRevoked) => assert!(revoked),
        Ok(ReencryptResult::Current) => {
            assert!(!revoked && flags & 1 == 0);
            assert_eq!(engine.open(&envelope, &ctx).unwrap().expose_secret(), data);
        }
        Ok(ReencryptResult::Rotated(e)) => {
            assert!(!revoked && flags & 1 != 0);
            assert_eq!(engine.open(&e, &ctx).unwrap().expose_secret(), data);
            assert!(matches!(
                engine.reencrypt_if_needed(&e, &ctx),
                Ok(ReencryptResult::Current)
            ));
        }
        other => panic!("unexpected rotation result: {other:?}"),
    }
});
