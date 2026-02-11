# LyxalNet: Secure Cloud Transport Layer

LyxalNet is the high-performance networking engine responsible for physical data transport, cryptographic security, and multi-tenant isolation. It implements the Lyxal Sync Protocol (LSP) over TCP with advanced protection mechanisms for cloud environments.

## 1. Secure Handshake (Zero-Trust Identity)

LyxalNet enforces a strict "Zero-Trust" policy where every peer must prove its identity before any data is exchanged.

### Mutual Authentication
- **Ed25519 Identity**: Each node has a persistent identity. The `NodeId` is cryptographically derived from its Ed25519 public key.
- **X25519 Key Exchange**: During the `Hello` phase, nodes perform an Ephemeral Diffie-Hellman (ECDH) exchange to derive a unique session key.
- **Mutual Determinism**: Session salts are derived by sorting both nonces to ensure both sides arrive at the exact same key without transmitting it.

### DoS Protection
To prevent memory saturation attacks, LyxalNet enforces strict size limits on handshake fields:
- `nonce`, `public_key`, `ephemeral_key`: Exactly 32 bytes.
- `signature`: Exactly 64 bytes.
- Any violation results in immediate connection termination.

## 2. Secure Framing & Encryption

Once established, all communication is encrypted and authenticated.

- **Session Cipher**: Uses AEAD (Authenticated Encryption with Associated Data) to ensure confidentiality and integrity.
- **Anti-Replay**: Every frame includes a monotonic sequence number (`send_seq` / `recv_seq`). Messages with duplicate or out-of-order sequences are rejected.
- **Frame Validation**: Frames exceeding the `MAX_FRAME_SIZE` (16MB) are discarded to protect against buffer overflow attempts.

## 3. Multi-Tenant Isolation (Realms)

LyxalNet is "Realm-Aware," meaning it enforces strict isolation between different tenants at the network level.

- **Realm Validation**: The `RealmId` is exchanged during the handshake. If a peer attempts to connect to a Realm it doesn't belong to, the connection is rejected.
- **Trust Store**: Each node maintains a `TrustStore` scoped to its Realm, preventing unauthorized nodes from joining the cluster.

## 4. Cloud Quotas & Throttling

To ensure infrastructure stability and cost control in the cloud, LyxalNet implements a sophisticated quota system.

### Peer Limits
- **Slot Guard**: Limits the maximum number of concurrent peer connections allowed for a specific Realm.

### Bandwidth Throttling (Token Bucket)
LyxalNet implements a thread-safe **Token Bucket** algorithm to rate-limit data transmission:
- **Bandwidth Limit**: Configurable `bandwidth_limit_bps` (bytes per second) per Realm.
- **Burstable Traffic**: Allows for short bursts of high-speed transfer (up to 2 seconds of buffer) while maintaining a strict long-term average.
- **Enforcement**: Incremental updates (Deltas) and full transfers (Snapshots) are both subject to this throttle.

## 5. Resilience & Chaos Engineering

LyxalNet includes built-in hooks for testing resilience in unstable cloud networks:
- **Chaos Injection**: Macros like `failpoint!` and `error_point!` allow simulating network delays, frame tampering, or connection drops.
- **Connectivity Watermarks**: Peers track "lag" and health status (`Healthy`, `Lagging`, `NeedsSnapshot`), allowing the Kernel to make informed decisions about cluster health.

## 6. Observability

Native metrics are integrated into the transport layer:
- **Identity Rejections**: Tracks failed handshake attempts.
- **Trust Rejections**: Tracks unauthorized node attempts.
- **Throughput Stats**: Real-time tracking of raw vs compressed bytes sent.

---
*For details on the synchronization logic, see [SYNC.md](./SYNC.md). For high-level orchestration, see [OPERATIONS.md](./OPERATIONS.md).*