use crate::error::CryptoError;
use crate::key::KeyId;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;

/// Versions supportées d'enveloppes chiffrées.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EnvelopeVersion {
    V1,
}

impl EnvelopeVersion {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::V1 => "v1",
        }
    }
}

/// Structure représentant une enveloppe chiffrée et parsée.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EncryptedEnvelope {
    pub version: EnvelopeVersion,
    pub key_id: KeyId,
    pub payload: Vec<u8>,
}

impl EncryptedEnvelope {
    pub fn new(key_id: KeyId, payload: Vec<u8>) -> Self {
        Self {
            version: EnvelopeVersion::V1,
            key_id,
            payload,
        }
    }

    /// Encode l'enveloppe sous le format canonique : `enc:v1:<key_id>:<base64url>`
    pub fn encode(&self) -> String {
        let b64 = URL_SAFE_NO_PAD.encode(&self.payload);
        format!("enc:{}:{}:{}", self.version.as_str(), self.key_id.as_str(), b64)
    }

    /// Tente de parser une chaîne sous le format enveloppé `enc:v1:<key_id>:<base64url>`.
    pub fn parse(input: &str) -> Result<Self, CryptoError> {
        let input = input.trim();
        if !input.starts_with("enc:") {
            return Err(CryptoError::InvalidEnvelope);
        }

        let parts: Vec<&str> = input.splitn(4, ':').collect();
        if parts.len() != 4 || parts[0] != "enc" {
            return Err(CryptoError::InvalidEnvelope);
        }

        let version = match parts[1] {
            "v1" => EnvelopeVersion::V1,
            other => return Err(CryptoError::UnsupportedVersion { version: other.to_string() }),
        };

        let key_id = KeyId::parse(parts[2])?;

        let payload_b64 = parts[3];
        let payload = URL_SAFE_NO_PAD
            .decode(payload_b64)
            .map_err(|_| CryptoError::InvalidPayload)?;

        if payload.len() < 28 {
            // Nonce 12 octets + Tag 16 octets = 28 octets minimum
            return Err(CryptoError::InvalidPayload);
        }

        Ok(Self {
            version,
            key_id,
            payload,
        })
    }
}
