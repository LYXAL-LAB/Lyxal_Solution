//! Explicit key loading before snapshot construction. No implicit refresh or database IO.
mod environment;
mod file;
use crate::{CryptoError, EncryptionKey, SecretBytes};
use base64::{engine::general_purpose::STANDARD, Engine};
pub use environment::EnvironmentKeyProvider;
pub use file::{FileKeyProvider, KeyGenerationPolicy};
fn decode_key(raw: &[u8]) -> Result<EncryptionKey, CryptoError> {
    if raw.len() != 44 {
        return Err(CryptoError::InvalidKeyEncoding);
    }
    let mut bytes = SecretBytes::zeroed(32)?;
    let len = STANDARD
        .decode_slice(raw, &mut bytes.inner)
        .map_err(|_| CryptoError::InvalidKeyEncoding)?;
    if len != 32 {
        return Err(CryptoError::InvalidKeyLength);
    }
    EncryptionKey::import(bytes)
}
