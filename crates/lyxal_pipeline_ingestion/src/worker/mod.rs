//! Module worker supervisé pour le pipeline d'ingestion Lyxal OS.

pub mod ingestion_worker;

pub use ingestion_worker::{BatchProcessingReport, IngestionWorker};
