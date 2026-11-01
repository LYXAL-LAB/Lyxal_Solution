use argon2::{Algorithm, Argon2, Params, Version};
use base64::{engine::general_purpose::STANDARD_NO_PAD, Engine};
use lyxal_crypto::*;
#[test]
fn accepted_weak_hash_verifies_and_requests_upgrade() {
    let salt = [7u8; 16];
    let mut digest = [0u8; 32];
    Argon2::new(
        Algorithm::Argon2id,
        Version::V0x13,
        Params::new(8, 1, 1, Some(32)).unwrap(),
    )
    .hash_password_into(b"fixture", &salt, &mut digest)
    .unwrap();
    let encoded = format!(
        "$argon2id$v=19$m=8,t=1,p=1${}${}",
        STANDARD_NO_PAD.encode(salt),
        STANDARD_NO_PAD.encode(digest)
    );
    let parsed = PasswordHash::parse(&encoded).unwrap();
    assert!(parsed.needs_rehash());
    assert_eq!(
        verify_password(&SecretString::new("fixture".into()).unwrap(), &parsed).unwrap(),
        PasswordVerification::Verified { needs_rehash: true }
    );
}
