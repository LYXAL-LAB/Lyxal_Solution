use crate::clock::{NodeId, Sequence, StreamId};
use crate::envelope::LyxalEnvelope;
use lyxal_revision::lyxal_revisioned;
use serde::{Deserialize, Serialize};

/// Unité de stockage persistante d'un log.
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct LogEntry {
	/// ID unique composite (NodeId, Sequence)
	/// Note: Dans la DB, ceci est souvent la clé primaire.
	pub id: (NodeId, Sequence),
	pub stream_id: StreamId,
	pub timestamp: u64,
	pub kind: u8,              // Type de payload
	pub payload_hash: Vec<u8>, // [u8; 32] mais Vec pour lyxal_revision simplicité
	pub payload: Vec<u8>,
}

/// Unité de transport réseau.
/// Décore l'enveloppe avec les informations de routing Sync.
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct LogWireItem {
	pub key: Vec<u8>, // P20.7: Added key for state-aware sync
	pub sequence: Sequence,
	pub stream_id: StreamId,
	pub envelope: LyxalEnvelope,
}

/// Represents a batch of key-value operations to be replicated across the cluster.
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct ReplicatedBatch {
	pub entries: Vec<ReplicatedEntry>,
}

/// A single operation within a replicated batch.
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub enum ReplicatedEntry {
	Set(Vec<u8>, Vec<u8>),
	Del(Vec<u8>),
}
