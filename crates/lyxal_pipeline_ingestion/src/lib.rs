//! # `lyxal_pipeline_ingestion`
//!
//! Ingestion, normalisation, qualification et publication des catalogues fabricants vers le
//! catalogue maître de Lyxal OS. Les données, les règles métier, les contrôles d'identité et les
//! transitions d'état vivent dans le SurrealQL du module (`fn::ingestion_*`) ; le Rust fournit :
//!
//! - [`PipelineIngestionModule`] (contrat `LyxalModule`) et [`IngestionHealthCheck`] ;
//! - les adaptateurs de sources ([`adapters::FabDisAdapter`], [`adapters::CsvAdapter`],
//!   [`adapters::XmlAdapter`], [`adapters::JsonAdapter`]) ;
//! - la normalisation et la qualification initiale ([`normalization::NormalizationEngine`]) ;
//! - le worker supervisé ([`IngestionWorker`]) ;
//! - le store ([`IngestionStore`], appels `call_fn` des fonctions du module) ;
//! - la publication vers le catalogue ([`ControlledPublisher`], [`PublicationConsumer`]) sous le
//!   jeton de service `catalogue_sync_agent` ([`HmacCatalogueTokenIssuer`]).

pub mod adapters;
pub mod error;
pub mod events;
pub mod health;
pub mod models;
pub mod module;
pub mod normalization;
pub mod proof;
pub mod publisher;
pub mod rules;
pub mod storage;
pub mod types;
pub mod worker;

// Ré-exports : modèles, store, types
pub use error::{IngestionError, IngestionResult};
pub use models::{
    CatalogueConditionnement, CatalogueDimensions, CataloguePayload, IngestionBatch, ManifestEntry,
    PublicationManifest, QuarantineRecord, RawRecord, StagedItem,
};
pub use module::PipelineIngestionModule;
pub use storage::IngestionStore;
pub use types::{
    BatchStatus, Dimensions, ItemQualification, ManifestStatus, PackagingDetails,
    PublicationAction, SourceFormat, StateTransitionRecord,
};

// Ré-exports : adaptateurs, normalisation, référentiels
pub use adapters::{
    AdapterRegistry, CsvAdapter, FabDisAdapter, JsonAdapter, RawDimensionsDto, RawRecordDto,
    RawWeightDto, SourceAdapter, XmlAdapter,
};
pub use normalization::{
    normalize_dimensions, normalize_technical_attributes, normalize_weight, BlockReferentials,
    CanonicalDimensions, CanonicalTechnicalAttributes, CanonicalWeight, NormalizationEngine,
    NormalizedItemDto, ResolvedManufacturer,
};
pub use rules::{
    ContextualSubstitutionRule, FamilyRule, SpecificationTolerances, TechnicalSpecification,
};

// Ré-exports : événements, santé, preuves, publication, worker
pub use events::{
    BatchFailedEvent, BatchStagedEvent, ManifestApprovedEvent, ManifestPublishedEvent,
};
pub use health::IngestionHealthCheck;
pub use proof::{CommercialProof, CommercialProofType};
pub use publisher::{
    CatalogueSyncKey, CatalogueTokenIssuer, ControlledPublisher, HmacCatalogueTokenIssuer,
    PublicationConsumer, PublicationExecutionReport,
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
