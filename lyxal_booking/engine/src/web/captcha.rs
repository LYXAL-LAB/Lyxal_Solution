use anyhow::Result;
use lyxal_crypto::{CryptoError, EncryptionKey, SecretString};
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{captcha_secret_context, BookingCryptoEngine};
use crate::db::SurrealBookingStore;

pub const DEFAULT_WIDGET_URL: &str = "https://cdn.jsdelivr.net/npm/cap-widget";

pub struct CaptchaConfig {
    pub instance_url: String,
    pub site_key: String,
    pub secret: SecretString,
    pub widget_url: String,
}

impl std::fmt::Debug for CaptchaConfig {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CaptchaConfig")
            .field("instance_url", &self.instance_url)
            .field("site_key", &self.site_key)
            .field("secret", &"<redacted>")
            .field("widget_url", &self.widget_url)
            .finish()
    }
}

pub struct CaptchaVars {
    pub enabled: bool,
    pub api_endpoint: String,
    pub widget_url: String,
}

impl CaptchaVars {
    pub fn from_config(config: &Option<CaptchaConfig>) -> Self {
        Self {
            enabled: config.is_some(),
            api_endpoint: config
                .as_ref()
                .map(|c| c.api_endpoint())
                .unwrap_or_default(),
            widget_url: config
                .as_ref()
                .map(|c| c.widget_url.clone())
                .unwrap_or_else(|| DEFAULT_WIDGET_URL.to_string()),
        }
    }
}

impl CaptchaConfig {
    /// API endpoint URL passed to the <cap-widget> data-cap-api-endpoint attribute.
    pub fn api_endpoint(&self) -> String {
        format!(
            "{}/{}/",
            self.instance_url.trim_end_matches('/'),
            self.site_key
        )
    }

    /// Extract scheme+host from widget_url for use in Content-Security-Policy script-src.
    /// e.g. "https://cdn.jsdelivr.net/npm/cap-widget" → "https://cdn.jsdelivr.net"
    pub fn widget_script_origin(&self) -> String {
        extract_origin(&self.widget_url)
    }

    /// Extract scheme+host from instance_url for use in Content-Security-Policy connect-src.
    /// e.g. "https://captcha.example.com" → "https://captcha.example.com"
    pub fn instance_origin(&self) -> String {
        extract_origin(&self.instance_url)
    }
}

pub fn is_valid_instance_url(url: &str) -> bool {
    let Ok(parsed) = reqwest::Url::parse(url.trim()) else {
        return false;
    };
    if !matches!(parsed.scheme(), "http" | "https") {
        return false;
    }
    if parsed.host_str().unwrap_or("").is_empty() {
        return false;
    }
    if !parsed.username().is_empty() || parsed.password().is_some() {
        return false;
    }
    true
}

fn extract_origin(url: &str) -> String {
    let Ok(parsed) = reqwest::Url::parse(url) else {
        return String::new();
    };
    if !matches!(parsed.scheme(), "http" | "https") {
        return String::new();
    }
    let host = parsed.host_str().unwrap_or("");
    match parsed.port() {
        Some(port) => format!("{}://{}:{}", parsed.scheme(), host, port),
        None => format!("{}://{}", parsed.scheme(), host),
    }
}

/// Format du secret stocké pour Captcha.
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum StoredIntegrationSecretFormat {
    LyxalEnvelope,
    CalrsHexPlaintext,
    CalrsAesBase64,
}

/// Règle déterministe de résolution du format de stockage pour les secrets d'intégration.
pub fn determine_integration_secret_format(
    stored: &str,
) -> Result<StoredIntegrationSecretFormat, CryptoError> {
    use base64::Engine;
    let value = stored.trim();

    if value.starts_with("enc:") {
        return Ok(StoredIntegrationSecretFormat::LyxalEnvelope);
    }

    if !value.is_empty() && value.len() % 2 == 0 && value.chars().all(|c| c.is_ascii_hexdigit()) {
        if let Ok(bytes) = hex::decode(value) {
            if std::str::from_utf8(&bytes).is_ok() {
                return Ok(StoredIntegrationSecretFormat::CalrsHexPlaintext);
            }
        }
    }

    if let Ok(payload) = base64::engine::general_purpose::STANDARD.decode(value) {
        if payload.len() >= 28 {
            return Ok(StoredIntegrationSecretFormat::CalrsAesBase64);
        }
    }

    Err(CryptoError::InvalidLegacyValue)
}

#[derive(Debug, Deserialize)]
struct UpdateSettingSecretResult {
    updated: bool,
}

#[derive(Serialize)]
struct UpdateParams<'a> {
    record_id: &'a RecordId,
    expected_old_value: &'a str,
    new_envelope: &'a str,
}

pub async fn load_captcha_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
) -> Result<Option<CaptchaConfig>> {
    let instance_url = match store.get_setting("captcha_instance_url").await? {
        Some(url) if is_valid_instance_url(&url) => url,
        _ => return Ok(None),
    };
    let site_key = match store.get_setting("captcha_site_key").await? {
        Some(key) if !key.trim().is_empty() => key,
        _ => return Ok(None),
    };
    let secret_enc = match store.get_setting("captcha_secret").await? {
        Some(enc) if !enc.trim().is_empty() => enc,
        _ => return Ok(None),
    };
    let widget_url = store
        .get_setting("captcha_widget_url")
        .await?
        .unwrap_or_else(|| DEFAULT_WIDGET_URL.to_string());

    let setting_id = RecordId::from(("booking_setting", "captcha_secret"));
    let context = captcha_secret_context(tenant, &setting_id)?;

    let secret_bytes = if secret_enc.trim().starts_with("enc:") {
        crypto.decrypt_secret(&secret_enc, &context)?
    } else if let Some(key) = legacy_key {
        crypto.decrypt_calrs_aes_base64(key, &secret_enc)?
    } else {
        lyxal_crypto::decode_calrs_legacy_hex(&secret_enc)?
    };

    let secret_str = String::from_utf8(secret_bytes.to_vec())
        .map_err(|_| CryptoError::InvalidLegacyValue)?;
    let secret = SecretString::new(secret_str);

    Ok(Some(CaptchaConfig {
        instance_url,
        site_key,
        secret,
        widget_url,
    }))
}

#[derive(serde::Serialize)]
struct VerifyRequest<'a> {
    secret: &'a str,
    response: &'a str,
}

#[derive(serde::Deserialize)]
struct VerifyResponse {
    success: bool,
}

/// Returns `Ok(())` if captcha is not configured (pass-through) or if the token
/// is valid. Returns `Err(())` if captcha is configured but the token is missing
/// or fails server-side verification.
pub async fn verify(config: &Option<CaptchaConfig>, token: Option<&str>) -> Result<(), ()> {
    let cfg = match config {
        Some(c) => c,
        None => return Ok(()),
    };

    let token = match token.filter(|t| !t.trim().is_empty()) {
        Some(t) => t,
        None => {
            tracing::warn!("captcha token missing on booking attempt");
            return Err(());
        }
    };
    let allowlist = crate::settings::private_host_allowlist();
    if let Err(e) = crate::utils::validate_outbound_url(&cfg.instance_url, &allowlist).await {
        tracing::warn!(error = %e, url = %cfg.instance_url, "captcha instance_url rejected by outbound SSRF policy");
        return Err(());
    }

    let verify_url = format!("{}/siteverify", cfg.api_endpoint().trim_end_matches('/'));

    let client = match crate::utils::build_ssrf_safe_client(10) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!(error = %e, "failed to build SSRF-safe HTTP client for captcha");
            return Err(());
        }
    };
    let resp = match client
        .post(&verify_url)
        .json(&VerifyRequest {
            secret: cfg.secret.as_str(),
            response: token,
        })
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            tracing::warn!(error = %e, "captcha verification request failed");
            return Err(());
        }
    };

    if !resp.status().is_success() {
        tracing::warn!(
            status = %resp.status(),
            "Captcha verification server returned non-success status"
        );
        return Err(());
    }

    match resp.json::<VerifyResponse>().await {
        Ok(r) if r.success => Ok(()),
        Ok(_) => {
            tracing::warn!("captcha token rejected by verification server");
            Err(())
        }
        Err(e) => {
            tracing::warn!(error = %e, "captcha verification response parse failed");
            Err(())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // --- extract_origin tests ---

    #[test]
    fn extract_origin_returns_scheme_and_host() {
        assert_eq!(
            extract_origin("https://cdn.jsdelivr.net/npm/cap-widget"),
            "https://cdn.jsdelivr.net"
        );
    }

    #[test]
    fn extract_origin_handles_root_url() {
        assert_eq!(
            extract_origin("https://cap.example.com"),
            "https://cap.example.com"
        );
    }

    #[test]
    fn extract_origin_handles_trailing_slash() {
        assert_eq!(
            extract_origin("https://cap.example.com/"),
            "https://cap.example.com"
        );
    }

    #[test]
    fn extract_origin_rejects_invalid_url() {
        assert_eq!(extract_origin("not-a-url"), "");
        assert_eq!(extract_origin(""), "");
    }

    // --- api_endpoint tests ---

    #[test]
    fn api_endpoint_strips_trailing_slash_on_instance() {
        let cfg = CaptchaConfig {
            instance_url: "https://cap.example.com/".to_string(),
            site_key: "mykey".to_string(),
            secret: SecretString::new("s".to_string()),
            widget_url: DEFAULT_WIDGET_URL.to_string(),
        };
        assert_eq!(cfg.api_endpoint(), "https://cap.example.com/mykey/");
    }

    #[test]
    fn api_endpoint_no_trailing_slash_on_instance() {
        let cfg = CaptchaConfig {
            instance_url: "https://cap.example.com".to_string(),
            site_key: "mykey".to_string(),
            secret: SecretString::new("s".to_string()),
            widget_url: DEFAULT_WIDGET_URL.to_string(),
        };
        assert_eq!(cfg.api_endpoint(), "https://cap.example.com/mykey/");
    }

    // --- verify passthrough tests (no network) ---

    #[tokio::test]
    async fn verify_passes_through_when_no_config() {
        assert!(verify(&None, None).await.is_ok());
        assert!(verify(&None, Some("any-token")).await.is_ok());
    }

    #[tokio::test]
    async fn verify_fails_when_config_set_and_token_missing() {
        let cfg = Some(CaptchaConfig {
            instance_url: "https://cap.example.com".to_string(),
            site_key: "key".to_string(),
            secret: SecretString::new("secret".to_string()),
            widget_url: DEFAULT_WIDGET_URL.to_string(),
        });
        assert!(verify(&cfg, None).await.is_err());
    }

    #[tokio::test]
    async fn verify_fails_when_config_set_and_token_empty() {
        let cfg = Some(CaptchaConfig {
            instance_url: "https://cap.example.com".to_string(),
            site_key: "key".to_string(),
            secret: SecretString::new("secret".to_string()),
            widget_url: DEFAULT_WIDGET_URL.to_string(),
        });
        assert!(verify(&cfg, Some("")).await.is_err());
        assert!(verify(&cfg, Some("   ")).await.is_err());
    }

    #[test]
    fn test_captcha_config_debug_redacts_secret() {
        let cfg = CaptchaConfig {
            instance_url: "https://cap.example.com".to_string(),
            site_key: "key".to_string(),
            secret: SecretString::new("super_secret_captcha_key_123".to_string()),
            widget_url: DEFAULT_WIDGET_URL.to_string(),
        };
        let debug_str = format!("{:?}", cfg);
        assert!(debug_str.contains("<redacted>"));
        assert!(!debug_str.contains("super_secret_captcha_key_123"));
    }

    #[test]
    fn test_determine_integration_secret_format() {
        assert_eq!(
            determine_integration_secret_format("enc:v1:some_envelope").unwrap(),
            StoredIntegrationSecretFormat::LyxalEnvelope
        );

        let hex_legacy = hex::encode("plain_secret");
        assert_eq!(
            determine_integration_secret_format(&hex_legacy).unwrap(),
            StoredIntegrationSecretFormat::CalrsHexPlaintext
        );

        use base64::Engine;
        let valid_b64 = base64::engine::general_purpose::STANDARD.encode(&[42u8; 32]);
        assert_eq!(
            determine_integration_secret_format(&valid_b64).unwrap(),
            StoredIntegrationSecretFormat::CalrsAesBase64
        );

        assert!(determine_integration_secret_format("too_short").is_err());
        assert!(determine_integration_secret_format("invalid_junk_$$$").is_err());
    }

    #[test]
    fn test_captcha_aad_context_integrity() {
        let crypto = crate::crypto_helpers::create_test_crypto_engine();

        let setting_id = RecordId::from(("booking_setting", "captcha_secret"));
        let ctx = crate::crypto_helpers::captcha_secret_context("default", &setting_id).unwrap();

        let secret = b"my_captcha_secret";
        let encrypted = crypto.encrypt_secret(secret, &ctx).unwrap();
        assert!(encrypted.starts_with("enc:v1:"));

        let decrypted = crypto.decrypt_secret(&encrypted, &ctx).unwrap();
        assert_eq!(decrypted.as_slice(), secret);

        let wrong_ctx = lyxal_crypto::SecretContext::with_tenant("default", "booking", "booking_setting", "captcha_secret", "wrong_field").unwrap();
        assert!(crypto.decrypt_secret(&encrypted, &wrong_ctx).is_err());
    }

    #[test]
    fn test_captcha_hex_migration_and_re_encryption() {
        let crypto = crate::crypto_helpers::create_test_crypto_engine();

        let setting_id = RecordId::from(("booking_setting", "captcha_secret"));
        let ctx = crate::crypto_helpers::captcha_secret_context("default", &setting_id).unwrap();

        let raw_secret = "my_plain_hex_captcha_secret";
        let stored_hex = hex::encode(raw_secret);

        assert_eq!(determine_integration_secret_format(&stored_hex).unwrap(), StoredIntegrationSecretFormat::CalrsHexPlaintext);

        let migrated_envelope = crypto.migrate_legacy_calrs_hex(&stored_hex, &ctx).unwrap();
        assert!(migrated_envelope.starts_with("enc:v1:"));

        let read_back = crypto.decrypt_secret(&migrated_envelope, &ctx).unwrap();
        assert_eq!(read_back.as_slice(), raw_secret.as_bytes());
    }

    #[test]
    fn test_captcha_tenant_isolation() {
        let crypto = crate::crypto_helpers::create_test_crypto_engine();

        let id = RecordId::from(("booking_setting", "captcha_secret"));
        let ctx_a = crate::crypto_helpers::captcha_secret_context("tenant-a", &id).unwrap();
        let ctx_b = crate::crypto_helpers::captcha_secret_context("tenant-b", &id).unwrap();

        let enc_a = crypto.encrypt_secret(b"secret_tenant_a", &ctx_a).unwrap();
        assert!(crypto.decrypt_secret(&enc_a, &ctx_b).is_err());
    }
}

