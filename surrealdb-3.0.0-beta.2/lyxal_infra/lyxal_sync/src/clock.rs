use std::collections::HashMap;
use lyxal_revision::lyxal_revisioned;
use serde::{Serialize, Deserialize};

pub type NodeId = u128;
pub type StreamId = u128;
pub type Sequence = u64;

/// Horloge vectorielle partitionnée par Stream (Namespace).
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct VectorClock {
    pub stream_id: StreamId,
    /// Mapping NodeId -> Last Seen Sequence
    pub clocks: HashMap<NodeId, Sequence>,
}

impl VectorClock {
    pub fn new(stream_id: StreamId) -> Self {
        Self {
            stream_id,
            clocks: HashMap::new(),
        }
    }

    /// Met à jour la connaissance pour un nœud donné.
    /// Retourne true si mis à jour.
    pub fn update(&mut self, node: NodeId, seq: Sequence) -> bool {
        let current = self.clocks.entry(node).or_insert(0);
        if seq > *current {
            *current = seq;
            true
        } else {
            false
        }
    }

    /// Obtient la séquence connue pour un nœud
    pub fn get(&self, node: &NodeId) -> Sequence {
        *self.clocks.get(node).unwrap_or(&0)
    }

    /// Incrémente la séquence pour un nœud donné et la retourne.
    pub fn increment(&mut self, node: NodeId) -> Sequence {
        let current = self.clocks.entry(node).or_insert(0);
        *current += 1;
        *current
    }
}
