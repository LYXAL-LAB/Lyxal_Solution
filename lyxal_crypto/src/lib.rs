pub mod cipher;
pub mod context;
pub mod envelope;
pub mod error;
pub mod key;
pub mod key_resolver;

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
pub use context::SecretContext;
pub use envelope::EncryptedEnvelope;
pub use error::CryptoError;
pub use key::{EncryptionKey, KeyId};
pub use key_resolver::{
    CompositeKeyResolver, EnvironmentKeyProvider, FileKeyProvider, KeyGenerationPolicy, KeyResolver,
};
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

/// Décode et valide une chaîne legacy Cal.rs (qui était l'encodage hex de la chaîne UTF-8 en clair).
///
/// Valide l'UTF-8 de manière zéro-copie sans créer de String temporaire non protégée.
pub fn decode_calrs_legacy_hex(stored_hex: &str) -> Result<SecretBytes, CryptoError> {
    let bytes = hex::decode(stored_hex.trim()).map_err(|_| CryptoError::InvalidLegacyValue)?;
    std::str::from_utf8(&bytes).map_err(|_| CryptoError::InvalidLegacyValue)?;
    Ok(Zeroizing::new(bytes))
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
    pub fn encrypt_secret(&self, plaintext: &[u8], context: &SecretContext) -> Result<String, CryptoError> {
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
    pub fn decrypt_secret(&self, envelope_str: &str, context: &SecretContext) -> Result<SecretBytes, CryptoError> {
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

    /// Déchiffre un secret legacy Cal.rs au format Base64 brut AES-256-GCM (sans enveloppe ni AAD) à l'aide de l'ancienne clé.
    pub fn decrypt_calrs_aes_base64(&self, legacy_key: &EncryptionKey, stored_b64: &str) -> Result<SecretBytes, CryptoError> {
        let payload = Zeroizing::new(
            STANDARD
                .decode(stored_b64.trim())
                .map_err(|_| CryptoError::InvalidLegacyValue)?,
        );
        cipher::decrypt_aes_gcm(legacy_key, &payload, &[])
    }

    /// Migre un secret legacy Cal.rs au format Base64 brut AES-256-GCM vers l'enveloppe moderne enc:v1 avec AAD et la clé active.
    pub fn migrate_calrs_aes_base64(&self, legacy_key: &EncryptionKey, stored_b64: &str, context: &SecretContext) -> Result<String, CryptoError> {
        let plaintext = self.decrypt_calrs_aes_base64(legacy_key, stored_b64)?;
        self.encrypt_secret(&plaintext, context)
    }

    /// Migre un ancien secret legacy Cal.rs (hex de la chaîne en clair) vers le format d'enveloppe AES-256-GCM v1.
    pub fn migrate_legacy_calrs_hex(&self, stored_hex: &str, context: &SecretContext) -> Result<String, CryptoError> {
        let plaintext = decode_calrs_legacy_hex(stored_hex)?;
        self.encrypt_secret(&plaintext, context)
    }

    /// Vérifie si l'enveloppe utilise une ancienne clé et la rechiffre avec la clé active si nécessaire.
    pub fn reencrypt_if_needed(&self, envelope_str: &str, context: &SecretContext) -> Result<ReencryptResult, CryptoError> {
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
