//! HKDF is for high-entropy key material, never for hashing human passwords.
use crate::{CryptoError, SecretBytes};
use hkdf::Hkdf;
use sha2::Sha256;
/// Derive a protected allocation (1..=8160 bytes), with explicit nonempty domain info.
/// The caller supplies sufficiently random IKM and admission for the borrowed salt.
pub fn hkdf_sha256(
    ikm: &SecretBytes,
    salt: Option<&[u8]>,
    info: &[u8],
    len: usize,
) -> Result<SecretBytes, CryptoError> {
    if len == 0 || len > 255 * 32 || info.is_empty() || info.len() > 1024 {
        return Err(CryptoError::HkdfFailed);
    }
    let mut output = SecretBytes::zeroed(len)?;
    Hkdf::<Sha256>::new(salt, ikm.expose_secret())
        .expand(info, &mut output.inner)
        .map_err(|_| CryptoError::HkdfFailed)?;
    Ok(output)
}
