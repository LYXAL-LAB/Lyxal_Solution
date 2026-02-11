use crate::accounting::{UsageEvent, UsageKind};
use crate::realm::RealmId;
use parking_lot::RwLock;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::io::Write;
use std::path::PathBuf;
use std::sync::Arc;
use tracing::{error, info};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct RealmLedgerView {
	pub totals: HashMap<UsageKind, u64>,
}

pub struct RealmLedger {
	// In-memory totals: RealmId -> UsageKind -> Total
	data: RwLock<HashMap<u128, HashMap<UsageKind, u64>>>,
	// In-memory totals: AccountId -> UsageKind -> Total
	account_data: RwLock<HashMap<u128, HashMap<UsageKind, u64>>>,
	base_path: PathBuf,
}

impl RealmLedger {
	pub fn new(base_path: PathBuf) -> Self {
		Self {
			data: RwLock::new(HashMap::new()),
			account_data: RwLock::new(HashMap::new()),
			base_path,
		}
	}

	pub fn get_view(&self, realm_id: u128) -> RealmLedgerView {
		let guard = self.data.read();
		let totals = guard.get(&realm_id).cloned().unwrap_or_default();
		RealmLedgerView {
			totals,
		}
	}

	pub async fn record_batch_v2(&self, events: &[UsageEvent], _owner_map: &HashMap<u128, u128>) {
		let mut acc_guard = self.account_data.write();
		let mut realm_guard = self.data.write();

		for event in events {
			// Aggregate by Account
			let account_totals = acc_guard.entry(event.account_id).or_insert_with(HashMap::new);
			// Map common meter_ids to UsageKind for legacy view compatibility
			let kind = match event.meter_id.as_str() {
				"sync.delta.bytes" => UsageKind::SyncDeltaBytes,
				"sync.snapshot.bytes" => UsageKind::SyncSnapshotBytes,
				"peer.connected.ms" => UsageKind::PeerConnectedMillis,
				_ => UsageKind::KernelAction,
			};
			let total = account_totals.entry(kind).or_insert(0);
			*total += event.units.max(0) as u64;

			// Aggregate by Realm
			let realm_totals = realm_guard.entry(event.realm_id).or_insert_with(HashMap::new);
			let r_total = realm_totals.entry(kind).or_insert(0);
			*r_total += event.units.max(0) as u64;
		}

		// Flush each affected account
		let mut affected_accounts = std::collections::HashSet::new();
		for event in events {
			affected_accounts.insert(event.account_id);
		}

		for account_id in affected_accounts {
			let _ = self.flush_account_v2(account_id, events);
		}
	}

	fn flush_account_v2(
		&self,
		account_id: u128,
		events: &[UsageEvent],
	) -> Result<(), anyhow::Error> {
		let billing_dir =
			self.base_path.join("accounts").join(account_id.to_string()).join("_billing");
		if !billing_dir.exists() {
			std::fs::create_dir_all(&billing_dir)?;
		}

		// For P29 "PROD", we should append to a log or update a state.
		// For now, we update the account's ledger view with last events.
		let path = billing_dir.join("history_v2.bin");

		let mut file = std::fs::OpenOptions::new().create(true).append(true).open(path)?;

		for event in events.iter().filter(|e| e.account_id == account_id) {
			let bytes = bincode::serialize(event)?;
			file.write_all(&bytes)?;
		}

		Ok(())
	}

	pub fn load_account_events(
		&self,
		account_id: u128,
		start_seq: u64,
		end_seq: u64,
	) -> Result<Vec<UsageEvent>, anyhow::Error> {
		let path = self
			.base_path
			.join("accounts")
			.join(account_id.to_string())
			.join("_billing")
			.join("history_v2.bin");
		if !path.exists() {
			return Ok(Vec::new());
		}

		let file = std::fs::File::open(path)?;
		let mut reader = std::io::BufReader::new(file);
		let mut events = Vec::new();

		loop {
			// bincode::deserialize_from will read exactly one UsageEvent
			match bincode::deserialize_from::<_, UsageEvent>(&mut reader) {
				Ok(event) => {
					let seq = event.seq;
					if seq > start_seq && seq <= end_seq {
						events.push(event);
					}
					if seq > end_seq {
						// Assuming sequences are ordered in the file
						break;
					}
				}
				Err(e) => {
					if let bincode::ErrorKind::Io(ref io_err) = *e {
						if io_err.kind() == std::io::ErrorKind::UnexpectedEof {
							break;
						}
					}
					return Err(e.into());
				}
			}
		}

		Ok(events)
	}

	pub fn record_batch(&self, events: &[UsageEventV1], owner_map: &HashMap<u128, u128>) {
		// ... legacy impl ...
	}
}

// Legacy struct for V1 compatibility
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsageEventV1 {
	pub ts_ns: u64,
	pub realm_id: u128,
	pub service: String,
	pub kind: crate::accounting::UsageKind,
	pub units: u64,
	pub meta: Option<crate::accounting::UsageMeta>,
}
