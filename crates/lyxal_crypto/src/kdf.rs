use crate::error::CryptoError;
use hkdf::Hkdf;
use sha2::Sha256;
use zeroize::Zeroizing;

/// Dérive une clé cryptographique de longueur arbitraire via HKDF-SHA256 (RFC 5869).
pub fn hkdf_sha256(
    ikm: &[u8],
    salt: Option<&[u8]>,
    info: &[u8],
    output: &mut [u8],
) -> Result<(), CryptoError> {
    let hk = Hkdf::<Sha256>::new(salt, ikm);
    hk.expand(info, output).map_err(|_| CryptoError::HkdfError)
}

/// Dérive une clé cryptographique de 32 octets (256 bits) protégée en mémoire (`Zeroizing`) via HKDF-SHA256.
pub fn hkdf_sha256_32(
    ikm: &[u8],
    salt: Option<&[u8]>,
    info: &[u8],
) -> Result<Zeroizing<[u8; 32]>, CryptoError> {
    let mut okm = [0u8; 32];
    hkdf_sha256(ikm, salt, info, &mut okm)?;
    Ok(Zeroizing::new(okm))
}
