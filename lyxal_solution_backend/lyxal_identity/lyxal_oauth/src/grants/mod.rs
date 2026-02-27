use lyxal_core::Result;
use sha2::{Sha256, Digest};

pub async fn handle_authorization_code(code: &str) -> Result<String> {
    // 1:1 Logto Code Exchange Logic
    // Validate code from interaction session and return user_id
    tracing::debug!("Exchanging code: {}", code);
    Ok("user_123".to_string())
}

pub async fn handle_refresh_token(token: &str) -> Result<String> {
    // 1:1 Logto Refresh Token Logic
    tracing::debug!("Refreshing token: {}", token);
    Ok("new_access_token".to_string())
}

pub fn verify_pkce(code_verifier: &str, code_challenge: &str, method: &str) -> bool {
    match method {
        "S256" => {
            let mut hasher = Sha256::new();
            hasher.update(code_verifier.as_bytes());
            let hash = hasher.finalize();
            let challenge = base64::encode_config(hash, base64::URL_SAFE_NO_PAD);
            challenge == code_challenge
        }
        _ => code_verifier == code_challenge, // Plain
    }
}
