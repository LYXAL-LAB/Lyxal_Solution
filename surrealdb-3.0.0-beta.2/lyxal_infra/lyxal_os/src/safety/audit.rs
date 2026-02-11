use serde::{Serialize, Deserialize};
use std::sync::Arc;
use anyhow::{Result, anyhow};
use blake3;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SafetyAction {
    TxDebit,
    TxCredit,
    TxTransfer,
    RealmStart,
    SnapshotForce,
    AdminFreeze,
    AdminUnfreeze,
    AdminDispute,
    SystemStart,
    Settlement,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SafetyDecision {
    Allow,
    Deny(String),
    PendingReview(String),
    Frozen,
    Disputed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuditEntry {
    pub entry_id: u128,      // blake3(seed + seq + tx_id)
    pub timestamp_ns: u64,
    pub realm_id: u128,
    pub account_id: u128,
    pub principal: String,   // Who initiated?
    pub tx_id: u128,
    pub action: SafetyAction,
    pub decision: SafetyDecision, // Allow, Deny, frozen...
    pub risk_score: u8,
    pub prev_hash: [u8; 32],
    pub this_hash: [u8; 32],
    pub sequence: u64,       // Monotonic sequence number
}

#[derive(Serialize, Deserialize)]
struct LogHead {
    sequence: u64,
    last_hash: [u8; 32],
}

pub struct SecureAuditLog {
    db: Arc<lyxalkv::Tree>,
}

impl SecureAuditLog {
    /// Opens the Secure Audit Log backed by LyxalKV.
    ///
    /// Schema:
    /// - `_safety/audit/{seq_be}` -> AuditEntry
    /// - `_safety/audit/head` -> LogHead { sequence, last_hash }
    /// - `_safety/idx/acc/{account_id}/{seq_be}` -> seq (Index)
    pub fn new(db: Arc<lyxalkv::Tree>) -> Self {
        Self { db }
    }

    fn key_entry(seq: u64) -> Vec<u8> {
        let mut k = Vec::with_capacity(20);
        k.extend_from_slice(b"_safety/audit/");
        k.extend_from_slice(&seq.to_be_bytes());
        k
    }

    fn key_head() -> &'static [u8] {
        b"_safety/audit/head"
    }

    fn key_idx_account(account_id: u128, seq: u64) -> Vec<u8> {
        let mut k = Vec::with_capacity(40);
        k.extend_from_slice(b"_safety/idx/acc/");
        k.extend_from_slice(&account_id.to_be_bytes());
        k.push(b'/');
        k.extend_from_slice(&seq.to_be_bytes());
        k
    }

    fn get_head(&self, txn: &lyxalkv::Transaction) -> Result<LogHead> {
        if let Some(val) = txn.get(Self::key_head())? {
            Ok(bincode::deserialize(&val)?)
        } else {
            Ok(LogHead {
                sequence: 0,
                last_hash: [0u8; 32],
            })
        }
    }

    pub async fn log(&self, realm_id: u128, account_id: u128, principal: String, tx_id: u128, action: SafetyAction, decision: SafetyDecision, risk_score: u8) -> Result<()> {
        let mut txn = self.db.begin()?;
        
        let head = self.get_head(&txn)?;
        let next_seq = head.sequence + 1;
        let timestamp_ns = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_nanos() as u64;

        // Generate Entry ID deterministic
        let mut hasher = blake3::Hasher::new();
        hasher.update(&next_seq.to_be_bytes());
        hasher.update(&tx_id.to_be_bytes());
        let entry_hash = hasher.finalize();
        let entry_id = u128::from_be_bytes(entry_hash.as_bytes()[0..16].try_into()?);

        let mut entry = AuditEntry {
            entry_id,
            timestamp_ns,
            realm_id,
            account_id,
            principal,
            tx_id,
            action,
            decision,
            risk_score,
            prev_hash: head.last_hash,
            this_hash: [0u8; 32],
            sequence: next_seq,
        };

        // Calculate this_hash (Cryptographic Chain)
        let content_bytes = bincode::serialize(&(
            entry.entry_id,
            entry.timestamp_ns,
            entry.realm_id,
            entry.account_id,
            &entry.principal,
            entry.tx_id,
            &entry.action,
            &entry.decision,
            entry.risk_score,
            entry.prev_hash,
            entry.sequence
        ))?;
        
        entry.this_hash = *blake3::hash(&content_bytes).as_bytes();

        // 1. Write Entry
        let entry_bytes = bincode::serialize(&entry)?;
        txn.set(&Self::key_entry(next_seq), &entry_bytes)?;

        // 2. Write Index (Account -> Seq)
        txn.set(&Self::key_idx_account(account_id, next_seq), &next_seq.to_be_bytes())?;

        // 3. Update Head
        let new_head = LogHead {
            sequence: next_seq,
            last_hash: entry.this_hash,
        };
        txn.set(Self::key_head(), &bincode::serialize(&new_head)?)?;

        txn.commit().await.map_err(|e| anyhow!(e))?;
        Ok(())
    }
    
    pub fn read_entries(&self, filter_account: Option<u128>, limit: usize) -> Result<Vec<AuditEntry>> {
        let txn = self.db.begin()?;
        let mut results = Vec::new();

        if let Some(acc_id) = filter_account {
            // Index Scan: _safety/idx/acc/{acc_id}/...
            let prefix = Self::key_idx_account(acc_id, 0); // Base prefix
            // Remove the sequence part to get pure prefix
            let prefix_base = &prefix[0..prefix.len()-8]; 
            
            // We want to scan backwards if possible to get latest, but KV scan is usually forward.
            // Let's scan forward all for this account (assuming not millions of logs per account yet).
            // Optimization: In real world, use reverse iterator if available or scan from end key.
            
            let mut iter = txn.range(prefix_base, &b"_safety/idx/acc0"[..])?; // Hacky bound
            
            while let Some(res) = iter.next() {
                let (k, v) = res?;
                if !k.starts_with(prefix_base) { break; } // Bound check
                
                // v contains sequence (u64 be)
                if v.len() == 8 {
                    let seq = u64::from_be_bytes(v.try_into().unwrap());
                    if let Some(entry_bytes) = txn.get(&Self::key_entry(seq))? {
                        let entry: AuditEntry = bincode::deserialize(&entry_bytes)?;
                        results.push(entry);
                    }
                }
            }
        } else {
            // Full Scan (Last N)
            // Get Head first
            let head = self.get_head(&txn)?;
            let start = if head.sequence > limit as u64 { head.sequence - limit as u64 } else { 0 };
            
            for seq in start..=head.sequence {
                if let Some(entry_bytes) = txn.get(&Self::key_entry(seq))? {
                    let entry: AuditEntry = bincode::deserialize(&entry_bytes)?;
                    results.push(entry);
                }
            }
        }
        
        // Return latest first (optional, but good UX)
        results.reverse();
        if results.len() > limit {
            results.truncate(limit);
        }
        
        Ok(results)
    }

    // Validate chain integrity
    pub fn verify_integrity(&self) -> Result<bool> {
        let txn = self.db.begin()?;
        let head = self.get_head(&txn)?;
        
        if head.sequence == 0 { return Ok(true); }

        let mut prev_hash = [0u8; 32]; // Genesis hash

        for seq in 1..=head.sequence {
            let entry_bytes = txn.get(&Self::key_entry(seq))?
                .ok_or_else(|| anyhow!("Missing audit sequence {}", seq))?;
            
            let entry: AuditEntry = bincode::deserialize(&entry_bytes)?;

            if entry.prev_hash != prev_hash {
                return Ok(false); // Chain broken
            }

            // Recompute strict hash
            let content_bytes = bincode::serialize(&(
                entry.entry_id,
                entry.timestamp_ns,
                entry.realm_id,
                entry.account_id,
                &entry.principal,
                entry.tx_id,
                &entry.action,
                &entry.decision,
                entry.risk_score,
                entry.prev_hash,
                entry.sequence
            ))?;
            
            let computed = *blake3::hash(&content_bytes).as_bytes();
            if computed != entry.this_hash {
                return Ok(false); // Content tampered
            }

            prev_hash = entry.this_hash;
        }

        // Verify head matches last entry
        if prev_hash != head.last_hash {
            return Ok(false); // Head mismatch
        }

        Ok(true)
    }
}

