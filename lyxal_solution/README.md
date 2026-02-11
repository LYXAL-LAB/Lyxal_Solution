# Lyxal Solution: Strategic Fork of SurrealDB

This document outlines the vision and technical strategy for **Lyxal**, a high-performance, distributed, and multi-tenant operating system and database engine built upon a strategic fork of SurrealDB.

## 1. The Vision
Lyxal is not merely a database; it is a **Cloud-Native Distributed Operating System** where the data storage layer (based on SurrealDB) is seamlessly integrated with network routing, multi-tenant resource management (Realms), and real-time communication (RTC/SFU).

## 2. Core Pillars

### 2.1 LyxalKV (Storage Layer)
A specialized storage engine based on the **WiscKey** architecture.
- **Decoupled Keys/Values**: Minimizes write amplification by storing large values in a separate Value Log (VLog).
- **MVCC & Time Travel**: Native support for versioned queries and snapshots.
- **Resilience**: Atomic commit pipelines and verified isolation levels via Oracle-based concurrency control.

### 2.2 LyxalOS (Control Plane)
The governance layer managing system-wide coordination.
- **Realms**: Logical isolation for multi-tenancy with strict resource accounting.
- **Raft Consensus**: Distributed leadership management with full state persistence to ensure cluster stability across restarts.
- **Kernel**: Orchestrates services and handles the lifecycle of various system components.

### 2.3 LyxalNet (Networking Layer)
A leader-aware P2P networking stack.
- **Adaptive Routing**: Intelligently routes requests to the current Raft leader or consistent followers.
- **Direct Messaging**: Optimized RPC protocol to reduce network noise by avoiding unnecessary broadcasts.
- **Identity & Security**: Cryptographic node identity and verified trust stores.

### 2.4 RTC & SFU (Communication Engine)
Integrated real-time signaling and multi-party conferencing.
- **SFU Integration**: Native support for Selective Forwarding Units within the database RPC protocol.
- **P2P Signaling**: Built-in methods for WebRTC handshake and session management.

## 3. Technical Strategy: The "Clean Fork"

To maintain long-term stability and ease of integration with upstream SurrealDB updates (like the migration from Beta 1 to Beta 2), Lyxal follows a **Modular Separation Strategy**:

1.  **Isolated Crates**: All Lyxal-specific logic resides in dedicated `lyxal_*` crates.
2.  **Explicit Patching**: Modifications to the inherited SurrealDB core are kept to a minimum and clearly documented to allow for surgical "Backporting" of upstream fixes.
3.  **Unified Protocol**: Lyxal components speak a common language of identity and sequencing, ensuring that storage, network, and consensus are perfectly coordinated.

## 4. Current Roadmap
- [x] Implementation of Raft persistence for LyxalOS.
- [x] Integration of leader-aware routing in LyxalNet.
- [x] Stabilization of the WiscKey storage engine (LyxalKV).
- [x] Full compilation and warning cleanup.
- [ ] Migration to SurrealDB Beta 2 core architecture while preserving custom Lyxal modules.

---
*Lyxal: Redefining the boundary between the Operating System and the Database.*
```markdown