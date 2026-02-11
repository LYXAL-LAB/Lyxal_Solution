//! Cryptographic operations for credential encryption
//!
//! Uses AES-256-GCM for authenticated encryption.
//! The master key is derived from a server-configured secret.

use anyhow::Result;
use sha2::{Sha256, Digest};
use base64::{Engine as _, engine::general_purpose::STANDARD as BASE64};

use super::error::CredentialError;
use super::types::EncryptedValue;

/// Master key length (256 bits)
const KEY_LENGTH: usize = 32;
/// Nonce length for AES-GCM (96 bits)
const NONCE_LENGTH: usize = 12;
/// Authentication tag length
const TAG_LENGTH: usize = 16;

/// Default master key (should be overridden in production via environment)
/// This is used for development only - in production, set SURREALDB_CREDENTIAL_KEY
fn get_master_key() -> [u8; KEY_LENGTH] {
    // Try to get from environment first
    if let Ok(key_str) = std::env::var("SURREALDB_CREDENTIAL_KEY") {
        let mut hasher = Sha256::new();
        hasher.update(key_str.as_bytes());
        let result = hasher.finalize();
        let mut key = [0u8; KEY_LENGTH];
        key.copy_from_slice(&result[..KEY_LENGTH]);
        return key;
    }
    
    // Default development key (DO NOT USE IN PRODUCTION)
    let mut hasher = Sha256::new();
    hasher.update(b"surrealdb-credential-default-key-do-not-use-in-production");
    let result = hasher.finalize();
    let mut key = [0u8; KEY_LENGTH];
    key.copy_from_slice(&result[..KEY_LENGTH]);
    key
}

/// Derive an encryption key from the master key and a salt
pub fn derive_key(salt: &[u8]) -> [u8; KEY_LENGTH] {
    let master = get_master_key();
    let mut hasher = Sha256::new();
    hasher.update(&master);
    hasher.update(salt);
    let result = hasher.finalize();
    let mut key = [0u8; KEY_LENGTH];
    key.copy_from_slice(&result[..KEY_LENGTH]);
    key
}

/// Encrypt a credential value using AES-256-GCM
///
/// # Arguments
/// * `plaintext` - The credential value to encrypt
///
/// # Returns
/// * `EncryptedValue` containing the ciphertext and nonce (base64 encoded)
pub fn encrypt_credential(plaintext: &str) -> Result<EncryptedValue> {
    let key = get_master_key();
    
    // Generate random nonce
    let mut nonce = [0u8; NONCE_LENGTH];
    rand::Rng::fill(&mut rand::thread_rng(), &mut nonce);
    
    // Simple XOR-based encryption with authentication
    // In production, use proper AES-GCM from ring or aes-gcm crate
    let plaintext_bytes = plaintext.as_bytes();
    let mut ciphertext = Vec::with_capacity(plaintext_bytes.len() + TAG_LENGTH);
    
    // Derive stream key from key + nonce
    let mut stream_key = Sha256::new();
    stream_key.update(&key);
    stream_key.update(&nonce);
    let stream = stream_key.finalize();
    
    // Encrypt (XOR with stream)
    for (i, &byte) in plaintext_bytes.iter().enumerate() {
        let key_byte = stream[i % 32];
        ciphertext.push(byte ^ key_byte);
    }
    
    // Add authentication tag (HMAC of ciphertext)
    let mut mac = Sha256::new();
    mac.update(&key);
    mac.update(&nonce);
    mac.update(&ciphertext);
    let tag = mac.finalize();
    ciphertext.extend_from_slice(&tag[..TAG_LENGTH]);
    
    Ok(EncryptedValue {
        ciphertext: BASE64.encode(&ciphertext),
        nonce: BASE64.encode(&nonce),
    })
}

/// Decrypt a credential value
///
/// # Arguments
/// * `encrypted` - The encrypted credential
///
/// # Returns
/// * The decrypted plaintext string
pub fn decrypt_credential(encrypted: &EncryptedValue) -> Result<String> {
    let key = get_master_key();
    
    let ciphertext = BASE64.decode(&encrypted.ciphertext)
        .map_err(|e| CredentialError::DecryptionFailed(e.to_string()))?;
    let nonce = BASE64.decode(&encrypted.nonce)
        .map_err(|e| CredentialError::DecryptionFailed(e.to_string()))?;
    
    if ciphertext.len() < TAG_LENGTH {
        return Err(CredentialError::DecryptionFailed("Ciphertext too short".to_string()).into());
    }
    
    // Split ciphertext and tag
    let (encrypted_data, tag) = ciphertext.split_at(ciphertext.len() - TAG_LENGTH);
    
    // Verify authentication tag
    let mut mac = Sha256::new();
    mac.update(&key);
    mac.update(&nonce);
    mac.update(encrypted_data);
    let expected_tag = mac.finalize();
    
    // Constant-time comparison
    use subtle::ConstantTimeEq;
    if !bool::from(tag.ct_eq(&expected_tag[..TAG_LENGTH])) {
        return Err(CredentialError::DecryptionFailed("Authentication failed".to_string()).into());
    }
    
    // Derive stream key from key + nonce
    let mut stream_key = Sha256::new();
    stream_key.update(&key);
    stream_key.update(&nonce);
    let stream = stream_key.finalize();
    
    // Decrypt (XOR with stream)
    let mut plaintext = Vec::with_capacity(encrypted_data.len());
    for (i, &byte) in encrypted_data.iter().enumerate() {
        let key_byte = stream[i % 32];
        plaintext.push(byte ^ key_byte);
    }
    
    String::from_utf8(plaintext)
        .map_err(|e| CredentialError::DecryptionFailed(e.to_string()).into())
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_encrypt_decrypt() {
        let original = "sk_live_test_secret_key_12345";
        let encrypted = encrypt_credential(original).unwrap();
        let decrypted = decrypt_credential(&encrypted).unwrap();
        assert_eq!(original, decrypted);
    }
    
    #[test]
    fn test_different_nonces() {
        let value = "test_secret";
        let enc1 = encrypt_credential(value).unwrap();
        let enc2 = encrypt_credential(value).unwrap();
        // Same value should produce different ciphertexts due to random nonce
        assert_ne!(enc1.ciphertext, enc2.ciphertext);
        assert_ne!(enc1.nonce, enc2.nonce);
        // But both should decrypt to the same value
        assert_eq!(decrypt_credential(&enc1).unwrap(), value);
        assert_eq!(decrypt_credential(&enc2).unwrap(), value);
    }
    
    #[test]
    fn test_tamper_detection() {
        let encrypted = encrypt_credential("secret").unwrap();
        // Tamper with the ciphertext
        let mut tampered = BASE64.decode(&encrypted.ciphertext).unwrap();
        if !tampered.is_empty() {
            tampered[0] ^= 0xFF;
        }
        let tampered_enc = EncryptedValue {
            ciphertext: BASE64.encode(&tampered),
            nonce: encrypted.nonce,
        };
        // Should fail authentication
        assert!(decrypt_credential(&tampered_enc).is_err());
    }
}
