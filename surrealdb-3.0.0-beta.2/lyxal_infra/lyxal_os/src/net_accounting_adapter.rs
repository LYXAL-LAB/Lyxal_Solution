use std::sync::Arc;
use crate::accounting::{AccountingEngine, UsageEvent, UsageKind, UsageMeta};

pub struct OsAccountingObserver {
    pub engine: Arc<AccountingEngine>,
}

impl lyxal_net::accounting_observer::AccountingObserver for OsAccountingObserver {
    fn on_delta_sent(&self, realm_id: u128, bytes: u64) {
        self.emit(realm_id, UsageKind::SyncDeltaBytes, bytes, None, None);
    }

    fn on_snapshot_sent(&self, realm_id: u128, bytes: u64) {
        self.emit(realm_id, UsageKind::SyncSnapshotBytes, bytes, None, None);
    }

    fn on_peer_connected(&self, _realm_id: u128, _peer_id: u128) {
        // Optionnel : on peut enregistrer l'event de connexion
    }

    fn on_peer_disconnected(&self, realm_id: u128, peer_id: u128, connected_ms: u64) {
        self.emit(realm_id, UsageKind::PeerConnectedMillis, connected_ms, Some(peer_id), None);
    }
}

impl OsAccountingObserver {
    fn emit(&self, realm_id: u128, kind: UsageKind, units: u64, _peer_id: Option<u128>, _note: Option<String>) {
        let meter_id = match kind {
            UsageKind::SyncDeltaBytes => "sync.delta.bytes",
            UsageKind::SyncSnapshotBytes => "sync.snapshot.bytes",
            UsageKind::PeerConnectedMillis => "sync.peer.millis",
            UsageKind::KernelAction => "os.kernel.action",
            UsageKind::StorageBytesHour => "os.storage.bytes",
        };
        
        // Note: owner_id is handled by AccountingEngine internally if we use a better emit.
        // For now, we use 0 as account_id and let the ledger resolve it if needed, 
        // OR we just use emit_simple.
        self.engine.emit_simple(realm_id, 0, "sync".to_string(), meter_id.to_string(), units as i64);
    }
}
