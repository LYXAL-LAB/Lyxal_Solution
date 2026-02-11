# Lyxal Strategic Migration & Fork Management

This document defines the engineering strategy for evolving Lyxal from a deep integration within SurrealDB Beta 1 to a sustainable, modular fork based on SurrealDB Beta 2.

## 1. Context: The Beta 1 to Beta 2 Pivot

During the development of Lyxal, significant custom logic was added to the SurrealDB Beta 1 codebase, including:
- **Consensus Persistence**: Full Raft state saving.
- **Leader-Aware Routing**: Network optimizations.
- **RTC/SFU Engine**: Real-time communication methods integrated into the RPC protocol.
- **Storage Evolution**: WiscKey-based optimizations in LyxalKV.

Upgrading to SurrealDB Beta 2 revealed that a manual, line-by-line merge is unsustainable due to deep architectural changes in the upstream project (specifically in AST structures, transaction handling, and session management).

## 2. The "Pragmatic Fork" Strategy

To ensure Lyxal remains a cutting-edge product without becoming bogged down in perpetual merge conflicts, we are adopting the **Pragmatic Fork** model.

### 2.1 Component Isolation
Instead of mixing Lyxal code with legacy SurrealDB code, we enforce a strict directory separation:
- **`lyxal/`**: Contains pure Lyxal logic (`os`, `kv`, `net`, `sync`, `revision`). This is the "Holy Land" where code is modern, audited, and strictly versioned.
- **`legacy/`**: Contains the inherited SurrealDB core (currently Beta 2). This code is treated as a dependency that we maintain and adapt.

### 2.2 Inversion of Control
We are moving towards a model where the **LyxalOS Kernel** orchestrates the **Legacy SQL Engine**, rather than the SQL engine trying to host Lyxal services. This ensures that the core database becomes a service *on* the Lyxal platform.

## 3. The "Deep Patch" Policy

Certain modifications to the legacy core are unavoidable (e.g., adding RTC methods to the `RpcProtocol` trait). These are managed via a strict **Deep Patch** policy:

1.  **Code Markers**: Every manual modification in the `legacy/` or `core/` folders must be wrapped in markers:
    ```rust
    // LYXAL_START: [Feature Name]
    [Custom Lyxal Code]
    // LYXAL_END
    ```
2.  **Trait Extensions**: Prefer extending existing traits rather than modifying them.
3.  **Minimal Surface Area**: Logic should remain in `lyxal_*` crates; the core should only contain the "hooks" necessary to call that logic.

## 4. Migration Workflow (Beta 2 Implementation)

The transition to Beta 2 will follow these steps:

1.  **Freeze & Extract**: Extract current `lyxal_*` crates into a separate workspace.
2.  **Legacy Reset**: Replace the existing `core`, `sql`, and `syn` folders with fresh versions from the SurrealDB Beta 2 release.
3.  **Protocol Re-Injection**: Manually re-apply the RTC/SFU patches to `rpc/protocol.rs` using the updated Beta 2 logic (e.g., the new `diff` field in Live Queries).
4.  **Structural Alignment**: Adjust `lyxal/` components to match any breaking interface changes in the Beta 2 core (primarily in the `kvs` and `Transaction` traits).
5.  **Validation**: Run the full `cargo check` and `cargo test` suites to verify that the "New Core" works perfectly with the "Custom Brain".

## 5. Maintenance Philosophy

- **Stop Chasing Upstream**: We no longer aim for 1:1 parity with every minor SurrealDB commit.
- **Selective Backporting**: We monitor SurrealDB Pull Requests for critical bug fixes (e.g., Scanner race conditions, security fixes) and surgically apply them to our `legacy/` layer.
- **Innovation Focus**: Engineering resources are prioritized for Lyxal-exclusive features: distributed consensus, multi-tenant accounting, and high-performance RTC.

---
*Strategy approved for implementation: January 2025*