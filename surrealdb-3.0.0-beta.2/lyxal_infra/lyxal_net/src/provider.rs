pub use crate::accounting_observer::AccountingObserver;
use crate::config::{DynamicConfig, SyncConfig};
use crate::discovery::DiscoveryManager;
use crate::error::{NetError, Result};
use crate::identity::NodeIdentity as PersistentIdentity;
use crate::peer::SyncPeer;
use crate::quotas::{PeerSlotGuard, RealmQuota, RealmRuntimeStats};
use crate::status::{DrainReport, DrainResult, PeerContext, PeerStatus, SyncState, SyncStatus};
use crate::store::SyncStore;
use crate::trust::TrustStore;
use lyxal_sync::log::LogWireItem;
use lyxal_sync::protocol::LspMessage;
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Arc, Mutex as StdMutex, Weak};
use std::time::Instant;
use tokio::net::TcpListener;
use tokio::sync::{Mutex, Notify, RwLock};
use tokio::sync::{Mutex as AsyncMutex, Semaphore};
use tokio::task::JoinHandle;

#[derive(Clone)]
pub struct CancellationToken {
	inner: Arc<Inner>,
}

struct Inner {
	cancelled: AtomicBool,
	notify: Notify,
	parent: Option<Weak<Inner>>,
}

impl CancellationToken {
	pub fn new() -> Self {
		Self {
			inner: Arc::new(Inner {
				cancelled: AtomicBool::new(false),
				notify: Notify::new(),
				parent: None,
			}),
		}
	}

	pub fn cancel(&self) {
		if !self.inner.cancelled.swap(true, Ordering::SeqCst) {
			self.inner.notify.notify_waiters();
		}
	}

	pub fn is_cancelled(&self) -> bool {
		if self.inner.cancelled.load(Ordering::SeqCst) {
			return true;
		}
		if let Some(parent) = self.inner.parent.as_ref().and_then(|p| p.upgrade()) {
			return CancellationToken {
				inner: parent,
			}
			.is_cancelled();
		}
		false
	}

	pub async fn cancelled(&self) {
		if self.is_cancelled() {
			return;
		}

		let local_wait = self.inner.notify.notified();

		if let Some(parent) = self.inner.parent.as_ref().and_then(|p| p.upgrade()) {
			let parent_token = CancellationToken {
				inner: parent,
			};
			tokio::select! {
				_ = local_wait => {},
				_ = Box::pin(async move { parent_token.cancelled().await }) => {},
			}
		} else {
			local_wait.await;
		}
	}

	pub fn child_token(&self) -> Self {
		Self {
			inner: Arc::new(Inner {
				cancelled: AtomicBool::new(false),
				notify: Notify::new(),
				parent: Some(Arc::downgrade(&self.inner)),
			}),
		}
	}
}

pub struct TransferGuard {
	counter: Arc<AtomicU64>,
}

impl TransferGuard {
	pub fn new(counter: Arc<AtomicU64>) -> Self {
		counter.fetch_add(1, Ordering::Relaxed);
		Self {
			counter,
		}
	}
}

impl Drop for TransferGuard {
	fn drop(&mut self) {
		self.counter.fetch_sub(1, Ordering::Relaxed);
	}
}

pub struct SyncProvider {
	store: Arc<dyn SyncStore + Send + Sync>,
	static_cfg: crate::config::StaticConfig,
	dynamic_cfg: Arc<RwLock<DynamicConfig>>,
	state: Arc<StdMutex<SyncState>>,
	draining: Arc<AtomicBool>,
	active_transfers: Arc<AtomicU64>,
	cancel: CancellationToken,
	handles: Mutex<Vec<JoinHandle<()>>>,
	start_time: Instant,
	// P23 Control Plane Hooks
	control_tx: Arc<RwLock<Option<tokio::sync::mpsc::Sender<LspMessage>>>>,

	// P14 Registry
	peers: Arc<RwLock<HashMap<u128, PeerContext>>>,
	// P14 Control Channels (map PeerId -> Sender)
	controls: Arc<RwLock<HashMap<u128, tokio::sync::mpsc::Sender<LspMessage>>>>,
	pub identity: Arc<PersistentIdentity>,
	pub trust_store: Arc<TrustStore>,
	discovery: Arc<AsyncMutex<DiscoveryManager>>,
	stats: Arc<RealmRuntimeStats>,
	quota: RealmQuota,
	pub observer: Option<Arc<dyn AccountingObserver>>,

	// P23: Raft Leader Hint
	pub leader_id: Arc<RwLock<Option<u128>>>,
}

impl SyncProvider {
	pub fn store(&self) -> &Arc<dyn SyncStore + Send + Sync> {
		&self.store
	}

	pub fn static_config(&self) -> &crate::config::StaticConfig {
		&self.static_cfg
	}

	pub fn dynamic_cfg(&self) -> &Arc<RwLock<DynamicConfig>> {
		&self.dynamic_cfg
	}

	pub fn active_transfers(&self) -> &Arc<AtomicU64> {
		&self.active_transfers
	}

	pub fn cancel_token(&self) -> &CancellationToken {
		&self.cancel
	}

	pub fn on_delta_sent(&self, bytes: u64) {
		self.stats.consume_bandwidth(bytes, &self.quota);
		if let Some(obs) = &self.observer {
			obs.on_delta_sent(self.static_cfg.realm_id, bytes);
		}
	}

	pub fn on_snapshot_sent(&self, bytes: u64) {
		self.stats.consume_bandwidth(bytes, &self.quota);
		if let Some(obs) = &self.observer {
			obs.on_snapshot_sent(self.static_cfg.realm_id, bytes);
		}
	}

	pub async fn start(
		config: SyncConfig,
		store: Arc<dyn SyncStore + Send + Sync>,
		stats: Arc<RealmRuntimeStats>,
		quota: RealmQuota,
		observer: Option<Arc<dyn AccountingObserver>>,
	) -> Result<Arc<Self>> {
		let cancel = CancellationToken::new();
		let draining = Arc::new(AtomicBool::new(false));
		let active_transfers = Arc::new(AtomicU64::new(0));
		let state = Arc::new(StdMutex::new(SyncState::Running));

		// P16: Load Persistent Identity
		let identity = PersistentIdentity::load_or_generate(&config.static_cfg.identity_path)?;
		// P20.5: Global Scoped Trust (pass realm_id)
		let trust_store =
			TrustStore::new(&config.static_cfg.trust_store_path, config.static_cfg.realm_id)?;

		// Update NodeID in config to match persistent identity
		let mut static_cfg = config.static_cfg;
		static_cfg.node_id = identity.node_id;

		// P17: Discovery Manager
		let discovery = Arc::new(AsyncMutex::new(DiscoveryManager::new(static_cfg.clone())));

		let provider = Arc::new(Self {
			store,
			static_cfg,
			dynamic_cfg: Arc::new(RwLock::new(config.dynamic_cfg)),
			state,
			draining,
			active_transfers,
			cancel: cancel.clone(),
			handles: Mutex::new(Vec::new()),
			start_time: Instant::now(),
			control_tx: Arc::new(RwLock::new(None)), // P23
			peers: Arc::new(RwLock::new(HashMap::new())),
			controls: Arc::new(RwLock::new(HashMap::new())),
			identity: Arc::new(identity),
			trust_store: Arc::new(trust_store),
			discovery: discovery.clone(),
			stats,
			quota,
			observer,
			leader_id: Arc::new(RwLock::new(None)),
		});

		let provider_c = provider.clone();
		let cancel_c = cancel.clone();
		let discovery_c = discovery.clone(); // For bootstrap loop

		// P17 Bootstrap Loop
		let provider_bg = provider.clone();
		tokio::spawn(async move {
			Self::bootstrap_loop(provider_bg, discovery_c, cancel_c).await;
		});
		let listener_handle = tokio::spawn(async move {
			if let Err(e) = provider_c.run_listener().await {
				log::error!("Listener error: {:?}", e);
			}
		});

		provider.handles.lock().await.push(listener_handle);

		Ok(provider)
	}

	pub fn try_acquire_peer_slot(&self) -> Result<PeerSlotGuard> {
		let current = self.stats.active_peers.load(Ordering::Relaxed);
		if current >= self.quota.max_peers {
			// Record metric
			if let Some(c) = crate::metrics::get_metrics()
				.realm_quota_rejects_peers
				.get(&self.static_cfg.realm_id)
			{
				c.fetch_add(1, Ordering::Relaxed);
			}
			return Err(NetError::Generic("Quota Exceeded: Max Peers".into()));
		}

		let prev = self.stats.active_peers.fetch_add(1, Ordering::SeqCst);
		if prev >= self.quota.max_peers {
			// Race condition lost, rollback
			self.stats.active_peers.fetch_sub(1, Ordering::SeqCst);
			if let Some(c) = crate::metrics::get_metrics()
				.realm_quota_rejects_peers
				.get(&self.static_cfg.realm_id)
			{
				c.fetch_add(1, Ordering::Relaxed);
			}
			return Err(NetError::Generic("Quota Exceeded: Max Peers (Race)".into()));
		}

		// Update Gauge
		if let Some(g) =
			crate::metrics::get_metrics().realm_active_peers.get(&self.static_cfg.realm_id)
		{
			g.store(prev + 1, Ordering::Relaxed);
		}

		Ok(PeerSlotGuard::new(self.stats.clone()))
	}

	// P21.3 Token Bucket Check
	pub fn try_consume_snapshot_token(&self) -> bool {
		// Refill logic
		let mut last_refill = self.stats.last_refill.lock().unwrap();
		let now = Instant::now();
		let elapsed = now.duration_since(*last_refill);
		let tokens_to_add =
			(elapsed.as_secs_f64() / 3600.0 * self.quota.max_snapshots_per_hour as f64) as u32;

		if tokens_to_add > 0 {
			*last_refill = now;
			let current = self.stats.snapshot_tokens.load(Ordering::Relaxed);
			let new_val = (current + tokens_to_add).min(self.quota.snapshot_bucket_size);
			self.stats.snapshot_tokens.store(new_val, Ordering::Relaxed);
		}

		// Consume
		let current_tokens = self.stats.snapshot_tokens.load(Ordering::Relaxed);
		if current_tokens > 0 {
			if self
				.stats
				.snapshot_tokens
				.compare_exchange(
					current_tokens,
					current_tokens - 1,
					Ordering::SeqCst,
					Ordering::Relaxed,
				)
				.is_ok()
			{
				if let Some(g) = crate::metrics::get_metrics()
					.realm_snapshot_tokens
					.get(&self.static_cfg.realm_id)
				{
					g.store(current_tokens - 1, Ordering::Relaxed);
				}
				return true;
			}
		}

		// Reject
		if let Some(c) = crate::metrics::get_metrics()
			.realm_quota_rejects_snapshots
			.get(&self.static_cfg.realm_id)
		{
			c.fetch_add(1, Ordering::Relaxed);
		}
		false
	}

	async fn run_listener(self: Arc<Self>) -> Result<()> {
		let listener = TcpListener::bind(&self.static_cfg.bind_addr).await.map_err(|e| {
			NetError::Protocol(format!("Failed to bind {}: {:?}", self.static_cfg.bind_addr, e))
		})?;

		log::info!("SyncProvider listener started on {}", self.static_cfg.bind_addr);

		loop {
			tokio::select! {
				_ = self.cancel.cancelled() => break,
				accept_res = listener.accept() => {
					if self.draining.load(Ordering::Relaxed) {
						log::info!("Draining: rejecting new connection");
						continue;
					}

					match accept_res {
						Ok((stream, addr)) => {
							log::info!("Accepted connection from {}", addr);

							let provider = self.clone();
							let store = self.store.clone();
							let cancel = self.cancel.child_token();
							let node_id = self.static_cfg.node_id;
							let identity_clone = provider.identity.clone();

							let (tx, rx) = tokio::sync::mpsc::channel(32);
							tokio::spawn(async move {
								let mut peer = SyncPeer::new(
									stream,
									addr,
									node_id,
									identity_clone,
									store,
									provider,
									cancel,
									rx,
									tx
								);
								if let Err(e) = peer.run().await {
									log::error!("Peer error ({}): {:?}", addr, e);
								}
							});
						}
						Err(e) => {
							log::error!("Accept error: {:?}", e);
						}
					}
				}
			}
		}

		Ok(())
	}

	pub async fn update_leader(&self, leader: Option<u128>) {
		let mut lock = self.leader_id.write().await;
		if *lock != leader {
			log::info!("SyncProvider: Leader changed from {:?} to {:?}", *lock, leader);
			*lock = leader;
		}
	}

	pub fn status(&self) -> SyncStatus {
		SyncStatus {
			node_id: self.static_cfg.node_id,
			state: *self.state.lock().unwrap(),
			connected_peers: self.peers.try_read().map(|p| p.len() as u64).unwrap_or(0),
			active_transfers: self.active_transfers.load(Ordering::Relaxed),
			uptime_secs: self.start_time.elapsed().as_secs(),
			last_error: None,
		}
	}

	pub async fn update_config(&self, cfg: DynamicConfig) -> Result<()> {
		let mut w = self.dynamic_cfg.write().await;
		*w = cfg;
		Ok(())
	}

	async fn bootstrap_loop(
		provider: Arc<SyncProvider>,
		discovery: Arc<AsyncMutex<DiscoveryManager>>,
		cancel: CancellationToken,
	) {
		let interval_secs = provider.static_cfg.bootstrap_interval_secs;
		let mut interval = tokio::time::interval(std::time::Duration::from_secs(interval_secs));
		let semaphore = Arc::new(Semaphore::new(provider.static_cfg.max_concurrent_dials));

		log::info!("Bootstrap loop started (Interval: {}s)", interval_secs);

		loop {
			tokio::select! {
				_ = cancel.cancelled() => {
					log::info!("Bootstrap loop cancelled.");
					return;
				}
				_ = interval.tick() => {
					// P24: Periodic cleanup of dead discovery hints
					{
						let mut disc = discovery.lock().await;
						disc.cleanup_dead_candidates();
					}

					let (active_count, active_set) = {
						let peers = provider.peers.read().await;
						let set: std::collections::HashSet<std::net::SocketAddr> = peers.values().map(|p| p.addr).collect();
						(peers.len(), set)
					};

					let candidates = {
						let mut disc = discovery.lock().await;
						disc.get_dial_candidates(active_count, &active_set, &provider.static_cfg.bind_addr)
					};

					if candidates.is_empty() {
						continue;
					}

					log::debug!("Bootstrap: Attempting to dial {} candidates", candidates.len());

					for addr in candidates {
						let permit = semaphore.clone().acquire_owned().await.unwrap();
						let provider_l = provider.clone();
						let discovery_l = discovery.clone();
						let cancel_l = cancel.child_token();

						tokio::spawn(async move {
							 let dial_timeout = std::time::Duration::from_millis(provider_l.static_cfg.dial_timeout_ms);
							 let res = tokio::time::timeout(dial_timeout, tokio::net::TcpStream::connect(addr)).await;

							 match res {
								 Ok(Ok(stream)) => {
									 log::debug!("Bootstrap: Connected to {}", addr);

									 let node_id = provider_l.static_cfg.node_id;
									 let (tx, rx) = tokio::sync::mpsc::channel(32);
									 let mut peer = SyncPeer::new(
										 stream,
										 addr,
										 node_id,
										 provider_l.identity.clone(),
										 provider_l.store.clone(),
										 provider_l.clone(),
										 cancel_l,
										 rx,
										 tx
									 );

									 if let Err(e) = peer.run().await {
										 log::error!("Peer {} failed during run/handshake: {:?}", addr, e);
									 }

									 discovery_l.lock().await.report_success(addr);
								 },
								 Ok(Err(e)) => {
									 log::warn!("Bootstrap: Dial failed for {}: {}", addr, e);
									 discovery_l.lock().await.report_failure(addr);
								 },
								 Err(_) => {
									 log::warn!("Bootstrap: Dial timeout for {}", addr);
									 discovery_l.lock().await.report_failure(addr);
								 }
							 }

							 drop(permit);
						});
					}
				}
			}
		}
	}

	pub async fn drain(&self, timeout: std::time::Duration) -> DrainReport {
		let start = Instant::now();
		let state_before = *self.state.lock().unwrap();
		let active_transfers_before = self.active_transfers.load(Ordering::SeqCst);

		self.draining.store(true, Ordering::Relaxed);
		{
			let mut state = self.state.lock().unwrap();
			if *state == SyncState::Running {
				*state = SyncState::Draining;
			} else if *state == SyncState::Stopped {
				// Already stopped, return report immediately
				return DrainReport {
					result: DrainResult::Completed,
					active_transfers_before,
					active_transfers_remaining: 0,
					duration_ms: 0,
					state_before,
					state_after: SyncState::Stopped,
				};
			}
		}

		let timeout_dur = timeout;

		// Wait for transfers to complete
		while self.active_transfers.load(Ordering::SeqCst) > 0 {
			if start.elapsed() > timeout_dur {
				let state_after = *self.state.lock().unwrap();
				return DrainReport {
					result: DrainResult::TimedOut,
					active_transfers_before,
					active_transfers_remaining: self.active_transfers.load(Ordering::Relaxed),
					duration_ms: start.elapsed().as_millis() as u64,
					state_before,
					state_after,
				};
			}
			tokio::time::sleep(std::time::Duration::from_millis(100)).await;
		}

		let state_after = *self.state.lock().unwrap();
		DrainReport {
			result: DrainResult::Completed,
			active_transfers_before,
			active_transfers_remaining: 0,
			duration_ms: start.elapsed().as_millis() as u64,
			state_before,
			state_after,
		}
	}

	pub async fn shutdown(&self) -> Result<()> {
		let _ = self.drain(std::time::Duration::from_secs(1)).await; // Fast drain attempt
		self.cancel.cancel();
		{
			let mut state = self.state.lock().unwrap();
			*state = SyncState::Stopped;
		}
		let mut handles = self.handles.lock().await;
		for handle in handles.drain(..) {
			let _ = handle.await;
		}
		log::info!("SyncProvider shutdown complete.");
		Ok(())
	}

	pub fn connected_peers(&self) -> Vec<PeerStatus> {
		self.peers.blocking_read().values().map(|ctx| ctx.status.clone()).collect()
	}

	// === P14 Registry API ===

	pub async fn register_peer(&self, peer_id: u128, ctx: PeerContext) {
		let mut peers = self.peers.write().await;
		peers.insert(peer_id, ctx);
	}

	pub async fn unregister_peer(&self, peer_id: u128) {
		let mut peers = self.peers.write().await;
		peers.remove(&peer_id);
	}

	pub async fn update_peer_status(&self, peer_id: u128, status: PeerStatus) {
		let mut peers = self.peers.write().await;
		if let Some(ctx) = peers.get_mut(&peer_id) {
			ctx.status = status;
		}
	}

	pub async fn peers_map(&self) -> HashMap<u128, PeerContext> {
		self.peers.read().await.clone()
	}

	pub async fn force_snapshot(&self, peer_id: u128) -> Result<()> {
		if !self.try_consume_snapshot_token() {
			return Err(NetError::Generic("Quota Exceeded: Snapshot Rate Limit".into()));
		}

		if let Some(_sender) = self.controls.read().await.get(&peer_id).cloned() {
			Ok(())
		} else {
			Err(NetError::Generic("Peer not found or no control channel".into()))
		}
	}

	pub async fn notify_peers(&self) {
		let peers = self.peers.read().await;
		for peer in peers.values() {
			let _ = peer.trigger_tx.send(()).await;
		}
	}

	// === P20.8 Gossip Hints ===

	pub async fn get_gossip_hints(&self) -> Vec<(String, u128)> {
		let peers = self.peers.read().await;
		let mut hints = Vec::new();
		let my_realm = self.static_cfg.realm_id;

		// Return a subset of connected peers as hints
		for ctx in peers.values().take(10) {
			hints.push((ctx.addr.to_string(), my_realm));
		}
		hints
	}

	pub async fn add_discovery_hints(&self, hints: Vec<(String, u128)>) {
		let mut converted = Vec::new();
		for (addr_str, realm_id) in hints {
			if let Ok(addr) = addr_str.parse::<std::net::SocketAddr>() {
				converted.push((addr, realm_id));
			}
		}
		let mut disc = self.discovery.lock().await;
		disc.add_hints(converted);
	}

	// === P23 Control Plane Hooks ===

	pub async fn register_control_channel(&self, tx: tokio::sync::mpsc::Sender<LspMessage>) {
		let mut guard = self.control_tx.write().await;
		*guard = Some(tx);
	}

	pub async fn notify_control(&self, msg: LspMessage) {
		let guard = self.control_tx.read().await;
		if let Some(tx) = &*guard {
			// Non-blocking send or weak?
			// If receiver is full, we might block sync loop.
			// P23 Control heartbeats are important but shouldn't stall Data Sync.
			// Try send or clone/spawn? try_send is better.
			// Wait, LspMessage is typically small.
			if let Err(e) = tx.try_send(msg) {
				log::trace!("Control channel full/closed: {}", e);
			}
		}
	}

	pub async fn send_control_message(&self, peer_id: u128, msg: LspMessage) {
		let controls = self.controls.read().await;
		if let Some(tx) = controls.get(&peer_id) {
			if let Err(_) = tx.try_send(msg) {
				log::warn!("Failed to send control message to peer {}", peer_id);
			}
		}
	}

	pub async fn broadcast_control_message(&self, msg: LspMessage) {
		let controls = self.controls.read().await;
		for (pid, tx) in controls.iter() {
			if let Err(_) = tx.try_send(msg.clone()) {
				log::warn!("Failed to send control message to peer {}", pid);
			}
		}
	}

	pub async fn broadcast_log_item(&self, _item: LogWireItem) -> Result<()> {
		// P20.7: Notify peers about new data
		// Ideally we would push the item to a queue or use it to optimize fetch.
		// For now, trigger pull.
		self.notify_peers().await;
		Ok(())
	}
}
