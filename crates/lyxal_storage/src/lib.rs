#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_storage` : fichiers et documents stockés de Lyxal OS.
//!
//! Les règles (buckets, fiches, états, droits, quotas) vivent dans les fonctions SurrealQL
//! `fn::storage_*` (installées par `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les
//! appels typés (`StorageStore`), les supports qui portent les octets (`Backends`, sur
//! `object_store`), l'écriture et la lecture en flux avec empreinte BLAKE3 de `lyxal_crypto`
//! (`StorageService`), l'envoi reprenable en plusieurs requêtes (`upload`), le worker de nettoyage supervisé, le module `LyxalModule` et sa sonde de
//! santé.

pub mod backend;
pub mod content;
pub mod error;
pub mod models;
pub mod module;
pub mod scanner;
pub mod service;
pub mod store;
pub mod upload;
pub mod worker;

pub use backend::{Backend, BackendConfig, Backends};
pub use error::{StorageError, StorageResult};
pub use module::{StorageHealthCheck, StorageModule, MODULE_ID};
pub use scanner::{ClamAvScanner, ContentScanner, ScanSession, ScanVerdict, ScannerConfig};
pub use service::{ByteRange, OpenedObject, PutRequest, StorageService, PART_SIZE};
pub use store::StorageStore;
pub use upload::{Appended, UploadRequest};
pub use worker::{CleanupReport, StorageCleanupWorker};
