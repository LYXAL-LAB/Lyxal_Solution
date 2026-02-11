use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use crate::error::{CoreError, Result};

/// Utility for password hashing and verification using Argon2id.
pub struct Crypto;

impl Crypto {
    /// Hashes a plain text password using Argon2id.
    ///
    /// # Arguments
    /// * `password` - The plain text password to hash.
    ///
    /// # Returns
    /// A Result containing the hashed password string or a CoreError.
    pub fn hash_password(password: &str) -> Result<String> {
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();

        let password_hash = argon2
            .hash_password(password.as_bytes(), &salt)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Password hashing failed: {}", e)))?
            .to_string();

        Ok(password_hash)
    }

    /// Verifies a plain text password against a hashed password.
    ///
    /// # Arguments
    /// * `password` - The plain text password to verify.
    /// * `hashed_password` - The hashed password string to check against.
    ///
    /// # Returns
    /// A Result containing a boolean indicating if the password is valid, or a CoreError.
    pub fn verify_password(password: &str, hashed_password: &str) -> Result<bool> {
        let parsed_hash = PasswordHash::new(hashed_password)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Invalid password hash format: {}", e)))?;

        let argon2 = Argon2::default();

        match argon2.verify_password(password.as_bytes(), &parsed_hash) {
            Ok(_) => Ok(true),
            Err(argon2::password_hash::Error::Password) => Ok(false),
            Err(e) => Err(CoreError::Internal(anyhow::anyhow!("Password verification failed: {}", e))),
        }
    }

    /// Generates a random secure token (e.g., for email verification or password reset).
    ///
    /// # Returns
    /// A 32-character hex-encoded random string.
    pub fn generate_random_token() -> String {
        use rand::{RngCore, thread_rng};
        let mut key = [0u8; 16];
        thread_rng().fill_bytes(&mut key);
        hex::encode(key)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hash_and_verify_password() {
        let password = "my_secure_password_123";
        let hash = Crypto::hash_password(password).unwrap();

        assert!(Crypto::verify_password(password, &hash).unwrap());
        assert!(!Crypto::verify_password("wrong_password", &hash).unwrap());
    }

    #[test]
    fn test_generate_token() {
        let token1 = Crypto::generate_random_token();
        let token2 = Crypto::generate_random_token();

        assert_eq!(token1.len(), 32);
        assert_ne!(token1, token2);
    }
}
