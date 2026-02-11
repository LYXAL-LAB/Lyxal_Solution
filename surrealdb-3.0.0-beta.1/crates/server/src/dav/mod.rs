//! # Lyxal DAV Server
//!
//! HTTP handlers for WebDAV, CalDAV, and CardDAV protocols.
//! Uses the core DAV types and backend trait from `surrealdb-core::dav`.
//!
//! ## HTTP Methods Supported
//!
//! - `OPTIONS` - Returns DAV capabilities
//! - `PROPFIND` - Query resource properties
//! - `PROPPATCH` - Modify resource properties
//! - `GET` - Retrieve resource content
//! - `PUT` - Create/update resource
//! - `DELETE` - Remove resource
//! - `MKCOL` - Create collection
//! - `MKCALENDAR` - Create calendar collection
//! - `MOVE` - Move resource
//! - `COPY` - Copy resource
//! - `LOCK` - Lock resource
//! - `UNLOCK` - Unlock resource
//! - `REPORT` - Query/sync operations
//!

pub mod context;
pub mod handlers;
pub mod router;

pub use context::DavContext;
pub use handlers::*;
pub use router::dav_router;
