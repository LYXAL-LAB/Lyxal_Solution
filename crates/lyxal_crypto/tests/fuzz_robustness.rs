use lyxal_crypto::{
    hash_password, needs_rehash, verify_password, CompositeKeyResolver, CryptoEngine,
    EncryptionKey, KeyId, SecretContext,
};

/// Test de robustesse aléatoire (Randomized Robustness Testing) simulant des milliers
/// d'entrées corrompues, malformées, tronquées et de grande taille pour garantir l'absence totale de panics.
#[test]
fn test_randomized_envelope_parsing_and_decryption_robustness() {
    let key = EncryptionKey::generate();
    let key_id = KeyId::parse("key-fuzz-1").unwrap();
    let resolver = CompositeKeyResolver::new(key_id, key);
    let engine = CryptoEngine::new(resolver);

    let ctx = SecretContext::with_tenant("tenant_fuzz", "module_fuzz", "res", "rec", "field").unwrap();

    // 1. Chaînes d'enveloppes tronquées ou corrompues
    let malformed_inputs = [
        "",
        " ",
        "enc",
        "enc:",
        "enc:v1",
        "enc:v1:",
        "enc:v1:key:",
        "enc:v1:key:not-valid-base64-!@#$%",
        "enc:v1:key:AQID", // payload trop court (< 28 octets)
        "enc:v2:key:AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA=", // version non supportée
        "enc:v1::AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA=",    // key_id vide
        "enc:v1:key with space:AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA=",
        "enc:v1:key:===invalid-padding===",
        "\0\0\0",
        "enc:v1:key:\0\0\0",
    ];

    for input in &malformed_inputs {
        let res = engine.decrypt_secret(input, &ctx);
        assert!(res.is_err(), "Malformed input '{input}' must fail gracefully without panic");

        let res_unbound = engine.decrypt_unbound(input);
        assert!(res_unbound.is_err(), "Malformed input '{input}' in decrypt_unbound must fail gracefully");
    }

    // 2. Fuzzing par mutation pseudo-aléatoire déterministe
    let mut state: u64 = 0xdeadbeef_cafebabe;
    let mut lcg_rand = || {
        state = state.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        state
    };

    let valid_env = engine.encrypt_secret(b"Hello Robustness Fuzzing", &ctx).unwrap();

    for _ in 0..2000 {
        let r = lcg_rand();
        let mutation_type = r % 5;
        let mut corrupted = valid_env.clone();

        match mutation_type {
            0 => {
                // Tronquer à une position aléatoire
                let cut = (lcg_rand() as usize) % corrupted.len();
                corrupted.truncate(cut);
            }
            1 => {
                // Remplacer un caractère par un octet arbitraire
                let idx = (lcg_rand() as usize) % corrupted.len();
                let random_char = ((lcg_rand() % 255) as u8) as char;
                corrupted.replace_range(idx..=idx, &random_char.to_string());
            }
            2 => {
                // Insérer des délimiteurs ':' supplémentaires
                corrupted.push_str(":extra:colons");
            }
            3 => {
                // Chaîne géante pour vérifier les allocations bornées
                let mut large = corrupted.clone();
                large.push_str(&"A".repeat(10_000));
                corrupted = large;
            }
            _ => {
                // Inverser des octets dans le base64
                if let Some(pos) = corrupted.rfind(':') {
                    let mut b64_part = corrupted[pos + 1..].to_string();
                    if !b64_part.is_empty() {
                        let flip_idx = (lcg_rand() as usize) % b64_part.len();
                        b64_part.replace_range(flip_idx..=flip_idx, "X");
                        corrupted = format!("{}:{}", &corrupted[..pos], b64_part);
                    }
                }
            }
        }

        // L'appel doit obligatoirement retourner Ok ou Err mais JAMAIS panic
        let _ = engine.decrypt_secret(&corrupted, &ctx);
    }
}

#[test]
fn test_randomized_password_verification_robustness() {
    // Hashes Argon2 malformés
    let bad_hashes = [
        "",
        "$argon2id$",
        "$argon2id$v=19$m=65536,t=3,p=1$",
        "$argon2id$v=19$m=0,t=0,p=0$c2FsdA$tag",
        "$invalid$v=19$m=65536,t=3,p=1$c2FsdA$tag",
        "$argon2id$v=99$m=65536,t=3,p=1$c2FsdA$tag",
        "not a phc string at all",
        "\0\0\0\0",
    ];

    for bad in &bad_hashes {
        assert!(verify_password("any_password", bad).is_err());
        assert!(needs_rehash(bad));
    }

    let valid_pw = "ValidP@ssw0rd!123";
    let valid_hash = hash_password(valid_pw).unwrap();
    assert!(!needs_rehash(&valid_hash));
}
