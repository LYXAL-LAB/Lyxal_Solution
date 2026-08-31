//! Shared SSRF Outbound Network Security Validator for Lyxal Booking.

use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use thiserror::Error;
use url::Url;

#[derive(Debug, Error)]
pub enum SsrfValidationError {
    #[error("Invalid URL syntax: {0}")]
    InvalidUrl(#[from] url::ParseError),

    #[error("Unsupported scheme: '{0}' (only http and https are allowed)")]
    UnsupportedScheme(String),

    #[error("Missing host in URL")]
    MissingHost,

    #[error("Credentials in URL are forbidden")]
    CredentialsForbidden,

    #[error("Host resolves to forbidden private IP address: {0}")]
    ForbiddenPrivateIp(IpAddr),

    #[error("DNS resolution failed for host '{0}': {1}")]
    DnsResolutionFailed(String, std::io::Error),
}

/// Checks if an IPv4 address is considered private/restricted unless explicitly allowed.
fn is_forbidden_ipv4(ip: Ipv4Addr) -> bool {
    let octets = ip.octets();

    // Loopback 127.0.0.0/8
    if ip.is_loopback() || octets[0] == 127 {
        return true;
    }

    // Unspecified 0.0.0.0 or Broadcast 255.255.255.255
    if ip.is_unspecified() || ip.is_broadcast() {
        return true;
    }

    // Private 10.0.0.0/8
    if octets[0] == 10 {
        return true;
    }

    // Private 172.16.0.0/12
    if octets[0] == 172 && (16..=31).contains(&octets[1]) {
        return true;
    }

    // Private 192.168.0.0/16
    if octets[0] == 192 && octets[1] == 168 {
        return true;
    }

    // Link-local / Cloud Metadata 169.254.0.0/16
    if octets[0] == 169 && octets[1] == 254 {
        return true;
    }

    false
}

/// Checks if an IPv6 address is considered private/restricted unless explicitly allowed.
fn is_forbidden_ipv6(ip: Ipv6Addr) -> bool {
    if ip.is_loopback() || ip.is_unspecified() {
        return true;
    }

    let segments = ip.segments();

    // Unique Local fc00::/7
    if (segments[0] & 0xfe00) == 0xfc00 {
        return true;
    }

    // Link Local fe80::/10
    if (segments[0] & 0xffc0) == 0xfe80 {
        return true;
    }

    // IPv4-mapped IPv6 addresses (e.g. ::ffff:127.0.0.1)
    if let Some(v4) = ip.to_ipv4_mapped() {
        return is_forbidden_ipv4(v4);
    }

    false
}

/// Check whether a hostname or IP string is explicitly permitted by the allowlist.
fn is_host_in_allowlist(host_str: &str, allowlist: &[String]) -> bool {
    let host_trimmed = host_str.trim().trim_start_matches('[').trim_end_matches(']').to_ascii_lowercase();
    for allowed in allowlist {
        let allowed_trimmed = allowed.trim().trim_start_matches('[').trim_end_matches(']').to_ascii_lowercase();
        if allowed_trimmed == "*" || allowed_trimmed == host_trimmed {
            return true;
        }
    }
    false
}

/// Validate an outbound URL against SSRF policy:
/// 1. Parse scheme (must be http or https)
/// 2. Host present & no user/password credentials
/// 3. Resolve host IPs and verify none fall into forbidden loopback, private, link-local or metadata ranges
///    unless matching the configured allowlist.
pub async fn validate_outbound_url(
    raw_url: &str,
    allowlist: &[String],
) -> Result<Url, SsrfValidationError> {
    let parsed = Url::parse(raw_url.trim())?;

    if !matches!(parsed.scheme(), "http" | "https") {
        return Err(SsrfValidationError::UnsupportedScheme(
            parsed.scheme().to_string(),
        ));
    }

    let host_str = parsed.host_str().ok_or(SsrfValidationError::MissingHost)?;
    if host_str.trim().is_empty() {
        return Err(SsrfValidationError::MissingHost);
    }

    if !parsed.username().is_empty() || parsed.password().is_some() {
        return Err(SsrfValidationError::CredentialsForbidden);
    }

    // If host is explicitly in allowlist, bypass IP check
    if is_host_in_allowlist(host_str, allowlist) {
        return Ok(parsed);
    }

    // Resolve host to socket addresses and check all returned IPs
    let port = parsed.port_or_known_default().unwrap_or(80);
    let socket_str = format!("{}:{}", host_str, port);

    let addrs = tokio::net::lookup_host(&socket_str)
        .await
        .map_err(|e| SsrfValidationError::DnsResolutionFailed(host_str.to_string(), e))?;

    for socket_addr in addrs {
        let ip = socket_addr.ip();
        if is_host_in_allowlist(&ip.to_string(), allowlist) {
            continue;
        }

        let is_forbidden = match ip {
            IpAddr::V4(v4) => is_forbidden_ipv4(v4),
            IpAddr::V6(v6) => is_forbidden_ipv6(v6),
        };

        if is_forbidden {
            return Err(SsrfValidationError::ForbiddenPrivateIp(ip));
        }
    }

    Ok(parsed)
}

/// Create an HTTP client configured with no-redirect policy to prevent redirect-based SSRF bypass.
pub fn build_ssrf_safe_client(timeout_secs: u64) -> Result<reqwest::Client, reqwest::Error> {
    reqwest::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .timeout(std::time::Duration::from_secs(timeout_secs))
        .build()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn rejects_loopback_and_metadata() {
        let allowlist = vec![];
        assert!(validate_outbound_url("http://127.0.0.1/api", &allowlist).await.is_err());
        assert!(validate_outbound_url("http://169.254.169.254/latest/meta-data", &allowlist).await.is_err());
        assert!(validate_outbound_url("http://[::1]/status", &allowlist).await.is_err());
    }

    #[tokio::test]
    async fn accepts_allowed_private_host() {
        let allowlist = vec!["127.0.0.1".to_string(), "meet.internal".to_string()];
        assert!(validate_outbound_url("http://127.0.0.1/api", &allowlist).await.is_ok());
    }

    #[tokio::test]
    async fn rejects_credentials_and_bad_schemes() {
        let allowlist = vec![];
        assert!(validate_outbound_url("ftp://example.com", &allowlist).await.is_err());
        assert!(validate_outbound_url("http://admin:pass@example.com", &allowlist).await.is_err());
    }
}
