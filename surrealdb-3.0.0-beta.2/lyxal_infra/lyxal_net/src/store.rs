use lyxal_sync::protocol::SnapshotHeader;
use lyxal_sync::clock::{VectorClock, NodeId};
use lyxal_sync::log::LogWireItem;
use lyxal_sync::envelope::LyxalEnvelope;
use crate::error::Result;
use async_trait::async_trait;

/// Interface abstraite pour le stockage synchronisé.
/// Permet au Peer d'interroger l'état local et d'appliquer les mises à jour distantes.
#[async_trait]
pub trait SyncStore: Send + Sync {
    /// Retourne l'horloge vectorielle actuelle du store.
    fn get_clock(&self) -> VectorClock;

    /// Récupère une liste d'opérations (logs) pour combler un delta.
    /// `since`: Horloge connue par le distant.
    /// `limit`: Nombre max d'items à retourner.
    async fn get_delta(&self, since: &VectorClock, limit: usize) -> Result<Vec<LogWireItem>>;

    /// Applique des opérations reçues d'un distant.
    async fn apply_delta(&self, items: Vec<LogWireItem>) -> Result<()>;

    // Snapshot Methods
    async fn get_snapshot(&self) -> Result<(SnapshotHeader, Vec<u8>)>;
    async fn apply_snapshot_begin(&self, header: SnapshotHeader) -> Result<()>;
    async fn apply_snapshot_chunk(&self, snapshot_id: &[u8], offset: u64, data: Vec<u8>) -> Result<()>;
    async fn apply_snapshot_commit(&self, snapshot_id: &[u8]) -> Result<()>;
}

/// Implémentation Mock en mémoire pour les tests.
pub struct MemoryStore {
    id: NodeId,
    inner: parking_lot::RwLock<MemoryStoreInner>,
}

struct MemoryStoreInner {
    clock: VectorClock,
    logs: Vec<LogWireItem>,
    // Snapshot state
    current_snapshot_data: Option<Vec<u8>>,
    current_snapshot_id: Option<Vec<u8>>,
    current_snapshot_header: Option<SnapshotHeader>,
}

impl MemoryStore {
    pub fn new(id: NodeId) -> Self {
        Self {
            id,
            inner: parking_lot::RwLock::new(MemoryStoreInner {
                clock: VectorClock::new(0u128),
                logs: Vec::new(),
                current_snapshot_data: None,
                current_snapshot_id: None,
                current_snapshot_header: None,
            }),
        }
    }

    pub fn append(&self, payload: Vec<u8>) {
        let mut inner = self.inner.write();
        let seq = inner.clock.increment(self.id);
        let envelope = LyxalEnvelope::new(payload, self.id, 0); // Timestamp 0 pour test
        inner.logs.push(LogWireItem {
            key: Vec::new(), // Mock key
            sequence: seq,
            stream_id: 0,
            envelope,
        });
    }
}

#[async_trait]
impl SyncStore for MemoryStore {
    fn get_clock(&self) -> VectorClock {
        self.inner.read().clock.clone()
    }

    async fn get_delta(&self, since: &VectorClock, limit: usize) -> Result<Vec<LogWireItem>> {
        let inner = self.inner.read();
        let mut delta = Vec::new();
        for item in &inner.logs {
            let remote_seq = since.get(&item.envelope.node_id);
            if item.sequence > remote_seq {
                delta.push(item.clone());
            }
            if delta.len() >= limit {
                break;
            }
        }
        Ok(delta)
    }

    async fn apply_delta(&self, items: Vec<LogWireItem>) -> Result<()> {
        let mut inner = self.inner.write();
        for item in items {
            let node = item.envelope.node_id;
            let current = inner.clock.get(&node);
            if item.sequence > current {
                inner.clock.update(node, item.sequence);
                inner.logs.push(item);
            }
        }
        Ok(())
    }

    async fn get_snapshot(&self) -> Result<(SnapshotHeader, Vec<u8>)> {
        let inner = self.inner.read();
        let snapshot_data = format!("SNAP:{:?}", inner.clock).into_bytes();
        let snapshot_id = vec![1, 2, 3, 4]; // Test ID

        let header = SnapshotHeader {
            snapshot_id: snapshot_id.clone(),
            covers_clock: inner.clock.clocks.clone(),
            size_bytes: snapshot_data.len() as u64,
            created_at_ns: 0,
            compression: None,
            root_hash: [0u8; 32],
        };

        Ok((header, snapshot_data))
    }

    async fn apply_snapshot_begin(&self, header: SnapshotHeader) -> Result<()> {
        let mut inner = self.inner.write();
        inner.current_snapshot_header = Some(header.clone());
        inner.current_snapshot_id = Some(header.snapshot_id);
        inner.current_snapshot_data = Some(Vec::new());
        Ok(())
    }

    async fn apply_snapshot_chunk(&self, snapshot_id: &[u8], _offset: u64, data: Vec<u8>) -> Result<()> {
        let mut inner = self.inner.write();
        if let Some(curr_id) = &inner.current_snapshot_id {
            if curr_id == snapshot_id {
                if let Some(buf) = &mut inner.current_snapshot_data {
                    buf.extend(data);
                }
            }
        }
        Ok(())
    }

    async fn apply_snapshot_commit(&self, snapshot_id: &[u8]) -> Result<()> {
         let mut inner = self.inner.write();
         if let Some(curr_id) = &inner.current_snapshot_id {
            if curr_id == snapshot_id {
                if let Some(header) = &inner.current_snapshot_header {
                    inner.clock.clocks = header.covers_clock.clone();
                    inner.logs.clear();
                }
                inner.current_snapshot_id = None;
                inner.current_snapshot_data = None;
                inner.current_snapshot_header = None;
            }
         }
         Ok(())
    }
}
