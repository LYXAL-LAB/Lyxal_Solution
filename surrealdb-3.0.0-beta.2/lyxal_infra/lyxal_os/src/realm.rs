use serde::{Serialize, Deserialize};
use std::fmt;
use std::path::{Path, PathBuf};
// use lyxal_net::boot::BootContext;
use lyxal_net::identity::NodeIdentity;
use std::sync::Arc;
use lyxal_net::quotas::{RealmQuota, RealmRuntimeStats};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct RealmId(pub u128);

impl RealmId {
    pub fn new(id: u128) -> Self {
        Self(id)
    }
    
    // Canonical root realm (e.g. system realm)
    pub fn root() -> Self {
        Self(0)
    }
}

impl fmt::Display for RealmId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:032x}", self.0)
    }
}
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RealmState {
    Creating,
    Running,
    Draining,
    Stopped,
    Deleted,
    Failed,
}

impl fmt::Display for RealmState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RealmStatus {
    pub realm_id: RealmId,
    pub state: RealmState,
    pub uptime_secs: u64,
    pub active_peers: usize,
    pub active_transfers: u64,
    pub last_error: Option<String>,
}

#[derive(Debug, Clone)]
pub struct RealmPaths {
    pub root_dir: PathBuf,
    pub data_dir: PathBuf,
    pub log_dir: PathBuf,
}

// RealmQuota imported from lyxal_net::quotas

#[derive(Debug, Clone)]
pub struct RealmConfig {
    pub quota: RealmQuota,
    pub max_storage_bytes: u64,
    pub bind_addr: Option<String>,
}

impl Default for RealmConfig {
    fn default() -> Self {
        Self {
            quota: RealmQuota::default(),
            max_storage_bytes: 10 * 1024 * 1024 * 1024,
            bind_addr: None,
        }
    }
}

// RealmRuntimeStats imported from lyxal_net::quotas

#[derive(Debug, Clone)]
pub struct RealmContext {
    pub id: RealmId,
    pub owner_id: u128, // P27: AccountId
    pub paths: RealmPaths,
    pub config: RealmConfig,
    pub identity: Arc<NodeIdentity>,
    pub stats: Arc<RealmRuntimeStats>,
}

impl RealmContext {
    pub fn new(id: RealmId, owner_id: u128, base_os_path: &Path, identity: Arc<NodeIdentity>, config: RealmConfig) -> Self {
        let realm_root = base_os_path.join("realms").join(id.to_string());
        // RealmId.0 is the u128
        let stats = Arc::new(RealmRuntimeStats::new(id.0, &config.quota));
        Self {
            id,
            owner_id,
            paths: RealmPaths {
                data_dir: realm_root.join("data"),
                log_dir: realm_root.join("logs"),
                root_dir: realm_root,
            },
            config,
            identity,
            stats,
        }
    }
}
