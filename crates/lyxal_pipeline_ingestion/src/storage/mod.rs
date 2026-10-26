//! Module de persistance industrielle SurrealDB v3.2.0 (Directive CTO Phase 4).
//!
//! Assure :
//! - La persistance des 5 tables du staging et de la quarantaine.
//! - L'enregistrement et la lecture des checkpoints (`cursor_offset`) pour reprise sur incident.
//! - L'idempotence durable par hachage de fichier et déduplication de lignes.
//! - Le scellement et l'approbation formelle des manifestes de publication.

pub mod store;

pub use store::IngestionStore;
