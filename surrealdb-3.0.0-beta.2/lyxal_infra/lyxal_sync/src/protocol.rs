use crate::clock::{NodeId, Sequence, StreamId};
use crate::log::LogWireItem;
use lyxal_revision::lyxal_revisioned;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Capabilities {
	pub supports_push: bool,
	pub supports_snapshot: bool,
	pub supports_compression_zstd: bool,
	pub supports_delta_patch: bool, // For cloud bandwidth optimization
	pub max_chunk_bytes: u32,

	// P19: OS-Level Capabilities
	pub protocol_version: u16,
	pub os_version: String,
	pub node_features: u64,     // bitflags
	pub required_features: u64, // bitflags
}

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct RaftLogEntry {
	pub term: u64,
	pub index: u64,
	pub data: Vec<u8>,
}

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub enum RaftMessage {
	RequestVote {
		term: u64,
		candidate_id: NodeId,
		last_log_index: u64,
		last_log_term: u64,
	},
	VoteResponse {
		term: u64,
		vote_granted: bool,
	},
	AppendEntries {
		term: u64,
		leader_id: NodeId,
		prev_log_index: u64,
		prev_log_term: u64,
		entries: Vec<RaftLogEntry>,
		leader_commit: u64,
	},
	AppendResponse {
		term: u64,
		success: bool,
		match_index: u64,
	},
}

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct SnapshotHeader {
	pub snapshot_id: Vec<u8>, // [u8; 32]
	pub covers_clock: HashMap<NodeId, Sequence>,
	pub size_bytes: u64,
	pub created_at_ns: u64,
	pub compression: Option<u8>, // 0=None, 1=Zstd
	pub root_hash: [u8; 32],     // BLAKE3 root
}

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub enum LspMessage {
	// 1. Handshake
	Hello {
		node_id: NodeId,
		realm_id: u128, // P20.4 Protocol Realm-Aware
		protocol_version: u32,
		nonce: Vec<u8>,         // [u8; 32]
		public_key: Vec<u8>,    // [u8; 32] Ed25519
		ephemeral_key: Vec<u8>, // [u8; 32] X25519
		signature: Vec<u8>,     // [u8; 64] Sign(Context)
		capabilities: Capabilities,
	},

	// 2. Anti-entropy
	StateSummary {
		stream_id: StreamId,
		my_clock: HashMap<NodeId, Sequence>,
		// P20.8: Gossip hints (Address string, RealmID)
		hints: Vec<(String, u128)>,
	},

	// 3. Convergence (Request)
	RequestDelta {
		stream_id: StreamId,
		// (NodeId, StartSeq, EndSeq)
		ranges: Vec<(NodeId, Sequence, Sequence)>,
	},

	// 4. Convergence (Offer Snapshot)
	SnapshotOffer {
		header: SnapshotHeader,
	},

	// 5. Convergence (Accept Snapshot)
	RequestSnapshot {
		snapshot_id: Vec<u8>,
	},

	// 6. Data Transfer (Log)
	DeltaChunk {
		items: Vec<LogWireItem>,
		next_cursor: Option<u64>, // Opaque cursor for pagination
	},

	// 6.5 Data Transfer (Delta Patch)
	DeltaPatch {
		stream_id: StreamId,
		key: Vec<u8>,
		base_sequence: Sequence,
		target_sequence: Sequence,
		patch_data: Vec<u8>,
	},

	// 7. Data Transfer (Snapshot)
	SnapshotChunk {
		snapshot_id: Vec<u8>,
		offset: u64,
		data: Vec<u8>,
		is_last: bool,
		codec: u8, // 0=None, 1=Zstd
		raw_len: u32,
		compressed_len: u32,
		chunk_hash: [u8; 32], // BLAKE3(raw_data)
	},

	// 8. Confirmation
	ApplyAck {
		stream_id: StreamId,
		updated_clock: HashMap<NodeId, Sequence>,
	},

	// 9. Consensus (P23)
	Heartbeat {
		term: u64,
		leader_id: NodeId,
		timestamp_ms: u64,
	},

	// 10. Raft Consensus
	Raft {
		from: NodeId,
		message: RaftMessage,
	},
}
