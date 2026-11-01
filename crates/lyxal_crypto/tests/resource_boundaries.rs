//! Normative admission boundaries: accepted edges must remain usable, oversized inputs fail.
use base64::{engine::general_purpose::STANDARD_NO_PAD, Engine};
use lyxal_crypto::*;

#[test]
fn every_context_field_enforces_its_own_byte_limit() {
    for index in 0..5 {
        let limit = [128, 64, 64, 1024, 64][index];
        for size in [0, limit - 1, limit, limit + 1] {
            let mut fields = [
                "a".to_owned(),
                "m".into(),
                "r".into(),
                "id".into(),
                "f".into(),
            ];
            fields[index] = "a".repeat(size);
            let result = SecretContext::with_tenant(
                &fields[0], &fields[1], &fields[2], &fields[3], &fields[4],
            );
            assert_eq!(result.is_ok(), size != 0 && size <= limit);
        }
    }
    for size in [0, 127, 128, 129] {
        assert_eq!(
            SecretContext::global(&"a".repeat(size)).is_ok(),
            size != 0 && size <= 128
        );
    }
    for size in [0, 63, 64, 65] {
        assert_eq!(
            KeyId::parse(&"a".repeat(size)).is_ok(),
            size != 0 && size <= 64
        );
    }
}

fn phc(params: &str, salt_size: usize, digest_size: usize) -> String {
    format!(
        "$argon2id$v=19${params}${}${}",
        STANDARD_NO_PAD.encode(vec![0; salt_size]),
        STANDARD_NO_PAD.encode(vec![0; digest_size])
    )
}

#[test]
fn phc_salt_digest_and_cost_boundaries_do_not_require_hashing() {
    for size in [15, 16, 17, 31, 32, 33] {
        assert_eq!(
            PasswordHash::parse(&phc("m=8,t=1,p=1", size, 32)).is_ok(),
            (16..=32).contains(&size)
        );
    }
    for size in [31, 32, 33] {
        assert_eq!(
            PasswordHash::parse(&phc("m=8,t=1,p=1", 16, size)).is_ok(),
            size == 32
        );
    }
    for (params, allowed) in [
        ("m=131071,t=1,p=1", true),
        ("m=131072,t=1,p=1", true),
        ("m=131073,t=1,p=1", false),
        ("m=32,t=4,p=1", true),
        ("m=32,t=5,p=1", true),
        ("m=32,t=6,p=1", false),
        ("m=32,t=1,p=3", true),
        ("m=32,t=1,p=4", true),
        ("m=40,t=1,p=5", false),
    ] {
        assert_eq!(PasswordHash::parse(&phc(params, 16, 32)).is_ok(), allowed);
    }
    for size in [511, 512, 513] {
        let error = PasswordHash::parse(&"x".repeat(size)).unwrap_err();
        assert_eq!(matches!(error, CryptoError::InputTooLarge), size > 512);
    }
}

#[test]
fn password_admission_and_owned_secret_edges_are_exact() {
    let hash = PasswordHash::parse(&phc("m=8,t=1,p=1", 16, 32)).unwrap();
    for size in [1023, 1024, 1025] {
        let password = SecretString::new("x".repeat(size)).unwrap();
        assert_eq!(verify_password(&password, &hash).is_ok(), size <= 1024);
    }
    for size in [MAX_SECRET_BYTES - 1, MAX_SECRET_BYTES, MAX_SECRET_BYTES + 1] {
        assert_eq!(
            SecretBytes::new(vec![0; size]).is_ok(),
            size <= MAX_SECRET_BYTES
        );
        assert_eq!(
            SecretString::new("x".repeat(size)).is_ok(),
            size <= MAX_SECRET_BYTES
        );
    }
}

#[test]
fn mac_and_kdf_edges_preserve_fixed_size_contracts() {
    let key = HmacKey::import(SecretBytes::new(vec![0; 32]).unwrap()).unwrap();
    for size in [31, 32, 33] {
        assert_eq!(
            verify_hmac_sha256(&key, b"", &vec![0; size]).is_ok(),
            size == 32
        );
    }
    for size in [63, 64, 65] {
        assert_eq!(
            verify_hmac_sha256_hex(&key, b"", &"0".repeat(size)).is_ok(),
            size == 64
        );
    }
    let ikm = SecretBytes::new(vec![1; 32]).unwrap();
    for size in [0, 1, 8159, 8160, 8161] {
        assert_eq!(
            hkdf_sha256(&ikm, None, b"purpose", size).is_ok(),
            (1..=8160).contains(&size)
        );
    }
    for size in [0, 1, 1023, 1024, 1025] {
        assert_eq!(
            hkdf_sha256(&ikm, None, &vec![1; size], 32).is_ok(),
            (1..=1024).contains(&size)
        );
    }
}
