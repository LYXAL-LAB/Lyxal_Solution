```# LyxalOS: The Distributed Resource Kernel

LyxalOS is the "brain" of the Lyxal system. It operates as a distributed kernel responsible for resource orchestration, multi-tenant lifecycle management, strong consistency via Raft, and cloud-native billing.

## 1. The Kernel Philosophy

The LyxalOS Kernel follows a **Reconciliation Loop** pattern (similar to Kubernetes). Instead of executing one-off commands, it constantly compares the **Desired State** (what should be) with the **Observed State** (what actually is) and performs actions to align them.

### Key Responsibilities:
- **Realm Management**: Creation, starting, stopping, and deletion of isolated tenant environments (Realms).
- **Service Injection**: Dynamically wiring networking (`lyxal_net`) and storage (`lyxalkv`) into active realms.
- **Resource Guarding**: Enforcing security policies and credit limits before allowing any physical system action.

## 2. Distributed Consensus (Raft)

LyxalOS implements a fully distributed state machine using the **Raft Consensus Algorithm**. This ensures that the kernel remains highly available and consistent across a cluster.

### Consensus Features:
- **Leader Election**: Automated election with randomized timeouts to prevent split-brain scenarios.
- **Log Replication**: All kernel decisions (e.g., "Start Realm X", "Charge Account Y") are replicated across a quorum of nodes before being applied.
- **Safety**: Guarantees that only one leader is active per term and that the log is never overwritten or corrupted.
- **Transition Logic**: Prioritizes Raft-based decisions over legacy disk-based leases, ensuring resilience against network partitions.

## 3. Multi-Tenancy & Realms

Isolation is the core of LyxalOS. Every tenant operates within a **Realm**.
- **Context Isolation**: Each Realm has its own cryptographic identity, dedicated storage paths, and network quota.
- **Policy Enforcement**: A global policy engine evaluates every action (Create/Start/Stop) against the tenant's rights.
- **Hard Quotas**: Physical resource limits (max peers, bandwidth) are enforced at the kernel level.

## 4. Cloud Billing & Financial Audit

LyxalOS includes a high-precision billing engine designed for cloud scale.

### The Accounting Engine:
- **Event Streaming**: Services emit `UsageEvents` (bytes transferred, storage hours, etc.) into a lock-free buffer.
- **RealmLedger**: Aggregates usage in real-time by Account and Realm.
- **Atomic Settlement**: Uses a multi-stage workflow (`Recorded` -> `Applied` -> `Finalized`) to ensure financial integrity even during crashes.

### Financial Immutability (Time Travel):
Leveraging LyxalKV's versioned storage, LyxalOS provides **Auditability-as-a-Service**:
- **Historical Queries**: Retrieve the exact balance of any account at any nanosecond in the past.
- **Incorruptible History**: Every balance change creates a new immutable version in the LSM-tree, providing a perfect audit trail for compliance.

## 5. Kernel Lifecycle

1. **Boot**: Initializes the local `lyxalkv` storage and triggers financial recovery for any interrupted settlements.
2. **Consensus Loop**: Heartbeats keep the cluster alive. If the node is elected leader, it takes control of the reconciliation loop.
3. **Reconcile**: The leader scans the global manifest, checks account balances, and issues commands to start/stop realms across the cluster.
4. **Shutdown**: Drains active transfers and cleanly closes storage engines to ensure 0% data loss.

## 6. Developer & IA Integration

- **Control Plane**: Use the `ConsensusManager` to propose state changes to the cluster.
- **Resource Monitoring**: Access the `AccountingEngine` to get real-time consumption metrics.
- **Safety Governance**: Use the `SafetyManager` to freeze accounts or dispute high-risk transactions.

---
*For low-level protocol details, see [SYNC.md](./SYNC.md). For transport security, see [NET.md](./NET.md).*
