use serde::{Serialize, Deserialize};
use crate::registry_new::MoneyMicros;
use crate::billing::RatedPeriod;
use std::sync::Arc;
use anyhow::{Result, anyhow};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum InvoiceStatus {
    Open,
    ClosedSigned,
    Paid,
    Defaulted { reason: String },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Invoice {
    pub period_id: [u8; 32],
    pub account_id: u128,
    pub plan_id: String,
    pub cursor_start: u64,
    pub cursor_end: u64,
    pub status: InvoiceStatus,
    pub total_micros: MoneyMicros,
    pub created_at_ns: u64,
    pub closed_at_ns: Option<u64>,
    pub signature: Option<Vec<u8>>,
    pub digest: [u8; 32],
    // P30bis: For rendering
    #[serde(default)]
    pub line_items: std::collections::HashMap<String, i64>,
    #[serde(default)]
    pub meter_totals: std::collections::HashMap<String, i64>,
}

pub struct InvoiceStore {
    db: Arc<lyxalkv::Tree>,
}

impl InvoiceStore {
    /// Opens the Invoice Store backed by LyxalKV.
    ///
    /// Schema:
    /// - `_ledger/inv/{period_id_hex}` -> Invoice (Bincode)
    /// - `_ledger/idx/acc_inv/{account_id_be}/{period_id_hex}` -> period_id (Index)
    pub fn new(db: Arc<lyxalkv::Tree>) -> Self {
        Self { db }
    }

    fn key_inv(period_id: &[u8; 32]) -> Vec<u8> {
        let hex = hex::encode(period_id);
        let mut key = Vec::with_capacity(50);
        key.extend_from_slice(b"_ledger/inv/");
        key.extend_from_slice(hex.as_bytes());
        key
    }

    fn key_idx_account(account_id: u128, period_id: &[u8; 32]) -> Vec<u8> {
        let hex = hex::encode(period_id);
        let mut key = Vec::with_capacity(80);
        key.extend_from_slice(b"_ledger/idx/acc_inv/");
        key.extend_from_slice(&account_id.to_be_bytes());
        key.push(b'/');
        key.extend_from_slice(hex.as_bytes());
        key
    }

    pub async fn save(&self, invoice: &Invoice) -> Result<()> {
        let mut txn = self.db.begin()?;

        let key_inv = Self::key_inv(&invoice.period_id);
        let key_idx = Self::key_idx_account(invoice.account_id, &invoice.period_id);

        let bytes = bincode::serialize(invoice)?;

        // 1. Write Primary Record
        txn.set(&key_inv, &bytes)?;

        // 2. Write Index (Account -> Invoice)
        // Value can be empty or just the period_id, the key is enough for range scan
        txn.set(&key_idx, &invoice.period_id)?;

        txn.commit().await.map_err(|e| anyhow!(e))?;
        Ok(())
    }

    pub fn get(&self, period_id: &[u8; 32]) -> Result<Option<Invoice>> {
        let txn = self.db.begin()?;
        let key = Self::key_inv(period_id);
        
        if let Some(bytes) = txn.get(&key)? {
            let inv: Invoice = bincode::deserialize(&bytes)?;
            Ok(Some(inv))
        } else {
            Ok(None)
        }
    }

    pub fn list_for_account(&self, account_id: u128) -> Result<Vec<Invoice>> {
        let txn = self.db.begin()?;
        let mut invoices = Vec::new();

        // Range Scan on Index: _ledger/idx/acc_inv/{account_id}/...
        let mut prefix = Vec::with_capacity(40);
        prefix.extend_from_slice(b"_ledger/idx/acc_inv/");
        prefix.extend_from_slice(&account_id.to_be_bytes());
        prefix.push(b'/');

        // Upper bound hack: append 0xFF to prefix
        let mut end = prefix.clone();
        end.push(0xFF);

        let mut iter = txn.range(&prefix[..], &end[..])?;

        while let Some(entry) = iter.next() {
            let (_, val) = entry?;
            // val contains period_id (32 bytes)
            if val.len() == 32 {
                let mut period_id = [0u8; 32];
                period_id.copy_from_slice(&val);

                // Fetch full invoice
                let key_inv = Self::key_inv(&period_id);
                if let Some(inv_bytes) = txn.get(&key_inv)? {
                    let inv: Invoice = bincode::deserialize(&inv_bytes)?;
                    invoices.push(inv);
                }
            }
        }
        Ok(invoices)
    }

    /// P30bis: List all invoices (for metrics) - Full Scan
    /// Warning: Expensive operation in KV store
    pub fn list_all(&self) -> Result<Vec<Invoice>> {
        let txn = self.db.begin()?;
        let mut invoices = Vec::new();
        
        // Scan _ledger/inv/
        let start = b"_ledger/inv/";
        let end = b"_ledger/inv0"; // ASCII successor of / is 0

        let mut iter = txn.range(&start[..], &end[..])?;

        while let Some(entry) = iter.next() {
            let (_, val) = entry?;
            let inv: Invoice = bincode::deserialize(&val)?;
            invoices.push(inv);
        }
        Ok(invoices)
    }
}

pub struct InvoiceEngine;

impl InvoiceEngine {
    pub fn create_open(rated: &RatedPeriod) -> Invoice {
        let mut inv = Invoice {
            period_id: rated.period_id,
            account_id: rated.account_id,
            plan_id: rated.plan_id.clone(),
            cursor_start: rated.cursor_start,
            cursor_end: rated.cursor_end,
            status: InvoiceStatus::Open,
            total_micros: rated.total_micros,
            created_at_ns: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u64,
            closed_at_ns: None,
            signature: None,
            digest: [0u8; 32],
            line_items: rated.line_items.clone(),
            meter_totals: rated.meter_totals.clone(),
        };
        inv.digest = Self::compute_digest(&inv);
        inv
    }

    pub fn compute_digest(inv: &Invoice) -> [u8; 32] {
        let mut hasher = blake3::Hasher::new();
        hasher.update(&inv.period_id);
        hasher.update(&inv.account_id.to_be_bytes());
        hasher.update(inv.plan_id.as_bytes());
        hasher.update(&inv.cursor_start.to_be_bytes());
        hasher.update(&inv.cursor_end.to_be_bytes());
        hasher.update(&inv.total_micros.to_be_bytes());
        // Note: status is not in digest as it may change (Paid, Defaulted)
        // But digest is fixed when ClosedSigned.
        hasher.finalize().into()
    }
}

