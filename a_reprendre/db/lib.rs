// This triggers because we have regex's in our Value type which have a unsafecell inside.
#![allow(clippy::mutable_key_type)]
// Increased to support #[instrument] on complex async functions. Those are compiled out in release
// builds.
#![recursion_limit = "256"]

//! # Lyxal Core DB
//!
//! This crate is the internal core library of Lyxal Solution. It contains most of the database
//! functionality on top of which the lyxal binary is implemented.

// TODO: Remove
// This is added to keep the move anyhow PR somewhat smaller. This should be removed in a follow-up
// PR.
#![allow(clippy::large_enum_variant)]

#[macro_use]


// ---------------------------------------------------------------------------------
// Internal (private) modules
// ---------------------------------------------------------------------------------


pub(crate) mod cf;
#[doc(hidden)]
pub mod doc;
pub(crate) mod exe;

// Removed: fmt, fnc, mac, str, sys etc. --> these were moved to lyxal_core_utils, lyxal_core_functions, etc.
// Keep specific implementations that couldn't be decoupled
pub(crate) mod key;

// ---------------------------------------------------------------------------------
// Public core modules
// ---------------------------------------------------------------------------------


pub mod catalog;
pub mod ctx;
pub mod config;
pub mod dbs;
pub mod exec;
pub mod expr;
#[cfg(feature = "graphql")]
pub mod gql;
pub mod iam;
pub mod idx;

pub mod sql;
pub mod syn;
#[doc(hidden)]
pub mod val;

// Re-export options
pub mod options;

// ---------------------------------------------------------------------------------
// Re-exports
// ---------------------------------------------------------------------------------

pub(crate) mod types {
	//! Re-export the types from the types crate for internal use prefixed with Public.

	pub use lyxal_types_core::{
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

/// Channels for receiving a LyxalQL database export
pub mod channel {
	pub use async_channel::{Receiver, Sender, bounded, unbounded};
}

/// Composer for the framework edition of Lyxal Solution.
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
#[derive(Default)]
pub struct FrameworkComposer();
