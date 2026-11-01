//! Strict, bounded transport. Parsing is NOT authentication.
use crate::{CryptoError, KeyId, MAX_SECRET_BYTES};
use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use std::fmt;
/// Maximum complete ASCII envelope length, including a 64-byte key ID.
pub const MAX_ENVELOPE_BYTES: usize = 1_398_211;
const MAX_PAYLOAD: usize = MAX_SECRET_BYTES + 28;
/// Unauthenticated until opened with a key and the host-authorized context.
pub struct EncryptedEnvelope {
    pub(crate) key_id: KeyId,
    pub(crate) payload: Vec<u8>,
}
impl EncryptedEnvelope {
    /// Parse only canonical enc:v2. Unknown versions never trigger a legacy fallback.
    pub fn parse(input: &str) -> Result<Self, CryptoError> {
        if input.len() > MAX_ENVELOPE_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        if !input.is_ascii() {
            return Err(CryptoError::InvalidEnvelope);
        }
        let mut parts = input.split(':');
        let (Some(prefix), Some(version), Some(id), Some(b64), None) = (
            parts.next(),
            parts.next(),
            parts.next(),
            parts.next(),
            parts.next(),
        ) else {
            return Err(CryptoError::InvalidEnvelope);
        };
        if prefix != "enc" || id.is_empty() || b64.is_empty() {
            return Err(CryptoError::InvalidEnvelope);
        }
        if version != "v2" {
            let numeric = version.strip_prefix('v').unwrap_or("");
            if !numeric.is_empty()
                && numeric.len() <= 3
                && !numeric.starts_with('0')
                && numeric.bytes().all(|b| b.is_ascii_digit())
            {
                return Err(CryptoError::UnsupportedVersion);
            }
            return Err(CryptoError::InvalidEnvelope);
        }
        let key_id = KeyId::parse(id).map_err(|_| CryptoError::InvalidEnvelope)?;
        if b64.len() > 1_398_139 {
            return Err(CryptoError::InputTooLarge);
        }
        if b64.len() % 4 == 1
            || !b64
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"-_".contains(&b))
        {
            return Err(CryptoError::InvalidEnvelope);
        }
        let payload = URL_SAFE_NO_PAD
            .decode(b64)
            .map_err(|_| CryptoError::InvalidEnvelope)?;
        if payload.len() < 28 || payload.len() > MAX_PAYLOAD {
            return Err(CryptoError::InvalidEnvelope);
        }
        // RustCrypto/base64's canonical no-pad decoder also rejects nonzero trailing bits.
        Ok(Self { key_id, payload })
    }
    /// Explicitly encode ciphertext for storage; does not authenticate a parsed input.
    pub fn encode(&self) -> String {
        format!(
            "enc:v2:{}:{}",
            self.key_id.as_str(),
            URL_SAFE_NO_PAD.encode(&self.payload)
        )
    }
    /// Read routing metadata; it is untrusted until successful open.
    pub fn key_id(&self) -> &KeyId {
        &self.key_id
    }
    pub(crate) fn from_payload(key_id: KeyId, payload: Vec<u8>) -> Self {
        Self { key_id, payload }
    }
}
impl fmt::Debug for EncryptedEnvelope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("EncryptedEnvelope")
            .field("version", &"v2")
            .field("payload_bytes", &self.payload.len())
            .finish()
    }
}
