mod cnf;

use crate::key::debug::Sprintable;
use crate::kvs::api::Transactable;
use crate::kvs::err::Error;
use crate::kvs::{Key, Result, Val, Version};
use async_trait::async_trait;
extern crate lyxalkv as lyxalkv_engine;
pub use lyxalkv_engine::{Mode, Tree, TreeBuilder};
use std::ops::Range;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use tokio::sync::RwLock;
use tracing::{info, instrument};

const TARGET: &str = "surrealdb::core::kvs::lyxalkv";

pub struct Datastore {
	db: Arc<Tree>,
	enable_versions: bool,
}

pub struct Transaction {
	/// Is the transaction complete?
	done: AtomicBool,
	/// Is the transaction writeable?
	write: bool,
	/// The underlying datastore transaction
	inner: RwLock<lyxalkv_engine::Transaction>,
}

impl Datastore {
	pub(crate) async fn new(path: &str, enable_versions: bool) -> Result<Datastore> {
		// Configure custom options
		let builder = TreeBuilder::new();
		// Enable separated keys and values
		info!(target: TARGET, "Enabling value log separation: {}", *cnf::SURREALKV_ENABLE_VLOG);
		let builder = builder.with_enable_vlog(*cnf::SURREALKV_ENABLE_VLOG);
		// Configure the maximum value log file size
		info!(target: TARGET, "Setting value log max file size: {}", *cnf::SURREALKV_VLOG_MAX_FILE_SIZE);
		let builder = builder.with_vlog_max_file_size(*cnf::SURREALKV_VLOG_MAX_FILE_SIZE);
		// Enable the block cache capacity
		info!(target: TARGET, "Setting block cache capacity: {}", *cnf::SURREALKV_BLOCK_CACHE_CAPACITY);
		let builder = builder.with_block_cache_capacity(*cnf::SURREALKV_BLOCK_CACHE_CAPACITY);
		// Configure versioned queries
		info!(target: TARGET, "Versioning enabled: {} with unlimited retention period", enable_versions);
		let builder = builder.with_versioning(enable_versions, 0);
		// Set the block size
		info!(target: TARGET, "Setting block size: {}", *cnf::SURREALKV_BLOCK_SIZE);
		let builder = builder.with_block_size(*cnf::SURREALKV_BLOCK_SIZE);
		// Set the data storage directory
		let builder = builder.with_path(path.to_string().into());
		// Create a new datastore
		match builder.build() {
			Ok(db) => {
				let db = Arc::new(db);
				Ok(Datastore {
					db,
					enable_versions,
				})
			}
			Err(e) => Err(Error::Datastore(e.to_string())),
		}
	}

	/// Expose the underlying LyxalKV tree handle
	pub fn inner_db(&self) -> Arc<Tree> {
		self.db.clone()
	}

	pub(crate) async fn shutdown(&self) -> Result<()> {
		self.db.close().await.map_err(|e| Error::Datastore(e.to_string()))?;
		Ok(())
	}

	pub(crate) async fn transaction(
		&self,
		write: bool,
		_lock: bool,
	) -> Result<Box<dyn Transactable>> {
		let mode = if write {
			Mode::ReadWrite
		} else {
			Mode::ReadOnly
		};
		let inner = self.db.begin_with_mode(mode).map_err(|e| Error::Datastore(e.to_string()))?;
		Ok(Box::new(Transaction {
			inner: RwLock::new(inner),
			done: AtomicBool::new(false),
			write,
		}))
	}
}

#[cfg_attr(target_family = "wasm", async_trait(?Send))]
#[cfg_attr(not(target_family = "wasm"), async_trait)]
impl Transactable for Transaction {
	fn kind(&self) -> &'static str {
		"lyxalkv"
	}

	fn closed(&self) -> bool {
		self.done.load(Ordering::Relaxed)
	}

	fn writeable(&self) -> bool {
		self.write
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self))]
	async fn cancel(&self) -> Result<()> {
		if self.done.swap(true, Ordering::AcqRel) {
			return Err(Error::TransactionFinished);
		}
		self.inner.write().await.rollback();
		Ok(())
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self))]
	async fn commit(&self) -> Result<()> {
		if self.done.swap(true, Ordering::AcqRel) {
			return Err(Error::TransactionFinished);
		}
		if !self.writeable() {
			return Err(Error::TransactionReadonly);
		}

		// P25: Extract the pending writes from LyxalKV transaction
		let write_set = self.inner.read().await.get_write_set();

		if !write_set.is_empty() {
			// Transform to ReplicatedBatch
			let entries = write_set
				.into_iter()
				.map(|(k, v)| match v {
					Some(val) => lyxal_sync::log::ReplicatedEntry::Set(k, val),
					None => lyxal_sync::log::ReplicatedEntry::Del(k),
				})
				.collect();

			let batch = lyxal_sync::log::ReplicatedBatch {
				entries,
			};

			// Propose to LyxalOS Consensus Engine (Raft)
			// This will replicate the data to all nodes before applying it locally
			let mut retry_count = 0;
			loop {
				match lyxal_os::propose_replicated_batch(batch.clone()).await {
					Ok(_) => break,
					Err(e) if retry_count < 10 => {
						retry_count += 1;
						tracing::warn!(target: TARGET, "Consensus proposal failed (attempt {}): {}. Retrying in 500ms...", retry_count, e);
						tokio::time::sleep(std::time::Duration::from_millis(500)).await;
					}
					Err(e) => return Err(Error::Datastore(e.to_string())),
				}
			}
		} else {
			// If empty, just commit locally to finalize any internal state
			self.inner
				.write()
				.await
				.commit()
				.await
				.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		}

		Ok(())
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn exists(&self, key: Key, version: Option<u64>) -> Result<bool> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		let inner = self.inner.read().await;
		match version {
			Some(v) => inner.get_at_version(&key, v),
			None => inner.get(&key),
		}
		.map(|v| v.is_some())
		.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn get(&self, key: Key, version: Option<u64>) -> Result<Option<Val>> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		let inner = self.inner.read().await;
		match version {
			Some(v) => inner.get_at_version(&key, v),
			None => inner.get(&key),
		}
		.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn set(&self, key: Key, val: Val, version: Option<u64>) -> Result<()> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		if !self.writeable() {
			return Err(Error::TransactionReadonly);
		}
		let mut inner = self.inner.write().await;
		match version {
			Some(v) => inner.set_at_version(&key, val, v),
			None => inner.set(&key, val),
		}
		.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn put(&self, key: Key, val: Val, version: Option<u64>) -> Result<()> {
		self.set(key, val, version).await
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn putc(&self, key: Key, val: Val, chk: Option<Val>) -> Result<()> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		if !self.writeable() {
			return Err(Error::TransactionReadonly);
		}
		let mut inner = self.inner.write().await;
		let current =
			inner.get(&key).map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		if current == chk {
			inner.set(&key, val).map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))
		} else {
			Err(Error::TransactionConditionNotMet)
		}
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn del(&self, key: Key) -> Result<()> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		if !self.writeable() {
			return Err(Error::TransactionReadonly);
		}
		self.inner
			.write()
			.await
			.delete(&key)
			.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		Ok(())
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(key = key.sprint()))]
	async fn delc(&self, key: Key, chk: Option<Val>) -> Result<()> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		if !self.writeable() {
			return Err(Error::TransactionReadonly);
		}
		let mut inner = self.inner.write().await;
		let current =
			inner.get(&key).map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		if current == chk {
			inner.delete(&key).map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))
		} else {
			Err(Error::TransactionConditionNotMet)
		}
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(rng = rng.sprint()))]
	async fn keys(&self, rng: Range<Key>, limit: u32, version: Option<u64>) -> Result<Vec<Key>> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		let mut keys = Vec::new();
		let inner = self.inner.read().await;
		match version {
			Some(v) => {
				let range = inner
					.range_at_version(&rng.start, &rng.end, v)
					.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
				for result in range {
					let (key, _): (Key, Val) =
						result.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
					keys.push(key);
					if limit > 0 && keys.len() >= limit as usize {
						break;
					}
				}
			}
			None => {
				let range = inner
					.range(&rng.start, &rng.end)
					.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
				for result in range {
					let (key, _): (Key, Val) =
						result.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
					keys.push(key);
					if limit > 0 && keys.len() >= limit as usize {
						break;
					}
				}
			}
		}
		Ok(keys)
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(rng = rng.sprint()))]
	async fn keysr(&self, rng: Range<Key>, limit: u32, version: Option<u64>) -> Result<Vec<Key>> {
		let mut res = self.keys(rng, limit, version).await?;
		res.reverse();
		Ok(res)
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(rng = rng.sprint()))]
	async fn scan(
		&self,
		rng: Range<Key>,
		limit: u32,
		version: Option<u64>,
	) -> Result<Vec<(Key, Val)>> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		let mut pairs = Vec::new();
		let inner = self.inner.read().await;
		match version {
			Some(v) => {
				let range = inner
					.range_at_version(&rng.start, &rng.end, v)
					.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
				for result in range {
					let (key, val): (Key, Val) =
						result.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
					pairs.push((key, val));
					if limit > 0 && pairs.len() >= limit as usize {
						break;
					}
				}
			}
			None => {
				let range = inner
					.range(&rng.start, &rng.end)
					.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
				for result in range {
					let (key, val): (Key, Val) =
						result.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
					pairs.push((key, val));
					if limit > 0 && pairs.len() >= limit as usize {
						break;
					}
				}
			}
		}
		Ok(pairs)
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(rng = rng.sprint()))]
	async fn scanr(
		&self,
		rng: Range<Key>,
		limit: u32,
		version: Option<u64>,
	) -> Result<Vec<(Key, Val)>> {
		let mut res = self.scan(rng, limit, version).await?;
		res.reverse();
		Ok(res)
	}

	#[instrument(level = "trace", target = "surrealdb::core::kvs::api", skip(self), fields(rng = rng.sprint()))]
	async fn scan_all_versions(
		&self,
		rng: Range<Key>,
		limit: u32,
	) -> Result<Vec<(Key, Val, Version, bool)>> {
		if self.closed() {
			return Err(Error::TransactionFinished);
		}
		let inner = self.inner.read().await;
		let limit_opt = if limit > 0 {
			Some(limit as usize)
		} else {
			None
		};
		let results = inner
			.scan_all_versions(&rng.start, &rng.end, limit_opt)
			.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;

		Ok(results)
	}

	async fn new_save_point(&self) -> Result<()> {
		self.inner
			.write()
			.await
			.set_savepoint()
			.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		Ok(())
	}

	async fn rollback_to_save_point(&self) -> Result<()> {
		self.inner
			.write()
			.await
			.rollback_to_savepoint()
			.map_err(|e: lyxalkv_engine::Error| Error::Datastore(e.to_string()))?;
		Ok(())
	}

	async fn release_last_save_point(&self) -> Result<()> {
		Ok(())
	}
}
