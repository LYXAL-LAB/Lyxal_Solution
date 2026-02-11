use std::collections::HashMap;
use lyxal_revision::lyxal_revisioned;
use crate::clock::{NodeId, Sequence, StreamId};

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq)]
pub struct Snapshot {
    pub id: Vec<u8>, // Hash ID
    pub stream_id: StreamId,
    pub covers_clock: HashMap<NodeId, Sequence>,
    pub timestamp: u64,
    pub data: Vec<u8>, // Blob compressé ou brut
}
