//! Opaque owners. Explicit exposure is an intentional escape from log protection.
use crate::CryptoError;
use std::fmt;
use zeroize::{ZeroizeOnDrop, Zeroizing};

/// Maximum length AND retained capacity of an owned application secret.
pub const MAX_SECRET_BYTES: usize = 1_048_576;
/// Bytes wiped on destruction; deliberately neither dereferenceable nor clonable.
///
/// ```compile_fail
/// use lyxal_crypto::SecretBytes;
/// let s = SecretBytes::new(vec![1]).unwrap();
/// let leaked: &[u8] = s.as_ref();
/// ```
/// ```compile_fail
/// use lyxal_crypto::SecretBytes;
/// let s = SecretBytes::new(vec![1]).unwrap();
/// let duplicate = s.clone();
/// ```
/// ```compile_fail
/// use lyxal_crypto::SecretBytes;
/// let s = SecretBytes::new(vec![1]).unwrap();
/// println!("{}", s);
/// ```
pub struct SecretBytes {
    pub(crate) inner: Zeroizing<Vec<u8>>,
}
impl SecretBytes {
    /// Adopt the allocation. Also wipes oversized owned buffers on rejection.
    pub fn new(bytes: Vec<u8>) -> Result<Self, CryptoError> {
        let inner = Zeroizing::new(bytes);
        if inner.len() > MAX_SECRET_BYTES || inner.capacity() > MAX_SECRET_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        Ok(Self { inner })
    }
    /// Deliberate borrowed plaintext access; copies made by callers are their responsibility.
    pub fn expose_secret(&self) -> &[u8] {
        &self.inner
    }
    /// Length in bytes, not a diagnostic representation of the contents.
    pub fn len(&self) -> usize {
        self.inner.len()
    }
    /// Whether the protected value is empty.
    pub fn is_empty(&self) -> bool {
        self.inner.is_empty()
    }
    /// Transfer the allocation into a UTF-8 owner. Invalid bytes are wiped on error.
    pub fn into_utf8(mut self) -> Result<SecretString, CryptoError> {
        let raw = std::mem::take(&mut *self.inner);
        match String::from_utf8(raw) {
            Ok(text) => SecretString::new(text),
            Err(err) => {
                let _wipe = Zeroizing::new(err.into_bytes());
                Err(CryptoError::InvalidUtf8)
            }
        }
    }
    pub(crate) fn zeroed(len: usize) -> Result<Self, CryptoError> {
        if len > MAX_SECRET_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        let mut inner = Zeroizing::new(Vec::new());
        inner
            .try_reserve_exact(len)
            .map_err(|_| CryptoError::AllocationFailed)?;
        inner.resize(len, 0);
        Ok(Self { inner })
    }
}
impl fmt::Debug for SecretBytes {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("SecretBytes([REDACTED])")
    }
}
impl ZeroizeOnDrop for SecretBytes {}

/// UTF-8 owner with named access and redacted diagnostics.
///
/// ```compile_fail
/// use lyxal_crypto::SecretString;
/// let s = SecretString::new("secret".into()).unwrap();
/// let raw: String = s.into();
/// ```
/// ```compile_fail
/// use lyxal_crypto::SecretString;
/// let s = SecretString::new("secret".into()).unwrap();
/// let raw: &str = &*s;
/// ```
pub struct SecretString {
    pub(crate) inner: Zeroizing<String>,
}
impl SecretString {
    /// Adopt an allocation; original copies made by the caller cannot be wiped here.
    pub fn new(text: String) -> Result<Self, CryptoError> {
        let inner = Zeroizing::new(text);
        if inner.len() > MAX_SECRET_BYTES || inner.capacity() > MAX_SECRET_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        Ok(Self { inner })
    }
    /// Explicit borrowed exposure of the plaintext.
    pub fn expose_secret(&self) -> &str {
        &self.inner
    }
    /// Length in UTF-8 bytes.
    pub fn len(&self) -> usize {
        self.inner.len()
    }
    /// Whether this value is empty.
    pub fn is_empty(&self) -> bool {
        self.inner.is_empty()
    }
    /// Transfer the same allocation to a protected byte owner.
    pub fn into_bytes(mut self) -> SecretBytes {
        SecretBytes {
            inner: Zeroizing::new(std::mem::take(&mut *self.inner).into_bytes()),
        }
    }
}
impl fmt::Debug for SecretString {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("SecretString([REDACTED])")
    }
}
impl ZeroizeOnDrop for SecretString {}
