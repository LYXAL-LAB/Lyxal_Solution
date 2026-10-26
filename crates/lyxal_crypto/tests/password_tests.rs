use lyxal_crypto::password::{hash_password, needs_rehash, verify_password};

#[test]
fn test_argon2id_hash_and_verify_success() {
    let password = "SuperSecretLyxalAdminPassword2026!";
    let encoded_hash = hash_password(password).unwrap();

    // Vérifie le format PHC et les paramètres Lyxal imposés
    assert!(
        encoded_hash.starts_with("$argon2id$v=19$m=65536,t=3,p=1$"),
        "Hash must conform to Lyxal Argon2id PHC format: {}",
        encoded_hash
    );

    // Vérification correcte
    let is_valid = verify_password(password, &encoded_hash).unwrap();
    assert!(is_valid);

    // Vérification mot de passe incorrect
    let is_invalid = verify_password("WrongPassword!", &encoded_hash).unwrap();
    assert!(!is_invalid);

    // Le hash respecte la politique actuelle
    assert!(!needs_rehash(&encoded_hash));
}

#[test]
fn test_argon2id_unique_salts_for_same_password() {
    let password = "IdenticalPassword";
    let hash1 = hash_password(password).unwrap();
    let hash2 = hash_password(password).unwrap();

    assert_ne!(hash1, hash2, "Salts must be randomly generated and unique");
    assert!(verify_password(password, &hash1).unwrap());
    assert!(verify_password(password, &hash2).unwrap());
}

#[test]
fn test_needs_rehash_detects_outdated_or_invalid_hashes() {
    // Hash avec coût mémoire inférieur (m=32768 au lieu de 65536)
    let outdated_m_cost_hash =
        "$argon2id$v=19$m=32768,t=3,p=1$c29tZXNhbHRzdHJpbmc$5Zq8E9N+w9t5q6tU5uW9rQ";
    assert!(needs_rehash(outdated_m_cost_hash));

    // Hash avec algorithme différent (argon2i au lieu de argon2id)
    let outdated_algo_hash =
        "$argon2i$v=19$m=65536,t=3,p=1$c29tZXNhbHRzdHJpbmc$5Zq8E9N+w9t5q6tU5uW9rQ";
    assert!(needs_rehash(outdated_algo_hash));

    // Chaîne corrompue
    assert!(needs_rehash("not-a-valid-phc-hash"));
}

#[test]
fn test_verify_password_with_corrupted_hash_returns_error() {
    let res = verify_password("password", "invalid_phc_format");
    assert!(res.is_err());
}
