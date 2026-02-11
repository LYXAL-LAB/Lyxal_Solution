use async_trait::async_trait;
use lyxal_net::boot::BootContext;
use lyxal_net::status::DrainReport;
use std::time::Duration;
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct ServiceId(pub String);

impl std::fmt::Display for ServiceId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceCapabilities {
    pub service_name: String,
    pub version: String,
    pub features: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum ServiceStatus {
    Starting,
    Running,
    Draining,
    Stopped,
    Failed(String),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceHealth {
    pub id: ServiceId,
    pub status: ServiceStatus,
    pub active_tasks: u64,
    pub uptime_secs: u64,
}

#[async_trait]
pub trait KernelService: Send + Sync {
    fn id(&self) -> ServiceId;
    fn capabilities(&self) -> ServiceCapabilities;
    fn as_any(&self) -> &dyn std::any::Any;
    
    // Non-blocking health check
    fn health(&self) -> ServiceHealth;

    // Lifecycle
    async fn start(&self, ctx: &BootContext) -> Result<(), anyhow::Error>;
    async fn drain(&self, deadline: Duration) -> DrainReport;
    async fn shutdown(&self) -> Result<(), anyhow::Error>;
}
