//! Credential error types

use thiserror::Error;

#[derive(Debug, Error)]
pub enum CredentialError {
    #[error("Encryption failed: {0}")]
    EncryptionFailed(String),
    
    #[error("Decryption failed: {0}")]
    DecryptionFailed(String),
    
    #[error("Invalid key length")]
    InvalidKeyLength,
    
    #[error("Credential not found: {name}")]
    NotFound { name: String },
    
    #[error("Credential type mismatch: expected {expected}, got {actual}")]
    TypeMismatch { expected: String, actual: String },
    
    #[error("Master key not configured")]
    MasterKeyNotConfigured,
}

