use totp_rs::{Algorithm, TOTP, Secret};
use lyxal_core::Result;

pub fn generate_totp_secret(user_email: &str) -> Result<(String, String)> {
    let secret = Secret::generate_base32();
    let totp = TOTP::new(
        Algorithm::SHA1,
        6,
        1,
        30,
        secret.to_bytes().unwrap(),
        Some("Lyxal Identity".to_string()),
        user_email.to_string(),
    ).map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

    Ok((secret.to_string(), totp.get_url()))
}

pub fn verify_totp(secret: &str, code: &str) -> bool {
    let secret_bytes = Secret::from_base32(secret).unwrap().to_bytes().unwrap();
    let totp = TOTP::new(Algorithm::SHA1, 6, 1, 30, secret_bytes, None, "".to_string()).unwrap();
    totp.check_current(code).unwrap_or(false)
}
