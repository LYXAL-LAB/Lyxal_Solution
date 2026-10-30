use lyxal_crypto::*;
use std::sync::{
    atomic::{AtomicUsize, Ordering},
    Arc,
};
fn id(s: &str) -> KeyId {
    KeyId::parse(s).unwrap()
}
fn key(byte: u8) -> EncryptionKey {
    EncryptionKey::import(SecretBytes::new(vec![byte; 32]).unwrap()).unwrap()
}
fn initial() -> Arc<KeyRing> {
    let mut b = KeyRingBuilder::new();
    b.insert(id("old"), key(1), KeyUse::Active).unwrap();
    Arc::new(b.build().unwrap())
}
fn ctx() -> SecretContext {
    SecretContext::with_tenant("Acme", "booking", "setting", "rec_1", "password").unwrap()
}
#[test]
fn duplicate_and_failed_transitions_never_mutate() {
    let mut b = KeyRingBuilder::new();
    b.insert(id("old"), key(1), KeyUse::Active).unwrap();
    assert!(matches!(
        b.insert(id("old"), key(2), KeyUse::DecryptOnly),
        Err(CryptoError::DuplicateKeyId)
    ));
    assert!(matches!(
        b.insert_revoked(id("old")),
        Err(CryptoError::DuplicateKeyId)
    ));
    assert!(matches!(
        b.revoke(&id("old")),
        Err(CryptoError::ActiveKeyRevocation)
    ));
    assert!(b.activate(&id("missing")).is_err());
    let ring = b.build().unwrap();
    assert_eq!(ring.active_id().as_str(), "old");
    initial().validate_successor(&ring).unwrap();
}
#[test]
fn restoring_tombstones_needs_no_destroyed_key() {
    // Fictitious durable host registry restored after all original snapshots are dropped.
    let registry = ["retired-2025", "retired-2026"];
    let mut b = KeyRingBuilder::new();
    for name in registry {
        b.insert_revoked(id(name)).unwrap();
    }
    assert!(matches!(
        b.activate(&id(registry[0])),
        Err(CryptoError::KeyRevoked)
    ));
    assert!(matches!(
        b.insert(id(registry[0]), key(7), KeyUse::DecryptOnly),
        Err(CryptoError::DuplicateKeyId)
    ));
    b.insert(id("current"), key(3), KeyUse::Active).unwrap();
    let engine = CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())));
    let bogus =
        EncryptedEnvelope::parse("enc:v2:retired-2025:DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw")
            .unwrap();
    assert!(matches!(
        engine.open(&bogus, &ctx()),
        Err(CryptoError::KeyRevoked)
    ));
}
#[test]
fn complete_rotation_and_retirement() {
    let old = initial();
    let e1 = CryptoEngine::new(StaticKeyResolver::new(old.clone()));
    let secret = SecretBytes::new(b"FAKE-SECRET".to_vec()).unwrap();
    let original = e1.seal(&secret, &ctx()).unwrap();
    let mut b = KeyRingBuilder::from_snapshot(&old);
    b.insert(id("new"), key(2), KeyUse::DecryptOnly).unwrap();
    b.activate(&id("new")).unwrap();
    let new = Arc::new(b.build().unwrap());
    old.validate_successor(&new).unwrap();
    let e2 = CryptoEngine::new(StaticKeyResolver::new(new.clone()));
    let ReencryptResult::Rotated(migrated) = e2.reencrypt_if_needed(&original, &ctx()).unwrap()
    else {
        panic!("rotation required")
    };
    assert_eq!(
        e2.open(&migrated, &ctx()).unwrap().expose_secret(),
        secret.expose_secret()
    );
    assert!(matches!(
        e2.reencrypt_if_needed(&migrated, &ctx()),
        Ok(ReencryptResult::Current)
    ));
    let mut b = KeyRingBuilder::from_snapshot(&new);
    b.revoke(&id("old")).unwrap();
    b.revoke(&id("old")).unwrap();
    let retired = Arc::new(b.build().unwrap());
    new.validate_successor(&retired).unwrap();
    let e3 = CryptoEngine::new(StaticKeyResolver::new(retired));
    assert!(matches!(
        e3.open(&original, &ctx()),
        Err(CryptoError::KeyRevoked)
    ));
    assert!(e3.open(&migrated, &ctx()).is_ok());
    assert!(
        e1.open(&original, &ctx()).is_ok(),
        "old Arc is NOT remotely revoked"
    );
}
#[test]
fn successor_rejects_substitution_and_forgotten_tombstones() {
    let old = initial();
    let mut b = KeyRingBuilder::new();
    b.insert(id("old"), key(2), KeyUse::Active).unwrap();
    assert!(matches!(
        old.validate_successor(&b.build().unwrap()),
        Err(CryptoError::KeySubstitution)
    ));
    let mut b = KeyRingBuilder::from_snapshot(&old);
    b.insert_revoked(id("gone")).unwrap();
    let with_tombstone = b.build().unwrap();
    assert!(matches!(
        with_tombstone.validate_successor(&old),
        Err(CryptoError::InvalidSnapshotTransition)
    ));
}
#[test]
fn current_requires_authentication_and_wrong_same_id_key_fails() {
    let ring = initial();
    let engine = CryptoEngine::new(StaticKeyResolver::new(ring));
    let envelope = engine
        .seal(&SecretBytes::new(vec![1; 16]).unwrap(), &ctx())
        .unwrap();
    let wrong_ctx = SecretContext::global("smtp.password").unwrap();
    assert!(matches!(
        engine.reencrypt_if_needed(&envelope, &wrong_ctx),
        Err(CryptoError::AuthenticationFailed)
    ));
    let mut text = envelope.encode().into_bytes();
    let index = text.len() - 3;
    text[index] = if text[index] == b'A' { b'B' } else { b'A' };
    let bad = EncryptedEnvelope::parse(std::str::from_utf8(&text).unwrap()).unwrap();
    assert!(matches!(
        engine.reencrypt_if_needed(&bad, &ctx()),
        Err(CryptoError::AuthenticationFailed)
    ));
    let mut b = KeyRingBuilder::new();
    b.insert(id("old"), key(9), KeyUse::Active).unwrap();
    let other = CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())));
    assert!(matches!(
        other.open(&envelope, &ctx()),
        Err(CryptoError::AuthenticationFailed)
    ));
}
struct ChangingResolver {
    calls: AtomicUsize,
    first: Arc<KeyRing>,
    second: Arc<KeyRing>,
}
impl KeyResolver for ChangingResolver {
    fn snapshot(&self) -> Result<Arc<KeyRing>, CryptoError> {
        Ok(if self.calls.fetch_add(1, Ordering::SeqCst) == 0 {
            self.first.clone()
        } else {
            self.second.clone()
        })
    }
}
#[test]
fn each_operation_captures_exactly_once() {
    let old = initial();
    let source = CryptoEngine::new(StaticKeyResolver::new(old.clone()))
        .seal(&SecretBytes::new(vec![42]).unwrap(), &ctx())
        .unwrap();
    let mut b = KeyRingBuilder::from_snapshot(&old);
    b.insert(id("new"), key(2), KeyUse::DecryptOnly).unwrap();
    b.activate(&id("new")).unwrap();
    let new = Arc::new(b.build().unwrap());
    for op in 0..3 {
        let resolver = Arc::new(ChangingResolver {
            calls: AtomicUsize::new(0),
            first: new.clone(),
            second: old.clone(),
        });
        let engine = CryptoEngine::new(resolver.clone());
        match op {
            0 => {
                assert_eq!(
                    engine
                        .seal(&SecretBytes::new(vec![1]).unwrap(), &ctx())
                        .unwrap()
                        .key_id()
                        .as_str(),
                    "new"
                );
            }
            1 => {
                engine.open(&source, &ctx()).unwrap();
            }
            _ => {
                let ReencryptResult::Rotated(e) =
                    engine.reencrypt_if_needed(&source, &ctx()).unwrap()
                else {
                    panic!("rotation")
                };
                assert_eq!(e.key_id().as_str(), "new");
            }
        }
        assert_eq!(resolver.calls.load(Ordering::SeqCst), 1);
    }
}
#[test]
fn capacity_and_initial_active_are_enforced() {
    assert!(matches!(
        KeyRingBuilder::new().build(),
        Err(CryptoError::MissingActiveKey)
    ));
    let mut b = KeyRingBuilder::new();
    b.insert(id("old"), key(1), KeyUse::Active).unwrap();
    for n in 0..63 {
        b.insert_revoked(id(&format!("gone-{n}"))).unwrap();
    }
    assert!(matches!(
        b.insert_revoked(id("overflow")),
        Err(CryptoError::KeyStoreUnavailable)
    ));
    assert_eq!(b.build().unwrap().active_id().as_str(), "old");
}

#[test]
fn duplicate_historical_material_is_not_replaced() {
    let old = initial();
    let mut b = KeyRingBuilder::from_snapshot(&old);
    b.insert(id("historic"), key(2), KeyUse::DecryptOnly)
        .unwrap();
    assert!(matches!(
        b.insert(id("historic"), key(3), KeyUse::DecryptOnly),
        Err(CryptoError::DuplicateKeyId)
    ));
    let mut source = KeyRingBuilder::new();
    source
        .insert(id("historic"), key(2), KeyUse::Active)
        .unwrap();
    let source = CryptoEngine::new(StaticKeyResolver::new(Arc::new(source.build().unwrap())));
    let encrypted = source
        .seal(&SecretBytes::new(vec![42]).unwrap(), &ctx())
        .unwrap();
    let destination = CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())));
    assert_eq!(
        destination
            .open(&encrypted, &ctx())
            .unwrap()
            .expose_secret(),
        &[42]
    );
}
