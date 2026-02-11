use std::sync::Arc;
use async_trait::async_trait;
use lyxalkv::{Tree, Mode, ReadOptions};
use lyxal_sync::clock::{VectorClock, StreamId};
use lyxal_sync::log::LogWireItem;
use lyxal_sync::protocol::SnapshotHeader;
use crate::store::SyncStore;
use crate::error::{Result, NetError};
use bincode;

pub struct LyxalStore {
    db: Arc<Tree>,
    node_id: u128,
}

impl LyxalStore {
    pub fn new(db: Arc<Tree>, node_id: u128) -> Self {
        Self { db, node_id }
    }

    fn clock_key(stream_id: StreamId) -> Vec<u8> {
        let mut key = b"c".to_vec();
        key.extend_from_slice(&stream_id.to_be_bytes());
        key
    }

    fn log_prefix(stream_id: StreamId) -> Vec<u8> {
        let mut key = b"l".to_vec();
        key.extend_from_slice(&stream_id.to_be_bytes());
        key
    }

    fn log_key(stream_id: StreamId, seq: u64) -> Vec<u8> {
        let mut key = Self::log_prefix(stream_id);
        key.extend_from_slice(&seq.to_be_bytes());
        key
    }
}

#[async_trait]
impl SyncStore for LyxalStore {
    fn get_clock(&self) -> VectorClock {
        // Here we use a default stream_id 0 because the trait doesn't provide it
        let stream_id = 0;
        let txn = self.db.begin_with_mode(Mode::ReadOnly).expect("Failed to begin transaction");
        let key = Self::clock_key(stream_id);
        match txn.get(&key).expect("Failed to get clock from DB") {
            Some(val) => {
                bincode::deserialize(&val).expect("Failed to deserialize clock")
            }
            None => VectorClock::new(stream_id),
        }
    }

    async fn get_delta(&self, since: &VectorClock, limit: usize) -> Result<Vec<LogWireItem>> {
        let txn = self.db.begin_with_mode(Mode::ReadOnly).map_err(|e| NetError::Generic(e.to_string()))?;
        let prefix = Self::log_prefix(since.stream_id);
        
        let mut opts = ReadOptions::default();
        opts.set_iterate_lower_bound(Some(prefix.clone()));
        
        let mut upper = prefix.clone();
        if let Some(last) = upper.last_mut() {
            *last = last.wrapping_add(1);
        } else {
            upper.push(1);
        }
        opts.set_iterate_upper_bound(Some(upper));

        let mut items = Vec::new();
        let range = txn.range_with_options(&opts).map_err(|e| NetError::Generic(e.to_string()))?;
        
        for result in range {
            let (_key, val) = result.map_err(|e| NetError::Generic(e.to_string()))?;
            let item: LogWireItem = bincode::deserialize(&val).map_err(|e| NetError::Generic(e.to_string()))?;
            
            let remote_seq = since.get(&item.envelope.node_id);
            if item.sequence > remote_seq {
                items.push(item.clone());
            }
            
            if items.len() >= limit {
                break;
            }
        }
        
        Ok(items)
    }

    async fn apply_delta(&self, items: Vec<LogWireItem>) -> Result<()> {
        let mut txn = self.db.begin().map_err(|e| NetError::Generic(e.to_string()))?;
        
        for item in items {
            let stream_id = item.stream_id;
            
            let clock_key = Self::clock_key(stream_id);
            let mut clock = match txn.get(&clock_key).map_err(|e| NetError::Generic(e.to_string()))? {
                Some(val) => bincode::deserialize(&val).map_err(|e| NetError::Generic(e.to_string()))?,
                None => VectorClock::new(stream_id),
            };

            let node = item.envelope.node_id;
            let current = clock.get(&node);
            if item.sequence > current {
                clock.update(node, item.sequence);
                let key = Self::log_key(stream_id, item.sequence);
                let val = bincode::serialize(&item).map_err(|e| NetError::Generic(e.to_string()))?;
                txn.set(&key, &val).map_err(|e| NetError::Generic(e.to_string()))?;
                
                let clock_val = bincode::serialize(&clock).map_err(|e| NetError::Generic(e.to_string()))?;
                txn.set(&clock_key, &clock_val).map_err(|e| NetError::Generic(e.to_string()))?;
            }
        }

        txn.commit().await.map_err(|e| NetError::Generic(e.to_string()))?;
        Ok(())
    }

    async fn get_snapshot(&self) -> Result<(SnapshotHeader, Vec<u8>)> {
        let clock = self.get_clock();
        let snapshot_data = bincode::serialize(&clock).map_err(|e| NetError::Generic(e.to_string()))?;
        
        let header = SnapshotHeader {
            snapshot_id: vec![0],
            covers_clock: clock.clocks.clone(),
            size_bytes: snapshot_data.len() as u64,
            created_at_ns: 0,
            compression: None,
            root_hash: [0u8; 32],
        };
        
        Ok((header, snapshot_data))
    }

    async fn apply_snapshot_begin(&self, _header: SnapshotHeader) -> Result<()> {
        Ok(())
    }

    async fn apply_snapshot_chunk(&self, _snapshot_id: &[u8], _offset: u64, _data: Vec<u8>) -> Result<()> {
        Ok(())
    }

    async fn apply_snapshot_commit(&self, _snapshot_id: &[u8]) -> Result<()> {
        Ok(())
    }
}
