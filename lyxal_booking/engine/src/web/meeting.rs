//! Auto-generated video meeting links (issue #45).
//!
//! Two providers ship today:
//!
//! * **Jitsi** — a fresh room is computed locally from a pattern of tokens
//!   (`{username}`, `{event}`, `{date}`, `{random}`) and appended to a base
//!   URL (e.g. `https://meet.dyb.fr`). No external network call.
//! * **Generic webhook** — calrs POSTs the booking payload to a configured URL
//!   when the booking is confirmed and expects `{"url": "..."}` back. The
//!   request is optionally signed with HMAC-SHA256 so the receiver can prove
//!   the call came from calrs.
//!
//! The generated URL is persisted to `bookings.meeting_url` and read back by
//! every downstream consumer (host email, ICS attachment, CalDAV write-back,
//! guest reschedule, reminder emails) via
//! `COALESCE(NULLIF(b.meeting_url, ''), et.location_value)`. Recomputing each
//! time would otherwise produce a different `{random}` between the email body
//! and the ICS attachment.

use anyhow::Result;
use lyxal_crypto::{CryptoError, EncryptionKey, SecretString};
use lyxal_surreal::LyxalSurrealCall;
use rand::RngCore;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{meeting_webhook_secret_context, BookingCryptoEngine};
use crate::db::SurrealBookingStore;
use crate::web::captcha::{determine_integration_secret_format, StoredIntegrationSecretFormat};

/// Default Jitsi pattern when neither org-wide nor per-event-type pattern is
/// configured. Chosen to mirror cal.com's behaviour (random room name with
/// just enough context to be greppable in server logs).
pub const DEFAULT_JITSI_PATTERN: &str = "{event}-{random}";

/// Location type stored in `event_types.location_type` for the auto providers.
pub const LOCATION_TYPE_JITSI: &str = "jitsi_auto";
pub const LOCATION_TYPE_WEBHOOK: &str = "webhook_auto";

/// Webhook auth mode stored in `auth_config.meeting_webhook_auth_mode`.
pub const WEBHOOK_AUTH_NONE: &str = "none";
pub const WEBHOOK_AUTH_HMAC: &str = "hmac";

/// Org-wide meeting provider configuration.
#[derive(Clone, Default)]
pub struct MeetingConfig {
    pub jitsi: Option<JitsiConfig>,
    pub webhook: Option<WebhookConfig>,
}

#[derive(Clone)]
pub struct JitsiConfig {
    /// Base URL, e.g. `https://meet.dyb.fr`. Trailing slash tolerated.
    pub base_url: String,
    /// Pattern with `{token}` placeholders, or empty for `DEFAULT_JITSI_PATTERN`.
    pub pattern: String,
    /// Human-readable label shown to guests in the slot/booking UI, e.g.
    /// "Meet DYB". `None` = use the generic "Video call" badge.
    pub display_name: Option<String>,
}

#[derive(Clone)]
pub struct WebhookConfig {
    pub url: String,
    pub auth_mode: WebhookAuthMode,
    /// Shared secret for HMAC; empty when `auth_mode` is `None`.
    pub secret: SecretString,
    /// Human-readable label shown to guests; same semantics as
    /// [`JitsiConfig::display_name`].
    pub display_name: Option<String>,
}

impl std::fmt::Debug for WebhookConfig {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("WebhookConfig")
            .field("url", &self.url)
            .field("auth_mode", &self.auth_mode)
            .field("secret", &"<redacted>")
            .field("display_name", &self.display_name)
            .finish()
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum WebhookAuthMode {
    None,
    Hmac,
}

impl WebhookAuthMode {
    pub fn from_str(s: &str) -> Self {
        match s {
            WEBHOOK_AUTH_HMAC => WebhookAuthMode::Hmac,
            _ => WebhookAuthMode::None,
        }
    }
    pub fn as_str(&self) -> &'static str {
        match self {
            WebhookAuthMode::Hmac => WEBHOOK_AUTH_HMAC,
            WebhookAuthMode::None => WEBHOOK_AUTH_NONE,
        }
    }
}

/// Tokens available to the pattern expander.
pub struct PatternTokens<'a> {
    pub username: &'a str,
    pub event_slug: &'a str,
    pub start_at: &'a str,
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

/// Load the org-wide meeting config from SurrealDB store. Returns a `MeetingConfig`
/// with `jitsi` and/or `webhook` set when configured. Decrypts the webhook
/// secret on the fly using canonical AAD context.
pub async fn load_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
) -> Result<MeetingConfig> {
    let jitsi_url = store.get_setting("jitsi_base_url").await?;
    let jitsi_pat = store.get_setting("jitsi_pattern").await?;
    let jitsi_name = store.get_setting("jitsi_display_name").await?;
    let hook_url = store.get_setting("meeting_webhook_url").await?;
    let hook_mode = store.get_setting("meeting_webhook_auth_mode").await?;
    let hook_secret_enc = store.get_setting("meeting_webhook_secret").await?;
    let hook_name = store.get_setting("meeting_webhook_display_name").await?;

    let jitsi = jitsi_url
        .as_deref()
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .map(|base_url| JitsiConfig {
            base_url: base_url.to_string(),
            pattern: jitsi_pat
                .as_deref()
                .map(str::trim)
                .filter(|s| !s.is_empty())
                .unwrap_or(DEFAULT_JITSI_PATTERN)
                .to_string(),
            display_name: jitsi_name
                .as_deref()
                .map(str::trim)
                .filter(|s| !s.is_empty())
                .map(str::to_string),
        });

    let webhook = if let Some(url) = hook_url.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
        let auth_mode =
            WebhookAuthMode::from_str(hook_mode.as_deref().unwrap_or(WEBHOOK_AUTH_NONE));
        let secret = match (auth_mode, hook_secret_enc.as_deref()) {
            (WebhookAuthMode::Hmac, Some(enc)) if !enc.trim().is_empty() => {
                let setting_id = RecordId::from(("booking_setting", "meeting_webhook_secret"));
                let context = meeting_webhook_secret_context(tenant, &setting_id)?;

                let secret_bytes = if enc.trim().starts_with("enc:") {
                    crypto.decrypt_secret(enc, &context)?
                } else if let Some(key) = legacy_key {
                    crypto.decrypt_calrs_aes_base64(key, enc)?
                } else {
                    lyxal_crypto::decode_calrs_legacy_hex(enc)?
                };

                let secret_str = String::from_utf8(secret_bytes.to_vec())
                    .map_err(|_| CryptoError::InvalidLegacyValue)?;
                SecretString::new(secret_str)
            }
            _ => SecretString::new(String::new()),
        };
        Some(WebhookConfig {
            url: url.to_string(),
            auth_mode,
            secret,
            display_name: hook_name
                .as_deref()
                .map(str::trim)
                .filter(|s| !s.is_empty())
                .map(str::to_string),
        })
    } else {
        None
    };

    Ok(MeetingConfig { jitsi, webhook })
}

/// Pick the guest-facing label for a `location_type`, falling back to `None`
/// for non-auto providers.
pub fn provider_label(location_type: &str, cfg: &MeetingConfig) -> Option<String> {
    match location_type {
        LOCATION_TYPE_JITSI => cfg.jitsi.as_ref().and_then(|j| j.display_name.clone()),
        LOCATION_TYPE_WEBHOOK => cfg.webhook.as_ref().and_then(|w| w.display_name.clone()),
        _ => None,
    }
}

/// Expand `{username}`, `{event}`, `{date}`, `{random}` in `pattern`.
pub fn expand_pattern(pattern: &str, tokens: &PatternTokens<'_>) -> String {
    let mut out = String::with_capacity(pattern.len() + 16);
    let mut chars = pattern.chars().peekable();
    while let Some(c) = chars.next() {
        if c != '{' {
            out.push(c);
            continue;
        }
        let mut name = String::new();
        let mut closed = false;
        for nc in chars.by_ref() {
            if nc == '}' {
                closed = true;
                break;
            }
            name.push(nc);
        }
        if !closed {
            out.push('{');
            out.push_str(&name);
            continue;
        }
        match name.as_str() {
            "username" => out.push_str(tokens.username),
            "event" => out.push_str(tokens.event_slug),
            "date" => out.push_str(&extract_date(tokens.start_at)),
            "random" => out.push_str(&random_alphanumeric(8)),
            other => {
                out.push('{');
                out.push_str(other);
                out.push('}');
            }
        }
    }
    sanitize_room(&out)
}

/// Build the Jitsi room URL by expanding the pattern and joining to `base_url`.
pub fn build_jitsi_url(
    cfg: &JitsiConfig,
    override_pattern: Option<&str>,
    tokens: &PatternTokens<'_>,
) -> String {
    let pattern = override_pattern
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .unwrap_or(&cfg.pattern);
    let pattern = if pattern.is_empty() {
        DEFAULT_JITSI_PATTERN
    } else {
        pattern
    };
    let room = expand_pattern(pattern, tokens);
    format!("{}/{}", cfg.base_url.trim_end_matches('/'), room)
}

#[derive(serde::Serialize)]
pub struct WebhookPayload<'a> {
    pub booking_uid: &'a str,
    pub event_slug: &'a str,
    pub host_username: &'a str,
    pub guest_name: &'a str,
    pub guest_email: &'a str,
    pub start_at: &'a str,
    pub end_at: &'a str,
}

#[derive(serde::Deserialize)]
struct WebhookResponse {
    url: String,
}

pub fn is_valid_meeting_url(url: &str) -> bool {
    let trimmed = url.trim();
    if trimmed.is_empty() || trimmed.len() > 2048 {
        return false;
    }
    let Ok(parsed) = reqwest::Url::parse(trimmed) else {
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
    if trimmed.chars().any(|c| c.is_control()) {
        return false;
    }
    true
}

/// Call the configured webhook with the booking payload, expecting `{"url": ...}`
/// back. Returns the meeting URL on success.
pub async fn call_webhook(cfg: &WebhookConfig, payload: &WebhookPayload<'_>) -> Result<String, ()> {
    let allowlist = crate::settings::private_host_allowlist();
    if let Err(e) = crate::utils::validate_outbound_url(&cfg.url, &allowlist).await {
        tracing::warn!(error = %e, url = %cfg.url, "meeting webhook url rejected by outbound SSRF policy");
        return Err(());
    }

    let body = match serde_json::to_vec(payload) {
        Ok(b) => b,
        Err(e) => {
            tracing::error!(error = %e, "meeting webhook payload serialise failed");
            return Err(());
        }
    };

    let client = match crate::utils::build_ssrf_safe_client(10) {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!(error = %e, "failed to build SSRF-safe HTTP client for meeting webhook");
            return Err(());
        }
    };
    let mut req = client
        .post(&cfg.url)
        .header("content-type", "application/json")
        .header("user-agent", "lyxal-booking-meeting-webhook/1");

    if cfg.auth_mode == WebhookAuthMode::Hmac && !cfg.secret.as_str().is_empty() {
        let sig = sign_hmac_sha256(cfg.secret.as_str().as_bytes(), &body);
        let signature = format!("sha256={}", sig);
        req = req
            .header("X-Lyxal-Signature", &signature)
            .header("X-Calrs-Signature", &signature); // LEGACY-WEBHOOK-HEADER-001
    }

    let resp = match req
        .body(body)
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            tracing::warn!(error = %e, "meeting webhook request failed");
            return Err(());
        }
    };

    if !resp.status().is_success() {
        tracing::warn!(status = %resp.status(), "meeting webhook returned non-2xx");
        return Err(());
    }

    let parsed: WebhookResponse = match resp.json().await {
        Ok(p) => p,
        Err(e) => {
            tracing::warn!(error = %e, "meeting webhook response parse failed");
            return Err(());
        }
    };

    let url = parsed.url.trim().to_string();
    if !is_valid_meeting_url(&url) {
        tracing::warn!(url = %url, "meeting webhook returned invalid url");
        return Err(());
    }
    Ok(url)
}

/// Generate a meeting URL for a freshly-confirmed booking and persist it to
/// `bookings.meeting_url`. Returns `Some(url)` when an auto provider produced
/// a URL, `None` otherwise.
pub async fn generate_and_persist(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    booking_id: &str,
    event_type_id: &str,
    host_user_id: Option<&str>,
    guest_name: &str,
    guest_email: &str,
) -> Option<String> {
    let existing: Option<(Option<String>, String, String, String)> = match crate::db::surreal_query_opt(
        store
            .client()
            .query("RETURN fn::booking_get_booking_meeting_info($booking_id);")
            .bind(("booking_id", booking_id.to_string()))
            .await,
    ) {
        Ok(opt) => opt,
        Err(e) => {
            tracing::warn!(error = %e, booking_id = %booking_id, "Failed to query booking meeting info");
            return None;
        }
    };
    let (meeting_url, booking_uid, start_at, end_at) = existing?;
    if let Some(url) = meeting_url {
        let trimmed = url.trim();
        if !trimmed.is_empty() {
            return Some(trimmed.to_string());
        }
    }

    let et: Option<(String, String, Option<String>)> = match crate::db::surreal_query_opt(
        store
            .client()
            .query("RETURN fn::booking_get_event_type_meeting_info($event_type_id);")
            .bind(("event_type_id", event_type_id.to_string()))
            .await,
    ) {
        Ok(opt) => opt,
        Err(e) => {
            tracing::warn!(error = %e, event_type_id = %event_type_id, "Failed to query event type meeting info");
            return None;
        }
    };
    let (location_type, event_slug, pattern_override) = et?;

    if location_type != LOCATION_TYPE_JITSI && location_type != LOCATION_TYPE_WEBHOOK {
        return None;
    }

    let host_username = match host_user_id {
        Some(uid) => {
            let u: Option<String> = match crate::db::surreal_query_opt(
                store
                    .client()
                    .query("RETURN fn::booking_get_user_username($user_id);")
                    .bind(("user_id", uid.to_string()))
                    .await,
            ) {
                Ok(opt) => opt,
                Err(e) => {
                    tracing::warn!(error = %e, user_id = %uid, "Failed to query user username");
                    None
                }
            };
            u.unwrap_or_else(|| "host".to_string())
        }
        None => "host".to_string(),
    };

    let tokens = PatternTokens {
        username: &host_username,
        event_slug: &event_slug,
        start_at: &start_at,
    };

    let cfg = match load_config(store, crypto, legacy_key, tenant).await {
        Ok(c) => c,
        Err(e) => {
            tracing::warn!(error = %e, "Failed to load meeting config in generate_and_persist");
            return None;
        }
    };

    let url = match location_type.as_str() {
        LOCATION_TYPE_JITSI => cfg
            .jitsi
            .as_ref()
            .map(|j| build_jitsi_url(j, pattern_override.as_deref(), &tokens)),
        LOCATION_TYPE_WEBHOOK => {
            let webhook_cfg = cfg.webhook.as_ref()?;
            let payload = WebhookPayload {
                booking_uid: &booking_uid,
                event_slug: &event_slug,
                host_username: &host_username,
                guest_name,
                guest_email,
                start_at: &start_at,
                end_at: &end_at,
            };
            match call_webhook(webhook_cfg, &payload).await {
                Ok(url) => Some(url),
                Err(()) => {
                    tracing::warn!(booking_uid = %booking_uid, "Meeting webhook call failed in generate_and_persist");
                    None
                }
            }
        }
        _ => None,
    }?;

    match store
        .client()
        .query("RETURN fn::booking_persist_meeting_url($booking_id, $url);")
        .bind(("booking_id", booking_id.to_string()))
        .bind(("url", url.clone()))
        .await
    {
        Ok(_) => {
            tracing::info!(booking_id = %booking_id, "Meeting URL successfully persisted");
            Some(url)
        }
        Err(error) => {
            tracing::warn!(%error, booking_id = %booking_id, "Failed to persist meeting URL to database");
            None
        }
    }
}

/// Hex-encoded HMAC-SHA256 of `body` keyed by `secret`.
pub fn sign_hmac_sha256(secret: &[u8], body: &[u8]) -> String {
    use hmac::{Hmac, Mac};
    use sha2::Sha256;
    type HmacSha256 = Hmac<Sha256>;
    let mut mac = HmacSha256::new_from_slice(secret).expect("HMAC accepts any key length");
    mac.update(body);
    let tag = mac.finalize().into_bytes();
    hex::encode(tag)
}

/// Restrict an expanded room string to URL-safe chars.
fn sanitize_room(s: &str) -> String {
    let cleaned: String = s
        .trim()
        .to_lowercase()
        .chars()
        .filter(|c| c.is_ascii_alphanumeric() || matches!(*c, '-' | '_' | '{' | '}'))
        .collect();
    if cleaned.is_empty() {
        "x".to_string()
    } else {
        cleaned
    }
}

/// Pull the YYYYMMDD prefix out of an ISO8601 datetime stored in `bookings.start_at`.
fn extract_date(start_at: &str) -> String {
    if start_at.len() < 10 {
        return String::new();
    }
    let (y, m, d) = (&start_at[0..4], &start_at[5..7], &start_at[8..10]);
    if y.chars().all(|c| c.is_ascii_digit())
        && m.chars().all(|c| c.is_ascii_digit())
        && d.chars().all(|c| c.is_ascii_digit())
    {
        format!("{}{}{}", y, m, d)
    } else {
        String::new()
    }
}

/// Generate `n` cryptographically-random alphanumeric characters using OsRng.
pub fn random_alphanumeric(n: usize) -> String {
    const ALPHABET: &[u8] = b"abcdefghijklmnopqrstuvwxyz0123456789";
    let mut out = String::with_capacity(n);
    let mut buf = vec![0u8; n];
    rand::rngs::OsRng.fill_bytes(&mut buf);
    for &b in &buf {
        out.push(ALPHABET[(b as usize) % ALPHABET.len()] as char);
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn expand_pattern_replaces_known_tokens() {
        let tokens = PatternTokens {
            username: "alice",
            event_slug: "intro-call",
            start_at: "2026-06-05T10:00:00",
        };
        let out = expand_pattern("{username}-{event}-{date}", &tokens);
        assert_eq!(out, "alice-intro-call-20260605");
    }

    #[test]
    fn test_webhook_config_debug_redacts_secret() {
        let cfg = WebhookConfig {
            url: "https://webhook.example.com".to_string(),
            auth_mode: WebhookAuthMode::Hmac,
            secret: SecretString::new("super_secret_hmac_key_999".to_string()),
            display_name: None,
        };
        let debug_str = format!("{:?}", cfg);
        assert!(debug_str.contains("<redacted>"));
        assert!(!debug_str.contains("super_secret_hmac_key_999"));
    }

    #[test]
    fn test_meeting_webhook_aad_context_integrity() {
        use lyxal_crypto::{CryptoEngine, EnvironmentKeyProvider};
        use std::sync::Arc;

        let provider = Arc::new(EnvironmentKeyProvider::new("LYXAL_TEST_SECRET_KEY_FOR_MEETING_AAD_5678"));
        let crypto = CryptoEngine::new(provider);

        let setting_id = RecordId::from(("booking_setting", "meeting_webhook_secret"));
        let ctx = crate::crypto_helpers::meeting_webhook_secret_context("default", &setting_id).unwrap();

        let secret = b"my_webhook_hmac_secret";
        let encrypted = crypto.encrypt_secret(secret, &ctx).unwrap();
        assert!(encrypted.starts_with("enc:v1:"));

        let decrypted = crypto.decrypt_secret(&encrypted, &ctx).unwrap();
        assert_eq!(decrypted.as_ref(), secret);

        let wrong_ctx = lyxal_crypto::SecretContext::with_tenant("default", "booking", "booking_setting", "meeting_webhook_secret", "wrong_field").unwrap();
        assert!(crypto.decrypt_secret(&encrypted, &wrong_ctx).is_err());
    }

    #[test]
    fn test_meeting_webhook_aes_base64_migration() {
        use lyxal_crypto::{CryptoEngine, EnvironmentKeyProvider, EncryptionKey};
        use std::sync::Arc;

        let provider = Arc::new(EnvironmentKeyProvider::new("LYXAL_TEST_SECRET_KEY_FOR_MEETING_MIGRATION_777"));
        let crypto = CryptoEngine::new(provider);

        let legacy_key_bytes = [3u8; 32];
        let legacy_key = EncryptionKey::from_bytes("legacy_key", &legacy_key_bytes);

        let setting_id = RecordId::from(("booking_setting", "meeting_webhook_secret"));
        let ctx = crate::crypto_helpers::meeting_webhook_secret_context("default", &setting_id).unwrap();

        let secret = b"my_legacy_hmac_webhook_secret";

        // Chiffrement avec la clé legacy (AES Base64)
        use base64::Engine;
        let cipher_payload = lyxal_crypto::cipher::encrypt_aes_gcm(&legacy_key, secret, &[]).unwrap();
        let stored_b64 = base64::engine::general_purpose::STANDARD.encode(&cipher_payload);

        let dec = crypto.migrate_calrs_aes_base64(&legacy_key, &stored_b64, &ctx).unwrap();
        assert_eq!(dec.plaintext.as_ref(), secret);
        let migrated_envelope = dec.migrated_envelope.unwrap();
        assert!(migrated_envelope.starts_with("enc:v1:"));

        let read_back = crypto.decrypt_secret(&migrated_envelope, &ctx).unwrap();
        assert_eq!(read_back.as_ref(), secret);
    }

    #[test]
    fn test_meeting_webhook_tenant_isolation() {
        use lyxal_crypto::{CryptoEngine, EnvironmentKeyProvider};
        use std::sync::Arc;

        let provider = Arc::new(EnvironmentKeyProvider::new("LYXAL_TEST_SECRET_KEY_FOR_MEETING_TENANT_ISO_000"));
        let crypto = CryptoEngine::new(provider);

        let id = RecordId::from(("booking_setting", "meeting_webhook_secret"));
        let ctx_a = crate::crypto_helpers::meeting_webhook_secret_context("tenant-a", &id).unwrap();
        let ctx_b = crate::crypto_helpers::meeting_webhook_secret_context("tenant-b", &id).unwrap();

        let enc_a = crypto.encrypt_secret(b"secret_meeting_tenant_a", &ctx_a).unwrap();
        assert!(crypto.decrypt_secret(&enc_a, &ctx_b).is_err());
    }
}

