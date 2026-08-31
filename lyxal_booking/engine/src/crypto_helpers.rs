use lyxal_crypto::{CryptoError, SecretContext};
use surrealdb::RecordId;

pub type BookingKeyResolver = std::sync::Arc<dyn lyxal_crypto::KeyResolver>;
pub type BookingCryptoEngine = lyxal_crypto::CryptoEngine<BookingKeyResolver>;

/// Contexte d'authentification pour les mots de passe de sources CalDAV / CardDAV (`booking_caldav_source`).
pub fn caldav_password_context(tenant: &str, source_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_caldav_source", source_id.to_string(), "password")
}

/// Contexte d'authentification pour les jetons d'accès et de rafraîchissement OAuth stockés directement sur `booking_caldav_source`.
pub fn caldav_oauth_token_context(tenant: &str, source_id: &RecordId, field: &str) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_caldav_source", source_id.to_string(), field)
}

/// Contexte d'authentification pour les tokens OAuth autonomes (`booking_oauth_token`).
pub fn oauth_token_context(tenant: &str, token_id: &RecordId, field: &str) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_oauth_token", token_id.to_string(), field)
}

/// Contexte d'authentification pour les secrets client des fournisseurs OAuth (`booking_setting`).
pub fn oauth_provider_context(tenant: &str, provider_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", provider_id.to_string(), "client_secret")
}

/// Contexte d'authentification pour les mots de passe de serveurs SMTP (`booking_setting:smtp_config`).
pub fn smtp_password_context(tenant: &str, setting_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", setting_id.to_string(), "smtp_password")
}

/// Contexte d'authentification pour le client_secret Google OAuth2 stocké dans le record `booking_setting:auth_config`.
pub fn google_oauth_client_secret_context(tenant: &str, setting_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", setting_id.to_string(), "google_oauth_client_secret")
}

/// Contexte AAD pour le secret de vérification Captcha (`booking_setting:captcha_secret`).
pub fn captcha_secret_context(tenant: &str, setting_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", setting_id.to_string(), "captcha_secret")
}

/// Contexte AAD pour le secret HMAC du Webhook Meeting (`booking_setting:meeting_webhook_secret`).
pub fn meeting_webhook_secret_context(tenant: &str, setting_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", setting_id.to_string(), "meeting_webhook_secret")
}

/// Contexte d'authentification pour les secrets d'intégration et Captcha (`booking_setting`).
pub fn integration_secret_context(tenant: &str, setting_id: &RecordId) -> Result<SecretContext, CryptoError> {
    SecretContext::with_tenant(tenant, "booking", "booking_setting", setting_id.to_string(), "secret")
}

// --- High-level Encryption & Decryption Helpers ---

use lyxal_crypto::{EncryptionKey, SecretBytes};

/// Chiffre un mot de passe CalDAV avec son contexte AAD canonique (`booking_caldav_source`).
pub fn encrypt_caldav_password(
    crypto: &BookingCryptoEngine,
    tenant: &str,
    source_id: &RecordId,
    plaintext: &[u8],
) -> Result<String, CryptoError> {
    let ctx = caldav_password_context(tenant, source_id)?;
    crypto.encrypt_secret(plaintext, &ctx)
}

/// Déchiffre un mot de passe CalDAV chiffré (moderne enveloppé ou legacy).
pub fn decrypt_caldav_password(
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source_id: &RecordId,
    stored: &str,
) -> Result<SecretBytes, CryptoError> {
    let ctx = caldav_password_context(tenant, source_id)?;
    if stored.trim().starts_with("enc:") {
        crypto.decrypt_secret(stored, &ctx)
    } else if let Some(key) = legacy_key {
        crypto.decrypt_calrs_aes_base64(key, stored)
    } else {
        Err(CryptoError::MissingActiveKey)
    }
}

/// Chiffre un secret client Google OAuth2 (`booking_setting:auth_config`).
pub fn encrypt_google_client_secret(
    crypto: &BookingCryptoEngine,
    tenant: &str,
    setting_id: &RecordId,
    plaintext: &[u8],
) -> Result<String, CryptoError> {
    let ctx = google_oauth_client_secret_context(tenant, setting_id)?;
    crypto.encrypt_secret(plaintext, &ctx)
}

/// Déchiffre un secret client Google OAuth2 (`booking_setting:auth_config`).
pub fn decrypt_google_client_secret(
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    setting_id: &RecordId,
    stored: &str,
) -> Result<SecretBytes, CryptoError> {
    let ctx = google_oauth_client_secret_context(tenant, setting_id)?;
    if stored.trim().starts_with("enc:") {
        crypto.decrypt_secret(stored, &ctx)
    } else if let Some(key) = legacy_key {
        crypto.decrypt_calrs_aes_base64(key, stored)
    } else {
        Err(CryptoError::MissingActiveKey)
    }
}

/// Chiffre un mot de passe SMTP (`booking_setting:smtp_config`).
pub fn encrypt_smtp_password(
    crypto: &BookingCryptoEngine,
    tenant: &str,
    setting_id: &RecordId,
    plaintext: &[u8],
) -> Result<String, CryptoError> {
    let ctx = smtp_password_context(tenant, setting_id)?;
    crypto.encrypt_secret(plaintext, &ctx)
}

/// Chiffre un secret Captcha (`booking_setting:captcha_secret`).
pub fn encrypt_captcha_secret(
    crypto: &BookingCryptoEngine,
    tenant: &str,
    setting_id: &RecordId,
    plaintext: &[u8],
) -> Result<String, CryptoError> {
    let ctx = captcha_secret_context(tenant, setting_id)?;
    crypto.encrypt_secret(plaintext, &ctx)
}

/// Chiffre un secret HMAC de Webhook Meeting (`booking_setting:meeting_webhook_secret`).
pub fn encrypt_meeting_webhook_secret(
    crypto: &BookingCryptoEngine,
    tenant: &str,
    setting_id: &RecordId,
    plaintext: &[u8],
) -> Result<String, CryptoError> {
    let ctx = meeting_webhook_secret_context(tenant, setting_id)?;
    crypto.encrypt_secret(plaintext, &ctx)
}




/// Chargement ou génération de la clé de signature de session (256 bits).
pub fn load_or_create_session_signing_key(data_dir: &std::path::Path) -> anyhow::Result<[u8; 32]> {
    use anyhow::Context;
    use base64::Engine;
    use rand::RngCore;
    use zeroize::Zeroizing;

    const KEY_LEN: usize = 32;
    const KEY_FILE: &str = "secret.key";

    if let Ok(val) = std::env::var("CALRS_SECRET_KEY") {
        let bytes = Zeroizing::new(
            base64::engine::general_purpose::STANDARD
                .decode(val.trim())
                .context("CALRS_SECRET_KEY must be valid base64")?,
        );
        if bytes.len() != KEY_LEN {
            anyhow::bail!(
                "CALRS_SECRET_KEY must decode to exactly 32 bytes (got {})",
                bytes.len()
            );
        }
        let mut key = [0u8; KEY_LEN];
        key.copy_from_slice(&bytes);
        return Ok(key);
    }

    let key_path = data_dir.join(KEY_FILE);
    if key_path.exists() {
        let bytes = Zeroizing::new(
            std::fs::read(&key_path)
                .with_context(|| format!("Failed to read {}", key_path.display()))?,
        );
        if bytes.len() != KEY_LEN {
            anyhow::bail!(
                "Secret key file has wrong size ({} bytes, expected {})",
                bytes.len(),
                KEY_LEN
            );
        }
        let mut key = [0u8; KEY_LEN];
        key.copy_from_slice(&bytes);
        return Ok(key);
    }

    let mut key = [0u8; KEY_LEN];
    rand::rngs::OsRng.fill_bytes(&mut key);
    std::fs::create_dir_all(data_dir)?;
    std::fs::write(&key_path, key)
        .with_context(|| format!("Failed to write {}", key_path.display()))?;

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        std::fs::set_permissions(&key_path, std::fs::Permissions::from_mode(0o600))?;
    }

    Ok(key)
}

/// Chargement conditionnel de la clé legacy Cal.rs AES Base64 si configurée
pub fn load_legacy_secret_key_if_configured(
    data_dir: &std::path::Path,
) -> anyhow::Result<Option<lyxal_crypto::EncryptionKey>> {
    match load_or_create_session_signing_key(data_dir) {
        Ok(key_bytes) => Ok(Some(lyxal_crypto::EncryptionKey::from_bytes(key_bytes))),
        Err(_) => Ok(None),
    }
}

/// Helper pour initialiser un moteur de test cryptographique en mémoire
pub fn create_test_crypto_engine() -> BookingCryptoEngine {
    use lyxal_crypto::{CompositeKeyResolver, EncryptionKey, KeyId};
    let active_id = KeyId::parse("main").unwrap();
    let key = EncryptionKey::generate();
    let resolver = CompositeKeyResolver::new(active_id, key);
    BookingCryptoEngine::new(std::sync::Arc::new(resolver))
}
