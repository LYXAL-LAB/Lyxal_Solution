use serde::{Serialize, Deserialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::fs::{OpenOptions};
use std::io::{Write, Read};

// Status for Accounts
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum AccountSafetyStatus {
    Active,
    Frozen { reason: String, admin: String, timestamp: u64 },
    UnderAudit { reason: String },
    Terminated,
}

// Status for Specific Transactions (Disputes)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct DisputeRecord {
    pub tx_id: u128,
    pub amount_held: i64,
    pub reason: String,
    pub open_at: u64,
    pub resolved_at: Option<u64>,
}

pub struct GovernanceManager {
    path: PathBuf,
    // In-memory state (replayed from log or snapshot)
    pub account_status: HashMap<u128, AccountSafetyStatus>,
    pub disputes: HashMap<u128, Vec<DisputeRecord>>, 
}

impl GovernanceManager {
    pub fn new(data_dir: PathBuf) -> Self {
        let path = data_dir.join("governance.bin");
        let mut gov = Self {
            path,
            account_status: HashMap::new(),
            disputes: HashMap::new(),
        };
        // Load state
        let _ = gov.load();
        gov
    }

    fn load(&mut self) -> Result<(), anyhow::Error> {
        if !self.path.exists() { return Ok(()); }
        let file = std::fs::File::open(&self.path)?;
        let state: (HashMap<u128, AccountSafetyStatus>, HashMap<u128, Vec<DisputeRecord>>) = bincode::deserialize_from(file)?;
        self.account_status = state.0;
        self.disputes = state.1;
        Ok(())
    }

    fn save(&self) -> Result<(), anyhow::Error> {
        // Atomic save: tmp -> rename
        let tmp_path = self.path.with_extension("tmp");
        let mut file = std::fs::File::create(&tmp_path)?;
        bincode::serialize_into(&mut file, &(&self.account_status, &self.disputes))?;
        file.sync_all()?;
        std::fs::rename(tmp_path, &self.path)?;
        Ok(())
    }

    pub fn freeze(&mut self, account_id: u128, reason: String, admin: String) -> Result<(), anyhow::Error> {
        let status = AccountSafetyStatus::Frozen {
             reason,
             admin,
             timestamp: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_secs(),
        };
        self.account_status.insert(account_id, status);
        self.save()
    }

    pub fn unfreeze(&mut self, account_id: u128) -> Result<(), anyhow::Error> {
        self.account_status.insert(account_id, AccountSafetyStatus::Active);
        self.save()
    }

    pub fn get_status(&self, account_id: u128) -> AccountSafetyStatus {
        self.account_status.get(&account_id).cloned().unwrap_or(AccountSafetyStatus::Active)
    }

    pub fn dispute_tx(&mut self, account_id: u128, tx_id: u128, amount: i64, reason: String) -> Result<(), anyhow::Error> {
        let record = DisputeRecord {
            tx_id,
            amount_held: amount, // Positive amount to hold
            reason,
            open_at: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_secs(),
            resolved_at: None,
        };
        
        self.disputes.entry(account_id).or_default().push(record);
        self.save()
    }

    pub fn get_held_balance(&self, account_id: u128) -> i64 {
        self.disputes.get(&account_id)
            .map(|list| list.iter()
                .filter(|d| d.resolved_at.is_none())
                .map(|d| d.amount_held)
                .sum()
            )
            .unwrap_or(0)
    }
}
