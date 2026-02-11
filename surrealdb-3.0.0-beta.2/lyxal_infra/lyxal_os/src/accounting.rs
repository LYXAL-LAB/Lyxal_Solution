use serde::{Serialize, Deserialize};
use std::sync::Arc;
use tokio::sync::mpsc;
use tracing::{warn, info};
use crate::ledger::RealmLedger;
use crate::realm::RealmId;
use std::sync::atomic::{AtomicU64, Ordering};
use std::collections::HashMap;

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum UsageKind {
    KernelAction,
    SyncDeltaBytes,
    SyncSnapshotBytes,
    PeerConnectedMillis,
    StorageBytesHour, // Réservé pour futur usage
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsageMeta {
    pub peer_id: Option<u128>,
    pub action: Option<String>,
    pub note: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsageEvent {
    pub seq: u64,           // P29: Global monotone sequence
    pub ts_ns: u64,
    pub account_id: u128,   // P29: Target account
    pub realm_id: u128,
    pub service: String,
    pub meter_id: String,   // P29: Canonical ID (e.g. dav.write.ops)
    pub units: i64,         // Signed for potential adjustments
    pub meta: Option<UsageMeta>,
}

pub struct AccountingEngine {
    tx: mpsc::Sender<UsageEvent>,
    pub dropped_count: Arc<AtomicU64>,
    pub next_seq: Arc<AtomicU64>, // Monotone sequence generator
    ledger: Arc<RealmLedger>,     // P30bis: For read-only access
}

impl AccountingEngine {
    pub fn new(ledger: Arc<RealmLedger>, owner_map: Arc<parking_lot::RwLock<HashMap<u128, u128>>>) -> Self {
        let (tx, mut rx) = mpsc::channel(10000);
        let dropped_count = Arc::new(AtomicU64::new(0));
        let dc_clone = dropped_count.clone();
        let ledger_clone = ledger.clone();
        
        // In a real system, we might load the last seq from disk/ledger.
        // For now, we start at 1.
        let next_seq = Arc::new(AtomicU64::new(1));

        tokio::spawn(async move {
            info!("AccountingEngine: Worker started.");
            let mut batch = Vec::with_capacity(100);
            let mut interval = tokio::time::interval(std::time::Duration::from_secs(2));

            loop {
                tokio::select! {
                    Some(event) = rx.recv() => {
                        batch.push(event);
                        if batch.len() >= 100 {
                            let om = owner_map.read().clone();
                            ledger_clone.record_batch_v2(&batch, &om).await;
                            batch.clear();
                        }
                    }
                    _ = interval.tick() => {
                        if !batch.is_empty() {
                            let om = owner_map.read().clone();
                            ledger_clone.record_batch_v2(&batch, &om).await;
                            batch.clear();
                        }
                        
                        let dropped = dc_clone.load(Ordering::Relaxed);
                        if dropped > 0 {
                            warn!("AccountingEngine: {} events dropped due to full channel.", dropped);
                        }
                    }
                }
            }
        });

        Self {
            tx,
            dropped_count,
            next_seq,
            ledger,
        }
    }

    pub fn emit_simple(&self, realm_id: u128, account_id: u128, service: String, meter_id: String, units: i64) {
        let seq = self.next_seq.fetch_add(1, Ordering::SeqCst);
        let ts = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u64;
        
        let event = UsageEvent {
            seq,
            ts_ns: ts,
            account_id,
            realm_id,
            service,
            meter_id,
            units,
            meta: None,
        };

        if let Err(_) = self.tx.try_send(event) {
            self.dropped_count.fetch_add(1, Ordering::Relaxed);
        }
    }

    pub fn emit(&self, mut event: UsageEvent) {
        // Enforce sequence if not set
        if event.seq == 0 {
            event.seq = self.next_seq.fetch_add(1, Ordering::SeqCst);
        }
        if let Err(_) = self.tx.try_send(event) {
            self.dropped_count.fetch_add(1, Ordering::Relaxed);
        }
    }

    pub fn dropped_count(&self) -> u64 {
        self.dropped_count.load(Ordering::Relaxed)
    }

    /// P30bis: Read-only access to account events from ledger
    pub fn get_events_for_account(&self, account_id: u128) -> Vec<UsageEvent> {
        // Load all events for this account (start_seq=0, end_seq=u64::MAX)
        self.ledger.load_account_events(account_id, 0, u64::MAX).unwrap_or_default()
    }
}
