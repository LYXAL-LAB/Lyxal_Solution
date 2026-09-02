//! # `lyxal_event`
//!
//! Moteur d'événements asynchrone, persistance Transactional Outbox, Fan-out et distribution pour Lyxal OS.
//!
//! ## Architecture générale
//!
//! ```text
//!          PRODUCERS
//!
//!    SurrealDB DEFINE EVENT
//!              │
//!              ▼
//!        event_outbox
//!              ▲
//!              │
//!        Rust publish()
//!              │
//!              ▼
//!        LYXAL EVENT
//!          ENGINE
//!              │
//!              ▼
//!      event_subscription
//!              │
//!           FAN-OUT
//!              │
//!              ▼
//!       event_delivery
//!     ┌────────┼─────────┐
//!     ▼        ▼         ▼
//! notification scheduler webhook
//!    crm     analytics    ai
//! ```

pub mod error;
pub mod gc;
pub mod handler;
pub mod models;
pub mod publisher;
pub mod store;
pub mod types;
pub mod worker;

pub use error::LyxalEventError;
pub use gc::GarbageCollector;
pub use handler::{
    BoxFuture, ErasedHandler, Event, Handler, HandlerContext, HandlerRegistry, TypedHandler,
};
pub use models::{
    DeliveryStatus, EventContext, EventDeadLetter, EventDelivery, EventSubscription,
    LyxalEventEnvelope,
};
pub use publisher::EventPublisher;
pub use store::EventStore;
pub use types::{CausationId, CorrelationId, EventId};
pub use worker::{
    compute_lease_duration, compute_next_retry_delay, EventWorker, EventWorkerConfig,
};

/// Prelude pour l'importation concise des types fondamentaux.
pub mod prelude {
    pub use crate::error::LyxalEventError;
    pub use crate::handler::{Event, Handler, HandlerContext, HandlerRegistry};
    pub use crate::models::{
        DeliveryStatus, EventContext, EventDeadLetter, EventDelivery, EventSubscription,
        LyxalEventEnvelope,
    };
    pub use crate::publisher::EventPublisher;
    pub use crate::store::EventStore;
    pub use crate::types::{CausationId, CorrelationId, EventId};
    pub use crate::worker::{
        compute_lease_duration, compute_next_retry_delay, EventWorker, EventWorkerConfig,
    };
}
