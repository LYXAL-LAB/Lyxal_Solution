use crate::account::AccountId;
use crate::policy::{self, EvalContext};
use crate::realm::{RealmConfig, RealmContext, RealmId, RealmState, RealmStatus};
use crate::registry::DesiredState;

use crate::service::{KernelService, ServiceId}; // Removed ServiceStatus
use crate::settlement::SettlementManager;
use crate::transactions::{KernelReceipt, Transaction, TransactionRequest};
use ed25519_dalek::{Signature, VerifyingKey};
use hex;
use lyxal_net::{boot::BootContext, identity::NodeIdentity, SyncController};
use lyxal_sync::log::LogWireItem;

use parking_lot::Mutex;
use std::collections::{BTreeMap, HashMap};
use std::sync::Arc;
use std::time::{Duration, Instant, SystemTime};
use tokio::signal;
use tracing::{error, info, warn};

pub struct RealmHandle {
	pub context: Arc<RealmContext>,
	pub services: HashMap<ServiceId, Arc<dyn KernelService>>,
	pub state: Arc<Mutex<RealmState>>,
	pub start_time: Arc<Mutex<Option<Instant>>>,
	pub last_error: Arc<Mutex<Option<String>>>,
}

impl RealmHandle {
	pub fn new(context: RealmContext) -> Self {
		Self {
			context: Arc::new(context),
			services: HashMap::new(),
			state: Arc::new(Mutex::new(RealmState::Creating)), // Initial state
			start_time: Arc::new(Mutex::new(None)),
			last_error: Arc::new(Mutex::new(None)),
		}
	}

	pub fn register<S: KernelService + 'static>(&mut self, service: Arc<S>) {
		self.services.insert(service.id(), service);
	}

	pub fn set_state(&self, new_state: RealmState) {
		let mut guard = self.state.lock();
		*guard = new_state;
	}

	pub fn get_status(&self) -> RealmStatus {
		let state = *self.state.lock();
		let uptime = if state == RealmState::Running {
			self.start_time.lock().as_ref().map(|t| t.elapsed().as_secs()).unwrap_or(0)
		} else {
			0
		};

		let active_peers = 0;
		let active_transfers = 0;

		RealmStatus {
			realm_id: self.context.id,
			state,
			uptime_secs: uptime,
			active_peers,
			active_transfers,
			last_error: self.last_error.lock().clone(),
		}
	}

	pub async fn start(
		&mut self,
		_boot_ctx: &BootContext,
		accounting_engine: Arc<crate::accounting::AccountingEngine>,
	) -> Result<(), anyhow::Error> {
		{
			let mut state = self.state.lock();
			match *state {
				RealmState::Running => return Ok(()),
				RealmState::Draining => return Err(anyhow::anyhow!("Cannot start while draining")),
				_ => *state = RealmState::Running,
			}
		}

		let mut realm_ctx = _boot_ctx.clone();

		realm_ctx.paths.data_dir = self.context.paths.data_dir.clone();
		realm_ctx.paths.log_dir = self.context.paths.log_dir.clone();
		realm_ctx.paths.config_dir = self.context.paths.root_dir.join("config");

		realm_ctx.paths.trust_store_path = realm_ctx.paths.config_dir.join("trusted_peers.toml");
		realm_ctx.config.static_cfg.trust_store_path = realm_ctx.paths.trust_store_path.clone();

		let identity_path = self.context.paths.root_dir.join("identity.pem");
		realm_ctx.paths.identity_path = identity_path.clone();
		realm_ctx.config.static_cfg.identity_path = identity_path;

		realm_ctx.config.static_cfg.node_id = self.context.identity.node_id;
		realm_ctx.config.static_cfg.realm_id = self.context.id.0;

		if let Some(addr) = &self.context.config.bind_addr {
			realm_ctx.config.static_cfg.bind_addr = addr.clone();
		}

		realm_ctx.quota = self.context.config.quota.clone();
		realm_ctx.stats = Some(self.context.stats.clone());

		realm_ctx.observer = Some(Arc::new(crate::net_accounting_adapter::OsAccountingObserver {
			engine: accounting_engine.clone(),
		}));

		info!(
			"Realm {:?}: Starting services with root {:?}",
			self.context.id, self.context.paths.root_dir
		);

		*self.start_time.lock() = Some(Instant::now());
		self.set_state(RealmState::Running);

		for (id, service) in &self.services {
			info!("Realm {:?}: Starting service {}...", self.context.id, id);
			if let Err(e) = service.start(&realm_ctx).await {
				error!("Realm {:?}: Service {} failed to start: {}", self.context.id, id, e);
				self.set_state(RealmState::Failed);
				*self.last_error.lock() = Some(e.to_string());
				return Err(e);
			}
		}

		info!("Realm {:?}: All services started.", self.context.id);
		Ok(())
	}

	pub async fn drain(&self, deadline: std::time::Duration) -> lyxal_net::status::DrainReport {
		{
			let state = *self.state.lock();
			if matches!(state, RealmState::Stopped | RealmState::Deleted) {
				return lyxal_net::status::DrainReport {
					result: lyxal_net::status::DrainResult::Completed,
					active_transfers_remaining: 0,
					active_transfers_before: 0,
					duration_ms: 0,
					state_before: lyxal_net::status::SyncState::Stopped,
					state_after: lyxal_net::status::SyncState::Stopped,
				};
			}
		}

		self.set_state(RealmState::Draining);
		let start = std::time::Instant::now();

		let mut remaining = 0;
		let mut before = 0;
		let mut all_done = true;

		for (id, service) in &self.services {
			let report = service.drain(deadline).await;
			remaining += report.active_transfers_remaining;
			before += report.active_transfers_before;
			if !matches!(report.result, lyxal_net::status::DrainResult::Completed) {
				all_done = false;
				info!("Realm {:?}: Service {} drain incomplete.", self.context.id, id);
			} else {
				info!("Realm {:?}: Service {} drained.", self.context.id, id);
			}
		}

		let final_status = if all_done {
			self.set_state(RealmState::Stopped);
			lyxal_net::status::DrainResult::Completed
		} else {
			lyxal_net::status::DrainResult::TimedOut
		};

		lyxal_net::status::DrainReport {
			result: final_status,
			active_transfers_remaining: remaining,
			active_transfers_before: before,
			duration_ms: start.elapsed().as_millis() as u64,
			state_before: lyxal_net::status::SyncState::Running,
			state_after: if all_done {
				lyxal_net::status::SyncState::Stopped
			} else {
				lyxal_net::status::SyncState::Draining
			},
		}
	}

	pub async fn shutdown(&mut self) -> Result<(), anyhow::Error> {
		info!("Realm {:?}: Stop/Shutdown requested...", self.context.id);

		for (id, service) in &self.services {
			if let Err(e) = service.shutdown().await {
				error!("Realm {:?}: Service {} shutdown failed: {}", self.context.id, id, e);
			}
		}
		self.set_state(RealmState::Stopped);
		Ok(())
	}
}

use crate::consensus::{ConsensusManager, TargetStatus};
use crate::services::sync::SyncService;

pub struct Kernel {
	pub boot_ctx: BootContext,
	pub realms: HashMap<RealmId, RealmHandle>,
	pub consensus: Arc<ConsensusManager>,

	// Channels for Injection
	consensus_tx: Option<tokio::sync::mpsc::Sender<lyxal_sync::protocol::LspMessage>>,
	consensus_rx:
		std::sync::Mutex<Option<tokio::sync::mpsc::Receiver<lyxal_sync::protocol::LspMessage>>>,
	ledger_rx: std::sync::Mutex<Option<tokio::sync::mpsc::Receiver<LogWireItem>>>,

	pub kv_db: Arc<lyxalkv::Tree>, // P32: Shared Truth Journal
	pub ledger: Arc<crate::ledger::RealmLedger>,
	pub accounting: Arc<crate::accounting::AccountingEngine>,
	pub accounts: Arc<parking_lot::RwLock<crate::account::AccountRegistry>>,
	pub owner_map: Arc<parking_lot::RwLock<HashMap<u128, u128>>>,

	pub tx_store: Arc<crate::transactions::TransactionStore>,

	pub invoice_store: Arc<crate::invoice::InvoiceStore>,
	pub cached_plans: Arc<parking_lot::RwLock<BTreeMap<String, crate::registry_new::PricingPlan>>>,
	pub safety: Arc<crate::safety::SafetyManager>,
	pub settlement: Arc<SettlementManager>,
}

impl Kernel {
	pub fn new(ctx: BootContext) -> Self {
		// P25: Anti-loop protection: Remove self from seeds to prevent self-connection
		if let (Ok(seeds), Ok(my_addr)) =
			(std::env::var("LYXAL_SEEDS"), std::env::var("LYXAL_BIND_ADDR"))
		{
			let filtered: Vec<_> = seeds
				.split(',')
				.filter(|&s| s.trim() != my_addr.trim())
				.map(|s| s.to_string())
				.collect::<Vec<_>>();
			std::env::set_var("LYXAL_SEEDS", filtered.join(","));
		}

		let store: Arc<dyn crate::consensus::ConsensusStore + Send + Sync> =
			if std::env::var("LYXAL_USE_MOCK_CONSENSUS").is_ok() {
				info!("Kernel: Using MockConsensusStore (Shared In-Memory) for Consensus Torture Test");
				Arc::new(crate::consensus::MockConsensusStore::new())
			} else {
				let consensus_path = if let Ok(p) = std::env::var("LYXAL_CONSENSUS_PATH") {
					std::path::PathBuf::from(p)
				} else {
					ctx.paths.data_dir.join("consensus.kv")
				};
				Arc::new(crate::consensus::KvConsensusStore::new(consensus_path))
			};
		let node_id = ctx.config.static_cfg.node_id;

		// P25: Load Raft peers from TrustStore to prevent split-brain.
		// By loading authorized peers at boot, the node knows the expected cluster size
		// and won't elect itself as a "standalone" leader if other nodes are expected.
		let realm_id = ctx.config.static_cfg.realm_id;
		let peers = if let Ok(ts) =
			lyxal_net::trust::TrustStore::new(&ctx.paths.trust_store_path, realm_id)
		{
			let mut ids = ts.trusted_ids();
			ids.retain(|&id| id != node_id);
			ids
		} else {
			Vec::new()
		};

		info!("Kernel: Initializing Raft Quorum with {} trusted peers", peers.len());

		// P25: Increase election delay for non-seed nodes to favor the primary seed (Node 1)
		// This prevents "Split-Brain" by making secondary nodes wait longer before starting an election.
		if std::env::var("LYXAL_SEEDS").is_ok() {
			let delay = 2000; // +2 seconds delay for non-seed nodes
			let min = std::env::var("LYXAL_RAFT_ELECTION_MIN_MS")
				.unwrap_or_else(|_| "1000".into())
				.parse::<u64>()
				.unwrap_or(1000)
				+ delay;
			let max = std::env::var("LYXAL_RAFT_ELECTION_MAX_MS")
				.unwrap_or_else(|_| "2000".into())
				.parse::<u64>()
				.unwrap_or(2000)
				+ delay;
			std::env::set_var("LYXAL_RAFT_ELECTION_MIN_MS", min.to_string());
			std::env::set_var("LYXAL_RAFT_ELECTION_MAX_MS", max.to_string());
		}

		let consensus = Arc::new(ConsensusManager::new(node_id, store.clone(), peers));

		// P25: Register consensus globally for data replication
		crate::register_consensus(consensus.clone());

		// P23: Control Plane Channel
		let (tx, rx) = tokio::sync::mpsc::channel(100);

		// P32: Ledger Sync Channel
		let (ledger_tx, ledger_rx) = tokio::sync::mpsc::channel(1000);

		let kv_db = store.get_db().unwrap_or_else(|| {
			let path = ctx.paths.data_dir.join("lyxal_kernel.kv");
			let opts = lyxalkv::Options::new().with_path(path);
			Arc::new(
				lyxalkv::TreeBuilder::with_options(opts)
					.build()
					.expect("Failed to open kernel kv store"),
			)
		});

		let ledger = Arc::new(crate::ledger::RealmLedger::new(ctx.paths.data_dir.clone()));
		let accounts =
			Arc::new(parking_lot::RwLock::new(crate::account::AccountRegistry::new(kv_db.clone())));
		let owner_map = Arc::new(parking_lot::RwLock::new(HashMap::new()));
		let accounting =
			Arc::new(crate::accounting::AccountingEngine::new(ledger.clone(), owner_map.clone()));

		// Inject Ledger TX into TransactionStore
		let tx_store = Arc::new(
			crate::transactions::TransactionStore::new(kv_db.clone(), node_id).with_sync(ledger_tx),
		);

		let invoice_store = Arc::new(crate::invoice::InvoiceStore::new(kv_db.clone()));
		let cached_plans = Arc::new(parking_lot::RwLock::new(std::collections::BTreeMap::new()));
		let safety =
			Arc::new(crate::safety::SafetyManager::new(kv_db.clone(), ctx.paths.data_dir.clone()));

		let settlement = Arc::new(SettlementManager::new(
			node_id,
			kv_db.clone(),
			consensus.clone(),
			safety.clone(),
			accounts.clone(),
		));

		Self {
			realms: HashMap::new(),
			boot_ctx: ctx,
			consensus,
			consensus_tx: Some(tx),
			consensus_rx: std::sync::Mutex::new(Some(rx)),
			ledger_rx: std::sync::Mutex::new(Some(ledger_rx)),
			kv_db: kv_db.clone(),
			ledger,
			accounting,
			accounts,
			owner_map,
			tx_store,
			invoice_store,
			cached_plans,
			safety,
			settlement,
		}
	}

	pub async fn bootstrap(&self) -> Result<(), anyhow::Error> {
		info!("Kernel: Bootstrapping Phase 32 Settlement Recovery...");
		self.settlement.recover().await?;
		Ok(())
	}

	// === Reconciler ===

	pub async fn reconcile(&mut self) -> Result<(), anyhow::Error> {
		if !self.consensus.is_leader().await {
			return Ok(());
		}

		let store = self.consensus.store.clone();
		let manifest_opt = store.load_manifest().await.unwrap_or(None);

		if let Some(manifest) = manifest_opt {
			for (id, desired_realm) in &manifest.realms {
				let id = *id;
				let observed_status = if let Some(handle) = self.get_realm(id) {
					let status = handle.get_status();
					Some(status.state)
				} else {
					None
				};

				let resource = format!("realm:{}", id.0);

				match desired_realm.target_status {
					crate::registry::TargetStatus::Running => {
						match observed_status {
							Some(RealmState::Running) | Some(RealmState::Draining) => {}
							Some(RealmState::Stopped)
							| Some(RealmState::Failed)
							| Some(RealmState::Creating) => {
								if self.check_policy(
									&manifest,
									policy::ACTION_REALM_START,
									Some(id.0),
									resource.clone(),
								) {
									if !self
										.accounts
										.read()
										.get(desired_realm.owner_id)
										.map(|a| a.can_spend(0))
										.unwrap_or(false)
									{
										warn!("[INSUFFICIENT_FUNDS] Account {} cannot start Realm {:?}.", desired_realm.owner_id, id);
										continue;
									}
									info!("Reconciler[V2]: Starting Realm {:?}", id);
									let _ = self.start_realm(id).await;
									self.emit_accounting(
										id.0,
										"kernel",
										crate::accounting::UsageKind::KernelAction,
										1,
										Some("realm:start".to_string()),
									);
								}
							}
							None | Some(RealmState::Deleted) => {
								if self.check_policy(
									&manifest,
									policy::ACTION_REALM_CREATE,
									Some(id.0),
									resource.clone(),
								) {
									if !self
										.accounts
										.read()
										.get(desired_realm.owner_id)
										.map(|a| a.can_spend(100))
										.unwrap_or(false)
									{
										warn!("[INSUFFICIENT_FUNDS] Account {} cannot create Realm {:?}.", desired_realm.owner_id, id);
										continue;
									}
									info!("Reconciler[V2]: Creating and Starting Realm {:?}", id);
									let config = RealmConfig::default();
									self.create_realm(id, desired_realm.owner_id, config);
									let _ = self.start_realm(id).await;
									self.emit_accounting(
										id.0,
										"kernel",
										crate::accounting::UsageKind::KernelAction,
										1,
										Some("realm:create_and_start".to_string()),
									);
								}
							}
						}
					}
					crate::registry::TargetStatus::Stopped => match observed_status {
						Some(RealmState::Running) => {
							if self.check_policy(
								&manifest,
								policy::ACTION_REALM_STOP,
								Some(id.0),
								resource.clone(),
							) {
								info!("Reconciler[V2]: Stopping Realm {:?}", id);
								let _ = self.stop_realm(id).await;
								self.emit_accounting(
									id.0,
									"kernel",
									crate::accounting::UsageKind::KernelAction,
									1,
									Some("realm:stop".to_string()),
								);
							}
						}
						Some(RealmState::Draining) => {}
						None => {
							if self.check_policy(
								&manifest,
								policy::ACTION_REALM_CREATE,
								Some(id.0),
								resource.clone(),
							) {
								info!("Reconciler[V2]: Creating Realm {:?}", id);
								let config = RealmConfig::default();
								self.create_realm(id, desired_realm.owner_id, config);
								self.emit_accounting(
									id.0,
									"kernel",
									crate::accounting::UsageKind::KernelAction,
									1,
									Some("realm:create".to_string()),
								);
							}
						}
						_ => {}
					},
					crate::registry::TargetStatus::Deleted => {
						if observed_status.is_some() && observed_status != Some(RealmState::Deleted)
						{
							if self.check_policy(
								&manifest,
								policy::ACTION_REALM_DELETE,
								Some(id.0),
								resource.clone(),
							) {
								info!("Reconciler[V2]: Deleting Realm {:?}", id);
								if let Err(e) = self.delete_realm(id, false).await {
									if e.to_string().contains("not Stopped") {
										let _ = self.stop_realm(id).await;
										let _ = self.delete_realm(id, true).await;
									}
								}
							}
						}
					}
				}
			}
		} else {
			let desired_ids = store.list_desired().await.unwrap_or_default();
			for id_val in desired_ids {
				let id = RealmId(id_val);
				if let Ok(Some(desired)) = store.get_desired(id_val).await {
					let observed_status = if let Some(handle) = self.get_realm(id) {
						Some(handle.get_status().state)
					} else {
						None
					};

					match desired.target {
						TargetStatus::Running => {
							if observed_status.is_none() {
								self.create_realm(id, 0, RealmConfig::default());
								let _ = self.start_realm(id).await;
							} else if observed_status == Some(RealmState::Stopped) {
								let _ = self.start_realm(id).await;
							}
						}
						TargetStatus::Stopped => {
							if observed_status == Some(RealmState::Running) {
								let _ = self.stop_realm(id).await;
							}
						}
						TargetStatus::Deleted => {
							if observed_status.is_some()
								&& observed_status != Some(RealmState::Deleted)
							{
								let _ = self.delete_realm(id, true).await;
							}
						}
					}
				}
			}
		}

		if let Err(e) = self.reconcile_billing().await {
			error!("Kernel: Billing Cycle failed: {}", e);
		}

		Ok(())
	}

	pub async fn reconcile_billing(&mut self) -> Result<(), anyhow::Error> {
		let manifest = match self.consensus.store.load_manifest().await? {
			Some(m) => m,
			None => return Ok(()),
		};

		{
			let mut cache = self.cached_plans.write();
			*cache = manifest.pricing_plans.clone();
		}

		let accounts = self.accounts.read().list_accounts();
		let high_watermark =
			self.accounting.next_seq.load(std::sync::atomic::Ordering::Relaxed) - 1;

		for account in accounts {
			let cursor = account.billing_cursor_seq;
			if high_watermark <= cursor {
				continue;
			}

			let plan = match manifest.pricing_plans.get(&account.pricing_plan_id) {
				Some(p) => p,
				None => {
					warn!("Account {} uses unknown plan {}", account.id, account.pricing_plan_id);
					continue;
				}
			};

			let events = self.ledger.load_account_events(account.id, cursor, high_watermark)?;
			if events.is_empty() {
				let _ = self.accounts.write().update_cursor(account.id, high_watermark).await;
				continue;
			}

			let rated = crate::billing::BillingEngine::rate(
				account.id,
				plan,
				events,
				cursor,
				high_watermark,
			);

			self.execute_billing_atomic(account.id, rated).await?;
		}

		Ok(())
	}

	async fn execute_billing_atomic(
		&self,
		account_id: u128,
		rated: crate::billing::RatedPeriod,
	) -> Result<(), anyhow::Error> {
		use crate::invoice::{InvoiceEngine, InvoiceStatus};

		let mut invoice = match self.invoice_store.get(&rated.period_id)? {
			Some(inv) => inv,
			None => {
				let inv = InvoiceEngine::create_open(&rated);
				self.invoice_store.save(&inv).await?;
				inv
			}
		};

		if invoice.status == InvoiceStatus::Open {
			let kernel_identity =
				NodeIdentity::load_or_generate(&self.boot_ctx.paths.identity_path)?;
			invoice.signature = Some(kernel_identity.sign(&invoice.digest).to_vec());
			invoice.status = InvoiceStatus::ClosedSigned;
			invoice.closed_at_ns = Some(
				std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_nanos()
					as u64,
			);
			self.invoice_store.save(&invoice).await?;
		}

		if invoice.status == InvoiceStatus::ClosedSigned {
			let idempotency_key = hex::encode(rated.period_id);
			let mut idem_bytes = [0u8; 32];
			hex::decode_to_slice(&idempotency_key, &mut idem_bytes)?;

			let tx_req = TransactionRequest {
				kind: crate::transactions::TransactionKind::Debit,
				from: Some(account_id),
				to: None,
				amount: rated.total_micros,
				reason: format!("Invoice {}", &hex::encode(&rated.period_id)[0..8]),
				idempotency_key: idem_bytes,
			};

			info!(
				"Kernel[Billing]: Charging account {} for period {}. Amount={}",
				account_id,
				hex::encode(rated.period_id),
				rated.total_micros
			);

			// Re-read store to check idempotency (internal)
			if self.tx_store.get_by_idempotency(&idem_bytes)?.is_none() {
				let tx_id_full = blake3::hash(&idem_bytes);
				let tx_id = u128::from_be_bytes(tx_id_full.as_bytes()[0..16].try_into()?);

				let tx = Transaction {
					id: tx_id,
					ts_ns: std::time::SystemTime::now()
						.duration_since(std::time::UNIX_EPOCH)?
						.as_nanos() as u64,
					kind: tx_req.kind,
					from: tx_req.from,
					to: tx_req.to,
					amount: tx_req.amount,
					currency: 0,
					reason: tx_req.reason,
					idempotency_key: idem_bytes,
					signature: Vec::new(), // System-issued
					receipt: None,
				};

				let mut reg = self.accounts.write();
				reg.apply_transaction(&tx).await?;
				drop(reg); // Release account lock before async append

				self.tx_store.append(tx).await?;
			}

			self.accounts.write().update_cursor(account_id, rated.cursor_end).await?;
			info!(
				"Kernel[Billing]: Account {} billing cursor updated to {}",
				account_id, rated.cursor_end
			);
		}

		Ok(())
	}

	fn check_policy(
		&self,
		manifest: &DesiredState,
		action: &'static str,
		realm_id: Option<u128>,
		resource: String,
	) -> bool {
		let ctx = EvalContext {
			principal: self.boot_ctx.config.static_cfg.node_id,
			realm_id,
			service: Some("kernel"),
			action,
			resource: resource.clone(),
		};

		let decision = crate::policy::evaluate(&ctx, &manifest.policies);
		if decision.decision == crate::policy::Decision::Deny {
			warn!(
				"[POLICY DENIED] action={} resource={} principal={} policy_ids={:?}",
				action, resource, ctx.principal, decision.matched
			);
			return false;
		}
		true
	}

	fn emit_accounting(
		&self,
		realm_id: u128,
		service: &str,
		_kind: crate::accounting::UsageKind,
		units: u64,
		_action: Option<String>,
	) {
		self.accounting.emit_simple(
			realm_id,
			0,
			service.to_string(),
			"kernel.action".to_string(),
			units as i64,
		);
	}

	pub fn is_billing_allowed(&self, account_id: u128) -> bool {
		let reg = self.accounts.read();
		let account = match reg.get(account_id) {
			Some(a) => a,
			None => return false,
		};

		let plans = self.cached_plans.read();
		let plan = match plans.get(&account.pricing_plan_id) {
			Some(p) => p,
			None => return true,
		};

		let is_over_limit = account.balance + account.credit_limit < 0;

		if is_over_limit
			&& matches!(plan.enforcement, crate::registry_new::EnforcementMode::HardDeny)
		{
			return false;
		}

		true
	}

	pub async fn handle_billing_tx(
		&self,
		account_id: AccountId,
		nonce: u64,
		sig_bytes: Vec<u8>,
		req: TransactionRequest,
	) -> Result<(Transaction, KernelReceipt), anyhow::Error> {
		if !self.consensus.is_leader().await {
			return Err(anyhow::anyhow!("ErrNotLeader"));
		}

		let account = {
			let reg = self.accounts.read();
			reg.get(account_id).ok_or_else(|| anyhow::anyhow!("Account not found"))?
		};

		let body_bytes = bincode::serialize(&req)?;
		let body_hash = blake3::hash(&body_bytes);

		let mut hasher = blake3::Hasher::new();
		hasher.update(b"POST");
		hasher.update(b"/lyxal/billing/tx");
		hasher.update(&nonce.to_be_bytes());
		hasher.update(body_hash.as_bytes());
		hasher.update(&req.idempotency_key);
		let msg_hash = hasher.finalize();

		let vk = VerifyingKey::from_bytes(&account.public_key)?;
		let sig = Signature::from_slice(&sig_bytes)?;

		use ed25519_dalek::Verifier;
		vk.verify(msg_hash.as_bytes(), &sig)?;

		if nonce <= account.last_nonce {
			return Err(anyhow::anyhow!("Invalid nonce: must be strictly increasing"));
		}

		{
			if let Some(existing_tx) = self.tx_store.get_by_idempotency(&req.idempotency_key)? {
				if existing_tx.from == req.from
					&& existing_tx.to == req.to
					&& existing_tx.amount == req.amount
				{
					return Ok((existing_tx.clone(), existing_tx.receipt.clone().unwrap()));
				} else {
					return Err(anyhow::anyhow!(
						"Idempotency key collision with different content"
					));
				}
			}
		}

		let tx_id_full = blake3::hash(&req.idempotency_key);
		let tx_id = u128::from_be_bytes(tx_id_full.as_bytes()[0..16].try_into()?);
		let primary_realm = account.realms.iter().next().map(|r| r.0).unwrap_or(0);

		let status = self.safety.governance.read().get_status(account_id);
		if let crate::safety::governance::AccountSafetyStatus::Frozen {
			reason,
			..
		} = status
		{
			let _ = self
				.safety
				.audit
				.write()
				.log(
					primary_realm,
					account_id,
					"kernel".into(),
					tx_id,
					crate::safety::audit::SafetyAction::TxDebit,
					crate::safety::audit::SafetyDecision::Frozen,
					0,
				)
				.await;
			return Err(anyhow::anyhow!("Account Frozen: {}", reason));
		}

		let decision = {
			let mut risk = self.safety.risk.write();
			risk.evaluate(account_id, req.amount, &crate::safety::risk::RiskProfile::default())
		};

		if let crate::safety::audit::SafetyDecision::Deny(reason) = &decision {
			let _ = self
				.safety
				.audit
				.write()
				.log(
					primary_realm,
					account_id,
					"kernel".into(),
					tx_id,
					crate::safety::audit::SafetyAction::TxDebit,
					decision.clone(),
					100,
				)
				.await;
			return Err(anyhow::anyhow!("Risk Deny: {}", reason));
		}

		let held = self.safety.governance.read().get_held_balance(account_id);
		if held > 0 {
			let available = account.balance + account.credit_limit - held;
			if req.amount > available {
				let _ = self
					.safety
					.audit
					.write()
					.log(
						primary_realm,
						account_id,
						"kernel".into(),
						tx_id,
						crate::safety::audit::SafetyAction::TxDebit,
						crate::safety::audit::SafetyDecision::Disputed,
						50,
					)
					.await;
				return Err(anyhow::anyhow!("Insufficient available funds (Held: {})", held));
			}
		}

		self.safety
			.audit
			.write()
			.log(
				primary_realm,
				account_id,
				"kernel".into(),
				tx_id,
				crate::safety::audit::SafetyAction::TxDebit,
				crate::safety::audit::SafetyDecision::Allow,
				0,
			)
			.await?;

		let lease = self
			.consensus
			.store
			.get_lease()
			.await?
			.ok_or_else(|| anyhow::anyhow!("No active leader lease"))?;

		let tx = Transaction {
			id: tx_id,
			ts_ns: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_nanos()
				as u64,
			kind: req.kind.clone(),
			from: req.from,
			to: req.to,
			amount: req.amount,
			currency: 0,
			reason: req.reason.clone(),
			idempotency_key: req.idempotency_key,
			signature: sig_bytes,
			receipt: None,
		};

		let mut reg = self.accounts.write();
		reg.apply_transaction(&tx).await?;
		reg.update_nonce(account_id, nonce).await?;
		drop(reg); // Release lock before async

		let state_digest = self.tx_store.get_state_digest();

		let mut receipt = KernelReceipt {
			tx_id,
			applied: true,
			term: lease.term,
			leader_id: self.boot_ctx.config.static_cfg.node_id,
			state_digest,
			kernel_sig: Vec::new(),
		};

		let receipt_bytes = bincode::serialize(&receipt)?;
		let kernel_identity = NodeIdentity::load_or_generate(&self.boot_ctx.paths.identity_path)?;
		receipt.kernel_sig = kernel_identity.sign(&receipt_bytes).to_vec();

		let mut final_tx = tx;
		final_tx.receipt = Some(receipt.clone());

		self.tx_store.append(final_tx.clone()).await?;

		info!(
			"Billing: Transaction {} applied successfully. Account={} Nonce={}",
			tx_id, account_id, nonce
		);
		Ok((final_tx, receipt))
	}

	pub fn create_realm(
		&mut self,
		id: RealmId,
		owner_id: u128,
		config: RealmConfig,
	) -> &mut RealmHandle {
		if !self.is_billing_allowed(owner_id) {
			panic!("Critical: Realm creation blocked - ACCOUNT_OVER_LIMIT");
		}

		let realm_root = self.boot_ctx.paths.data_dir.join("realms").join(id.to_string());

		if let Err(e) = std::fs::create_dir_all(&realm_root) {
			error!("Failed to create realm directory {:?}: {}", realm_root, e);
			panic!("Critical: Realm creation failed due to FS error.");
		}

		let identity_path = realm_root.join("identity.pem");
		let identity = match NodeIdentity::load_or_generate(&identity_path) {
			Ok(id) => Arc::new(id),
			Err(e) => {
				error!("Failed to load/generate identity for realm at {:?}: {}", identity_path, e);
				panic!("Failed to load identity: {}", e);
			}
		};

		let ctx = RealmContext::new(id, owner_id, &self.boot_ctx.paths.data_dir, identity, config);

		self.owner_map.write().insert(id.0, owner_id);

		let handle = RealmHandle::new(ctx);
		handle.set_state(RealmState::Stopped);
		self.realms.entry(id).or_insert(handle)
	}

	pub fn get_realm_mut(&mut self, id: RealmId) -> Option<&mut RealmHandle> {
		self.realms.get_mut(&id)
	}

	pub fn get_realm(&self, id: RealmId) -> Option<&RealmHandle> {
		self.realms.get(&id)
	}

	pub fn list_realms(&self) -> Vec<RealmStatus> {
		self.realms.values().map(|handle| handle.get_status()).collect()
	}

	pub async fn get_realm_sync_controller(
		&self,
		id: RealmId,
	) -> Option<lyxal_net::control::SyncController> {
		let realm = self.realms.get(&id)?;
		let sync_service_id = ServiceId("lyxal.sync.v1".to_string());
		let service = realm.services.get(&sync_service_id)?;

		let sync_svc = service.as_any().downcast_ref::<crate::services::sync::SyncService>()?;
		sync_svc.controller().await
	}

	pub async fn start_realm(&mut self, id: RealmId) -> Result<(), anyhow::Error> {
		let owner_id = if let Some(realm) = self.realms.get(&id) {
			realm.context.owner_id
		} else {
			return Err(anyhow::anyhow!("Realm not found"));
		};

		if !self.is_billing_allowed(owner_id) {
			return Err(anyhow::anyhow!("ACCOUNT_OVER_LIMIT"));
		}

		if let Some(realm) = self.realms.get_mut(&id) {
			realm.start(&self.boot_ctx, self.accounting.clone()).await
		} else {
			Err(anyhow::anyhow!("Realm not found"))
		}
	}

	pub async fn drain_realm(
		&self,
		id: RealmId,
		deadline: std::time::Duration,
	) -> Result<lyxal_net::status::DrainReport, anyhow::Error> {
		if let Some(realm) = self.realms.get(&id) {
			Ok(realm.drain(deadline).await)
		} else {
			Err(anyhow::anyhow!("Realm not found"))
		}
	}

	pub async fn stop_realm(&mut self, id: RealmId) -> Result<(), anyhow::Error> {
		if let Some(realm) = self.realms.get_mut(&id) {
			realm.shutdown().await
		} else {
			Err(anyhow::anyhow!("Realm not found"))
		}
	}

	pub async fn delete_realm(&mut self, id: RealmId, force: bool) -> Result<(), anyhow::Error> {
		{
			if let Some(realm) = self.realms.get(&id) {
				let state = *realm.state.lock();
				if !force
					&& state != RealmState::Stopped
					&& state != RealmState::Failed
					&& state != RealmState::Creating
				{
					return Err(anyhow::anyhow!(
						"Realm is not Stopped (Current: {:?}). Use force=true.",
						state
					));
				}
			} else {
				return Err(anyhow::anyhow!("Realm not found"));
			}
		}

		if let Some(mut realm) = self.realms.remove(&id) {
			if force {
				let _ = realm.shutdown().await;
			}

			let paths = &realm.context.paths;
			info!("Deleting Realm {:?} data at {:?}", id, paths.root_dir);

			if paths.root_dir.exists() {
				if let Err(e) = std::fs::remove_dir_all(&paths.root_dir) {
					error!("Failed to delete realm directory: {}", e);
					return Err(anyhow::anyhow!("Failed to delete realm directory: {}", e));
				}
			}

			realm.set_state(RealmState::Deleted);
			info!("Realm {:?} Deleted.", id);
			Ok(())
		} else {
			Err(anyhow::anyhow!("Realm not found (race?)"))
		}
	}

	pub fn register(&mut self, service: Arc<SyncService>) {
		info!(target: "lyxal_os", "SyncService registered. Injecting channels and shared storage...");

		let node_id = self.boot_ctx.config.static_cfg.node_id;
		let kv_db = self.kv_db.clone();
		let svc_clone = service.clone();

		tokio::spawn(async move {
			// P32: Inject shared storage
			svc_clone.with_shared_tree(kv_db, node_id).await;
		});

		// P32: Inject Ledger RX
		if let Some(rx) = self.ledger_rx.lock().unwrap().take() {
			let svc_clone = service.clone();
			tokio::spawn(async move {
				svc_clone.set_ledger_channel(rx).await;
			});
		}
	}

	/// Helper for Integration Tests to verify Pump Wiring.
	/// DO NOT USE IN PRODUCTION.
	pub fn get_ledger_rx_for_test(&self) -> Option<tokio::sync::mpsc::Receiver<LogWireItem>> {
		self.ledger_rx.lock().unwrap().take()
	}

	pub async fn boot(&mut self) -> Result<(), anyhow::Error> {
		self.boot_with_controller(None).await
	}

	pub async fn boot_with_controller(
		&mut self,
		controller: Option<SyncController>,
	) -> Result<(), anyhow::Error> {
		info!("Kernel: Boot Sequence Initiated (Networking: {}).", controller.is_some());

		if let Some(rx) = self.consensus_rx.lock().unwrap().take() {
			let consensus = self.consensus.clone();
			tokio::spawn(async move {
				Self::consensus_loop(consensus, rx, controller).await;
			});
		}

		info!("Kernel: Core Ready. System Ready.");
		Ok(())
	}

	async fn consensus_loop(
		consensus: Arc<ConsensusManager>,
		mut rx: tokio::sync::mpsc::Receiver<lyxal_sync::protocol::LspMessage>,
		controller: Option<SyncController>,
	) {
		// P23: Load persistent Raft state
		if let Err(e) = consensus.load_initial_state().await {
			tracing::error!("Kernel: Failed to load initial consensus state: {}", e);
		}

		let mut ticker = tokio::time::interval(Duration::from_millis(50));
		let mut last_lease_check = tokio::time::Instant::now();
		let mut last_known_leader: Option<u128> = None;

		loop {
			tokio::select! {
				_ = ticker.tick() => {
					// Raft maintenance & Log Application
					let _ = consensus.apply_committed_logs().await;

					if let Some(raft_msg) = consensus.raft_tick().await {
						if let Some(ctrl) = &controller {
							let msg = lyxal_sync::protocol::LspMessage::Raft {
								from: consensus.node_id,
								message: raft_msg,
							};
							ctrl.broadcast(msg).await;
						}
					}

					// Propagate leader changes to network layer
					if let Some(ctrl) = &controller {
						let current_hint = consensus.get_leader_hint().map(|(_, id)| id);
						if current_hint != last_known_leader {
							last_known_leader = current_hint;
							ctrl.set_leader(current_hint).await;
						}
					}

					// Legacy Heartbeat & Lease (less frequent)
					if last_lease_check.elapsed() >= std::time::Duration::from_millis(1500) {
						last_lease_check = tokio::time::Instant::now();

						if let Some((term, leader, ts)) = consensus.prepare_heartbeat().await {
							 let msg = lyxal_sync::protocol::LspMessage::Heartbeat {
								 term,
								 leader_id: leader,
								 timestamp_ms: ts
							 };
							 if let Some(ctrl) = &controller {
								 ctrl.broadcast(msg).await;
							 }
						}

						let now = std::time::SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_millis() as u64;
						match consensus.try_acquire_or_renew(now, 5000).await {
							 crate::consensus::LeaseAcquireResult::Acquired { term, .. } => {
								 info!("Consensus: Became leader for term {}", term);
							 }
							 _ => {}
						}
					}
				}
				Some(msg) = rx.recv() => {
					match msg {
						lyxal_sync::protocol::LspMessage::Heartbeat { term, leader_id, timestamp_ms } => {
							consensus.handle_heartbeat(term, leader_id, timestamp_ms).await;
						}
						lyxal_sync::protocol::LspMessage::Raft { from, message } => {
							if let Some(resp) = consensus.handle_raft_message(from, message).await {
								if let Some(ctrl) = &controller {
									let resp_msg = lyxal_sync::protocol::LspMessage::Raft {
										from: consensus.node_id,
										message: resp,
									};
									ctrl.send_to(from, resp_msg).await;
								}
							}
						}
						_ => {}
					}
				}
			}
		}
	}

	pub async fn await_shutdown(&mut self) -> Result<(), anyhow::Error> {
		match signal::ctrl_c().await {
			Ok(()) => {
				info!("Kernel: Shutdown signal received.");
			}
			Err(err) => {
				error!("Kernel: Unable to listen for shutdown signal: {}", err);
			}
		}

		self.shutdown().await
	}

	pub async fn shutdown(&mut self) -> Result<(), anyhow::Error> {
		info!("Kernel: Shutdown Sequence Initiated.");

		for (_, realm) in &mut self.realms {
			let _ = realm.drain(std::time::Duration::from_secs(5)).await;
			let _ = realm.shutdown().await;
		}

		info!("Kernel: System Shutdown Complete.");
		Ok(())
	}
}

pub async fn boot_minimal(data_dir: std::path::PathBuf) -> anyhow::Result<()> {
	use lyxal_net::boot;
	use lyxal_net::control::SyncController;
	use lyxal_net::lyxal_store::LyxalStore;
	use lyxal_net::provider::SyncProvider;
	use std::sync::Arc;
	use tracing::{error, info};

	info!("LyxalOS: Starting minimal boot sequence...");

	// Use the official lyxal_net bootstrap logic to handle Profile, Paths, and Logging
	// We override the data directory with a dedicated Lyxal OS directory
	// to avoid lock contention and directory pollution with SurrealDB's database.
	let mut lyxos_data = data_dir.clone();
	if let Some(name) = data_dir.file_name() {
		let mut new_name = name.to_os_string();
		new_name.push(".lyxos");
		lyxos_data.set_file_name(new_name);
	} else {
		lyxos_data.push("lyxos");
	}
	std::env::set_var("LYXAL_DATA_DIR", lyxos_data.as_os_str());

	let boot_ctx =
		boot::bootstrap().map_err(|e| anyhow::anyhow!("Lyxal OS Bootstrap failed: {}", e))?;

	// Create Kernel first to get access to KV DB
	let mut kernel = Kernel::new(boot_ctx.clone());
	let node_id = kernel.boot_ctx.config.static_cfg.node_id;

	// P25: Reverted User DB open to avoid lock conflict (os error 33).
	// The Kernel now correctly uses its isolated consensus.kv for orchestration,
	// letting SurrealDB open the user database independently.
	let store = Arc::new(LyxalStore::new(kernel.kv_db.clone(), node_id));
	let stats = boot_ctx.stats.clone().expect("BootContext missing stats");

	let provider = SyncProvider::start(
		boot_ctx.config.clone(),
		store,
		stats,
		boot_ctx.quota.clone(),
		boot_ctx.observer.clone(),
	)
	.await
	.map_err(|e| anyhow::anyhow!("Lyxal Net Provider failed: {}", e))?;

	// P23: Register Consensus Channel
	let (tx, rx) = tokio::sync::mpsc::channel(1000);
	provider.register_control_channel(tx).await;
	let controller = SyncController::new(&provider);

	// Inject the network receiver into the kernel to listen for network messages
	*kernel.consensus_rx.lock().unwrap() = Some(rx);

	// Phase 32: Settlement Recovery
	kernel.bootstrap().await.map_err(|e| anyhow::anyhow!("Kernel recovery failed: {}", e))?;

	// Start Consensus with the Network Controller
	kernel
		.boot_with_controller(Some(controller))
		.await
		.map_err(|e| anyhow::anyhow!("Kernel boot failed: {}", e))?;

	info!("LyxalOS: Kernel is now active and networking.");
	Ok(())
}
