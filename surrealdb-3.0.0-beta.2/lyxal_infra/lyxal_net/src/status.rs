use serde::Serialize;

use std::net::SocketAddr;

#[derive(Debug, Clone, Copy, PartialEq, Serialize)]
pub enum PeerHealth {
    Disconnected,
    Healthy,
    Lagging,
    Syncing,
    NeedsSnapshot,
}

#[derive(Debug, Clone, Serialize)]
pub struct PeerStatus {
    pub health: PeerHealth,
    pub lag: u64,
    pub rtt_ms: u64,
}

#[derive(Debug)]
pub struct PeerContext {
    pub addr: SocketAddr,
    pub status: PeerStatus,
    /// Channel to send immediate sync triggers to the peer
    pub trigger_tx: tokio::sync::mpsc::Sender<()>,
}

impl Clone for PeerContext {
    fn clone(&self) -> Self {
        Self {
            addr: self.addr,
            status: self.status.clone(),
            trigger_tx: self.trigger_tx.clone(),
        }
    }
}

// Serializable view for API
#[derive(Debug, Clone, Serialize)]
pub struct PeerContextView {
    pub addr: SocketAddr,
    pub status: PeerStatus,
}

impl From<PeerContext> for PeerContextView {
    fn from(ctx: PeerContext) -> Self {
        Self {
            addr: ctx.addr,
            status: ctx.status,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize)]
pub enum SyncState {
    Running,
    Draining,
    Stopped,
}

#[derive(Debug, Clone, Serialize)]
pub struct SyncStatus {
    pub node_id: u128,
    pub state: SyncState,
    pub connected_peers: u64,
    pub active_transfers: u64,
    pub uptime_secs: u64,
    pub last_error: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize)]
pub enum DrainResult {
    Completed,
    TimedOut,
    Forced,
}

#[derive(Debug, Clone, Serialize)]
pub struct DrainReport {
    pub result: DrainResult,
    pub active_transfers_before: u64,
    pub active_transfers_remaining: u64,
    pub duration_ms: u64,
    pub state_before: SyncState,
    pub state_after: SyncState,
}
