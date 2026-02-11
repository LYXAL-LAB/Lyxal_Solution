#![allow(unused)]

extern crate lyxal_revision as revision;

pub mod consensus;
pub mod kernel;
pub mod raft;
pub mod realm;
pub mod registry_new;
pub mod service;
pub mod services;
use lyxalkv::Tree;
use once_cell::sync::OnceCell;
pub use registry_new as registry;
use std::sync::Arc;

static USER_DB: OnceCell<Arc<Tree>> = OnceCell::new();
static CONSENSUS: OnceCell<Arc<consensus::ConsensusManager>> = OnceCell::new();

/// Registers the main user database with the LyxalOS kernel for replication.
/// This avoids locking conflicts by allowing SurrealDB to open the DB first
/// and then sharing the handle with the LyxalOS replication engine.
pub fn register_user_db(db: Arc<Tree>) {
	if USER_DB.set(db).is_err() {
		log::warn!("LyxalOS: User DB already registered");
	} else {
		log::info!("LyxalOS: Main User DB registered for replication.");
	}
}

/// Internal helper to retrieve the registered user database.
pub(crate) fn get_user_db() -> Option<Arc<Tree>> {
	USER_DB.get().cloned()
}

/// Registers the consensus manager with the global state.
pub fn register_consensus(cm: Arc<consensus::ConsensusManager>) {
	if CONSENSUS.set(cm).is_err() {
		log::warn!("LyxalOS: Consensus already registered");
	}
}

/// Proposes a batch of data modifications to the cluster for replication.
pub async fn propose_replicated_batch(
	batch: lyxal_sync::log::ReplicatedBatch,
) -> anyhow::Result<u64> {
	if let Some(cm) = CONSENSUS.get() {
		log::debug!("LyxalOS: Proposing replicated batch with {} entries", batch.entries.len());
		let data = bincode::serialize(&batch)
			.map_err(|e| anyhow::anyhow!("Serialization error: {}", e))?;
		let index = cm.propose(data).await?;
		log::debug!("LyxalOS: Batch proposed at Raft index {}", index);
		Ok(index)
	} else {
		Err(anyhow::anyhow!("Consensus engine not available"))
	}
}

pub mod account;
pub mod accounting;
pub mod billing;
pub mod invoice;
pub mod ledger;
pub mod net_accounting_adapter;
pub mod policy;
pub mod safety;
pub mod settlement;
pub mod transactions;
