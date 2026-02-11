//! # Lyxal Webhook Core
//!
//! Native implementation of Webhooks for Lyxal OS.
//! Provides secure, transactional webhook handling with cryptographic verification.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                        HTTP Layer (server)                       │
//! │  ┌─────────────────────────────────────────────────────────────┐│
//! │  │              POST /webhook/*path                            ││
//! │  └─────────────────────────────────────────────────────────────┘│
//! └───────────────────────────────────────────────────────────────────┘
//!                              │
//!                              ▼
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                     WebhookDispatcher (core)                     │
//! │  1. Resolve DEFINE WEBHOOK from Registry                        │
//! │  2. Verify signature (HMAC / Stripe / RSA)                      │
//! │  3. Parse payload (JSON / Form / Raw / Binary)                  │
//! │  4. Emit system events                                          │
//! │  5. Execute handler (fn:: or EVENT)                             │
//! └─────────────────────────────────────────────────────────────────┘
//!                              │
//!                              ▼
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    SurrealDB Native Storage                      │
//! │  ┌──────────────┐ ┌──────────────┐                              │
//! │  │ !wh (KVS)    │ │DEFINE WEBHOOK│                              │
//! │  └──────────────┘ └──────────────┘                              │
//! └─────────────────────────────────────────────────────────────────┘
//! ```
//!
//! ## Multi-Tenant Design
//!
//! All webhooks are scoped to namespace/database for isolation:
//! - `/webhook/{ns}/{db}/{path}` or resolved via path matching
//!

pub mod dispatcher;
pub mod error;
pub mod registry;
pub mod types;
pub mod verifier;

// Re-exports for convenience
pub use dispatcher::WebhookDispatcher;
pub use error::{WebhookError, Result};
pub use registry::WebhookRegistry;
pub use types::{WebhookPayload, DispatchResult};
pub use verifier::WebhookVerifier;
