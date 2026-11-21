#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_storage` : fichiers et documents stockés de Lyxal OS.
//!
//! Les règles (buckets, fiches, états, droits, quotas) vivent dans les fonctions SurrealQL
//! `fn::storage_*` (installées par `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les
//! appels typés (`StorageStore`), les supports qui portent les octets (`Backends`, sur
//! `object_store`), l'écriture et la lecture en flux avec empreinte BLAKE3 de `lyxal_crypto`
//! (`StorageService`), le chiffrement au repos des buckets chiffrés (`encryption`, clés de
//! fichiers scellées par `lyxal_secrets`), l'envoi reprenable en plusieurs requêtes (`upload`),
//! le nettoyage (`StorageCleanup`, exécuté par `lyxal_scheduler` sur l'hôte : écritures
//! abandonnées, purges, rescellement des clés de fichiers après rotation), le module
//! `LyxalModule` et sa sonde de santé.

// `LyxalSurrealError` (erreur commune de `lyxal_surreal`, 272 octets) est rendue par les
// fonctions de ce crate ; Clippy de Rust 1.98 les signale (`result_large_err`), 1.97 ne le
// faisait pas. Même règle que `lyxal_surreal` et `lyxal_error` : réduire cette erreur serait un
// changement de contrat.
#![allow(clippy::result_large_err)]

pub mod backend;
pub mod cleanup;
pub mod content;
pub mod encryption;
pub mod error;
pub mod models;
pub mod module;
pub mod scanner;
pub mod service;
pub mod store;
pub mod upload;

pub use backend::{Backend, BackendConfig, Backends};
pub use cleanup::{CleanupReport, StorageCleanup};
pub use encryption::FileEncryption;
pub use error::{StorageError, StorageResult};
pub use module::{StorageHealthCheck, StorageModule, MODULE_ID};
pub use scanner::{ClamAvScanner, ContentScanner, ScanSession, ScanVerdict, ScannerConfig};
pub use service::{ByteRange, OpenedObject, PutRequest, StorageService, PART_SIZE};
pub use store::StorageStore;
pub use upload::{Appended, UploadRequest};
