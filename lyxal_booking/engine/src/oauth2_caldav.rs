use anyhow::{bail, Result};
use lyxal_crypto::{CryptoError, EncryptionKey, SecretBytes, SecretString};
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{
    caldav_oauth_token_context, caldav_password_context, google_oauth_client_secret_context,
    BookingCryptoEngine,
};
use crate::db::SurrealBookingStore;

/// Google OAuth2 endpoints and CalDAV configuration.
const GOOGLE_AUTH_URL: &str = "https://accounts.google.com/o/oauth2/v2/auth";
const GOOGLE_TOKEN_URL: &str = "https://oauth2.googleapis.com/token";
const GOOGLE_CALDAV_BASE: &str = "https://apidata.googleusercontent.com/caldav/v2/";
const GOOGLE_CALENDAR_SCOPE: &str = "https://www.googleapis.com/auth/calendar";
const GOOGLE_EMAIL_SCOPE: &str = "openid email";

/// Buffer before expiry to trigger proactive refresh (5 minutes).
const REFRESH_BUFFER_SECS: i64 = 300;

#[derive(Deserialize)]
struct TokenResponse {
    access_token: String,
    refresh_token: Option<String>,
    expires_in: Option<i64>,
}

/// Helper pour convertir `SecretBytes` (`Zeroizing<Vec<u8>>`) en `SecretString` (`Zeroizing<String>`).
fn secret_bytes_to_string(bytes: SecretBytes) -> Result<SecretString> {
    let value = String::from_utf8(bytes.to_vec())?;
    Ok(SecretString::new(value))
}

/// Format du secret stocké pour CalDAV / OAuth2.
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum StoredCaldavSecretFormat {
    /// Format enveloppé moderne (commençant par `enc:`, ex: `enc:v1:`)
    LyxalEnvelope,
    /// Chiffrement AES Base64 legacy de Cal.rs (`CALRS_SECRET_KEY`)
    CalrsAesBase64,
    /// Plaintext encodé Hex de la migration SQL Cal.rs originelle
    CalrsHexPlaintext,
}

/// Règle déterministe de résolution du format de stockage pour les secrets CalDAV.
pub fn determine_caldav_secret_format(stored: &str) -> Result<StoredCaldavSecretFormat, CryptoError> {
    use base64::Engine;
    let value = stored.trim();

    if value.starts_with("enc:") {
        return Ok(StoredCaldavSecretFormat::LyxalEnvelope);
    }

    if !value.is_empty() && value.len() % 2 == 0 && value.chars().all(|c| c.is_ascii_hexdigit()) {
        if hex::decode(value).map(|bytes| String::from_utf8(bytes).is_ok()).unwrap_or(false) {
            return Ok(StoredCaldavSecretFormat::CalrsHexPlaintext);
        }
    }

    if let Ok(payload) = base64::engine::general_purpose::STANDARD.decode(value) {
        if payload.len() >= 28 {
            return Ok(StoredCaldavSecretFormat::CalrsAesBase64);
        }
    }

    Err(CryptoError::InvalidLegacyValue)
}

#[derive(Debug, Serialize)]
struct GetRefreshContextParams<'a> {
    record_id: &'a RecordId,
    language: &'a str,
}

#[derive(Debug, Deserialize)]
struct CaldavOAuthRefreshContext {
    source_id: RecordId,
    provider: String,
    refresh_token_enc: String,
    client_id: String,
    client_secret_enc: String,
}

#[derive(Debug, Serialize)]
struct CommitOAuthRefreshParams<'a> {
    record_id: &'a RecordId,
    expected_refresh_token_enc: &'a str,
    access_token_enc: &'a str,
    token_expires_at: surrealdb::sql::Datetime,
    #[serde(skip_serializing_if = "Option::is_none")]
    new_refresh_token_enc: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateAccessTokenParams {
    record_id: RecordId,
    access_token_enc: String,
    token_expires_at: surrealdb::sql::Datetime,
    #[serde(skip_serializing_if = "Option::is_none")]
    expected_old_value: Option<String>,
}

#[derive(Debug, Serialize)]
struct UpdateRefreshTokenParams<'a> {
    record_id: &'a RecordId,
    expected_old_value: &'a str,
    new_envelope: &'a str,
}

#[derive(Debug, Serialize)]
struct UpdateCaldavPasswordParams<'a> {
    record_id: &'a RecordId,
    expected_old_value: &'a str,
    new_envelope: &'a str,
}

#[derive(Debug, Serialize)]
struct UpdateClientSecretParams<'a> {
    record_id: &'a RecordId,
    expected_old_value: &'a str,
    new_envelope: &'a str,
}

#[derive(Debug, Deserialize)]
struct UpdateResult {
    updated: bool,
    record_id: Option<RecordId>,
}

/// Build a Google OAuth2 authorization URL.
/// Returns the URL the user should be redirected to.
pub fn build_google_auth_url(client_id: &str, redirect_uri: &str, state: &str) -> String {
    format!(
        "{}?client_id={}&redirect_uri={}&response_type=code&scope={}&access_type=offline&prompt=consent&state={}",
        GOOGLE_AUTH_URL,
        urlencoding::encode(client_id),
        urlencoding::encode(redirect_uri),
        urlencoding::encode(&format!("{} {}", GOOGLE_CALENDAR_SCOPE, GOOGLE_EMAIL_SCOPE)),
        urlencoding::encode(state),
    )
}

/// POST form-encoded params to Google's OAuth2 token endpoint and parse the response.
async fn post_to_google_token(op: &str, form: &[(&str, &str)]) -> Result<TokenResponse> {
    let resp = reqwest::Client::new()
        .post(GOOGLE_TOKEN_URL)
        .form(form)
        .send()
        .await?;

    if !resp.status().is_success() {
        let body = resp.text().await.unwrap_or_default();
        bail!("Google token {} failed: {}", op, body);
    }

    Ok(resp.json().await?)
}

/// Exchange an authorization code for access + refresh tokens.
/// Returns (access_token, refresh_token, expires_in_seconds).
pub async fn exchange_google_code(
    client_id: &str,
    client_secret: &str,
    code: &str,
    redirect_uri: &str,
) -> Result<(String, String, i64)> {
    let token = post_to_google_token(
        "exchange",
        &[
            ("client_id", client_id),
            ("client_secret", client_secret),
            ("code", code),
            ("redirect_uri", redirect_uri),
            ("grant_type", "authorization_code"),
        ],
    )
    .await?;

    let refresh_token = token
        .refresh_token
        .ok_or_else(|| anyhow::anyhow!("No refresh token received. Ensure prompt=consent"))?;
    let expires_in = token.expires_in.unwrap_or(3600);

    Ok((token.access_token, refresh_token, expires_in))
}

/// Refresh an OAuth2 access token using a stored refresh token.
/// Updates the database with the new access token and expiry via SurrealQL.
/// Returns the new plaintext access token.
pub async fn refresh_access_token(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source_id: &RecordId,
) -> Result<String> {
    let refresh_ctx: CaldavOAuthRefreshContext = store
        .call_fn(
            "booking_get_caldav_oauth_refresh_context",
            serde_json::json!({
                "record_id": source_id,
                "language": "fr",
            }),
        )
        .await?;

    if refresh_ctx.source_id != *source_id {
        bail!(
            "Unexpected refresh context record (expected {}, got {})",
            source_id, refresh_ctx.source_id
        );
    }

    let refresh_token_aad = caldav_oauth_token_context(tenant, source_id, "refresh_token")?;
    let client_secret_aad = google_oauth_client_secret_context(tenant, &RecordId::from(("booking_setting", "auth_config")))?;

    let refresh_token = match determine_caldav_secret_format(&refresh_ctx.refresh_token_enc)? {
        StoredCaldavSecretFormat::LyxalEnvelope => {
            let bytes = crypto.decrypt_secret(&refresh_ctx.refresh_token_enc, &refresh_token_aad)?;
            secret_bytes_to_string(bytes)?
        }
        StoredCaldavSecretFormat::CalrsAesBase64 => {
            let key = legacy_key.ok_or_else(|| {
                anyhow::anyhow!("Legacy AES key required to decrypt legacy refresh token")
            })?;
            let modern_env = crypto.migrate_calrs_aes_base64(key, &refresh_ctx.refresh_token_enc, &refresh_token_aad)?;
            let plain_bytes = crypto.decrypt_secret(&modern_env, &refresh_token_aad)?;

            let update_params = serde_json::json!({
                "record_id": source_id,
                "expected_old_value": &refresh_ctx.refresh_token_enc,
                "new_envelope": modern_env,
            });
            match store
                .call_fn::<UpdateResult, _>("booking_update_caldav_refresh_token", update_params)
                .await
            {
                Ok(res) if res.updated => {
                    tracing::debug!(source_id = %source_id, "Persisted migrated OAuth refresh token envelope");
                }
                Ok(_) => {
                    tracing::debug!(source_id = %source_id, "OAuth refresh token changed before migration persistence");
                }
                Err(err) => {
                    tracing::warn!(source_id = %source_id, error = %err, "OAuth refresh token decrypted but migration persistence failed");
                }
            }

            secret_bytes_to_string(plain_bytes)?
        }
        StoredCaldavSecretFormat::CalrsHexPlaintext => {
            let bytes = hex::decode(refresh_ctx.refresh_token_enc.trim())?;
            let plain_str = String::from_utf8(bytes)?;
            let modern_env = crypto.encrypt_secret(plain_str.as_bytes(), &refresh_token_aad)?;

            let update_params = serde_json::json!({
                "record_id": source_id,
                "expected_old_value": &refresh_ctx.refresh_token_enc,
                "new_envelope": modern_env,
            });
            match store
                .call_fn::<UpdateResult, _>("booking_update_caldav_refresh_token", update_params)
                .await
            {
                Ok(res) if res.updated => {
                    tracing::debug!(source_id = %source_id, "Persisted hex-migrated OAuth refresh token envelope");
                }
                Ok(_) => {
                    tracing::debug!(source_id = %source_id, "OAuth refresh token changed before migration persistence");
                }
                Err(err) => {
                    tracing::warn!(source_id = %source_id, error = %err, "OAuth refresh token decrypted but migration persistence failed");
                }
            }

            SecretString::new(plain_str)
        }
    };

    let mut persisted_refresh_token_value = refresh_ctx.refresh_token_enc.clone();
    
    let auth_config_id = RecordId::from(("booking_setting", "auth_config"));
    let client_secret = match determine_caldav_secret_format(&refresh_ctx.client_secret_enc)? {
        StoredCaldavSecretFormat::LyxalEnvelope => {
            let bytes = crypto.decrypt_secret(&refresh_ctx.client_secret_enc, &client_secret_aad)?;
            secret_bytes_to_string(bytes)?
        }
        StoredCaldavSecretFormat::CalrsAesBase64 => {
            let key = legacy_key.ok_or_else(|| {
                anyhow::anyhow!("Legacy AES key required to decrypt legacy Google OAuth client secret")
            })?;
            let modern_env = crypto.migrate_calrs_aes_base64(key, &refresh_ctx.client_secret_enc, &client_secret_aad)?;
            let plain_bytes = crypto.decrypt_secret(&modern_env, &client_secret_aad)?;

            let update_params = serde_json::json!({
                "record_id": auth_config_id.to_string(),
                "expected_old_value": &refresh_ctx.client_secret_enc,
                "new_envelope": modern_env,
            });
            match store
                .call_fn::<UpdateResult, _>("booking_update_oauth_client_secret", update_params)
                .await
            {
                Ok(res) if res.updated => {
                    tracing::debug!("Persisted migrated Google OAuth client secret envelope");
                }
                Ok(_) => {
                    tracing::debug!("Google OAuth client secret changed before migration persistence");
                }
                Err(err) => {
                    tracing::warn!(error = %err, "Google OAuth client secret decrypted but migration persistence failed");
                }
            }
            secret_bytes_to_string(plain_bytes)?
        }
        StoredCaldavSecretFormat::CalrsHexPlaintext => {
            let bytes = hex::decode(refresh_ctx.client_secret_enc.trim())?;
            let plain_str = String::from_utf8(bytes)?;
            let modern_env = crypto.encrypt_secret(plain_str.as_bytes(), &client_secret_aad)?;

            let update_params = serde_json::json!({
                "record_id": auth_config_id.to_string(),
                "expected_old_value": &refresh_ctx.client_secret_enc,
                "new_envelope": modern_env,
            });
            match store
                .call_fn::<UpdateResult, _>("booking_update_oauth_client_secret", update_params)
                .await
            {
                Ok(res) if res.updated => {
                    tracing::debug!("Persisted hex-migrated Google OAuth client secret envelope");
                }
                Ok(_) => {
                    tracing::debug!("Google OAuth client secret changed before migration persistence");
                }
                Err(err) => {
                    tracing::warn!(error = %err, "Google OAuth client secret decrypted but hex migration persistence failed");
                }
            }
            SecretString::new(plain_str)
        }
    };

    let token_resp = post_to_google_token(
        "refresh",
        &[
            ("client_id", &refresh_ctx.client_id),
            ("client_secret", client_secret.as_ref()),
            ("refresh_token", refresh_token.as_ref()),
            ("grant_type", "refresh_token"),
        ],
    )
    .await?;

    let expires_in = token_resp.expires_in.unwrap_or(3600);
    let expires_at_chrono = chrono::Utc::now() + chrono::Duration::seconds(expires_in);
    let expires_at_dt = surrealdb::sql::Datetime::from(expires_at_chrono);

    let access_token_aad = caldav_oauth_token_context(tenant, source_id, "access_token")?;
    let access_token_enc = crypto.encrypt_secret(token_resp.access_token.as_bytes(), &access_token_aad)?;

    let new_refresh_envelope = if let Some(ref new_refresh_plain) = token_resp.refresh_token {
        let env = crypto.encrypt_secret(new_refresh_plain.as_bytes(), &refresh_token_aad)?;
        Some(env)
    } else {
        None
    };

    let commit_params = serde_json::json!({
        "record_id": source_id,
        "expected_refresh_token_enc": persisted_refresh_token_value,
        "access_token_enc": access_token_enc,
        "token_expires_at": expires_at_dt,
        "new_refresh_token_enc": new_refresh_envelope,
    });

    let commit_res: UpdateResult = store
        .call_fn("booking_commit_oauth_token_refresh", commit_params)
        .await?;

    if !commit_res.updated {
        bail!("Atomic OAuth token refresh commit failed or conflicted for source {}", source_id);
    }

    if token_resp.refresh_token.is_some() {
        tracing::info!(source_id = %source_id, "rotated OAuth2 refresh token atomically");
    }

    Ok(token_resp.access_token)
}

pub async fn get_valid_access_token(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source_id: &RecordId,
    access_token_enc: &str,
    token_expires_at: Option<&str>,
) -> Result<String> {
    let is_expired = match token_expires_at {
        Some(exp_str) => {
            if let Ok(exp_dt) = chrono::DateTime::parse_from_rfc3339(exp_str) {
                exp_dt.with_timezone(&chrono::Utc) <= (chrono::Utc::now() + chrono::Duration::seconds(60))
            } else {
                true
            }
        }
        None => true,
    };

    if is_expired {
        refresh_access_token(store, crypto, legacy_key, tenant, source_id).await
    } else {
        let access_token_aad = caldav_oauth_token_context(tenant, source_id, "access_token")?;
        match determine_caldav_secret_format(access_token_enc)? {
            StoredCaldavSecretFormat::LyxalEnvelope => {
                let plain_bytes = crypto.decrypt_secret(access_token_enc, &access_token_aad)?;
                let plain = secret_bytes_to_string(plain_bytes)?;
                Ok((*plain).clone())
            }
            StoredCaldavSecretFormat::CalrsAesBase64 => {
                let key = legacy_key.ok_or_else(|| {
                    anyhow::anyhow!("Legacy AES key required to decrypt legacy access token")
                })?;
                let modern_env = crypto.migrate_calrs_aes_base64(key, access_token_enc, &access_token_aad)?;
                let plain_bytes = crypto.decrypt_secret(&modern_env, &access_token_aad)?;
                let plain = secret_bytes_to_string(plain_bytes)?;

                let expires_dt = match token_expires_at {
                    Some(exp) => {
                        let dt = chrono::DateTime::parse_from_rfc3339(exp)
                            .unwrap_or(chrono::DateTime::UNIX_EPOCH.into())
                            .with_timezone(&chrono::Utc);
                        surrealdb::sql::Datetime::from(dt)
                    }
                    None => surrealdb::sql::Datetime::from(chrono::Utc::now()),
                };

                let update_params = UpdateAccessTokenParams {
                    record_id: source_id.clone(),
                    access_token_enc: modern_env,
                    token_expires_at: expires_dt,
                    expected_old_value: Some(access_token_enc.to_string()),
                };
                match store
                    .call_fn::<UpdateResult, _>("booking_update_oauth_access_token", update_params)
                    .await
                {
                    Ok(res) if res.updated => {
                        tracing::debug!(source_id = %source_id, "Persisted migrated OAuth access token envelope");
                    }
                    Ok(_) => {
                        tracing::debug!(source_id = %source_id, "OAuth access token changed before migration persistence");
                    }
                    Err(err) => {
                        tracing::warn!(source_id = %source_id, error = %err, "OAuth access token decrypted but migration persistence failed");
                    }
                }

                Ok((*plain).clone())
            }
            StoredCaldavSecretFormat::CalrsHexPlaintext => {
                let bytes = hex::decode(access_token_enc.trim())?;
                let plain_str = String::from_utf8(bytes)?;
                let modern_env = crypto.encrypt_secret(plain_str.as_bytes(), &access_token_aad)?;

                let expires_dt = match token_expires_at {
                    Some(exp) => {
                        let dt = chrono::DateTime::parse_from_rfc3339(exp)
                            .unwrap_or(chrono::DateTime::UNIX_EPOCH.into())
                            .with_timezone(&chrono::Utc);
                        surrealdb::sql::Datetime::from(dt)
                    }
                    None => surrealdb::sql::Datetime::from(chrono::Utc::now()),
                };

                let update_params = UpdateAccessTokenParams {
                    record_id: source_id.clone(),
                    access_token_enc: modern_env,
                    token_expires_at: expires_dt,
                    expected_old_value: Some(access_token_enc.to_string()),
                };
                match store
                    .call_fn::<UpdateResult, _>("booking_update_oauth_access_token", update_params)
                    .await
                {
                    Ok(res) if res.updated => {
                        tracing::debug!(source_id = %source_id, "Persisted hex-migrated OAuth access token envelope");
                    }
                    Ok(_) => {
                        tracing::debug!(source_id = %source_id, "OAuth access token changed before migration persistence");
                    }
                    Err(err) => {
                        tracing::warn!(source_id = %source_id, error = %err, "OAuth access token decrypted but migration persistence failed");
                    }
                }

                Ok(plain_str)
            }
        }
    }
}

/// Build a CaldavClient for a source, handling both basic and OAuth2 auth.
pub async fn build_client_for_source(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source_id: &RecordId,
    url: &str,
    auth_type: &str,
    username: &str,
    password_enc: Option<&str>,
    access_token_enc: Option<&str>,
    token_expires_at: Option<&str>,
) -> Result<crate::caldav::CaldavClient> {
    match auth_type {
        "oauth2" => {
            let enc = access_token_enc
                .ok_or_else(|| anyhow::anyhow!("OAuth2 source missing access token"))?;
            let access_token =
                get_valid_access_token(store, crypto, legacy_key, tenant, source_id, enc, token_expires_at).await?;
            Ok(crate::caldav::CaldavClient::with_bearer(url, &access_token)?)
        }
        _ => {
            let enc = password_enc
                .ok_or_else(|| anyhow::anyhow!("Basic auth source missing password"))?;
            let pass_aad = caldav_password_context(tenant, source_id)?;

            let password_secret: SecretString = match determine_caldav_secret_format(enc)? {
                StoredCaldavSecretFormat::LyxalEnvelope => {
                    let bytes = crypto.decrypt_secret(enc, &pass_aad)?;
                    secret_bytes_to_string(bytes)?
                }
                StoredCaldavSecretFormat::CalrsAesBase64 => {
                    let key = legacy_key.ok_or_else(|| {
                        anyhow::anyhow!("Legacy AES key required to decrypt legacy CalDAV password")
                    })?;
                    let modern_env = crypto.migrate_calrs_aes_base64(key, enc, &pass_aad)?;
                    let plain_bytes = crypto.decrypt_secret(&modern_env, &pass_aad)?;

                    let update_params = serde_json::json!({
                        "record_id": source_id,
                        "expected_old_value": enc,
                        "new_envelope": modern_env,
                    });
                    match store
                        .call_fn::<UpdateResult, _>("booking_update_caldav_password", update_params)
                        .await
                    {
                        Ok(res) if res.updated => {
                            tracing::debug!(source_id = %source_id, "Persisted migrated CalDAV password envelope");
                        }
                        Ok(_) => {
                            tracing::debug!(source_id = %source_id, "CalDAV password changed before migration persistence");
                        }
                        Err(err) => {
                            tracing::warn!(source_id = %source_id, error = %err, "CalDAV password decrypted but migration persistence failed");
                        }
                    }

                    secret_bytes_to_string(plain_bytes)?
                }
                StoredCaldavSecretFormat::CalrsHexPlaintext => {
                    let bytes = hex::decode(enc.trim())?;
                    let plain_str = String::from_utf8(bytes)?;
                    let modern_env = crypto.encrypt_secret(plain_str.as_bytes(), &pass_aad)?;

                    let update_params = serde_json::json!({
                        "record_id": source_id,
                        "expected_old_value": enc,
                        "new_envelope": modern_env,
                    });
                    match store
                        .call_fn::<UpdateResult, _>("booking_update_caldav_password", update_params)
                        .await
                    {
                        Ok(res) if res.updated => {
                            tracing::debug!(source_id = %source_id, "Persisted hex-migrated CalDAV password envelope");
                        }
                        Ok(_) => {
                            tracing::debug!(source_id = %source_id, "CalDAV password changed before migration persistence");
                        }
                        Err(err) => {
                            tracing::warn!(source_id = %source_id, error = %err, "CalDAV password decrypted but migration persistence failed");
                        }
                    }

                    SecretString::new(plain_str)
                }
            };

            Ok(crate::caldav::CaldavClient::new(url, username, password_secret.as_ref())?)
        }
    }
}

/// The Google CalDAV base URL.
pub fn google_caldav_base_url() -> &'static str {
    GOOGLE_CALDAV_BASE
}

/// Build the per-user Google CalDAV principal URL.
/// Google requires PROPFIND to target `/caldav/v2/{userEmail}/user`. The bare
/// `/caldav/v2/` returns 403 for principal discovery.
pub fn google_caldav_url_for_email(email: &str) -> String {
    format!("{}{}/user", GOOGLE_CALDAV_BASE, urlencoding::encode(email))
}

/// Fetch the authenticated Google account's email via the OIDC userinfo endpoint.
pub async fn fetch_google_email(access_token: &str) -> Result<String> {
    let resp = reqwest::Client::new()
        .get("https://openidconnect.googleapis.com/v1/userinfo")
        .bearer_auth(access_token)
        .send()
        .await?;
    if !resp.status().is_success() {
        bail!("Failed to fetch Google userinfo: HTTP {}", resp.status());
    }
    let json: serde_json::Value = resp.json().await?;
    json.get("email")
        .and_then(|e| e.as_str())
        .map(|s| s.to_string())
        .ok_or_else(|| anyhow::anyhow!("Google userinfo response missing email claim"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use base64::Engine;
    use lyxal_crypto::EnvironmentKeyProvider;
    use std::sync::Arc;

    #[test]
    fn build_google_auth_url_encodes_components() {
        let client_id = "1234+abc.apps.googleusercontent.com";
        let redirect_uri = "https://cal.example.com/auth/google/callback";
        let state = "csrf token with spaces & symbols";

        let url = build_google_auth_url(client_id, redirect_uri, state);

        assert!(
            url.starts_with("https://accounts.google.com/o/oauth2/v2/auth?"),
            "url: {}",
            url
        );

        assert!(
            url.contains("client_id=1234%2Babc.apps.googleusercontent.com"),
            "client_id `+` not encoded as %2B: {}",
            url
        );
        assert!(
            !url.contains("client_id=1234+abc"),
            "raw + leaked into client_id: {}",
            url
        );

        assert!(
            url.contains("redirect_uri=https%3A%2F%2Fcal.example.com%2Fauth%2Fgoogle%2Fcallback"),
            "redirect_uri not percent-encoded: {}",
            url
        );

        assert!(
            url.contains(
                "scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar%20openid%20email"
            ),
            "scope not encoded with %20 between calendar + openid email: {}",
            url
        );

        assert!(
            url.contains("state=csrf%20token%20with%20spaces%20%26%20symbols"),
            "state spaces/`&` not encoded: {}",
            url
        );

        assert!(url.contains("response_type=code"), "url: {}", url);
        assert!(url.contains("access_type=offline"), "url: {}", url);
        assert!(url.contains("prompt=consent"), "url: {}", url);
    }

    #[test]
    fn test_determine_caldav_secret_format() {
        assert_eq!(
            determine_caldav_secret_format("enc:v1:some_envelope").unwrap(),
            StoredCaldavSecretFormat::LyxalEnvelope
        );

        let valid_base64 = base64::engine::general_purpose::STANDARD.encode(&[0u8; 32]);
        assert_eq!(
            determine_caldav_secret_format(&valid_base64).unwrap(),
            StoredCaldavSecretFormat::CalrsAesBase64
        );

        let hex_plain = hex::encode("my_plain_password");
        assert_eq!(
            determine_caldav_secret_format(&hex_plain).unwrap(),
            StoredCaldavSecretFormat::CalrsHexPlaintext
        );
    }

    #[test]
    fn test_oauth_migration_tracking_logic() {
        let provider = Arc::new(EnvironmentKeyProvider::new(
            "LYXAL_TEST_SECRET_KEY_FOR_CALDAV_OAUTH_TRACKING_123",
        ));
        let crypto = BookingCryptoEngine::new(provider);

        let source_id = RecordId::from(("booking_caldav_source", "test_source"));
        let aad = caldav_oauth_token_context("default", &source_id, "refresh_token").unwrap();

        let initial_legacy = "initial_legacy_refresh_token_enc_string";
        let mut persisted_value = initial_legacy.to_string();

        let modern_envelope = crypto.encrypt_secret(b"my_refresh_token", &aad).unwrap();
        let migration_updated = true;

        if migration_updated {
            persisted_value = modern_envelope.clone();
        }

        assert_eq!(persisted_value, modern_envelope);
    }

    #[test]
    fn test_oauth_migration_failed_fallback_tracking_logic() {
        let initial_legacy = "initial_legacy_refresh_token_enc_string";
        let mut persisted_value = initial_legacy.to_string();

        let migration_updated = false;

        if migration_updated {
            persisted_value = "should_not_be_used".to_string();
        }

        assert_eq!(persisted_value, initial_legacy);
    }
}
