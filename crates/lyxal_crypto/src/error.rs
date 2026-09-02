use thiserror::Error;

/// Erreurs cryptographiques fortement typées du moteur `lyxal_crypto`.
#[derive(Debug, Error)]
pub enum CryptoError {
    #[error("no active encryption key configured")]
    MissingActiveKey,

    #[error("key not found: {key_id}")]
    KeyNotFound { key_id: String },

    #[error("invalid key id format: {0}")]
    InvalidKeyId(String),

    #[error("invalid secret context field: {0}")]
    InvalidContext(String),

    #[error("invalid key length: expected 32 bytes")]
    InvalidKeyLength,

    #[error("invalid key encoding")]
    InvalidKeyEncoding,

    #[error("unsupported envelope version: {version}")]
    UnsupportedVersion { version: String },

    #[error("invalid encrypted envelope")]
    InvalidEnvelope,

    #[error("invalid encrypted payload")]
    InvalidPayload,

    #[error("encryption failed")]
    EncryptionFailed,

    #[error("decryption failed")]
    DecryptionFailed,

    #[error("AAD mismatch or encrypted data corrupted")]
    AuthenticationFailed,

    #[error("key file I/O error: {0}")]
    KeyFileIo(#[from] std::io::Error),

    #[error("legacy value is invalid")]
    InvalidLegacyValue,

    #[error("key generation prohibited by policy")]
    GenerationProhibited,

    #[error("key store lock unavailable or poisoned")]
    KeyStoreUnavailable,
}
