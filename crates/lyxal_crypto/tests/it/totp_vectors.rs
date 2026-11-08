//! TOTP : vecteurs de la RFC 6238 annexe B, bornes, fenêtre, réutilisation et URI d'enrôlement.
use lyxal_crypto::*;

const SHA1_SEED: &[u8] = b"12345678901234567890";
const SHA256_SEED: &[u8] = b"12345678901234567890123456789012";

fn secret(seed: &[u8]) -> TotpSecret {
    TotpSecret::import(SecretBytes::new(seed.to_vec()).unwrap()).unwrap()
}

fn config(algorithm: TotpAlgorithm, digits: u8) -> TotpConfig {
    TotpConfig {
        algorithm,
        digits,
        step_seconds: 30,
    }
}

/// RFC 6238 annexe B : (instant, code SHA-1, code SHA-256), 8 chiffres, pas de 30 s.
const RFC6238: [(u64, &str, &str); 6] = [
    (59, "94287082", "46119246"),
    (1_111_111_109, "07081804", "68084774"),
    (1_111_111_111, "14050471", "67062674"),
    (1_234_567_890, "89005924", "91819424"),
    (2_000_000_000, "69279037", "90698825"),
    (20_000_000_000, "65353130", "77737706"),
];

#[test]
fn rfc6238_appendix_b_vectors() {
    let sha1 = config(TotpAlgorithm::Sha1, 8);
    let sha256 = config(TotpAlgorithm::Sha256, 8);
    for (time, code_sha1, code_sha256) in RFC6238 {
        let generated = totp_generate(&secret(SHA1_SEED), &sha1, time).unwrap();
        assert_eq!(generated.expose_secret(), code_sha1, "SHA-1 à {time}");
        let generated = totp_generate(&secret(SHA256_SEED), &sha256, time).unwrap();
        assert_eq!(generated.expose_secret(), code_sha256, "SHA-256 à {time}");
        let step = time / 30;
        assert_eq!(
            totp_verify(&secret(SHA1_SEED), &sha1, code_sha1, time, 0).unwrap(),
            Some(step)
        );
        assert_eq!(
            totp_verify(&secret(SHA256_SEED), &sha256, code_sha256, time, 0).unwrap(),
            Some(step)
        );
    }
}

#[test]
fn six_digit_codes_are_the_last_six_digits() {
    let code = totp_generate(&secret(SHA1_SEED), &TotpConfig::default(), 59).unwrap();
    assert_eq!(code.expose_secret(), "287082");
    let code = totp_generate(&secret(SHA1_SEED), &TotpConfig::default(), 1_111_111_109).unwrap();
    assert_eq!(code.expose_secret(), "081804", "zéro initial conservé");
}

#[test]
fn window_accepts_neighbouring_steps_and_returns_the_matching_step() {
    let cfg = TotpConfig::default();
    let s = secret(SHA1_SEED);
    let now = 1_234_567_890;
    let step = now / 30;
    let previous = totp_generate(&s, &cfg, now - 30).unwrap();
    let next = totp_generate(&s, &cfg, now + 30).unwrap();
    let far = totp_generate(&s, &cfg, now - 90).unwrap();
    assert_eq!(
        totp_verify(&s, &cfg, previous.expose_secret(), now, 0).unwrap(),
        None
    );
    assert_eq!(
        totp_verify(&s, &cfg, previous.expose_secret(), now, 1).unwrap(),
        Some(step - 1)
    );
    assert_eq!(
        totp_verify(&s, &cfg, next.expose_secret(), now, 1).unwrap(),
        Some(step + 1)
    );
    assert_eq!(
        totp_verify(&s, &cfg, far.expose_secret(), now, 2).unwrap(),
        None
    );
    assert_eq!(
        totp_verify(&s, &cfg, far.expose_secret(), now, 3),
        Err(CryptoError::InvalidTotpParameter),
        "fenêtre bornée à 2 pas"
    );
}

#[test]
fn window_at_the_epoch_does_not_underflow() {
    let cfg = TotpConfig::default();
    let s = secret(SHA1_SEED);
    let code = totp_generate(&s, &cfg, 0).unwrap();
    assert_eq!(
        totp_verify(&s, &cfg, code.expose_secret(), 0, 2).unwrap(),
        Some(0)
    );
    assert!(totp_verify(&s, &cfg, "000000", u64::MAX, 2).is_ok());
}

#[test]
fn malformed_codes_are_mismatches() {
    let cfg = TotpConfig::default();
    let s = secret(SHA1_SEED);
    for code in [
        "",
        "28708",
        "2870820",
        "28708a",
        " 287082",
        "２８７０８２",
        "+287082",
    ] {
        assert_eq!(
            totp_verify(&s, &cfg, code, 59, 1).unwrap(),
            None,
            "{code:?}"
        );
    }
    assert_eq!(totp_verify(&s, &cfg, "287082", 59, 0).unwrap(), Some(1));
}

#[test]
fn configuration_bounds_are_enforced() {
    let s = secret(SHA1_SEED);
    for (digits, step_seconds) in [(5, 30), (9, 30), (6, 14), (6, 121), (0, 0)] {
        let cfg = TotpConfig {
            algorithm: TotpAlgorithm::Sha1,
            digits,
            step_seconds,
        };
        assert_eq!(
            totp_generate(&s, &cfg, 59).err(),
            Some(CryptoError::InvalidTotpParameter)
        );
        assert_eq!(
            totp_verify(&s, &cfg, "123456", 59, 0).err(),
            Some(CryptoError::InvalidTotpParameter)
        );
        assert!(TotpSecret::generate(&cfg).is_err());
        assert!(totp_uri(&s, &cfg, "Lyxal", "a@example.com").is_err());
    }
    for (digits, step_seconds) in [(6, 15), (8, 120)] {
        let cfg = TotpConfig {
            algorithm: TotpAlgorithm::Sha256,
            digits,
            step_seconds,
        };
        assert_eq!(
            totp_generate(&s, &cfg, 59).unwrap().len(),
            usize::from(digits)
        );
    }
}

#[test]
fn secrets_have_bounded_sizes_and_redacted_debug() {
    for len in [0, 15, 65] {
        assert_eq!(
            TotpSecret::import(SecretBytes::new(vec![7; len]).unwrap()).err(),
            Some(CryptoError::InvalidTotpParameter)
        );
    }
    for len in [16, 64] {
        assert!(TotpSecret::import(SecretBytes::new(vec![7; len]).unwrap()).is_ok());
    }
    let sha1 = TotpSecret::generate(&TotpConfig::default()).unwrap();
    assert_eq!(sha1.expose_secret().len(), 20);
    let sha256 = TotpSecret::generate(&config(TotpAlgorithm::Sha256, 6)).unwrap();
    assert_eq!(sha256.expose_secret().len(), 32);
    assert_ne!(
        sha1.expose_secret(),
        TotpSecret::generate(&TotpConfig::default())
            .unwrap()
            .expose_secret()
    );
    assert_eq!(format!("{sha1:?}"), "TotpSecret([REDACTED])");
}

#[test]
fn base32_is_what_authenticator_applications_expect() {
    assert_eq!(
        secret(SHA1_SEED).to_base32().expose_secret(),
        "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
    );
    let imported = secret(&[0xff; 16]);
    assert_eq!(
        imported.to_base32().expose_secret(),
        "77777777777777777777777774",
        "16 octets : 26 caractères sans remplissage"
    );
}

#[test]
fn enrolment_uri_follows_the_key_uri_format() {
    let uri = totp_uri(
        &secret(SHA1_SEED),
        &TotpConfig::default(),
        "Lyxal OS",
        "jean.dupont+test@example.com",
    )
    .unwrap();
    assert_eq!(
        uri.expose_secret(),
        "otpauth://totp/Lyxal%20OS:jean.dupont%2Btest%40example.com\
         ?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Lyxal%20OS\
         &algorithm=SHA1&digits=6&period=30"
    );
    let uri = totp_uri(
        &secret(SHA256_SEED),
        &config(TotpAlgorithm::Sha256, 8),
        "Société & Co",
        "é",
    )
    .unwrap();
    assert!(uri
        .expose_secret()
        .starts_with("otpauth://totp/Soci%C3%A9t%C3%A9%20%26%20Co:%C3%A9?secret="));
    assert!(uri
        .expose_secret()
        .ends_with("&algorithm=SHA256&digits=8&period=30"));
    assert_eq!(format!("{uri:?}"), "SecretString([REDACTED])");
}

#[test]
fn enrolment_uri_rejects_ambiguous_labels() {
    let s = secret(SHA1_SEED);
    let cfg = TotpConfig::default();
    let long = "a".repeat(MAX_TOTP_LABEL_BYTES + 1);
    for (issuer, account) in [
        ("", "a"),
        ("a", ""),
        ("Ly:xal", "a"),
        ("Lyxal", "a:b"),
        ("Lyxal\n", "a"),
        ("Lyxal", "a\u{0}"),
        (long.as_str(), "a"),
    ] {
        assert_eq!(
            totp_uri(&s, &cfg, issuer, account).err(),
            Some(CryptoError::InvalidTotpParameter),
            "{issuer:?} / {account:?}"
        );
    }
    assert!(totp_uri(&s, &cfg, &"a".repeat(MAX_TOTP_LABEL_BYTES), "a").is_ok());
}

proptest::proptest! {
    #![proptest_config(proptest::prelude::ProptestConfig::with_cases(64))]
    #[test]
    fn generated_code_is_accepted_at_its_own_step(
        seed in proptest::collection::vec(proptest::prelude::any::<u8>(), 16..=64),
        time in proptest::prelude::any::<u64>(),
        sha256 in proptest::prelude::any::<bool>(),
        digits in 6u8..=8,
        step_seconds in 15u32..=120,
    ) {
        let algorithm = if sha256 { TotpAlgorithm::Sha256 } else { TotpAlgorithm::Sha1 };
        let cfg = TotpConfig { algorithm, digits, step_seconds };
        let s = secret(&seed);
        let code = totp_generate(&s, &cfg, time).unwrap();
        proptest::prop_assert_eq!(code.len(), usize::from(digits));
        proptest::prop_assert_eq!(
            totp_verify(&s, &cfg, code.expose_secret(), time, 0).unwrap(),
            Some(time / u64::from(step_seconds))
        );
    }
}
