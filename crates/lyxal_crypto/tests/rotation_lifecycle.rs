use lyxal_crypto::{
    CompositeKeyResolver, CryptoEngine, CryptoError, EncryptionKey, KeyId, ReencryptResult,
    SecretContext,
};
use std::sync::Arc;

#[test]
fn test_end_to_end_key_rotation_and_retirement_lifecycle() {
    // 1. Initialisation : Clé v1 active
    let raw_v1 = [0x11u8; 32];
    let key_v1 = EncryptionKey::from_bytes(raw_v1);
    let key_id_v1 = KeyId::parse("key-v1-2026").unwrap();
    let resolver = Arc::new(CompositeKeyResolver::new(key_id_v1.clone(), key_v1));
    let engine = CryptoEngine::new(resolver.clone());

    let ctx = SecretContext::with_tenant("tenant-corp", "booking", "setting", "smtp_1", "password").unwrap();
    let original_secret = "smtp_super_secret_password_2026";

    // 2. Chiffrement sous la clé v1
    let env_v1 = engine.encrypt_secret(original_secret.as_bytes(), &ctx).unwrap();
    assert!(env_v1.starts_with("enc:v1:key-v1-2026:"));

    // 3. Activation de la Clé v2 dans le système
    let raw_v2 = [0x22u8; 32];
    let key_v2 = EncryptionKey::from_bytes(raw_v2);
    let key_id_v2 = KeyId::parse("key-v2-2026").unwrap();
    
    // Création d'un nouveau résolveur avec v2 active et v1 historique
    let resolver_v2 = Arc::new(CompositeKeyResolver::new(key_id_v2.clone(), key_v2));
    let key_v1_historical = EncryptionKey::from_bytes(raw_v1);
    resolver_v2.add_historical_key(key_id_v1.clone(), key_v1_historical).unwrap();
    let engine_v2 = CryptoEngine::new(resolver_v2.clone());

    // 4. Déchiffrement de l'ancienne enveloppe v1 avec le moteur v2 (qui possède v1 en historique)
    let decrypted_v1 = engine_v2.decrypt_secret(&env_v1, &ctx).unwrap();
    assert_eq!(std::str::from_utf8(&decrypted_v1).unwrap(), original_secret);

    // 5. Ré-encryption automatique via `reencrypt_if_needed`
    let reencrypt_result = engine_v2.reencrypt_if_needed(&env_v1, &ctx).unwrap();
    let env_v2 = match reencrypt_result {
        ReencryptResult::Rotated(new_env) => new_env,
        ReencryptResult::Current => panic!("Envelope should have been rotated to key-v2"),
    };
    assert!(env_v2.starts_with("enc:v1:key-v2-2026:"));

    // 6. Une enveloppe déjà chiffrée avec la clé active ne doit pas être re-chiffrée
    let reencrypt_again = engine_v2.reencrypt_if_needed(&env_v2, &ctx).unwrap();
    assert_eq!(reencrypt_again, ReencryptResult::Current);

    // 7. Retrait / Révocation complète de la Clé v1 (Simulation d'un nouveau resolver ne connaissant que v2)
    let key_v2_new_instance = EncryptionKey::from_bytes(raw_v2);
    let retired_resolver = Arc::new(CompositeKeyResolver::new(key_id_v2.clone(), key_v2_new_instance));
    let engine_post_retirement = CryptoEngine::new(retired_resolver);

    // 8. L'enveloppe migrée v2 se déchiffre parfaitement
    let decrypted_v2 = engine_post_retirement.decrypt_secret(&env_v2, &ctx).unwrap();
    assert_eq!(std::str::from_utf8(&decrypted_v2).unwrap(), original_secret);

    // 9. L'ancienne enveloppe v1 (non migrée) échoue avec une erreur contrôlée `KeyNotFound` et JAMAIS un panic
    let old_v1_attempt = engine_post_retirement.decrypt_secret(&env_v1, &ctx);
    match old_v1_attempt {
        Err(CryptoError::KeyNotFound { key_id }) => {
            assert_eq!(key_id, "key-v1-2026");
        }
        other => panic!("Expected KeyNotFound, got {:?}", other),
    }
}

#[test]
fn test_rotation_error_handling_unknown_or_missing_keys() {
    let active_key = EncryptionKey::generate();
    let active_id = KeyId::parse("active-main").unwrap();
    let resolver = CompositeKeyResolver::new(active_id, active_key);
    let engine = CryptoEngine::new(resolver);

    let ctx = SecretContext::with_tenant("tenant_x", "mod", "res", "rec", "field").unwrap();

    // Enveloppe référençant une clé inexistante avec payload base64url valide sans padding (>= 28B)
    let unknown_key_env = "enc:v1:non-existent-key-999:AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA";
    let res = engine.decrypt_secret(unknown_key_env, &ctx);
    assert!(matches!(res, Err(CryptoError::KeyNotFound { .. })));

    // Re-encryption avec clé inconnue doit échouer proprement
    let reencrypt_res = engine.reencrypt_if_needed(unknown_key_env, &ctx);
    assert!(matches!(reencrypt_res, Err(CryptoError::KeyNotFound { .. })));
}
