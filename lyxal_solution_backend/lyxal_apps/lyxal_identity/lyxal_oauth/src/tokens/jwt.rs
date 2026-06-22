use jsonwebtoken::{encode, Header, EncodingKey, Algorithm};
use serde::{Serialize, Deserialize};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,
    pub exp: usize,
    pub iat: usize,
    pub iss: String,
    pub aud: String,
    pub jti: String,
}

pub struct JwtService {
    secret: Vec<u8>,
    issuer: String,
}

impl JwtService {
    pub fn new(secret: &str, issuer: &str) -> Self {
        Self {
            secret: secret.as_bytes().to_vec(),
            issuer: issuer.to_string(),
        }
    }

    pub fn sign_token(&self, user_id: &str, audience: &str) -> Result<String, String> {
        let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs() as usize;
        let claims = Claims {
            sub: user_id.to_string(),
            exp: now + 3600, // 1 hour
            iat: now,
            iss: self.issuer.clone(),
            aud: audience.to_string(),
            jti: uuid::Uuid::new_4().to_string(),
        };

        encode(&Header::default(), &claims, &EncodingKey::from_secret(&self.secret))
            .map_err(|e| e.to_string())
    }
}
