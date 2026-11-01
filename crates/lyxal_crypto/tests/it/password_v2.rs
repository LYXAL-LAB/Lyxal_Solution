use lyxal_crypto::*;
fn password(s: &str) -> SecretString {
    SecretString::new(s.to_owned()).unwrap()
}
#[test]
fn password_roundtrip_policy_and_redaction() {
    let p = password("FAKE-PASSWORD");
    let hash = hash_password(&p).unwrap();
    assert!(hash
        .expose_phc()
        .starts_with("$argon2id$v=19$m=65536,t=3,p=1$"));
    assert_eq!(format!("{hash:?}"), "PasswordHash([REDACTED])");
    assert!(!hash.needs_rehash());
    assert_eq!(
        verify_password(&p, &hash).unwrap(),
        PasswordVerification::Verified {
            needs_rehash: false
        }
    );
    assert_eq!(
        verify_password(&password("wrong"), &hash).unwrap(),
        PasswordVerification::Mismatch
    );
    assert_ne!(hash.expose_phc(), hash_password(&p).unwrap().expose_phc());
}
#[test]
fn invalid_phc_and_excessive_costs_never_start_hashing() {
    for text in ["", "$argon2id$v=19$m=65536,t=3,p=1", "$argon2id$v=19$m=65536,t=3,p=1$c2hvcnQ$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "$argon2id$v=19$m=65536,t=3,p=1$AAAAAAAAAAAAAAAAAAAAAA$AAAA", "$argon2i$v=19$m=65536,t=3,p=1$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "$argon2id$v=19$m=65536,m=65536,p=1$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"] {
        assert!(PasswordHash::parse(text).is_err());
    }
    for params in [
        "m=4294967295,t=3,p=1",
        "m=65536,t=4294967295,p=1",
        "m=65536,t=3,p=4294967295",
    ] {
        let text=format!("$argon2id$v=19${params}$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        assert!(matches!(
            PasswordHash::parse(&text),
            Err(CryptoError::PasswordCostExceeded)
        ));
    }
    assert!(matches!(
        hash_password(&password(&"x".repeat(1025))),
        Err(CryptoError::InputTooLarge)
    ));
}
#[test]
fn stronger_cost_is_not_automatically_downgraded() {
    let stronger=PasswordHash::parse("$argon2id$v=19$m=131072,t=4,p=2$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").unwrap();
    assert!(!stronger.needs_rehash());
    let weaker=PasswordHash::parse("$argon2id$v=19$m=32768,t=3,p=1$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").unwrap();
    assert!(weaker.needs_rehash());
}
