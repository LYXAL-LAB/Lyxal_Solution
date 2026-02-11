//! # Lyxal DAV Core
//!
//! Native implementation of WebDAV, CalDAV, and CardDAV protocols.
//! Designed for zero-copy parsing and direct database integration.
//!
//! This module provides the core types, traits, and utilities for DAV operations.
//! The actual HTTP handlers are in the `server` crate.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                        HTTP Layer (server)                       │
//! │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
//! │  │PROPFIND │ │  PUT    │ │  GET    │ │ DELETE  │ │ REPORT  │   │
//! │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘   │
//! └───────┼───────────┼───────────┼───────────┼───────────┼─────────┘
//!         │           │           │           │           │
//!         ▼           ▼           ▼           ▼           ▼
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                     DavBackend Trait (core)                      │
//! │  - get_resource()  - put_resource()  - delete_resource()        │
//! │  - list_collection()  - sync_collection()  - query_collection() │
//! └─────────────────────────────────────────────────────────────────┘
//!         │
//!         ▼
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    SurrealDB Native Storage                      │
//! │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
//! │  │ dav_object   │ │dav_collection│ │   dav_lock   │             │
//! │  └──────────────┘ └──────────────┘ └──────────────┘             │
//! └─────────────────────────────────────────────────────────────────┘
//! ```
//!
//! ## Realm-Aware Design
//!
//! All DAV resources are scoped to a Realm for multi-tenant isolation:
//! - `/realms/{realm_id}/calendars/{user}/...`
//! - `/realms/{realm_id}/addressbooks/{user}/...`
//!

pub mod backend;
pub mod error;
pub mod surreal_backend;
pub mod types;
pub mod xml;

#[cfg(test)]
mod tests;

// Re-exports for convenience
pub use backend::DavBackend;
pub use surreal_backend::{SurrealConnection, SurrealDavBackend};
pub use error::DavError;
pub use types::{
    CalendarQuery, DavResponse, Lock, Principal, Resource, ResourceKind, Share, ShareAccess,
    ShareStatus, SyncCollectionResult,
};
pub use xml::{
    generate_lockdiscovery, generate_multistatus, parse_calendar_multiget, parse_calendar_query,
    parse_free_busy_query, parse_lockinfo, parse_propfind, parse_proppatch, parse_sync_collection,
    DavResource, PropPatchRequest, PropfindRequest, SyncCollectionRequest,
};
