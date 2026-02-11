use crate::realm::RealmId;
use anyhow::{anyhow, Result};
use blake3;
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;
use std::sync::Arc;

pub type AccountId = u128;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AccountStatus {
	Active,
	Suspended,
	Closed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Account {
	pub id: AccountId,
	pub public_key: [u8; 32],
	pub created_at: u64,
	pub balance: i64,      // In micro-credits (MoneyMicros)
	pub credit_limit: i64, // Allows spending below zero
	pub realms: BTreeSet<RealmId>,
	pub status: AccountStatus,
	pub last_nonce: u64,
	pub pricing_plan_id: String, // P29
	pub billing_cursor_seq: u64, // P29: Monotonic sequence watermark
}

impl Account {
	pub fn derive_id(pubkey: &[u8; 32]) -> AccountId {
		let hash = blake3::hash(pubkey);
		let mut bytes = [0u8; 16];
		bytes.copy_from_slice(&hash.as_bytes()[0..16]);
		u128::from_be_bytes(bytes)
	}

	pub fn can_spend(&self, amount: i64) -> bool {
		self.balance + self.credit_limit >= amount
	}

	pub fn new(id: AccountId, pubkey: [u8; 32]) -> Self {
		Self {
			id,
			public_key: pubkey,
			created_at: 0,
			balance: 0,
			credit_limit: 0,
			realms: BTreeSet::new(),
			status: AccountStatus::Active,
			last_nonce: 0,
			pricing_plan_id: "default".into(),
			billing_cursor_seq: 0,
		}
	}
}

pub struct AccountRegistry {
	db: Arc<lyxalkv::Tree>,
}

impl AccountRegistry {
	/// Opens the Account Registry backed by LyxalKV.
	///
	/// Keys: `_ledger/acc/{account_id_be}` -> Account (Bincode)
	pub fn new(db: Arc<lyxalkv::Tree>) -> Self {
		Self {
			db,
		}
	}

	fn key(id: AccountId) -> Vec<u8> {
		let mut k = Vec::with_capacity(20);
		k.extend_from_slice(b"_ledger/acc/");
		k.extend_from_slice(&id.to_be_bytes());
		k
	}

	/// Fetches an account from the KV store.
	pub fn get(&self, id: AccountId) -> Option<Account> {
		// Warning: get is technically async in KV usually, but here txn.get might be sync if it reads from mem/cache
		// Let's check if txn.get is async. In LyxalKV, reads are often sync on the transaction handle or async?
		// In the test example above: let result = txn.get(b"test_key").unwrap().unwrap();
		// It seems txn.get() is SYNC.
		// But txn.commit() is ASYNC.

		let txn = self.db.begin().ok()?;
		let k = Self::key(id);
		if let Some(bytes) = txn.get(&k).ok()? {
			bincode::deserialize(&bytes).ok()
		} else {
			None
		}
	}

	/// Fetches an account state at a specific historical timestamp.
	/// Uses LyxalKV Time Travel (versioned) queries.
	pub fn get_at_timestamp(&self, id: AccountId, timestamp: u64) -> Option<Account> {
		let txn = self.db.begin().ok()?;
		let k = Self::key(id);
		// Uses the native Time Travel query capability of LyxalKV
		if let Some(bytes) = txn.get_at_version(&k, timestamp).ok()? {
			bincode::deserialize(&bytes).ok()
		} else {
			None
		}
	}

	/// Returns the full history of an account's state and balance changes.
	/// Leverages LyxalKV's internal versioning for auditability.
	pub fn get_history(&self, id: AccountId) -> Vec<(u64, Account)> {
		let mut history = Vec::new();
		if let Ok(txn) = self.db.begin() {
			let k = Self::key(id);
			// Scan all historical versions of this specific account key
			if let Ok(versions) = txn.scan_all_versions(&k, &k, None) {
				for (_, value, timestamp, is_deletion) in versions {
					if !is_deletion {
						if let Ok(acc) = bincode::deserialize(&value) {
							history.push((timestamp, acc));
						}
					}
				}
			}
		}
		history
	}

	/// Lists all accounts (Full Scan).
	/// Optimized for admin tools, not high frequency.
	pub fn list_accounts(&self) -> Vec<Account> {
		let mut accounts = Vec::new();
		if let Ok(txn) = self.db.begin() {
			let prefix = b"_ledger/acc/";
			// Hacky upper bound
			let end = b"_ledger/acc0";

			if let Ok(mut iter) = txn.range(&prefix[..], &end[..]) {
				while let Some(res) = iter.next() {
					if let Ok((_, bytes)) = res {
						if let Ok(acc) = bincode::deserialize(&bytes) {
							accounts.push(acc);
						}
					}
				}
			}
		}
		accounts
	}

	pub async fn create_account(
		&mut self,
		pubkey: [u8; 32],
		initial_balance: i64,
		credit_limit: i64,
		pricing_plan_id: String,
	) -> Result<AccountId> {
		let id = Account::derive_id(&pubkey);
		let k = Self::key(id);
		let mut txn = self.db.begin()?;

		if txn.get(&k)?.is_some() {
			return Ok(id); // Idempotent
		}

		let now = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_secs();

		let account = Account {
			id,
			public_key: pubkey,
			created_at: now,
			balance: initial_balance,
			credit_limit,
			realms: BTreeSet::new(),
			status: AccountStatus::Active,
			last_nonce: 0,
			pricing_plan_id,
			billing_cursor_seq: 0,
		};

		let bytes = bincode::serialize(&account)?;
		txn.set(&k, &bytes)?;
		txn.commit().await.map_err(|e| anyhow!(e))?;

		Ok(id)
	}

	pub async fn link_realm(&mut self, owner_id: AccountId, realm_id: RealmId) -> Result<()> {
		let k = Self::key(owner_id);
		let mut txn = self.db.begin()?;

		if let Some(bytes) = txn.get(&k)? {
			let mut account: Account = bincode::deserialize(&bytes)?;
			account.realms.insert(realm_id);

			let new_bytes = bincode::serialize(&account)?;
			txn.set(&k, &new_bytes)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
			Ok(())
		} else {
			Err(anyhow!("Account not found"))
		}
	}

	pub async fn credit_balance(&mut self, account_id: AccountId, amount: i64) -> Result<()> {
		let k = Self::key(account_id);
		let mut txn = self.db.begin()?;

		if let Some(bytes) = txn.get(&k)? {
			let mut account: Account = bincode::deserialize(&bytes)?;
			account.balance += amount;

			let new_bytes = bincode::serialize(&account)?;
			txn.set(&k, &new_bytes)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
			Ok(())
		} else {
			Err(anyhow!("Account not found"))
		}
	}

	pub async fn debit_balance(&mut self, account_id: AccountId, amount: i64) -> Result<()> {
		let k = Self::key(account_id);
		let mut txn = self.db.begin()?;

		if let Some(bytes) = txn.get(&k)? {
			let mut account: Account = bincode::deserialize(&bytes)?;
			if !account.can_spend(amount) {
				return Err(anyhow!("Insufficient funds"));
			}
			account.balance -= amount;

			let new_bytes = bincode::serialize(&account)?;
			txn.set(&k, &new_bytes)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
			Ok(())
		} else {
			Err(anyhow!("Account not found"))
		}
	}

	pub async fn apply_transaction(&mut self, tx: &crate::transactions::Transaction) -> Result<()> {
		use crate::transactions::TransactionKind;
		let mut txn = self.db.begin()?;

		// Helper closure to get account within txn
		let get_acc = |txn: &lyxalkv::Transaction, id: AccountId| -> Result<Account> {
			let k = Self::key(id);
			let bytes = txn.get(&k)?.ok_or_else(|| anyhow!("Account not found"))?;
			Ok(bincode::deserialize(&bytes)?)
		};

		// Helper closure to save account within txn
		let save_acc = |txn: &mut lyxalkv::Transaction, acc: &Account| -> Result<()> {
			let k = Self::key(acc.id);
			let bytes = bincode::serialize(acc)?;
			txn.set(&k, &bytes)?;
			Ok(())
		};

		match tx.kind {
			TransactionKind::Credit => {
				let to_id = tx.to.ok_or_else(|| anyhow!("Credit requires 'to' account"))?;
				let mut to_acc = get_acc(&txn, to_id)?;
				to_acc.balance += tx.amount;
				save_acc(&mut txn, &to_acc)?;
			}
			TransactionKind::Debit => {
				let from_id = tx.from.ok_or_else(|| anyhow!("Debit requires 'from' account"))?;
				let mut from_acc = get_acc(&txn, from_id)?;
				if !from_acc.can_spend(tx.amount) {
					return Err(anyhow!("Insufficient funds"));
				}
				from_acc.balance -= tx.amount;
				save_acc(&mut txn, &from_acc)?;
			}
			TransactionKind::Transfer => {
				let from_id = tx.from.ok_or_else(|| anyhow!("Transfer requires 'from' account"))?;
				let to_id = tx.to.ok_or_else(|| anyhow!("Transfer requires 'to' account"))?;

				if from_id == to_id {
					return Err(anyhow!("Cannot transfer to self"));
				}

				let mut from_acc = get_acc(&txn, from_id)?;
				if !from_acc.can_spend(tx.amount) {
					return Err(anyhow!("Insufficient funds"));
				}
				from_acc.balance -= tx.amount;
				save_acc(&mut txn, &from_acc)?;

				let mut to_acc = get_acc(&txn, to_id)?;
				to_acc.balance += tx.amount;
				save_acc(&mut txn, &to_acc)?;
			}
			TransactionKind::Refund => {
				let to_id = tx.to.ok_or_else(|| anyhow!("Refund requires 'to' account"))?;
				let mut to_acc = get_acc(&txn, to_id)?;
				to_acc.balance += tx.amount;
				save_acc(&mut txn, &to_acc)?;
			}
			TransactionKind::Adjustment => {
				if let Some(from_id) = tx.from {
					let mut from_acc = get_acc(&txn, from_id)?;
					from_acc.balance -= tx.amount;
					save_acc(&mut txn, &from_acc)?;
				}
				if let Some(to_id) = tx.to {
					let mut to_acc = get_acc(&txn, to_id)?;
					to_acc.balance += tx.amount;
					save_acc(&mut txn, &to_acc)?;
				}
			}
		}

		txn.commit().await.map_err(|e| anyhow!(e))?;
		Ok(())
	}

	pub async fn debit(&mut self, owner_id: AccountId, amount: i64) -> Result<()> {
		self.debit_balance(owner_id, amount).await
	}

	pub async fn update_nonce(&mut self, id: AccountId, nonce: u64) -> Result<()> {
		let k = Self::key(id);
		let mut txn = self.db.begin()?;

		if let Some(bytes) = txn.get(&k)? {
			let mut account: Account = bincode::deserialize(&bytes)?;
			if nonce <= account.last_nonce {
				return Err(anyhow!("Nonce must be strictly increasing"));
			}
			account.last_nonce = nonce;

			let new_bytes = bincode::serialize(&account)?;
			txn.set(&k, &new_bytes)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
			Ok(())
		} else {
			Err(anyhow!("Account not found"))
		}
	}

	pub async fn update_cursor(&mut self, id: AccountId, seq: u64) -> Result<()> {
		let k = Self::key(id);
		let mut txn = self.db.begin()?;

		if let Some(bytes) = txn.get(&k)? {
			let mut account: Account = bincode::deserialize(&bytes)?;
			if seq < account.billing_cursor_seq {
				return Err(anyhow!("Billing cursor cannot move backwards"));
			}
			account.billing_cursor_seq = seq;

			let new_bytes = bincode::serialize(&account)?;
			txn.set(&k, &new_bytes)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
			Ok(())
		} else {
			Err(anyhow!("Account not found"))
		}
	}

	pub fn reset_cursor_for_test(&mut self, id: AccountId, seq: u64) {
		// Warning: This is an async operation in KV, but signature is sync for test compatibility
		// We'll use blocking execution for test helper
		let k = Self::key(id);
		if let Ok(mut txn) = self.db.begin() {
			if let Ok(Some(bytes)) = txn.get(&k) {
				if let Ok(mut acc) = bincode::deserialize::<Account>(&bytes) {
					acc.billing_cursor_seq = seq;
					if let Ok(new_bytes) = bincode::serialize(&acc) {
						let _ = txn.set(&k, &new_bytes);
						let _ = futures::executor::block_on(txn.commit());
					}
				}
			}
		}
	}

	pub fn set_balance_for_test(&mut self, id: AccountId, balance: i64) {
		let k = Self::key(id);
		if let Ok(mut txn) = self.db.begin() {
			if let Ok(Some(bytes)) = txn.get(&k) {
				if let Ok(mut acc) = bincode::deserialize::<Account>(&bytes) {
					acc.balance = balance;
					if let Ok(new_bytes) = bincode::serialize(&acc) {
						let _ = txn.set(&k, &new_bytes);
						let _ = futures::executor::block_on(txn.commit());
					}
				}
			}
		}
	}
}
