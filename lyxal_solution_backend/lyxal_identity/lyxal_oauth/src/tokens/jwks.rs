use serde::{Deserialize, Serialize};
use jsonwebtoken::{EncodingKey, DecodingKey, Header, Algorithm};
use rsa::{RsaPrivateKey, RsaPublicKey, pkcs8::{EncodePrivateKey, EncodePublicKey}};
use lyxal_core::{CoreError, Result};

/// Represents a JSON Web Key (JWK) as defined in RFC 7517.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Jwk {
    pub kty: String,
    pub use_: String,
    pub alg: String,
    pub kid: String,
    pub n: String,
    pub e: String,
}

/// Represents a set of JSON Web Keys.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JwksResponse {
    pub keys: Vec<Jwk>,
}

/// JwksService handles the generation and management of cryptographic keys
/// used for signing and verifying OIDC tokens.
#[derive(Clone)]
pub struct JwksService {
    kid: String,
    private_key: RsaPrivateKey,
    public_key: RsaPublicKey,
}

impl JwksService {
    /// Creates a new JwksService with a generated RSA key pair.
    pub fn new(kid: String) -> Result<Self> {
        let mut rng = rand::thread_rng();
        let private_key = RsaPrivateKey::new(&mut rng, 2048)
            .map_err(|e| CoreError::Internal(e.into()))?;
        let public_key = RsaPublicKey::from(&private_key);
        
        Ok(Self { kid, private_key, public_key })
    }

    /// Returns the Key ID currently used for signing.
    pub fn get_kid(&self) -> String {
        self.kid.clone()
    }

    /// Generates a JWKS response containing the public keys.
    pub fn get_public_jwks(&self) -> JwksResponse {
        use base64::{Engine as _, engine::general_purpose::URL_SAFE_NO_PAD};
        
        let n = URL_SAFE_NO_PAD.encode(self.public_key.n().to_bytes_be());
        let e = URL_SAFE_NO_PAD.encode(self.public_key.e().to_bytes_be());

        JwksResponse {
            keys: vec![Jwk {
                kty: "RSA".to_string(),
                use_: "sig".to_string(),
                alg: "RS256".to_string(),
                kid: self.kid.clone(),
                n,
                e,
            }],
        }
    }

    /// Helper to sign data (logic would be integrated with JwtService)
    pub fn get_encoding_key(&self) -> Result<EncodingKey> {
        let pem = self.private_key.to_pkcs8_pem(rsa::pkcs8::LineEnding::LF)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to encode private key: {}", e)))?;
        
        EncodingKey::from_rsa_pem(pem.as_bytes())
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to create encoding key: {}", e)))
    }

    /// Helper to verify data
    pub fn get_decoding_key(&self) -> Result<DecodingKey> {
        let pem = self.public_key.to_public_key_pem(rsa::pkcs8::LineEnding::LF)
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to encode public key: {}", e)))?;
            
        DecodingKey::from_rsa_pem(pem.as_bytes())
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to create decoding key: {}", e)))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_jwks_response_format() {
        let service = JwksService::new("test_key_1".to_string());
        let response = service.get_public_jwks();

        assert_eq!(response.keys.len(), 1);
        assert_eq!(response.keys[0].kid, "test_key_1");
        assert_eq!(response.keys[0].kty, "RSA");
    }
}
