//! # `lyxal_pipeline_ingestion`
//!
//! Moteur industriel d'ingestion, normalisation, qualification et préparation des catalogues fabricants
//! pour le Master Catalogue de Lyxal OS.
//!
//! ## Architecture
//!
//! Ce module implémente :
//! - Le contrat universel [`lyxal_runtime::LyxalModule`] via [`PipelineIngestionModule`].
//! - La machine à états stricte de cycle de vie de lot et de qualification via [`BatchStateMachine`], [`StagedItemStateMachine`] et [`ManifestStateMachine`].
//! - Le calcul d'empreintes canoniques et de scellement de publication par hachage BLAKE3 via [`FingerprintEngine`].
//! - Les adaptateurs de sources multiformats ([`adapters::FabDisAdapter`], [`adapters::CsvAdapter`], [`adapters::XmlAdapter`], [`adapters::JsonAdapter`]).
//! - Le moteur de normalisation universel ([`normalization::NormalizationEngine`]).
//! - Le moteur de regroupement technique multi-niveaux à 4 niveaux stricts ([`technical_grouping::TechnicalGroupingEngine`]).
//! - Les modèles typés du staging et de la quarantaine : [`IngestionBatch`], [`RawRecord`], [`StagedItem`], [`QuarantineRecord`], [`PublicationManifest`].

pub mod adapters;
pub mod error;
pub mod events;
pub mod fingerprint;
pub mod health;
pub mod models;
pub mod module;
pub mod normalization;
pub mod proof;
pub mod publisher;
pub mod quarantine;
pub mod state_machine;
pub mod storage;
pub mod technical_grouping;
pub mod types;
pub mod worker;

// Re-exports Phase 1 & Storage
pub use error::{IngestionError, IngestionResult};
pub use fingerprint::FingerprintEngine;
pub use models::{IngestionBatch, PublicationManifest, QuarantineRecord, RawRecord, StagedItem};
pub use module::PipelineIngestionModule;
pub use state_machine::{BatchStateMachine, ManifestStateMachine, StagedItemStateMachine};
pub use storage::IngestionStore;
pub use types::{
    BatchStatus, Dimensions, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat, StateTransitionRecord,
};

// Re-exports Phase 2
pub use adapters::{
    AdapterRegistry, CsvAdapter, FabDisAdapter, JsonAdapter, RawDimensionsDto, RawRecordDto,
    RawWeightDto, SourceAdapter, XmlAdapter,
};
pub use normalization::{
    normalize_dimensions, normalize_manufacturer, normalize_technical_attributes, normalize_unit,
    normalize_weight, validate_and_normalize_gtin, CanonicalDimensions, CanonicalTechnicalAttributes,
    CanonicalWeight, NormalizationEngine, NormalizedItemDto,
};
pub use technical_grouping::{
    ContextualSubstitutionRule, FamilyRule, SpecificationTolerances, TechnicalGroupLevel,
    TechnicalGroupingDecision, TechnicalGroupingEngine, TechnicalSpecification,
};

// Re-exports Phase 3 & 4
pub use events::{BatchFailedEvent, BatchStagedEvent, ManifestPublishedEvent};
pub use health::IngestionHealthCheck;
pub use proof::{CommercialProof, CommercialProofType};
pub use publisher::{ControlledPublisher, PublicationExecutionReport, SyncAgentSession};
pub use quarantine::{
    AnomalyCategory, AnomalySeverity, QuarantineEngine, QuarantineEntry, QuarantineStatus,
    QuarantineStats,
};
pub use worker::{BatchProcessingReport, IngestionWorker};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_module_descriptor() {
        use lyxal_runtime::module::LyxalModule;

        let module = PipelineIngestionModule::new();
        let descriptor = module.descriptor();

        assert_eq!(descriptor.id.as_str(), "lyxal_pipeline_ingestion");
        assert_eq!(descriptor.version, "0.1.0");
        assert!(descriptor.capabilities.contains(&"database".to_string()));
        assert!(descriptor.capabilities.contains(&"workers".to_string()));
        assert!(descriptor.capabilities.contains(&"events".to_string()));
    }
}
