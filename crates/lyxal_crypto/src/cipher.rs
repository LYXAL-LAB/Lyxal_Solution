//! Private AEAD operations. Raw nonces and keys are not part of the public API.
use crate::{CryptoError, EncryptionKey, SecretBytes, MAX_SECRET_BYTES};
use aes_gcm::{
    aead::{AeadInPlace, KeyInit},
    Aes256Gcm, Nonce, Tag,
};
use rand_core::{CryptoRng, OsRng, RngCore};
fn nonce_with(rng: &mut (impl RngCore + CryptoRng)) -> Result<[u8; 12], CryptoError> {
    let mut nonce = [0; 12];
    rng.try_fill_bytes(&mut nonce)
        .map_err(|_| CryptoError::RandomUnavailable)?;
    Ok(nonce)
}
pub(crate) fn encrypt_aes_gcm(
    key: &EncryptionKey,
    plaintext: &[u8],
    aad: &[u8],
) -> Result<Vec<u8>, CryptoError> {
    if plaintext.len() > MAX_SECRET_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let cipher =
        Aes256Gcm::new_from_slice(key.expose()).map_err(|_| CryptoError::EncryptionFailed)?;
    let nonce_bytes = nonce_with(&mut OsRng)?;
    let mut buffer = SecretBytes::zeroed(plaintext.len())?;
    buffer.inner.copy_from_slice(plaintext);
    let tag = cipher
        .encrypt_in_place_detached(&Nonce::from(nonce_bytes), aad, &mut buffer.inner)
        .map_err(|_| CryptoError::EncryptionFailed)?;
    let mut payload = Vec::new();
    payload
        .try_reserve_exact(plaintext.len() + 28)
        .map_err(|_| CryptoError::AllocationFailed)?;
    payload.extend_from_slice(&nonce_bytes);
    payload.extend_from_slice(buffer.expose_secret());
    payload.extend_from_slice(&tag);
    Ok(payload)
}
pub(crate) fn decrypt_aes_gcm(
    key: &EncryptionKey,
    payload: &[u8],
    aad: &[u8],
) -> Result<SecretBytes, CryptoError> {
    if payload.len() < 28 || payload.len() > MAX_SECRET_BYTES + 28 {
        return Err(CryptoError::InvalidEnvelope);
    }
    let cipher =
        Aes256Gcm::new_from_slice(key.expose()).map_err(|_| CryptoError::EncryptionFailed)?;
    let nonce: [u8; 12] = payload[..12]
        .try_into()
        .map_err(|_| CryptoError::InvalidEnvelope)?;
    let end = payload.len() - 16;
    let tag: [u8; 16] = payload[end..]
        .try_into()
        .map_err(|_| CryptoError::InvalidEnvelope)?;
    let mut buffer = SecretBytes::zeroed(end - 12)?;
    buffer.inner.copy_from_slice(&payload[12..end]);
    cipher
        .decrypt_in_place_detached(&Nonce::from(nonce), aad, &mut buffer.inner, &Tag::from(tag))
        .map_err(|_| CryptoError::AuthenticationFailed)?;
    Ok(buffer)
}
#[cfg(test)]
mod vectors {
    include!("cipher_vectors.rs");
}

#[cfg(test)]
mod rng_tests {
    #[test]
    fn nonce_rng_failure_has_no_infallible_fallback() {
        assert!(matches!(
            super::nonce_with(&mut crate::key::tests::FailedRandom),
            Err(crate::CryptoError::RandomUnavailable)
        ));
    }
}
