use chrono::{DateTime, Utc};
use lyxal_core::{CoreError, Crypto, Result};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Represents a set of backup codes for a specific user.
/// These codes are intended to be used as a fallback when the primary MFA method is unavailable.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BackupCodeSet {
    pub user_id: Uuid,
    pub codes: Vec<HashedBackupCode>,
    pub generated_at: DateTime<Utc>,
}

/// Represents a single backup code stored securely (hashed).
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct HashedBackupCode {
    pub hash: String,
    pub used_at: Option<DateTime<Utc>>,
}

pub struct BackupCodeService;

impl BackupCodeService {
    /// Generates a new set of plain-text backup codes and their corresponding hashes.
    /// Typically, you return the plain-text codes once to the user so they can save them.
    ///
    /// # Arguments
    /// * `user_id` - The ID of the user for whom the codes are generated.
    /// * `count` - Number of codes to generate (default is usually 10).
    ///
    /// # Returns
    /// A tuple containing:
    /// 1. The plain-text codes (to be shown to the user).
    /// 2. The `BackupCodeSet` (to be stored in the database).
    pub fn generate_codes(user_id: Uuid, count: usize) -> Result<(Vec<String>, BackupCodeSet)> {
        let mut plain_codes = Vec::with_capacity(count);
        let mut hashed_codes = Vec::with_capacity(count);

        for _ in 0..count {
            // Generate a random 12-character alphanumeric code
            let plain = Crypto::generate_random_token()[..12].to_uppercase();
            let hash = Crypto::hash_password(&plain)?;

            plain_codes.push(plain);
            hashed_codes.push(HashedBackupCode {
                hash,
                used_at: None,
            });
        }

        let set = BackupCodeSet {
            user_id,
            codes: hashed_codes,
            generated_at: Utc::now(),
        };

        Ok((plain_codes, set))
    }

    /// Validates a provided backup code against a user's stored hashed codes.
    /// If valid, it returns the index of the code to be marked as used.
    ///
    /// # Arguments
    /// * `provided_code` - The plain-text code entered by the user.
    /// * `stored_set` - The user's set of hashed backup codes from the database.
    ///
    /// # Returns
    /// A Result containing the index of the matched code if successful.
    pub fn verify_and_consume(
        provided_code: &str,
        stored_set: &mut BackupCodeSet,
    ) -> Result<usize> {
        let code_to_verify = provided_code.trim().to_uppercase();

        for (index, hashed_code) in stored_set.codes.iter_mut().enumerate() {
            // Only check unused codes
            if hashed_code.used_at.is_none() {
                if Crypto::verify_password(&code_to_verify, &hashed_code.hash)? {
                    hashed_code.used_at = Some(Utc::now());
                    return Ok(index);
                }
            }
        }

        Err(CoreError::Unauthorized(
            "Invalid or already used backup code".to_string(),
        ))
    }

    /// Returns the number of remaining (unused) backup codes.
    pub fn remaining_codes_count(set: &BackupCodeSet) -> usize {
        set.codes.iter().filter(|c| c.used_at.is_none()).count()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_backup_codes_lifecycle() {
        let user_id = Uuid::new_v4();

        // 1. Generate
        let (plain, mut set) = BackupCodeService::generate_codes(user_id, 5).unwrap();
        assert_eq!(plain.len(), 5);
        assert_eq!(BackupCodeService::remaining_codes_count(&set), 5);

        // 2. Verify valid code
        let first_code = &plain[0];
        let index = BackupCodeService::verify_and_consume(first_code, &mut set).unwrap();
        assert_eq!(index, 0);
        assert_eq!(BackupCodeService::remaining_codes_count(&set), 4);
        assert!(set.codes[0].used_at.is_some());

        // 3. Verify used code fails
        let result = BackupCodeService::verify_and_consume(first_code, &mut set);
        assert!(result.is_err());

        // 4. Verify invalid code fails
        let result = BackupCodeService::verify_and_consume("INVALID-CODE", &mut set);
        assert!(result.is_err());
    }
}
