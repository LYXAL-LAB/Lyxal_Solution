//! Runtime settings that can be configured either via environment variables
//! (`LYXAL_BOOKING_*` with `CALRS_*` fallback) or persisted in SurrealDB (`booking_setting`).
//!
//! ## Precedence
//!
//! The **environment variable wins** when it is set and non-empty. The DB value
//! is used as a fallback. Environment values are validated during `load` with the
//! same strict rules as DB values.
//!
//! ## Process-Global Snapshot Cache & Resilience
//!
//! `private_host_allowlist()` and `base_url()` are read synchronously from deep
//! code paths. Settings are validated and stored atomically in a process-global
//! snapshot cache (`RuntimeSettingsCache`). Reads are synchronous, infallible, and lock-resilient.
//!
//! **Atomic Update Guarantee**: If a database error occurs or if any environment or DB value fails
//! validation during `load`, the existing snapshot cache is preserved without partial modification.

use crate::db::SurrealBookingStore;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use std::sync::{OnceLock, RwLock};
use thiserror::Error;

const DEFAULT_SETTINGS_LANGUAGE: &str = "fr";

/// Runtime settings error types.
#[derive(Debug, Error)]
pub enum SettingsError {
    #[error(transparent)]
    Database(#[from] lyxal_surreal::LyxalSurrealError),

    #[error("Invalid base URL: {0}")]
    InvalidBaseUrl(String),

    #[error("Invalid private-host allowlist entry: {0}")]
    InvalidHostEntry(String),
}

/// Unified process-global snapshot cache.
#[derive(Debug, Clone, Default)]
struct RuntimeSettingsCache {
    base_url_env: Option<String>,
    base_url_db: Option<String>,

    allow_private_hosts_env: Option<Vec<String>>,
    allow_private_hosts_db: Vec<String>,
}

static SETTINGS_CACHE: OnceLock<RwLock<RuntimeSettingsCache>> = OnceLock::new();
static WARNED_CALRS_BASE_URL: OnceLock<()> = OnceLock::new();
static WARNED_CALRS_ALLOW_HOSTS: OnceLock<()> = OnceLock::new();

fn cache() -> &'static RwLock<RuntimeSettingsCache> {
    SETTINGS_CACHE.get_or_init(|| RwLock::new(RuntimeSettingsCache::default()))
}

fn read_cache() -> RuntimeSettingsCache {
    cache()
        .read()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
        .clone()
}

fn replace_cache(next: RuntimeSettingsCache) {
    *cache()
        .write()
        .unwrap_or_else(|poisoned| poisoned.into_inner()) = next;
}

#[derive(Debug, Serialize)]
struct GetRuntimeSettingsParams<'a> {
    language: &'a str,
}

#[derive(Debug, Deserialize)]
struct RuntimeSettingsRecord {
    base_url: Option<String>,
    allow_private_hosts: Option<String>,
}

/// Read non-empty environment variable.
fn env_non_empty(key: &str) -> Option<String> {
    std::env::var(key)
        .ok()
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

/// Read and validate base URL from environment (`LYXAL_BOOKING_BASE_URL` with `CALRS_BASE_URL` fallback).
fn base_url_env_val() -> Result<Option<String>, SettingsError> {
    if let Some(val) = env_non_empty("LYXAL_BOOKING_BASE_URL") {
        return Ok(Some(normalize_base_url(&val)?));
    }
    if let Some(val) = env_non_empty("CALRS_BASE_URL") {
        WARNED_CALRS_BASE_URL.get_or_init(|| {
            tracing::warn!("CALRS_BASE_URL is deprecated; use LYXAL_BOOKING_BASE_URL instead");
        });
        return Ok(Some(normalize_base_url(&val)?));
    }
    Ok(None)
}

/// Read and validate private host allowlist from environment (`LYXAL_BOOKING_ALLOW_PRIVATE_HOSTS` with `CALRS_ALLOW_PRIVATE_HOSTS` fallback).
fn allow_private_hosts_env_val() -> Result<Option<Vec<String>>, SettingsError> {
    if let Some(val) = env_non_empty("LYXAL_BOOKING_ALLOW_PRIVATE_HOSTS") {
        let list = parse_host_list(&val)?;
        return Ok(if list.is_empty() { None } else { Some(list) });
    }
    if let Some(val) = env_non_empty("CALRS_ALLOW_PRIVATE_HOSTS") {
        WARNED_CALRS_ALLOW_HOSTS.get_or_init(|| {
            tracing::warn!("CALRS_ALLOW_PRIVATE_HOSTS is deprecated; use LYXAL_BOOKING_ALLOW_PRIVATE_HOSTS instead");
        });
        let list = parse_host_list(&val)?;
        return Ok(if list.is_empty() { None } else { Some(list) });
    }
    Ok(None)
}

/// Validate and normalize a base URL.
pub fn normalize_base_url(raw: &str) -> Result<String, SettingsError> {
    let raw = raw.trim();
    let mut url = url::Url::parse(raw)
        .map_err(|_| SettingsError::InvalidBaseUrl(raw.to_string()))?;

    if !matches!(url.scheme(), "http" | "https")
        || url.host_str().is_none()
        || !url.username().is_empty()
        || url.password().is_some()
    {
        return Err(SettingsError::InvalidBaseUrl(raw.to_string()));
    }

    url.set_query(None);
    url.set_fragment(None);

    let normalized = url.to_string();
    Ok(normalized.trim_end_matches('/').to_string())
}

/// Validate a single SSRF host entry (IPv4, IPv6, or single/multi-label DNS hostname).
pub fn normalize_host_entry(input: &str) -> Result<String, SettingsError> {
    let raw = input.trim().to_ascii_lowercase();

    if raw.is_empty()
        || raw.contains('/')
        || raw.contains('@')
        || raw.contains('*')
        || raw.chars().any(char::is_whitespace)
    {
        return Err(SettingsError::InvalidHostEntry(input.to_string()));
    }

    let candidate = raw
        .strip_prefix('[')
        .and_then(|v| v.strip_suffix(']'))
        .unwrap_or(&raw);

    // Always check IP before DNS host rules!
    if let Ok(ip) = candidate.parse::<std::net::IpAddr>() {
        return Ok(ip.to_string());
    }

    // At this stage, any remaining ':' is a port or invalid IPv6
    if candidate.contains(':') {
        return Err(SettingsError::InvalidHostEntry(input.to_string()));
    }

    let host = candidate.strip_suffix('.').unwrap_or(candidate);

    if host.is_empty() || host.len() > 253 {
        return Err(SettingsError::InvalidHostEntry(input.to_string()));
    }

    for label in host.split('.') {
        if label.is_empty()
            || label.len() > 63
            || label.starts_with('-')
            || label.ends_with('-')
            || !label.chars().all(|c| c.is_ascii_alphanumeric() || c == '-')
        {
            return Err(SettingsError::InvalidHostEntry(input.to_string()));
        }
    }

    Ok(host.to_string())
}

/// Parse a comma-separated host list into normalized, sorted, and deduplicated entries.
pub fn parse_host_list(raw: &str) -> Result<Vec<String>, SettingsError> {
    let mut list = Vec::new();
    for part in raw.split(',') {
        let trimmed = part.trim();
        if !trimmed.is_empty() {
            let normalized = normalize_host_entry(trimmed)?;
            list.push(normalized);
        }
    }
    list.sort();
    list.dedup();
    Ok(list)
}

/// Load and validate environment settings and SurrealDB settings into the process-global cache.
pub async fn load(store: &SurrealBookingStore) -> Result<(), SettingsError> {
    let base_url_env = base_url_env_val()?;
    let allow_private_hosts_env = allow_private_hosts_env_val()?;

    let stored: RuntimeSettingsRecord = store
        .call_fn(
            "booking_get_runtime_settings",
            GetRuntimeSettingsParams {
                language: DEFAULT_SETTINGS_LANGUAGE,
            },
        )
        .await?;

    let base_url_db = match stored.base_url.as_deref().map(str::trim).filter(|v| !v.is_empty()) {
        Some(raw) => Some(normalize_base_url(raw)?),
        None => None,
    };

    let allow_private_hosts_db = match stored
        .allow_private_hosts
        .as_deref()
        .map(str::trim)
        .filter(|v| !v.is_empty())
    {
        Some(raw) => parse_host_list(raw)?,
        None => Vec::new(),
    };

    replace_cache(RuntimeSettingsCache {
        base_url_env,
        base_url_db,
        allow_private_hosts_env,
        allow_private_hosts_db,
    });

    Ok(())
}

/// Alias for `load` to maintain backward compatibility with callers.
pub async fn load_from_db(store: &SurrealBookingStore) -> Result<(), SettingsError> {
    load(store).await
}

/// Whether the environment is overriding the base URL.
pub fn base_url_from_env() -> bool {
    read_cache().base_url_env.is_some()
}

/// Effective public base URL (env var if set, else DB value, else `None`).
pub fn base_url() -> Option<String> {
    let c = read_cache();
    c.base_url_env.or(c.base_url_db)
}

/// Persisted DB base URL ignoring environment overrides.
pub fn base_url_db() -> Option<String> {
    read_cache().base_url_db
}

/// Whether the environment is overriding the SSRF private host allowlist.
pub fn allow_private_hosts_from_env() -> bool {
    read_cache().allow_private_hosts_env.is_some()
}

/// Effective SSRF private-host allowlist (env var if set, else DB value, else empty).
pub fn private_host_allowlist() -> Vec<String> {
    let c = read_cache();
    c.allow_private_hosts_env.unwrap_or(c.allow_private_hosts_db)
}

/// Persisted DB allowlist ignoring environment overrides.
pub fn private_host_allowlist_db() -> Vec<String> {
    read_cache().allow_private_hosts_db
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_base_url_valid() {
        assert_eq!(
            normalize_base_url(" https://example.com/booking/ ").unwrap(),
            "https://example.com/booking"
        );
        assert_eq!(
            normalize_base_url("http://localhost:8080").unwrap(),
            "http://localhost:8080"
        );
    }

    #[test]
    fn test_normalize_base_url_invalid() {
        assert!(normalize_base_url("ftp://example.com").is_err());
        assert!(normalize_base_url("https://user:pass@example.com").is_err());
        assert!(normalize_base_url("javascript:alert(1)").is_err());
    }

    #[test]
    fn test_parse_host_list_valid_and_deduplicated() {
        let list = parse_host_list(" 127.0.0.1 , Radicale , 127.0.0.1 , [::1] ").unwrap();
        assert_eq!(list, vec!["127.0.0.1", "::1", "radicale"]);
    }

    #[test]
    fn test_normalize_host_entry_single_label_and_ipv6() {
        assert_eq!(normalize_host_entry("radicale").unwrap(), "radicale");
        assert_eq!(normalize_host_entry("[::1]").unwrap(), "::1");
        assert_eq!(normalize_host_entry("127.0.0.1").unwrap(), "127.0.0.1");
    }

    #[test]
    fn accepts_uncompressed_ipv6() {
        assert_eq!(
            normalize_host_entry("2001:db8:0:1:1:1:1:1").unwrap(),
            "2001:db8:0:1:1:1:1:1"
        );
    }

    #[test]
    fn rejects_hostname_with_port() {
        assert!(normalize_host_entry("example.com:8080").is_err());
    }

    #[test]
    fn test_normalize_host_entry_invalid() {
        assert!(normalize_host_entry("http://example.com").is_err());
        assert!(normalize_host_entry("*.internal").is_err());
        assert!(normalize_host_entry("-host").is_err());
        assert!(normalize_host_entry("foo..bar").is_err());
    }
}
