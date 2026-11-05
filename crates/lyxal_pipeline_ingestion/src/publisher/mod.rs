//! Publication des manifestes approuvés vers le catalogue maître, sous l'identité de service
//! `catalogue_sync_agent`.

mod catalogue;
pub mod consumer;
pub mod controlled_publisher;
pub mod token;

pub use catalogue::catalogue_master_id;
pub use consumer::{
    ManifestApprovedHandler, PublicationConsumer, PUBLICATION_HANDLER, PUBLICATION_MODULE,
    PUBLICATION_SUBSCRIPTION,
};
pub use controlled_publisher::{ControlledPublisher, PublicationExecutionReport};
pub use token::{CatalogueSyncKey, CatalogueTokenIssuer, HmacCatalogueTokenIssuer};
