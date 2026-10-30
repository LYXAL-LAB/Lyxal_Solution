#![forbid(unsafe_code)]
#![deny(missing_docs)]
#![doc = include_str!("../README.md")]
//! Lyxal cryptographic foundation. Production API V1 uses the enc:v2 protocol.
//! Secret access is explicit; no database, scheduler or runtime dependency.
pub mod error;
pub mod hash;
pub mod key;
pub mod secret;
pub use error::{ContextField, CryptoError, IoOperation};
pub use hash::{blake3, blake3_hex, sha256, sha256_hex, Blake3Hasher, Sha256Hasher};
pub use key::{EncryptionKey, HmacKey, KeyId};
pub use secret::{SecretBytes, SecretString, MAX_SECRET_BYTES};

mod cipher;
pub mod context;
pub mod envelope;
pub use context::SecretContext;
pub use envelope::{EncryptedEnvelope, MAX_ENVELOPE_BYTES};

pub mod key_resolver;
pub use key_resolver::{
    KeyResolver, KeyRing, KeyRingBuilder, KeyState, KeyUse, ResolvedKey, StaticKeyResolver,
    MAX_KEY_IDS,
};

/// Result of authenticated rotation, relative to the one captured snapshot.
#[derive(Debug)]
pub enum ReencryptResult {
    /// The envelope authenticated correctly under this snapshot's active key.
    Current,
    /// Authenticated plaintext was re-sealed with the captured active key.
    Rotated(EncryptedEnvelope),
}
/// Application cryptography. No distributed nonce quota, identity authorization or remote revocation.
pub struct CryptoEngine<R: KeyResolver> {
    resolver: R,
}
impl<R: KeyResolver> CryptoEngine<R> {
    /// Use a host-managed or static snapshot source.
    pub fn new(resolver: R) -> Self {
        Self { resolver }
    }
    /// Seal in exactly one snapshot, with fresh OS randomness and authenticated metadata.
    pub fn seal(
        &self,
        secret: &SecretBytes,
        context: &SecretContext,
    ) -> Result<EncryptedEnvelope, CryptoError> {
        let snapshot = self.resolver.snapshot()?;
        Self::seal_in(&snapshot, secret, context)
    }
    fn seal_in(
        snapshot: &KeyRing,
        secret: &SecretBytes,
        context: &SecretContext,
    ) -> Result<EncryptedEnvelope, CryptoError> {
        let active = snapshot.active()?;
        let aad = context.aad(&active.id);
        let payload = cipher::encrypt_aes_gcm(&active.key, secret.expose_secret(), &aad)?;
        Ok(EncryptedEnvelope::from_payload(active.id, payload))
    }
    /// Authenticate before exposing any plaintext. No fallback between domains or versions.
    pub fn open(
        &self,
        envelope: &EncryptedEnvelope,
        context: &SecretContext,
    ) -> Result<SecretBytes, CryptoError> {
        let snapshot = self.resolver.snapshot()?;
        Self::open_in(&snapshot, envelope, context)
    }
    fn open_in(
        snapshot: &KeyRing,
        envelope: &EncryptedEnvelope,
        context: &SecretContext,
    ) -> Result<SecretBytes, CryptoError> {
        let key = snapshot.resolve(envelope.key_id())?;
        cipher::decrypt_aes_gcm(&key, &envelope.payload, &context.aad(envelope.key_id()))
    }
    /// Authenticate ALWAYS, including the Current branch. Capture source and target once.
    pub fn reencrypt_if_needed(
        &self,
        envelope: &EncryptedEnvelope,
        context: &SecretContext,
    ) -> Result<ReencryptResult, CryptoError> {
        let snapshot = self.resolver.snapshot()?;
        let plaintext = Self::open_in(&snapshot, envelope, context)?;
        if envelope.key_id() == snapshot.active_id() {
            Ok(ReencryptResult::Current)
        } else {
            Ok(ReencryptResult::Rotated(Self::seal_in(
                &snapshot, &plaintext, context,
            )?))
        }
    }
}

pub mod providers;
pub use providers::{EnvironmentKeyProvider, FileKeyProvider, KeyGenerationPolicy};

pub mod hmac;
pub mod kdf;
pub mod password;
pub use hmac::{
    sign_hmac_sha256, sign_hmac_sha256_hex, verify_hmac_sha256, verify_hmac_sha256_hex,
};
pub use kdf::hkdf_sha256;
pub use password::{
    hash_password, verify_password, PasswordHash, PasswordVerification, MAX_PASSWORD_BYTES,
    MAX_PHC_BYTES,
};
