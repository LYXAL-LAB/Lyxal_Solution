//! Module de publication strictement contrôlée vers LYXAL Catalogue V1.1.

pub mod controlled_publisher;

pub use controlled_publisher::{
    ControlledPublisher, PublicationExecutionReport, SyncAgentSession,
};
