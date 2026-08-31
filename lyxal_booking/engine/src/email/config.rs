//! SMTP Configuration, Status, and Loader functions for Lyxal Booking.

use anyhow::{bail, Result};
use lettre::message::Mailbox;
use lyxal_crypto::EncryptionKey;
use lyxal_surreal::LyxalSurrealCall;
use zeroize::Zeroizing;

use crate::crypto_helpers::BookingCryptoEngine;
use crate::db::SurrealBookingStore;

const SMTP_ENV_VARS: &[&str] = &[
    "CALRS_SMTP_HOST",
    "CALRS_SMTP_PORT",
    "CALRS_SMTP_USERNAME",
    "CALRS_SMTP_PASSWORD",
    "CALRS_SMTP_FROM_EMAIL",
    "CALRS_SMTP_FROM_NAME",
    "CALRS_SMTP_TLS_MODE",
];

pub struct SmtpConfig {
    pub host: String,
    pub port: u16,
    pub username: String,
    pub password: lyxal_crypto::SecretString,
    pub from_email: String,
    pub from_name: Option<String>,
    pub tls_mode: SmtpTlsMode,
}

impl std::fmt::Debug for SmtpConfig {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SmtpConfig")
            .field("host", &self.host)
            .field("port", &self.port)
            .field("username", &self.username)
            .field("password", &"<redacted>")
            .field("from_email", &self.from_email)
            .field("from_name", &self.from_name)
            .field("tls_mode", &self.tls_mode)
            .finish()
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SmtpTlsMode {
    StartTls,
    Tls,
}

impl SmtpTlsMode {
    pub(crate) fn parse(value: &str) -> Result<Self> {
        match value.trim().to_ascii_lowercase().as_str() {
            "starttls" => Ok(Self::StartTls),
            "tls" => Ok(Self::Tls),
            other => bail!(
                "CALRS_SMTP_TLS_MODE must be 'starttls' or 'tls' (got '{}')",
                other
            ),
        }
    }

    /// Canonical lowercase string used in the DB and `<select>` values.
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::StartTls => "starttls",
            Self::Tls => "tls",
        }
    }
}

pub struct SmtpStatus {
    pub host: String,
    pub port: u16,
    pub username: String,
    pub from_email: String,
    pub from_name: Option<String>,
    pub tls_mode: String,
    pub enabled: bool,
    pub from_env: bool,
}

impl SmtpConfig {
    /// Get "from" Mailbox, compliant with RFC 5322
    pub(crate) fn mailbox_from(&self) -> Result<Mailbox> {
        Ok(Mailbox::new(
            self.from_name.clone(),
            self.from_email.parse()?,
        ))
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum StoredSmtpPasswordFormat {
    LyxalEnvelope,
    CalrsAesBase64,
}

pub fn determine_smtp_password_format(raw: &str) -> Result<StoredSmtpPasswordFormat> {
    if raw.trim().starts_with("enc:") {
        Ok(StoredSmtpPasswordFormat::LyxalEnvelope)
    } else {
        use base64::Engine;
        let bytes = base64::engine::general_purpose::STANDARD
            .decode(raw.trim())
            .map_err(|_| anyhow::anyhow!("Invalid SMTP password format"))?;
        if bytes.len() == 32 || bytes.len() >= 28 {
            Ok(StoredSmtpPasswordFormat::CalrsAesBase64)
        } else {
            bail!("Invalid SMTP password format")
        }
    }
}

fn optional_smtp_env(name: &str) -> Option<String> {
    std::env::var(name)
        .ok()
        .filter(|value| !value.trim().is_empty())
}

pub fn load_smtp_config_from_env() -> Result<Option<SmtpConfig>> {
    if !SMTP_ENV_VARS
        .iter()
        .any(|name| std::env::var_os(name).is_some())
    {
        return Ok(None);
    }

    let (host, username, password, from_email) = match (
        optional_smtp_env("CALRS_SMTP_HOST"),
        optional_smtp_env("CALRS_SMTP_USERNAME"),
        optional_smtp_env("CALRS_SMTP_PASSWORD"),
        optional_smtp_env("CALRS_SMTP_FROM_EMAIL"),
    ) {
        (Some(host), Some(username), Some(password), Some(from_email)) => {
            (host, username, Zeroizing::new(password), from_email)
        }
        _ => {
            tracing::warn!(
                "partial CALRS_SMTP_* environment block (missing one of HOST/USERNAME/PASSWORD/FROM_EMAIL); falling back to database SMTP config"
            );
            return Ok(None);
        }
    };
    let port = match std::env::var("CALRS_SMTP_PORT") {
        Ok(value) if value.trim().is_empty() => bail!("CALRS_SMTP_PORT must not be empty"),
        Ok(value) => value.trim().parse::<u16>().map_err(|_| {
            anyhow::anyhow!("CALRS_SMTP_PORT must be a valid TCP port (got '{}')", value)
        })?,
        Err(_) => 587u16,
    };
    let tls_mode = match std::env::var("CALRS_SMTP_TLS_MODE") {
        Ok(value) if value.trim().is_empty() => bail!("CALRS_SMTP_TLS_MODE must not be empty"),
        Ok(value) => SmtpTlsMode::parse(&value)?,
        Err(_) => SmtpTlsMode::StartTls,
    };
    let from_name = std::env::var("CALRS_SMTP_FROM_NAME")
        .ok()
        .filter(|value| !value.trim().is_empty());

    Ok(Some(SmtpConfig {
        host,
        port,
        username,
        password,
        from_email,
        from_name,
        tls_mode,
    }))
}

pub fn smtp_env_active() -> bool {
    !matches!(load_smtp_config_from_env(), Ok(None))
}

#[derive(Debug, serde::Serialize)]
struct UpdateSmtpPasswordParams<'a> {
    record_id: surrealdb::RecordId,
    expected_old_value: &'a str,
    new_envelope: &'a str,
    language: &'a str,
}

#[derive(Debug, serde::Deserialize)]
struct UpdateSmtpPasswordResult {
    updated: bool,
}

/// Load SMTP config from environment or database.
///
/// NOTE [Ticket EMAIL-DB-001]: La migration du chargement SMTP vers la fonction SurrealQL
/// `fn::booking_get_smtp_config` + `store.call_fn(...)` fait l'objet d'un ticket dédié non-bloquant.
pub async fn load_smtp_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
) -> Result<Option<SmtpConfig>> {
    if let Some(config) = load_smtp_config_from_env()? {
        return Ok(Some(config));
    }

    let query = "SELECT host, port, username, password_enc, from_email, from_name, tls_mode FROM booking_setting:smtp_config WHERE enabled = true LIMIT 1";
    let mut response = store.client().query(query).await?;
    let row: Option<serde_json::Value> = response.take(0)?;

    if let Some(row) = row {
        let host = row["host"].as_str().unwrap_or("").to_string();
        let port = row["port"].as_u64().unwrap_or(587) as u16;
        let username = row["username"].as_str().unwrap_or("").to_string();
        let password_enc = row["password_enc"].as_str().unwrap_or("");
        let from_email = row["from_email"].as_str().unwrap_or("").to_string();
        let from_name = row["from_name"].as_str().map(|s| s.to_string());
        let tls_mode_str = row["tls_mode"].as_str().unwrap_or("starttls");
        let tls_mode = SmtpTlsMode::parse(tls_mode_str).unwrap_or(SmtpTlsMode::StartTls);

        let setting_id = surrealdb::RecordId::from(("booking_setting", "smtp_config"));
        let context = crate::crypto_helpers::smtp_password_context(tenant, &setting_id)?;

        let password = match determine_smtp_password_format(password_enc)? {
            StoredSmtpPasswordFormat::LyxalEnvelope => {
                let bytes = crypto.decrypt_secret(password_enc, &context)?;
                zeroize::Zeroizing::new(String::from_utf8((*bytes).clone())?)
            }
            StoredSmtpPasswordFormat::CalrsAesBase64 => {
                let key = legacy_key.ok_or_else(|| {
                    anyhow::anyhow!("Legacy AES key required to decrypt legacy SMTP password")
                })?;
                let modern_envelope = crypto.migrate_calrs_aes_base64(key, password_enc, &context)?;
                let plaintext_bytes = crypto.decrypt_secret(&modern_envelope, &context)?;

                // Best-effort persistence via SurrealQL fn::booking_update_smtp_password
                let params = serde_json::json!({
                    "record_id": setting_id,
                    "expected_old_value": password_enc,
                    "new_envelope": modern_envelope,
                    "language": "fr",
                });

                match store
                    .call_fn::<UpdateSmtpPasswordResult, _>("booking_update_smtp_password", params)
                    .await
                {
                    Ok(res) if res.updated => {
                        tracing::debug!("Persisted migrated SMTP secret envelope");
                    }
                    Ok(_) => {
                        tracing::debug!(
                            "SMTP secret migration was not persisted because stored value changed"
                        );
                    }
                    Err(err) => {
                        tracing::warn!(
                            error = %err,
                            "SMTP secret was decrypted but its migrated envelope could not be persisted"
                        );
                    }
                }

                zeroize::Zeroizing::new(String::from_utf8((*plaintext_bytes).clone())?)
            }
        };

        Ok(Some(SmtpConfig {
            host,
            port,
            username,
            password,
            from_email,
            from_name,
            tls_mode,
        }))
    } else {
        Ok(None)
    }
}

pub async fn load_smtp_status(store: &SurrealBookingStore) -> Result<Option<SmtpStatus>> {
    if let Some(config) = load_smtp_config_from_env()? {
        return Ok(Some(SmtpStatus {
            host: config.host,
            port: config.port,
            username: config.username,
            from_email: config.from_email,
            from_name: config.from_name,
            tls_mode: config.tls_mode.as_str().to_string(),
            enabled: true,
            from_env: true,
        }));
    }

    let query = "SELECT host, port, username, from_email, from_name, tls_mode, enabled FROM booking_setting:smtp_config ORDER BY enabled DESC LIMIT 1";
    let mut response = store.client().query(query).await?;
    let row: Option<serde_json::Value> = response.take(0)?;

    Ok(row.map(|r| SmtpStatus {
        host: r["host"].as_str().unwrap_or("").to_string(),
        port: r["port"].as_u64().unwrap_or(587) as u16,
        username: r["username"].as_str().unwrap_or("").to_string(),
        from_email: r["from_email"].as_str().unwrap_or("").to_string(),
        from_name: r["from_name"].as_str().map(|s| s.to_string()),
        tls_mode: r["tls_mode"].as_str().unwrap_or("starttls").to_string(),
        enabled: r["enabled"].as_bool().unwrap_or(false),
        from_env: false,
    }))
}
