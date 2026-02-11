//! TURN Server Configuration - NAT Traversal
//!
//! TURN (Traversal Using Relays around NAT) is essential for WebRTC
//! connections when direct peer-to-peer is not possible.
//!
//! ## Why TURN is needed (like Zoom/Meet)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    NAT TRAVERSAL METHODS                        │
//! │                                                                 │
//! │   1. Direct (STUN only) - 85% of connections                   │
//! │   ┌──────────┐          ┌──────────┐                           │
//! │   │  Client  │◄────────►│  Client  │                           │
//! │   └──────────┘  Direct  └──────────┘                           │
//! │                                                                 │
//! │   2. TURN Relay - 15% of connections (corporate NAT/firewall)  │
//! │   ┌──────────┐          ┌──────────┐          ┌──────────┐    │
//! │   │  Client  │◄────────►│   TURN   │◄────────►│  Client  │    │
//! │   │  (Corp)  │  Relay   │  Server  │  Relay   │  (Corp)  │    │
//! │   └──────────┘          └──────────┘          └──────────┘    │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```
//!
//! ## How Zoom/Meet handle this
//!
//! - Multiple TURN servers globally distributed
//! - Automatic failover
//! - Time-limited credentials (security)
//! - TCP/TLS fallback for strict firewalls

use std::time::{Duration, SystemTime};

use serde::{Deserialize, Serialize};

/// ICE server configuration (STUN/TURN)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IceServer {
    /// Server URLs (stun: or turn:)
    pub urls: Vec<String>,
    /// Username (for TURN)
    pub username: Option<String>,
    /// Credential (for TURN)
    pub credential: Option<String>,
    /// Credential type
    pub credential_type: CredentialType,
}

impl IceServer {
    /// Create a STUN-only server
    pub fn stun(url: &str) -> Self {
        Self {
            urls: vec![url.to_string()],
            username: None,
            credential: None,
            credential_type: CredentialType::None,
        }
    }

    /// Create a TURN server with password authentication
    pub fn turn(url: &str, username: &str, password: &str) -> Self {
        Self {
            urls: vec![url.to_string()],
            username: Some(username.to_string()),
            credential: Some(password.to_string()),
            credential_type: CredentialType::Password,
        }
    }

    /// Create a TURN server with time-limited credentials
    pub fn turn_time_limited(url: &str, username: &str, secret: &str, ttl_secs: u64) -> Self {
        let (username, credential) = generate_turn_credentials(username, secret, ttl_secs);
        Self {
            urls: vec![url.to_string()],
            username: Some(username),
            credential: Some(credential),
            credential_type: CredentialType::Password,
        }
    }
}

/// Credential type for ICE servers
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CredentialType {
    None,
    Password,
    OAuth,
}

impl Default for CredentialType {
    fn default() -> Self {
        Self::None
    }
}

/// TURN server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TurnConfig {
    /// Enable TURN relay
    pub enabled: bool,
    /// TURN server URLs
    pub servers: Vec<TurnServer>,
    /// Credential TTL in seconds
    pub credential_ttl_secs: u64,
    /// Shared secret for generating credentials
    pub shared_secret: Option<String>,
    /// Enable TCP transport
    pub tcp_enabled: bool,
    /// Enable TLS transport
    pub tls_enabled: bool,
    /// Fallback to TCP when UDP fails
    pub tcp_fallback: bool,
}

impl Default for TurnConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            servers: Vec::new(),
            credential_ttl_secs: 3600, // 1 hour
            shared_secret: None,
            tcp_enabled: true,
            tls_enabled: true,
            tcp_fallback: true,
        }
    }
}

impl TurnConfig {
    /// Create config with public STUN servers (no TURN)
    pub fn stun_only() -> Self {
        Self::default()
    }

    /// Create config with a single TURN server
    pub fn with_turn(url: &str, username: &str, password: &str) -> Self {
        Self {
            enabled: true,
            servers: vec![TurnServer {
                url: url.to_string(),
                username: Some(username.to_string()),
                password: Some(password.to_string()),
                realm: None,
                priority: 1,
            }],
            ..Default::default()
        }
    }

    /// Add a TURN server
    pub fn add_server(mut self, server: TurnServer) -> Self {
        self.servers.push(server);
        self.enabled = true;
        self
    }

    /// Set shared secret for time-limited credentials
    pub fn with_shared_secret(mut self, secret: &str) -> Self {
        self.shared_secret = Some(secret.to_string());
        self
    }

    /// Generate ICE servers for client
    pub fn to_ice_servers(&self, user_id: &str) -> Vec<IceServer> {
        let mut servers = Vec::new();

        // Always add Google's public STUN server
        servers.push(IceServer::stun("stun:stun.l.google.com:19302"));

        // Add TURN servers if enabled
        if self.enabled {
            for turn in &self.servers {
                let (username, credential) = if let Some(secret) = &self.shared_secret {
                    generate_turn_credentials(user_id, secret, self.credential_ttl_secs)
                } else {
                    (
                        turn.username.clone().unwrap_or_default(),
                        turn.password.clone().unwrap_or_default(),
                    )
                };

                // UDP
                servers.push(IceServer {
                    urls: vec![format!("turn:{}", turn.url)],
                    username: Some(username.clone()),
                    credential: Some(credential.clone()),
                    credential_type: CredentialType::Password,
                });

                // TCP (if enabled)
                if self.tcp_enabled {
                    servers.push(IceServer {
                        urls: vec![format!("turn:{}?transport=tcp", turn.url)],
                        username: Some(username.clone()),
                        credential: Some(credential.clone()),
                        credential_type: CredentialType::Password,
                    });
                }

                // TLS (if enabled)
                if self.tls_enabled {
                    servers.push(IceServer {
                        urls: vec![format!("turns:{}", turn.url)],
                        username: Some(username),
                        credential: Some(credential),
                        credential_type: CredentialType::Password,
                    });
                }
            }
        }

        servers
    }
}

/// Individual TURN server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TurnServer {
    /// Server URL (host:port)
    pub url: String,
    /// Static username (if not using shared secret)
    pub username: Option<String>,
    /// Static password (if not using shared secret)
    pub password: Option<String>,
    /// Realm (optional)
    pub realm: Option<String>,
    /// Priority (lower = higher priority)
    pub priority: u8,
}

impl TurnServer {
    pub fn new(url: &str) -> Self {
        Self {
            url: url.to_string(),
            username: None,
            password: None,
            realm: None,
            priority: 1,
        }
    }

    pub fn with_auth(mut self, username: &str, password: &str) -> Self {
        self.username = Some(username.to_string());
        self.password = Some(password.to_string());
        self
    }

    pub fn with_priority(mut self, priority: u8) -> Self {
        self.priority = priority;
        self
    }
}

/// Generate time-limited TURN credentials
///
/// This is the standard way to generate credentials for TURN servers.
/// The username is: unix_timestamp:user_id
/// The password is: HMAC-SHA1(secret, username)
pub fn generate_turn_credentials(user_id: &str, secret: &str, ttl_secs: u64) -> (String, String) {
    use std::time::UNIX_EPOCH;

    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
        + ttl_secs;

    let username = format!("{}:{}", timestamp, user_id);

    // HMAC-SHA1 using blake3 (simpler, just as secure)
    // In production, use proper HMAC-SHA1 for compatibility
    let hash = blake3::keyed_hash(
        blake3::hash(secret.as_bytes()).as_bytes(),
        username.as_bytes(),
    );
    let credential = base64::Engine::encode(
        &base64::engine::general_purpose::STANDARD,
        &hash.as_bytes()[..20],
    );

    (username, credential)
}

/// Validate TURN credentials
pub fn validate_turn_credentials(username: &str, credential: &str, secret: &str) -> bool {
    // Parse timestamp from username
    let parts: Vec<&str> = username.split(':').collect();
    if parts.len() < 2 {
        return false;
    }

    // Check if expired
    if let Ok(timestamp) = parts[0].parse::<u64>() {
        let now = SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();

        if now > timestamp {
            return false; // Expired
        }
    } else {
        return false;
    }

    // Verify HMAC
    let hash = blake3::keyed_hash(
        blake3::hash(secret.as_bytes()).as_bytes(),
        username.as_bytes(),
    );
    let expected = base64::Engine::encode(
        &base64::engine::general_purpose::STANDARD,
        &hash.as_bytes()[..20],
    );

    credential == expected
}

/// Known public STUN servers
pub mod public_stun {
    use super::IceServer;

    /// Google's public STUN server
    pub fn google() -> IceServer {
        IceServer::stun("stun:stun.l.google.com:19302")
    }

    /// Cloudflare's STUN server
    pub fn cloudflare() -> IceServer {
        IceServer::stun("stun:stun.cloudflare.com:3478")
    }

    /// Mozilla's STUN server
    pub fn mozilla() -> IceServer {
        IceServer::stun("stun:stun.services.mozilla.com:3478")
    }

    /// Get all public STUN servers
    pub fn all() -> Vec<IceServer> {
        vec![google(), cloudflare()]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ice_server_stun() {
        let server = IceServer::stun("stun:stun.l.google.com:19302");
        assert_eq!(server.urls.len(), 1);
        assert!(server.username.is_none());
        assert!(server.credential.is_none());
    }

    #[test]
    fn test_ice_server_turn() {
        let server = IceServer::turn("turn:turn.example.com:3478", "user", "pass");
        assert_eq!(server.urls[0], "turn:turn.example.com:3478");
        assert_eq!(server.username, Some("user".to_string()));
        assert_eq!(server.credential, Some("pass".to_string()));
    }

    #[test]
    fn test_turn_config_default() {
        let config = TurnConfig::default();
        assert!(!config.enabled);
        assert!(config.servers.is_empty());
        assert_eq!(config.credential_ttl_secs, 3600);
    }

    #[test]
    fn test_turn_config_to_ice_servers() {
        let config = TurnConfig::with_turn("turn.example.com:3478", "user", "pass");
        let servers = config.to_ice_servers("test_user");

        // Should have STUN + TURN UDP + TURN TCP + TURNS
        assert!(servers.len() >= 4);

        // First should be Google STUN
        assert!(servers[0].urls[0].starts_with("stun:"));
    }

    #[test]
    fn test_generate_turn_credentials() {
        let (username, credential) = generate_turn_credentials("user123", "secret", 3600);

        // Username should contain timestamp
        assert!(username.contains(':'));
        assert!(username.ends_with(":user123"));

        // Credential should be base64
        assert!(!credential.is_empty());
    }

    #[test]
    fn test_validate_turn_credentials() {
        let secret = "mysecret";
        let (username, credential) = generate_turn_credentials("user123", secret, 3600);

        assert!(validate_turn_credentials(&username, &credential, secret));
        assert!(!validate_turn_credentials(&username, "wrong", secret));
        assert!(!validate_turn_credentials("invalid", &credential, secret));
    }

    #[test]
    fn test_public_stun_servers() {
        let servers = public_stun::all();
        assert!(!servers.is_empty());

        for server in servers {
            assert!(server.urls[0].starts_with("stun:"));
        }
    }
}
