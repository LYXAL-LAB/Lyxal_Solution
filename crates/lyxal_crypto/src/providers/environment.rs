use super::decode_key;
use crate::{CryptoError, KeyId, ResolvedKey};
use std::sync::Arc;
use zeroize::Zeroizing;
/// Loads a single canonical Base64 key; does not reload or erase the process environment.
pub struct EnvironmentKeyProvider;
impl EnvironmentKeyProvider {
    /// Read exactly 44 canonical Base64 characters for 32 bytes, without trimming.
    /// The variable itself is owned by the host; borrowed/copies outside this call are not wiped.
    pub fn load(env_var: &str, id: KeyId) -> Result<ResolvedKey, CryptoError> {
        if env_var.is_empty() || env_var.bytes().any(|b| b == 0 || b == b'=') {
            return Err(CryptoError::KeyUnavailable);
        }
        // Protect even a non-Unicode OS value. std::env::var would leave its
        // VarError::NotUnicode(OsString) allocation unprotected on that error path.
        let value = std::env::var_os(env_var).ok_or(CryptoError::KeyUnavailable)?;
        let bytes = Zeroizing::new(value.into_encoded_bytes());
        std::str::from_utf8(&bytes).map_err(|_| CryptoError::KeyUnavailable)?;
        let key = decode_key(&bytes)?;
        Ok(ResolvedKey::new(id, Arc::new(key)))
    }
}
