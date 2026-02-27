use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use lyxal_core::Result;

pub struct Crypto;

impl Crypto {
    pub fn hash_password(password: &str) -> Result<String> {
        let salt = SaltString::generate(&mut OsRng);
        // Configured to match high security standards (similar to Logto/Production)
        let argon2 = Argon2::new(
            Algorithm::Argon2id,
            Version::V0x13,
            Params::new(15000, 2, 1, None).unwrap(), // Memory 15MB, Iterations 2, Parallelism 1
        );
        let password_hash = argon2
            .hash_password(password.as_bytes(), &salt)
            .map_err(|e| CoreError::Internal(e.to_string()))?
            .to_string();
        Ok(password_hash)
    }

    pub fn verify_password(password: &str, hash: &str) -> Result<bool> {
        let parsed_hash = PasswordHash::new(hash)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;
        Ok(Argon2::default()
            .verify_password(password.as_bytes(), &parsed_hash)
            .is_ok())
    }
}
