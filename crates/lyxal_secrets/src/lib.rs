#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_secrets` : coffre-fort des secrets applicatifs de Lyxal OS.
//!
//! Les règles (fiches, versions, étiquettes, droits, ticket de lecture, journal chaîné, clés des
//! organisations) vivent dans les fonctions SurrealQL `fn::secrets_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés (`SecretsStore`),
//! le scellement et l'ouverture des valeurs par `lyxal_crypto` sous la clé de chaque
//! organisation, elle-même scellée par la clé maîtresse du coffre-fort (`MasterKeys`), le
//! service des valeurs (`SecretsService`), la rotation par les rotateurs inscrits
//! (`SecretRotator`, `RotationRunner`), l'interface des autres modules de l'hôte
//! (`SecretsClient`), les partages à usage unique (`SecretsService::share_create`,
//! `SecretsService::share_open`), la maintenance (`SecretsMaintenance`, exécutée par
//! `lyxal_scheduler` sur l'hôte), le scellement des clés de fichiers chiffrés des autres modules
//! de l'hôte par une clé « fichiers » de chaque organisation (`FileKeys`), le module
//! `LyxalModule` et sa sonde de santé.

pub mod client;
pub mod error;
pub mod files;
pub mod health;
pub mod keys;
pub mod maintenance;
pub mod models;
pub mod module;
pub mod rotation;
pub mod service;
pub mod share;
pub mod store;

pub use client::{ClientRead, ClientWrite, SecretsClient};
pub use error::{SecretsError, SecretsResult};
pub use files::{FileKeys, SealedFileKey};
pub use health::SecretsHealthCheck;
pub use keys::MasterKeys;
pub use maintenance::{MaintenanceReport, SecretsMaintenance};
pub use module::{SecretsModule, MODULE_ID};
pub use rotation::{RotationOutcome, RotationRunner, RotatorError, RotatorRegistry, SecretRotator};
pub use service::{
    ProposeRequest, ProposedChange, PutValue, RevealRequest, RevealedValue, RotateRequest,
    SecretsService,
};
pub use share::{OpenerContext, ShareCreated, ShareOpen, ShareRequest, ShareSource};
pub use store::SecretsStore;
