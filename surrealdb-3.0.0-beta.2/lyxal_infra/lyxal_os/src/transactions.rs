use serde::{Serialize, Deserialize};
use std::sync::Arc;
use anyhow::Result;
use tokio::sync::mpsc::Sender;
use lyxal_sync::log::LogWireItem;
use lyxal_sync::envelope::LyxalEnvelope;
use lyxal_sync::clock::StreamId;

pub type TransactionId = u128;
pub type IdempotencyKey = [u8; 32];

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TransactionKind {
    Credit,
    Debit,
    Transfer,
    Refund,
    Adjustment,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KernelReceipt {
    pub tx_id: TransactionId,
    pub applied: bool,
    pub term: u64,
    pub leader_id: u128,
    pub state_digest: [u8; 32],
    pub kernel_sig: Vec<u8>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransactionRequest {
    pub kind: TransactionKind,
    pub from: Option<AccountId>,
    pub to: Option<AccountId>,
    pub amount: i64,
    pub reason: String,
    pub idempotency_key: IdempotencyKey,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    pub id: TransactionId,
    pub ts_ns: u64,
    pub kind: TransactionKind,
    pub from: Option<AccountId>,
    pub to: Option<AccountId>,
    pub amount: i64,
    pub currency: u32, // Defaults to 0 (Lyxal Credits)
    pub reason: String,
    pub idempotency_key: IdempotencyKey,
    pub signature: Vec<u8>, // Ed25519 signature of the request
    pub receipt: Option<KernelReceipt>,
}

use crate::account::AccountId;

pub struct TransactionStore {
    db: Arc<lyxalkv::Tree>,
    sync_tx: Option<Sender<LogWireItem>>,
    node_id: u128,
}

impl TransactionStore {
    /// Opens the transaction store backed by LyxalKV.
    /// 
    /// The store uses two prefixes:
    /// - `_ledger/tx/{tx_id}` -> Transaction (Primary Record)
    /// - `_ledger/idx/idem/{idem_key}` -> tx_id (Idempotency Index)
    pub fn new(db: Arc<lyxalkv::Tree>, node_id: u128) -> Self {
        Self { 
            db, 
            sync_tx: None,
            node_id,
        }
    }

    pub fn with_sync(mut self, tx: Sender<LogWireItem>) -> Self {
        self.sync_tx = Some(tx);
        self
    }

    fn key_tx(id: TransactionId) -> Vec<u8> {
        let mut key = Vec::with_capacity(20);
        key.extend_from_slice(b"_ledger/tx/");
        key.extend_from_slice(&id.to_be_bytes());
        key
    }

    fn key_idempotency(key: &IdempotencyKey) -> Vec<u8> {
        let mut k = Vec::with_capacity(40);
        k.extend_from_slice(b"_ledger/idx/idem/");
        k.extend_from_slice(key);
        k
    }

    pub fn get(&self, id: TransactionId) -> Result<Option<Transaction>> {
        let txn = self.db.begin()?;
        let key = Self::key_tx(id);
        
        if let Some(val) = txn.get(&key)? {
            let tx: Transaction = bincode::deserialize(&val)?;
            Ok(Some(tx))
        } else {
            Ok(None)
        }
    }

    pub fn get_by_idempotency(&self, key: &IdempotencyKey) -> Result<Option<Transaction>> {
        let txn = self.db.begin()?;
        let idx_key = Self::key_idempotency(key);
        
        if let Some(val) = txn.get(&idx_key)? {
            // Index contains the TransactionId
            let tx_id = u128::from_be_bytes(val.try_into().map_err(|_| anyhow::anyhow!("Invalid Index"))?);
            
            // Fetch the actual TX
            let tx_key = Self::key_tx(tx_id);
            if let Some(tx_bytes) = txn.get(&tx_key)? {
                let tx: Transaction = bincode::deserialize(&tx_bytes)?;
                return Ok(Some(tx));
            }
        }
        Ok(None)
    }

    /// Appends a new transaction atomically.
    /// Updates both the transaction record and the idempotency index.
    pub async fn append(&self, tx: Transaction) -> Result<()> {
        let mut txn = self.db.begin()?;
        
        let tx_key = Self::key_tx(tx.id);
        let idx_key = Self::key_idempotency(&tx.idempotency_key);
        
        // 1. Check Idempotency (Double-Check)
        if txn.get(&idx_key)?.is_some() {
            return Err(anyhow::anyhow!("Duplicate idempotency key"));
        }

        // 2. Serialize
        let tx_bytes = bincode::serialize(&tx)?;
        
        // 3. Write Primary Record
        txn.set(&tx_key, &tx_bytes)?;
        
        // 4. Write Index
        txn.set(&idx_key, &tx.id.to_be_bytes())?;
        
        // 5. Commit DB
        txn.commit().await.map_err(|e| anyhow::anyhow!(e))?;
        
        // 6. Emit Sync Event
        if let Some(sender) = &self.sync_tx {
            let envelope = LyxalEnvelope::new(
                tx_bytes, 
                self.node_id, 
                tx.ts_ns
            );
            
                let item = LogWireItem {
                    key: tx_key,
                    sequence: 0, // Assigned by SyncService
                    stream_id: 0, // Ledger Stream (StreamId = u128)
                    envelope,
                };
            
            // Fire and forget (or log error)
            if let Err(e) = sender.send(item).await {
                tracing::warn!("Failed to emit sync event for tx {}: {}", tx.id, e);
            }
        }

        Ok(())
    }

    /// Lists transactions involving a specific account.
    /// Note: This performs a full scan. In production, we need a secondary index `_ledger/idx/acc/{account_id}/{tx_id}`.
    pub fn list_for_account(&self, account_id: AccountId) -> Result<Vec<Transaction>> {
        let txn = self.db.begin()?;
        let mut res = Vec::new();
        
        // Scan prefix `_ledger/tx/`
        let prefix = b"_ledger/tx/";
        // We use a simplified range scan here assuming keys are ordered
        let mut iter = txn.range(&prefix[..], &b"_ledger/tx0"[..])?; // Hacky upper bound, strictly need a better prefix scan
        
        // Proper way: iterate over range. Since we only have _ledger/tx/ as prefix.
        // Let's iterate widely and filter.
        // Optimization TODO: Implement secondary index for AccountId
        
        while let Some(entry) = iter.next() {
             let (_, val) = entry?;
             let tx: Transaction = bincode::deserialize(&val)?;
             if tx.from == Some(account_id) || tx.to == Some(account_id) {
                 res.push(tx);
             }
        }
        
        Ok(res)
    }

    pub fn get_state_digest(&self) -> [u8; 32] {
        // Since we don't have a Merkle Tree yet (TODO), we return a dummy digest or
        // compute a hash of the last inserted ID if we tracked it.
        // For now, let's keep it simple to satisfy the interface.
        [0u8; 32] 
    }
}

