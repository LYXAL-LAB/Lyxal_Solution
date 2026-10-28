pub mod cipher;
pub mod context;
pub mod envelope;
pub mod error;
pub mod hash;
pub mod hmac;
pub mod kdf;
pub mod key;
pub mod key_resolver;
pub mod password;

pub use context::SecretContext;
pub use envelope::EncryptedEnvelope;
pub use error::CryptoError;
pub use hash::{blake3, blake3_hex, sha256, sha256_hex, Blake3Hasher, Sha256Hasher};
pub use hmac::{
    sign_hmac_sha256, sign_hmac_sha256_hex, verify_hmac_sha256, verify_hmac_sha256_hex,
};
pub use kdf::{hkdf_sha256, hkdf_sha256_32};
pub use key::{EncryptionKey, KeyId};
pub use key_resolver::{
    CompositeKeyResolver, EnvironmentKeyProvider, FileKeyProvider, KeyGenerationPolicy, KeyResolver,
};
pub use password::{hash_password, needs_rehash, verify_password};
pub use zeroize::Zeroizing;

/// Type protégé en mémoire pour les secrets déchiffrés (octets).
pub type SecretBytes = Zeroizing<Vec<u8>>;

/// Type protégé en mémoire pour les secrets déchiffrés (chaîne UTF-8).
pub type SecretString = Zeroizing<String>;

/// Résultat d'une tentative de re-chiffrement pour la rotation de clé.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ReencryptResult {
    /// L'enveloppe utilise déjà la clé active actuelle.
    Current,
    /// L'enveloppe a été ré-empaquetée avec la clé active.
    Rotated(String),
}


/// Moteur principal de chiffrement et déchiffrement de secrets Lyxal OS.
pub struct CryptoEngine<R: KeyResolver> {
    resolver: R,
}

impl<R: KeyResolver> CryptoEngine<R> {
    /// Crée une nouvelle instance de `CryptoEngine` à partir d'un `KeyResolver`.
    pub fn new(resolver: R) -> Self {
        Self { resolver }
    }

    /// Chiffre un secret en utilisant le contexte d'authentification AAD et la clé active.
    pub fn encrypt_secret(
        &self,
        plaintext: &[u8],
        context: &SecretContext,
    ) -> Result<String, CryptoError> {
        let active_id = self.resolver.active_key_id()?;
        let key = self.resolver.resolve(&active_id)?;
        let aad = context.to_aad_bytes();

        let payload = cipher::encrypt_aes_gcm(&key, plaintext, &aad)?;
        let envelope = EncryptedEnvelope::new(active_id, payload);

        Ok(envelope.encode())
    }

    /// Déchiffre une enveloppe en vérifiant le contexte AAD et la clé d'enveloppe spécifiée.
    ///
    /// Conserve strictement la propagation de l'erreur d'enveloppe si le préfixe `enc:` est présent.
    pub fn decrypt_secret(
        &self,
        envelope_str: &str,
        context: &SecretContext,
    ) -> Result<SecretBytes, CryptoError> {
        let trimmed = envelope_str.trim();
        if trimmed.starts_with("enc:") {
            let envelope = EncryptedEnvelope::parse(trimmed)?;
            let key = self.resolver.resolve(&envelope.key_id)?;
            let aad = context.to_aad_bytes();
            cipher::decrypt_aes_gcm(&key, &envelope.payload, &aad)
        } else {
            Err(CryptoError::InvalidEnvelope)
        }
    }

    /// Chiffre un secret de manière non liée (sans contexte AAD spécifique).
    pub fn encrypt_unbound(&self, plaintext: &[u8]) -> Result<String, CryptoError> {
        let active_id = self.resolver.active_key_id()?;
        let key = self.resolver.resolve(&active_id)?;

        let payload = cipher::encrypt_aes_gcm(&key, plaintext, &[])?;
        let envelope = EncryptedEnvelope::new(active_id, payload);

        Ok(envelope.encode())
    }

    /// Déchiffre un secret non lié (sans contexte AAD spécifique).
    pub fn decrypt_unbound(&self, envelope_str: &str) -> Result<SecretBytes, CryptoError> {
        let trimmed = envelope_str.trim();
        if trimmed.starts_with("enc:") {
            let envelope = EncryptedEnvelope::parse(trimmed)?;
            let key = self.resolver.resolve(&envelope.key_id)?;
            cipher::decrypt_aes_gcm(&key, &envelope.payload, &[])
        } else {
            Err(CryptoError::InvalidEnvelope)
        }
    }


    /// Vérifie si l'enveloppe utilise une ancienne clé et la rechiffre avec la clé active si nécessaire.
    pub fn reencrypt_if_needed(
        &self,
        envelope_str: &str,
        context: &SecretContext,
    ) -> Result<ReencryptResult, CryptoError> {
        let envelope = EncryptedEnvelope::parse(envelope_str)?;
        let active_id = self.resolver.active_key_id()?;

        if envelope.key_id == active_id {
            Ok(ReencryptResult::Current)
        } else {
            let decrypted = self.decrypt_secret(envelope_str, context)?;
            let new_envelope = self.encrypt_secret(&decrypted, context)?;
            Ok(ReencryptResult::Rotated(new_envelope))
        }
    }
}
