use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use lyxal_core::{CoreError, Result};

use crate::oidc::{AccessTokenClaims, IdTokenClaims};
use chrono::{Duration, Utc};

/// Service for generating and validating JSON Web Tokens (JWT).
/// It handles both Access Tokens and ID Tokens (OIDC).
#[derive(Clone)]
pub struct JwtService {
    encoding_key: EncodingKey,
    decoding_key: DecodingKey,
    issuer: String,
}

impl JwtService {
    /// Creates a new JwtService instance.
    ///
    /// # Arguments
    /// * `secret` - The secret key used for signing and verifying tokens.
    /// * `issuer` - The identifier of the token issuer (e.g., "https://auth.lyxal.com").
    pub fn new(secret: &str, issuer: &str) -> Self {
        Self {
            encoding_key: EncodingKey::from_secret(secret.as_bytes()),
            decoding_key: DecodingKey::from_secret(secret.as_bytes()),
            issuer: issuer.to_string(),
        }
    }

    /// Generates a new ID Token for OpenID Connect.
    pub fn generate_id_token(
        &self,
        user_id: uuid::Uuid,
        client_id: &str,
        nonce: Option<String>,
        expiration_hours: i64,
    ) -> Result<String> {
        let now = Utc::now();
        let claims = IdTokenClaims {
            iss: self.issuer.clone(),
            sub: user_id.to_string(),
            aud: client_id.to_string(),
            exp: (now + Duration::hours(expiration_hours)).timestamp(),
            iat: now.timestamp(),
            nonce,
            auth_time: Some(now.timestamp()),
        };

        encode(&Header::default(), &claims, &self.encoding_key)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("ID Token generation failed: {}", e)))
    }

    /// Generates a new Access Token.
    pub fn generate_access_token(
        &self,
        user_id: uuid::Uuid,
        client_id: &str,
        scopes: Vec<String>,
        expiration_hours: i64,
    ) -> Result<String> {
        let now = Utc::now();
        let claims = AccessTokenClaims {
            iss: self.issuer.clone(),
            sub: user_id.to_string(),
            aud: client_id.to_string(),
            exp: (now + Duration::hours(expiration_hours)).timestamp(),
            iat: now.timestamp(),
            jti: uuid::Uuid::new_v4().to_string(),
            scope: scopes.join(" "),
        };

        encode(&Header::default(), &claims, &self.encoding_key).map_err(|e| {
            CoreError::Internal(anyhow::anyhow!("Access Token generation failed: {}", e))
        })
    }

    /// Validates an Access Token and returns its claims.
    pub fn verify_access_token(
        &self,
        token: &str,
        client_id: Option<&str>,
    ) -> Result<AccessTokenClaims> {
        let mut validation = Validation::default();
        if let Some(aud) = client_id {
            validation.set_audience(&[aud]);
        }
        validation.set_issuer(&[&self.issuer]);

        let token_data = decode::<AccessTokenClaims>(token, &self.decoding_key, &validation)
            .map_err(|e| CoreError::Unauthorized(format!("Invalid token: {}", e)))?;

        Ok(token_data.claims)
    }

    /// Validates an ID Token and returns its claims.
    pub fn verify_id_token(&self, token: &str, client_id: &str) -> Result<IdTokenClaims> {
        let mut validation = Validation::default();
        validation.set_audience(&[client_id]);
        validation.set_issuer(&[&self.issuer]);

        let token_data = decode::<IdTokenClaims>(token, &self.decoding_key, &validation)
            .map_err(|e| CoreError::Unauthorized(format!("Invalid ID token: {}", e)))?;

        Ok(token_data.claims)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;

    #[test]
    fn test_jwt_lifecycle() {
        let secret = "super_secret_key_for_testing_12345";
        let issuer = "lyxal_test";
        let service = JwtService::new(secret, issuer);
        let user_id = Uuid::new_v4();
        let client_id = "test_client";

        // Access Token
        let token = service
            .generate_access_token(user_id, client_id, vec!["openid".into()], 1)
            .unwrap();
        let claims = service
            .verify_access_token(&token, Some(client_id))
            .unwrap();
        assert_eq!(claims.sub, user_id.to_string());
        assert_eq!(claims.iss, issuer);

        // ID Token
        let id_token = service
            .generate_id_token(user_id, client_id, None, 1)
            .unwrap();
        let id_claims = service.verify_id_token(&id_token, client_id).unwrap();
        assert_eq!(id_claims.sub, user_id.to_string());
    }
}
