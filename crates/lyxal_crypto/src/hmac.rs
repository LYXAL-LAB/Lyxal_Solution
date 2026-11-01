//! HMAC-SHA256 with distinct 256-bit keys and constant-time tag verification.
use crate::{CryptoError, HmacKey};
use hmac::{Hmac, Mac};
use sha2::Sha256;
type HmacSha256 = Hmac<Sha256>;
pub(crate) fn sign_bytes(key: &[u8], data: &[u8]) -> Result<[u8; 32], CryptoError> {
    let mut mac = HmacSha256::new_from_slice(key).map_err(|_| CryptoError::InvalidKeyLength)?;
    mac.update(data);
    Ok(mac.finalize().into_bytes().into())
}
pub(crate) fn verify_bytes(key: &[u8], data: &[u8], tag: &[u8]) -> Result<bool, CryptoError> {
    if tag.len() != 32 {
        return Err(CryptoError::InvalidTagEncoding);
    }
    let mut mac = HmacSha256::new_from_slice(key).map_err(|_| CryptoError::InvalidKeyLength)?;
    mac.update(data);
    Ok(mac.verify_slice(tag).is_ok())
}
/// Sign arbitrary bytes; caller controls admission and message-stream budgets.
pub fn sign_hmac_sha256(key: &HmacKey, data: &[u8]) -> Result<[u8; 32], CryptoError> {
    sign_bytes(key.expose(), data)
}
/// Verify exactly 32 tag bytes. Mismatch is false; malformed length is an error.
pub fn verify_hmac_sha256(key: &HmacKey, data: &[u8], tag: &[u8]) -> Result<bool, CryptoError> {
    verify_bytes(key.expose(), data, tag)
}
/// Explicit lowercase hex encoding of an authentication tag.
pub fn sign_hmac_sha256_hex(key: &HmacKey, data: &[u8]) -> Result<String, CryptoError> {
    Ok(hex::encode(sign_hmac_sha256(key, data)?))
}
/// Verify exactly 64 hex characters without trimming or input-sized allocation.
pub fn verify_hmac_sha256_hex(
    key: &HmacKey,
    data: &[u8],
    encoded: &str,
) -> Result<bool, CryptoError> {
    if encoded.len() != 64 {
        return Err(CryptoError::InvalidTagEncoding);
    }
    let mut tag = [0; 32];
    hex::decode_to_slice(encoded, &mut tag).map_err(|_| CryptoError::InvalidTagEncoding)?;
    verify_hmac_sha256(key, data, &tag)
}
#[cfg(test)]
mod vectors {
    include!("hmac_vectors.rs");
}
