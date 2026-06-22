//! # Lyxal Bridge — Outbound API Connector Engine
//!
//! Ce module est le moteur d'exécution du Lyxal Bridge. Il remplace l'ancien
//! système `DEFINE CONNECTOR` par une approche **data-driven** où toutes les
//! métadonnées (providers, opérations, auth, erreurs) sont lues dynamiquement
//! depuis les tables `bridge_*` de SurrealDB.
//!
//! ## Point d'entrée principal
//!
//! ```rust,ignore
//! use lyxal_bridge::bridge_call;
//!
//! let result = bridge_call(&ctx, "airtable", "list_records", params).await?;
//! ```
//!
//! ## Architecture
//!
//! ```text
//! SurrealQL: bridge::call("slack", "send_message", { channel: "general" })
//!     │
//!     ▼
//! bridge_call()  ─── resolver.rs   (lit la DB)
//!     │               │
//!     ├── request.rs  (construit la requête HTTP)
//!     ├── executor.rs (exécute avec retry/rate-limit)
//!     ├── hooks.rs    (pré/post traitement)
//!     └── response.rs (parse la réponse)
//! ```

pub mod context;
pub mod error;
pub mod executor;
pub mod hooks;
pub mod models;
pub mod rate_limit;
pub mod request;
pub mod resolver;
pub mod response;
pub mod trace;

// Re-exports principaux
pub use context::BridgeContext;
pub use error::BridgeError;
pub use executor::{bridge_call, BridgeCallResult};
pub use trace::{BridgeTrace, TraceBuilder};
