//! Publication des manifestes approuvés vers le catalogue maître, sous une session du compte
//! de service de synchronisation (`lyxal_auth`, permission `catalogue.master.write`).

mod catalogue;
pub mod consumer;
pub mod controlled_publisher;
pub mod token;

pub use consumer::{
    ManifestApprovedHandler, PublicationConsumer, PUBLICATION_HANDLER, PUBLICATION_MODULE,
    PUBLICATION_SUBSCRIPTION,
};
pub use controlled_publisher::{ControlledPublisher, PublicationExecutionReport};
pub use token::{CatalogueTokenIssuer, CATALOGUE_SYNC_CLIENT_ID};
