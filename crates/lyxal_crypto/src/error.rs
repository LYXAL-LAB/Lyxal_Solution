//! Structured diagnostics deliberately contain no caller-controlled strings.
use std::io::ErrorKind;
use thiserror::Error;

/// The invalid part of a cryptographic context (never its value).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ContextField {
    /// Tenant identity.
    Tenant,
    /// Module name.
    Module,
    /// Resource kind.
    Resource,
    /// Exact record identity.
    RecordId,
    /// Encrypted field.
    Field,
    /// Global infrastructure purpose.
    Purpose,
}
/// Non-secret storage phase for diagnosis without disclosing paths.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IoOperation {
    /// Inspect file metadata.
    Metadata,
    /// Open an existing object.
    Open,
    /// Read bounded bytes.
    Read,
    /// Create an exclusive temporary file.
    Create,
    /// Write complete protected bytes.
    Write,
    /// Synchronize file contents.
    SyncFile,
    /// Publish without replacement.
    Publish,
    /// Synchronize namespace changes.
    SyncDirectory,
    /// Remove only owned temporary state.
    Cleanup,
}
/// Failures never carry plaintext, PHC strings, keys, paths or raw OS errors.
#[derive(Debug, Error, PartialEq, Eq)]
#[non_exhaustive]
pub enum CryptoError {
    #[doc = "invalid key identifier"]
    #[error("invalid key identifier")]
    InvalidKeyId,
    #[doc = "expected a 32-byte key"]
    #[error("expected a 32-byte key")]
    InvalidKeyLength,
    #[doc = "invalid key encoding"]
    #[error("invalid key encoding")]
    InvalidKeyEncoding,
    #[doc = "duplicate key identifier"]
    #[error("duplicate key identifier")]
    DuplicateKeyId,
    #[doc = "no active key"]
    #[error("no active key")]
    MissingActiveKey,
    #[doc = "multiple active keys"]
    #[error("multiple active keys")]
    MultipleActiveKeys,
    #[doc = "activate another key before revocation"]
    #[error("activate another key before revocation")]
    ActiveKeyRevocation,
    #[doc = "key material substitution prohibited"]
    #[error("key material substitution prohibited")]
    KeySubstitution,
    #[doc = "invalid snapshot transition"]
    #[error("invalid snapshot transition")]
    InvalidSnapshotTransition,
    #[doc = "key unavailable"]
    #[error("key unavailable")]
    KeyUnavailable,
    #[doc = "key revoked"]
    #[error("key revoked")]
    KeyRevoked,
    #[doc = "invalid context field: {0:?}"]
    #[error("invalid context field: {0:?}")]
    InvalidContextField(ContextField),
    #[doc = "input exceeds resource limit"]
    #[error("input exceeds resource limit")]
    InputTooLarge,
    #[doc = "key store capacity exceeded"]
    #[error("key store capacity exceeded")]
    KeyStoreUnavailable,
    #[doc = "unsupported envelope version"]
    #[error("unsupported envelope version")]
    UnsupportedVersion,
    #[doc = "invalid encrypted envelope"]
    #[error("invalid encrypted envelope")]
    InvalidEnvelope,
    #[doc = "authentication failed"]
    #[error("authentication failed")]
    AuthenticationFailed,
    #[doc = "cryptographic operation failed"]
    #[error("cryptographic operation failed")]
    EncryptionFailed,
    #[doc = "system random generator unavailable"]
    #[error("system random generator unavailable")]
    RandomUnavailable,
    #[doc = "invalid UTF-8 secret"]
    #[error("invalid UTF-8 secret")]
    InvalidUtf8,
    #[doc = "invalid password hash"]
    #[error("invalid password hash")]
    InvalidPasswordHash,
    #[doc = "password cost exceeds budget"]
    #[error("password cost exceeds budget")]
    PasswordCostExceeded,
    #[doc = "password hashing failed"]
    #[error("password hashing failed")]
    PasswordHashFailed,
    #[doc = "HKDF failed"]
    #[error("HKDF failed")]
    HkdfFailed,
    #[doc = "invalid authentication tag encoding"]
    #[error("invalid authentication tag encoding")]
    InvalidTagEncoding,
    #[doc = "insecure key storage"]
    #[error("insecure key storage")]
    InsecureKeyFile,
    #[doc = "unsupported storage profile"]
    #[error("unsupported storage profile")]
    UnsupportedStorage,
    #[doc = "key durability uncertain at {0:?}: {1:?}"]
    #[error("key durability uncertain at {0:?}: {1:?}")]
    DurabilityUncertain(IoOperation, ErrorKind),
    #[doc = "key published but cleanup failed at {0:?}: {1:?}"]
    #[error("key published but cleanup failed at {0:?}: {1:?}")]
    CleanupFailed(IoOperation, ErrorKind),
    #[doc = "storage operation failed at {0:?}: {1:?}"]
    #[error("storage operation failed at {0:?}: {1:?}")]
    Io(IoOperation, ErrorKind),
    #[doc = "allocation failed"]
    #[error("allocation failed")]
    AllocationFailed,
}
