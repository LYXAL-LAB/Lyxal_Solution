use std::time::Duration;
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Profile {
    Dev,
    Prod,
    Edge,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StaticConfig {
    pub profile: Profile,
    pub bind_addr: String,
    pub max_frame_size: u64,
    pub node_id: u128,
    pub realm_id: u128, // P20.4 Protocol Realm-Aware
    pub identity_path: std::path::PathBuf,
    pub trust_store_path: std::path::PathBuf,
    
    // Discovery (Defaults derived from Profile)
    pub seeds: Vec<String>,
    pub connect_on_start: bool,
    pub bootstrap_interval_secs: u64,
    pub max_outbound_peers: usize,
    pub dial_timeout_ms: u64,
    pub per_addr_cooldown_secs: u64,
    pub max_candidates: usize,
    pub candidate_ttl_secs: u64,
    pub max_concurrent_dials: usize,
    
    pub dial_rate_limit: RateLimitConfig,
    pub backoff: BackoffConfig,
    
    // Security
    pub allow_non_tls: bool,
    pub psk_path: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RateLimitConfig {
    pub max_dials: usize,
    pub window_secs: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BackoffConfig {
    pub base_ms: u64,
    pub max_ms: u64,
    pub jitter: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DynamicConfig {
    pub handshake_timeout: Duration,
    pub idle_timeout: Duration,
    pub sync_timeout: Duration,
    pub drain_timeout: Duration,
    pub delta_threshold: u64,
    pub snapshot_rate_global: Duration,
    pub snapshot_rate_peer: Duration,
    pub max_snapshot_bytes: u64,
    pub max_delta_items: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SyncConfig {
    pub static_cfg: StaticConfig,
    pub dynamic_cfg: DynamicConfig,
}

impl StaticConfig {
    pub fn new(profile: Profile) -> Self {
        match profile {
            Profile::Dev => Self {
                profile,
                bind_addr: "0.0.0.0:9000".to_string(),
                node_id: 0,
                realm_id: 0,
                max_frame_size: 10 * 1024 * 1024,
                identity_path: std::path::PathBuf::from("node.key"),
                trust_store_path: std::path::PathBuf::from("trusted_peers.toml"),
                seeds: Vec::new(),
                connect_on_start: true,
                bootstrap_interval_secs: 5,
                max_outbound_peers: 4,
                dial_timeout_ms: 5000,
                per_addr_cooldown_secs: 10,
                max_candidates: 32,
                candidate_ttl_secs: 600,
                max_concurrent_dials: 2,
                dial_rate_limit: RateLimitConfig { max_dials: 10, window_secs: 5 },
                backoff: BackoffConfig { base_ms: 500, max_ms: 10000, jitter: false },
                allow_non_tls: true,
                psk_path: None,
            },
            Profile::Prod => Self {
                profile,
                bind_addr: "0.0.0.0:9000".to_string(),
                node_id: 0,
                realm_id: 0,
                max_frame_size: 20 * 1024 * 1024,
                identity_path: std::path::PathBuf::from("node.key"), // Should be overridden by PathLayout
                trust_store_path: std::path::PathBuf::from("trusted_peers.toml"),
                seeds: Vec::new(),
                connect_on_start: true,
                bootstrap_interval_secs: 30, // Slower check in prod
                max_outbound_peers: 16,
                dial_timeout_ms: 2000,
                per_addr_cooldown_secs: 60,
                max_candidates: 256,
                candidate_ttl_secs: 300,
                max_concurrent_dials: 8,
                dial_rate_limit: RateLimitConfig { max_dials: 10, window_secs: 60 },
                backoff: BackoffConfig { base_ms: 1000, max_ms: 60000, jitter: true },
                allow_non_tls: false, // Strict
                psk_path: None,
            },
            Profile::Edge => Self {
                profile,
                bind_addr: "0.0.0.0:9000".to_string(),
                node_id: 0,
                realm_id: 0,
                max_frame_size: 5 * 1024 * 1024, // Restricted memory
                identity_path: std::path::PathBuf::from("node.key"),
                trust_store_path: std::path::PathBuf::from("trusted_peers.toml"),
                seeds: Vec::new(),
                connect_on_start: true,
                bootstrap_interval_secs: 60, // Passive
                max_outbound_peers: 4, // Low bandwidth
                dial_timeout_ms: 1000, // Fail fast
                per_addr_cooldown_secs: 300, // Long ban
                max_candidates: 64, 
                candidate_ttl_secs: 120, // Short memory
                max_concurrent_dials: 2,
                dial_rate_limit: RateLimitConfig { max_dials: 2, window_secs: 60 },
                backoff: BackoffConfig { base_ms: 2000, max_ms: 120000, jitter: true },
                allow_non_tls: false,
                psk_path: None,
            },
        }
    }
}

impl Default for StaticConfig {
    fn default() -> Self {
        Self::new(Profile::Dev)
    }
}

impl DynamicConfig {
    pub fn new(profile: Profile) -> Self {
        match profile {
            Profile::Dev => Self {
                handshake_timeout: Duration::from_secs(5),
                idle_timeout: Duration::from_secs(60),
                sync_timeout: Duration::from_secs(60),
                drain_timeout: Duration::from_secs(5),
                delta_threshold: 10,
                snapshot_rate_global: Duration::from_secs(30),
                snapshot_rate_peer: Duration::from_secs(10),
                max_snapshot_bytes: 100 * 1024 * 1024,
                max_delta_items: 20,
            },
            Profile::Prod => Self {
                handshake_timeout: Duration::from_secs(10),
                idle_timeout: Duration::from_secs(300),
                sync_timeout: Duration::from_secs(600),
                drain_timeout: Duration::from_secs(30),
                delta_threshold: 100,
                snapshot_rate_global: Duration::from_secs(3600), // 1h
                snapshot_rate_peer: Duration::from_secs(600), // 10m
                max_snapshot_bytes: 1024 * 1024 * 1024, // 1GB
                max_delta_items: 500,
            },
            Profile::Edge => Self {
                handshake_timeout: Duration::from_secs(5),
                idle_timeout: Duration::from_secs(120),
                sync_timeout: Duration::from_secs(120),
                drain_timeout: Duration::from_secs(10),
                delta_threshold: 20,
                snapshot_rate_global: Duration::from_secs(7200), // 2h
                snapshot_rate_peer: Duration::from_secs(1200), // 20m
                max_snapshot_bytes: 256 * 1024 * 1024, // 256MB
                max_delta_items: 50,
            }
        }
    }
}

impl Default for DynamicConfig {
    fn default() -> Self {
        Self::new(Profile::Dev)
    }
}
