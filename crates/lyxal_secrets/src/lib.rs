#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_secrets` : coffre-fort des secrets applicatifs de Lyxal OS.
//!
//! Les règles (fiches, versions, étiquettes, droits, ticket de lecture, journal chaîné, clés des
//! organisations) vivent dans les fonctions SurrealQL `fn::secrets_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés (`SecretsStore`),
//! le scellement et l'ouverture des valeurs par `lyxal_crypto` sous la clé de chaque
//! organisation, elle-même scellée par la clé maîtresse du coffre-fort (`MasterKeys`), le
//! service des valeurs (`SecretsService`), l'interface des autres modules de l'hôte
//! (`SecretsClient`), le worker de maintenance supervisé, le module `LyxalModule` et sa sonde de
//! santé.

pub mod client;
pub mod error;
pub mod health;
pub mod keys;
pub mod models;
pub mod module;
pub mod service;
pub mod store;
pub mod worker;

pub use client::{ClientRead, ClientWrite, SecretsClient};
pub use error::{SecretsError, SecretsResult};
pub use health::SecretsHealthCheck;
pub use keys::MasterKeys;
pub use module::{SecretsModule, MODULE_ID};
pub use service::{PutValue, RevealRequest, RevealedValue, SecretsService};
pub use store::SecretsStore;
pub use worker::{MaintenanceReport, SecretsMaintenanceWorker};
