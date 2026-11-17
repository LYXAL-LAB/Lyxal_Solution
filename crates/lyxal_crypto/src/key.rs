//! Exact key identities and two deliberately distinct secret key types.
use crate::{CryptoError, SecretBytes};
use rand_core::{CryptoRng, OsRng, RngCore};
use std::fmt;
use zeroize::{ZeroizeOnDrop, Zeroizing};

/// Case-sensitive ASCII identifier, validated without trimming; never a file path.
#[derive(Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct KeyId(String);
impl KeyId {
    /// Accept exactly `[A-Za-z0-9._-]{1,64}`, without echoing rejected input.
    pub fn parse(input: &str) -> Result<Self, CryptoError> {
        if input.is_empty()
            || input.len() > 64
            || !input
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"._-".contains(&b))
        {
            return Err(CryptoError::InvalidKeyId);
        }
        Ok(Self(input.to_owned()))
    }
    /// Read the validated, non-secret ID.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}
impl fmt::Debug for KeyId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_tuple("KeyId").field(&self.0).finish()
    }
}
impl fmt::Display for KeyId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}
fn random_key(rng: &mut (impl CryptoRng + RngCore)) -> Result<Zeroizing<[u8; 32]>, CryptoError> {
    let mut bytes = Zeroizing::new([0; 32]);
    rng.try_fill_bytes(bytes.as_mut())
        .map_err(|_| CryptoError::RandomUnavailable)?;
    Ok(bytes)
}
fn import_key(secret: SecretBytes) -> Result<Zeroizing<[u8; 32]>, CryptoError> {
    if secret.len() != 32 {
        return Err(CryptoError::InvalidKeyLength);
    }
    let mut bytes = Zeroizing::new([0; 32]);
    bytes.copy_from_slice(secret.expose_secret());
    Ok(bytes)
}
/// AES-256 key. No public raw export, cloning, implicit conversions or serialization.
///
/// ```compile_fail
/// use lyxal_crypto::EncryptionKey;
/// let key = EncryptionKey::generate().unwrap();
/// let duplicate = key.clone();
/// ```
pub struct EncryptionKey {
    bytes: Zeroizing<[u8; 32]>,
}
impl EncryptionKey {
    /// Import exactly 32 owned bytes; the source is wiped on every return path.
    pub fn import(secret: SecretBytes) -> Result<Self, CryptoError> {
        Ok(Self {
            bytes: import_key(secret)?,
        })
    }
    /// Generate using the fallible OS CSPRNG.
    pub fn generate() -> Result<Self, CryptoError> {
        Ok(Self {
            bytes: random_key(&mut OsRng)?,
        })
    }
    pub(crate) fn expose(&self) -> &[u8; 32] {
        &self.bytes
    }
}
impl fmt::Debug for EncryptionKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("EncryptionKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for EncryptionKey {}
/// HMAC key, deliberately not interchangeable with an AES key.
pub struct HmacKey {
    bytes: Zeroizing<[u8; 32]>,
}
impl HmacKey {
    /// Import exactly 32 owned bytes, wiping the input afterward.
    pub fn import(secret: SecretBytes) -> Result<Self, CryptoError> {
        Ok(Self {
            bytes: import_key(secret)?,
        })
    }
    /// Generate a 256-bit key or return an RNG error.
    pub fn generate() -> Result<Self, CryptoError> {
        Ok(Self {
            bytes: random_key(&mut OsRng)?,
        })
    }
    pub(crate) fn expose(&self) -> &[u8; 32] {
        &self.bytes
    }
}
impl fmt::Debug for HmacKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("HmacKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for HmacKey {}

/// Largest external HMAC key accepted, in bytes.
pub const MAX_EXTERNAL_HMAC_KEY_BYTES: usize = 1024;

/// HMAC key imposed by a third-party protocol (webhook signing secret of a provider), used
/// exactly as given, whatever its length (1 to 1024 bytes; RFC 2104 applies the padding or
/// hashing itself). Distinct from `HmacKey`: it is only imported, never generated, and never
/// mixed with the platform's own 256-bit keys.
pub struct ExternalHmacKey {
    bytes: SecretBytes,
}
impl ExternalHmacKey {
    /// Import 1 to `MAX_EXTERNAL_HMAC_KEY_BYTES` owned bytes, without padding or derivation.
    pub fn import(secret: SecretBytes) -> Result<Self, CryptoError> {
        if secret.is_empty() || secret.len() > MAX_EXTERNAL_HMAC_KEY_BYTES {
            return Err(CryptoError::InvalidKeyLength);
        }
        Ok(Self { bytes: secret })
    }
    pub(crate) fn expose(&self) -> &[u8] {
        self.bytes.expose_secret()
    }
}
impl fmt::Debug for ExternalHmacKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("ExternalHmacKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for ExternalHmacKey {}

#[cfg(test)]
pub(crate) mod tests {
    use super::*;
    pub(crate) struct FailedRandom;
    impl CryptoRng for FailedRandom {}
    impl RngCore for FailedRandom {
        fn next_u32(&mut self) -> u32 {
            panic!("infallible path forbidden")
        }
        fn next_u64(&mut self) -> u64 {
            panic!("infallible path forbidden")
        }
        fn fill_bytes(&mut self, _: &mut [u8]) {
            panic!("infallible path forbidden")
        }
        fn try_fill_bytes(&mut self, bytes: &mut [u8]) -> Result<(), rand_core::Error> {
            bytes.fill(0x41);
            Err(rand_core::Error::from(
                std::num::NonZeroU32::new(rand_core::Error::CUSTOM_START).unwrap(),
            ))
        }
    }
    #[test]
    fn partially_filled_rng_error_is_propagated() {
        assert!(matches!(
            random_key(&mut FailedRandom),
            Err(CryptoError::RandomUnavailable)
        ));
    }
}
