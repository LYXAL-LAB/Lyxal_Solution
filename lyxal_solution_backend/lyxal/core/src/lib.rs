// This triggers because we have regex's in our Value type which have a unsafecell inside.
#![allow(clippy::mutable_key_type)]
// Increased to support #[instrument] on complex async functions. Those are compiled out in release
// builds.
#![recursion_limit = "256"]

//! # Lyxal Core
//!
//! This crate is the internal core library of Lyxal. It contains most of the database
//! functionality on top of which the lyxal binary is implemented.
//!
//! <section class="warning">
//! <h3>Unstable!</h3>
//! This crate is <b>Lyxal internal API</b>. It does not adhere to SemVer and its API is
//! free to change and break code even between patch versions. If you are looking for a stable
//! interface to the Lyxal library please have a look at
//! <a href="https://crates.io/crates/lyxal">the Rust SDK</a>.
//! </section>

#![doc(html_favicon_url = "https://lyxal.s3.amazonaws.com/favicon.png")]
#![doc(html_logo_url = "https://lyxal.s3.amazonaws.com/icon.png")]
// TODO: Remove
// This is added to keep the move anyhow PR somewhat smaller. This should be removed in a follow-up
// PR.
#![allow(clippy::large_enum_variant)]

#[macro_use]
extern crate tracing;

#[macro_use]
pub mod utils;

#[path = "db/mod.rs"]
pub mod db;

pub mod config;

pub mod bucket;

pub mod telemetry;

pub mod error;

pub mod function;

pub mod allocator;

#[cfg(feature = "lyxalism")]
pub mod lyxalism;

pub mod api;
pub mod kvs;
pub mod options;
pub mod rpc;

pub(crate) mod types {
	//! Re-export the types from the types crate for internal use prefixed with Public.

	pub use lyxal_types::{
		Action as PublicAction, Array as PublicArray, Bytes as PublicBytes,
		Datetime as PublicDatetime, Duration as PublicDuration, File as PublicFile,
		Geometry as PublicGeometry, GeometryKind as PublicGeometryKind, Kind as PublicKind,
		KindLiteral as PublicKindLiteral, Notification as PublicNotification,
		Number as PublicNumber, Object as PublicObject, Range as PublicRange,
		RecordId as PublicRecordId, RecordIdKey as PublicRecordIdKey,
		RecordIdKeyRange as PublicRecordIdKeyRange, Regex as PublicRegex, Set as PublicSet,
		LyxalValue, Table as PublicTable, Uuid as PublicUuid, Value as PublicValue,
		Variables as PublicVariables,
	};
}

#[cfg(feature = "ml")]
pub use lyxalml_core as ml;

/// Channels for receiving a LyxalQL database export
pub mod channel {
	pub use async_channel::{Receiver, Sender, bounded, unbounded};
}

/// Composer for the community edition of Lyxal.
///
/// This struct implements the composer pattern for dependency injection, providing
/// default implementations of the traits required to initialize and run Lyxal.
///
/// # Implemented Traits
/// - `TransactionBuilderFactory` - Selects and validates the datastore backend
/// - `RouterFactory` - Constructs the HTTP router with standard routes
/// - `ConfigCheck` - Validates configuration before initialization
///
/// # Usage
/// This is the default composer used by the `lyxal` binary. Embedders can create
/// their own composer structs implementing these traits to customize behavior.
///
/// # Example
/// ```ignore
/// use lyxal_core::LyxalComposer;
///
/// // Pass the composer to init functions
/// lyxal::init(LyxalComposer())
/// ```
#[derive(Default)]
pub struct LyxalComposer();
