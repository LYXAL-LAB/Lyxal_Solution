# LyxalSync: Distributed State Synchronization Protocol

LyxalSync is the core synchronization engine of the Lyxal system. it provides the protocol definitions and causal consistency mechanisms required for multi-node data replication and distributed consensus.

## 1. Overview

LyxalSync operates as a "State-Aware" synchronization layer. Unlike simple message queues, it understands the causal relationship between data updates using **Vector Clocks**. It is designed to minimize bandwidth while ensuring that all nodes in a cluster eventually converge to the same state.

## 2. Core Primitives

### Vector Clocks (`clock.rs`)
The `VectorClock` is the heart of LyxalSync's consistency model.
- **Partitioning**: Clocks are partitioned by `StreamId` (typically representing a Namespace or a Database).
- **Causality**: It maps `NodeId -> Sequence`, allowing the system to determine if one update is newer than, older than, or concurrent with another.
- **Watermarks**: Used to detect "lag" between nodes and trigger either incremental updates (Delta) or full state transfers (Snapshots).

### The Envelope (`envelope.rs`)
All data transported by LyxalSync is wrapped in a `LyxalEnvelope`.
- **Magic Number**: `0x4C59584C` for protocol identification.
- **Metadata**: Includes the producer's `NodeId` and a high-resolution UTC timestamp.
- **Opaque Payload**: Carries the actual business data, kept opaque to the sync layer to maintain separation of concerns.

## 3. Communication Protocol (LSP)

The **Lyxal Sync Protocol (LSP)** defines a multi-stage handshake and data exchange flow.

### Message Types (`protocol.rs`)
| Message | Stage | Description |
| :--- | :--- | :--- |
| `Hello` | Handshake | Negotiates capabilities, exchanges public keys (Ed25519), and authenticates the Realm. |
| `StateSummary` | Anti-Entropy | Nodes broadcast their current Vector Clock to peers to identify missing data. |
| `RequestDelta` | Convergence | Requests specific sequence ranges from a peer's log. |
| `DeltaChunk` | Data Transfer | Sends a batch of `LogWireItem` (Key + Sequence + Envelope). |
| `SnapshotOffer` | Convergence | Offered when a node is too far behind to be synced via Deltas. |
| `Raft` | Consensus | Encapsulates Raft-specific messages (`RequestVote`, `AppendEntries`). |

## 4. Distributed Consensus (Raft Integration)

LyxalSync provides the wire format for the Raft implementation in `lyxal_os`. 

- **Reliability**: Raft messages are transported over the same secure, authenticated channels as data sync.
- **Separation**: While Data Sync is eventually consistent (AP), Raft-driven Kernel operations are strongly consistent (CP).

## 5. Cloud-Native Optimizations

### Delta Patches
LSP supports `DeltaPatch` messages. Instead of sending the full object, the system can send only the diff between `base_sequence` and `target_sequence`, significantly reducing cloud egress costs.

### Capabilities Negotiation
Nodes exchange `Capabilities` during the handshake to agree on:
- **Zstd Compression**: Enable/Disable based on CPU/Bandwidth availability.
- **Protocol Versioning**: Ensures backward compatibility during rolling upgrades in the cloud.
- **Max Chunk Size**: Prevents large sync batches from saturating the network.

## 6. Developer Integration

To implement a new sync provider, you must fulfill the `SyncStore` trait:
1. Provide the current `VectorClock`.
2. Provide a `Snapshot` for full state transfer.
3. Supply a `Delta` (iterator of log entries) given a starting sequence.

---
*For network implementation details, see [NET.md](./NET.md). For orchestration details, see [OPERATIONS.md](./OPERATIONS.md).*