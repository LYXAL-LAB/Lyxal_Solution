//! Persistance SurrealDB du pipeline d'ingestion : [`IngestionStore`] appelle les fonctions
//! publiques `fn::ingestion_*` du module (lots, lignes brutes, staging, quarantaine,
//! manifestes, référentiels, console Data Steward).

pub mod store;

pub use store::{
    BatchClaim, BatchProgress, IngestionStore, ManifestDraft, NewBatch, QuarantineCorrections,
};
