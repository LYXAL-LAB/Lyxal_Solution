use lyxal_core::{CoreError, Result};
use serde::{Deserialize, Serialize};
use totp_rs::{Algorithm, Secret, TOTP};

/// Represents the configuration and state of a TOTP (Time-based One-Time Password) setup.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TotpConfig {
    pub secret: String,
    pub issuer: String,
    pub account_name: String,
}

pub struct TotpService;

impl TotpService {
    /// Generates a new TOTP secret and returns the configuration for setup.
    ///
    /// # Arguments
    /// * `issuer` - The name of the identity provider (e.g., "Lyxal Identity").
    /// * `account_name` - The user's identifier (usually their email).
    pub fn generate_new_setup(issuer: &str, account_name: &str) -> Result<TotpConfig> {
        let secret = Secret::generate_balanced();

        Ok(TotpConfig {
            secret: secret.to_string(),
            issuer: issuer.to_string(),
            account_name: account_name.to_string(),
        })
    }

    /// Verifies a TOTP code provided by the user against their stored secret.
    ///
    /// # Arguments
    /// * `secret_str` - The stored TOTP secret.
    /// * `code` - The 6-digit code entered by the user.
    pub fn verify_code(secret_str: &str, code: &str) -> Result<bool> {
        let secret = Secret::from_str(secret_str).map_err(|e| {
            CoreError::Internal(anyhow::anyhow!("Invalid TOTP secret format: {}", e))
        })?;

        let totp = TOTP::new(
            Algorithm::SHA1,
            6,
            1,
            30,
            secret.to_bytes().map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to decode TOTP secret: {}", e))
            })?,
        )
        .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to initialize TOTP: {}", e)))?;

        Ok(totp.check_current(code).unwrap_or(false))
    }

    /// Generates a QR code URI (otpauth://) for easy setup in apps like Google Authenticator.
    pub fn get_qr_code_url(config: &TotpConfig) -> Result<String> {
        let secret = Secret::from_str(&config.secret)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Invalid TOTP secret: {}", e)))?;

        let totp = TOTP::new(
            Algorithm::SHA1,
            6,
            1,
            30,
            secret.to_bytes().map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to decode secret: {}", e))
            })?,
            Some(config.issuer.clone()),
            config.account_name.clone(),
        )
        .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to create TOTP URI: {}", e)))?;

        Ok(totp.get_url())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_totp_lifecycle() {
        let issuer = "LyxalTest";
        let account = "user@example.com";

        // 1. Generate setup
        let config = TotpService::generate_new_setup(issuer, account).unwrap();
        assert!(!config.secret.is_empty());

        // 2. Generate URI
        let url = TotpService::get_qr_code_url(&config).unwrap();
        assert!(url.contains("otpauth://totp/"));
        assert!(url.contains("LyxalTest"));
    }
}
