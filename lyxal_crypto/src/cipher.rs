use crate::error::CryptoError;
use crate::key::EncryptionKey;
use aes_gcm::aead::{Aead, KeyInit, Payload};
use aes_gcm::{Aes256Gcm, Nonce};
use rand::RngCore;
use zeroize::Zeroizing;

/// Chiffre un buffer en AES-256-GCM avec un nonce de 12 octets et des données d'authentification AAD.
pub fn encrypt_aes_gcm(key: &EncryptionKey, plaintext: &[u8], aad: &[u8]) -> Result<Vec<u8>, CryptoError> {
    let cipher = Aes256Gcm::new_from_slice(key.expose()).map_err(|_| CryptoError::InvalidKeyLength)?;

    let mut nonce_bytes = [0u8; 12];
    rand::thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);

    let payload = Payload {
        msg: plaintext,
        aad,
    };

    let ciphertext = cipher.encrypt(nonce, payload).map_err(|_| CryptoError::EncryptionFailed)?;

    // Structure du payload enveloppé : Nonce (12B) + Ciphertext (incluant Tag 16B à la fin)
    let mut result = Vec::with_capacity(12 + ciphertext.len());
    result.extend_from_slice(&nonce_bytes);
    result.extend_from_slice(&ciphertext);

    Ok(result)
}

/// Déchiffre un buffer AES-256-GCM et vérifie son tag d'authenticité et son AAD.
pub fn decrypt_aes_gcm(key: &EncryptionKey, payload: &[u8], aad: &[u8]) -> Result<Zeroizing<Vec<u8>>, CryptoError> {
    if payload.len() < 28 {
        return Err(CryptoError::InvalidPayload);
    }

    let cipher = Aes256Gcm::new_from_slice(key.expose()).map_err(|_| CryptoError::InvalidKeyLength)?;

    let (nonce_bytes, ciphertext) = payload.split_at(12);
    let nonce = Nonce::from_slice(nonce_bytes);

    let payload_struct = Payload {
        msg: ciphertext,
        aad,
    };

    let decrypted = cipher.decrypt(nonce, payload_struct).map_err(|_| CryptoError::AuthenticationFailed)?;

    Ok(Zeroizing::new(decrypted))
}
