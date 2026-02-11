use async_trait::async_trait;
use lyxal_net::boot::{BootContext};
use lyxal_net::provider::SyncProvider;
use lyxal_net::store::SyncStore;
use lyxal_net::lyxal_store::LyxalStore;
use lyxal_net::status::{DrainReport, DrainResult};
use lyxal_net::identity::NodeIdentity;
use lyxalkv::{TreeBuilder};
use crate::service::{KernelService, ServiceId, ServiceCapabilities, ServiceHealth, ServiceStatus};
use std::sync::Arc;
use std::time::Duration;
use tracing::{info, warn, error};
use tokio::sync::RwLock;
use lyxal_sync::log::LogWireItem;

struct SyncServiceState {
    provider: Option<Arc<SyncProvider>>,
    store: Option<Arc<dyn SyncStore + Send + Sync>>,
    status: ServiceStatus,
    consensus_tx: Option<tokio::sync::mpsc::Sender<lyxal_sync::protocol::LspMessage>>,
    ledger_rx: Option<tokio::sync::mpsc::Receiver<LogWireItem>>,
}

pub struct SyncService {
    state: RwLock<SyncServiceState>,
}

impl SyncService {
    pub fn new(store: Option<Arc<dyn SyncStore + Send + Sync>>) -> Self {
        Self {
            state: RwLock::new(SyncServiceState {
                provider: None,
                store,
                status: ServiceStatus::Stopped,
                consensus_tx: None,
                ledger_rx: None,
            }),
        }
    }

    /// P32: Inject a shared KV Tree to use as the sync backend
    pub async fn with_shared_tree(&self, tree: Arc<lyxalkv::Tree>, node_id: u128) {
        let mut guard = self.state.write().await;
        guard.store = Some(Arc::new(LyxalStore::new(tree, node_id)));
    }

    pub async fn register_control_channel(&self, tx: tokio::sync::mpsc::Sender<lyxal_sync::protocol::LspMessage>) {
        let mut guard = self.state.write().await;
        guard.consensus_tx = Some(tx);
    }

    pub async fn set_ledger_channel(&self, rx: tokio::sync::mpsc::Receiver<LogWireItem>) {
        let mut guard = self.state.write().await;
        guard.ledger_rx = Some(rx);
    }

    pub async fn controller(&self) -> Option<lyxal_net::SyncController> {
        let guard = self.state.read().await;
        if let Some(p) = &guard.provider {
            Some(lyxal_net::SyncController::new(&p))
        } else {
            None
        }
    }

    /// Background task to consume ledger events and broadcast them via SyncProvider
    async fn run_ledger_pump(provider: Arc<SyncProvider>, mut rx: tokio::sync::mpsc::Receiver<LogWireItem>) {
        info!("SyncService: Ledger Pump Started.");
        while let Some(item) = rx.recv().await {
            // P20.7: Broadcast the log item to peers
            // SyncProvider handles strict ordering and replication
            if let Err(e) = provider.broadcast_log_item(item).await {
                error!("SyncService: Failed to broadcast ledger item: {}", e);
            }
        }
        info!("SyncService: Ledger Pump Stopped.");
    }
}

#[async_trait]
impl KernelService for SyncService {
    fn id(&self) -> ServiceId {
        ServiceId("lyxal.sync.v1".to_string())
    }

    fn capabilities(&self) -> ServiceCapabilities {
        ServiceCapabilities {
            service_name: "Lyxal Sync".to_string(),
            version: "0.1.0".to_string(),
            features: vec!["p2p".into(), "discovery".into(), "security".into()],
        }
    }

    fn as_any(&self) -> &dyn std::any::Any {
        self
    }

    fn health(&self) -> ServiceHealth {
        let status = if let Ok(guard) = self.state.try_read() {
            guard.status.clone()
        } else {
             ServiceStatus::Running 
        };
        
        let active = if let Ok(guard) = self.state.try_read() {
            if let Some(p) = &guard.provider {
                p.active_transfers().load(std::sync::atomic::Ordering::Relaxed)
            } else { 0 }
        } else { 0 };

        ServiceHealth {
            id: self.id(),
            status,
            active_tasks: active,
            uptime_secs: 0, 
        }
    }

    async fn start(&self, ctx: &BootContext) -> Result<(), anyhow::Error> {
        info!("Kernel: Starting SyncService...");
        let mut guard = self.state.write().await;
        
        if guard.status != ServiceStatus::Stopped {
            warn!("Service already running or failed.");
            return Ok(());
        }

        guard.status = ServiceStatus::Starting;

        // 1. Resolve Store
        let store = if let Some(s) = guard.store.clone() {
            s
        } else {
            let store_path = ctx.paths.data_dir.join("store");
            let identity_path = &ctx.config.static_cfg.identity_path;
            let identity = NodeIdentity::load_or_generate(identity_path).map_err(|e| anyhow::anyhow!(e))?;
            
            let tree = TreeBuilder::new()
                .with_path(store_path)
                .build()
                .map_err(|e| anyhow::anyhow!(e))?;
            let tree = Arc::new(tree);
            
            Arc::new(LyxalStore::new(tree, identity.node_id))
        };
        
        // 2. Start Provider
        let quota = ctx.quota.clone();
        let stats = ctx.stats.clone().ok_or_else(|| anyhow::anyhow!("BootContext missing RealmRuntimeStats for SyncService"))?;
        
        let provider = SyncProvider::start(ctx.config.clone(), store, stats, quota, ctx.observer.clone()).await.map_err(|e| anyhow::anyhow!(e))?;
        
        // P23: Register Consensus Channel
        if let Some(tx) = &guard.consensus_tx {
            provider.register_control_channel(tx.clone()).await;
        }

        // P32: Start Ledger Pump
        if let Some(rx) = guard.ledger_rx.take() {
            let p = provider.clone();
            tokio::spawn(async move {
                Self::run_ledger_pump(p, rx).await;
            });
        } else {
            warn!("SyncService: No ledger channel connected. Ledger replication disabled.");
        }

        guard.provider = Some(provider);
        guard.status = ServiceStatus::Running;
        
        info!("Kernel: SyncService Started.");
        Ok(())
    }

    async fn drain(&self, deadline: Duration) -> DrainReport {
        let guard = self.state.read().await;
        if let Some(p) = &guard.provider {
             return p.drain(deadline).await;
        }
        DrainReport { 
            result: DrainResult::Completed, 
            active_transfers_before: 0,
            active_transfers_remaining: 0,
            duration_ms: 0,
            state_before: lyxal_net::status::SyncState::Stopped,
            state_after: lyxal_net::status::SyncState::Stopped,
        }
    }

    async fn shutdown(&self) -> Result<(), anyhow::Error> {
        let mut guard = self.state.write().await;
        
        info!("Kernel: Shutting down SyncService...");
        guard.status = ServiceStatus::Draining; 
        
        if let Some(p) = &guard.provider {
            p.shutdown().await.map_err(|e| anyhow::anyhow!(e))?;
        }
        
        guard.provider = None;
        guard.status = ServiceStatus::Stopped;
        info!("Kernel: SyncService Stopped.");
        
        Ok(())
    }
}
