//! Basic types and traits with optional feature support.
//!
//! This module provides foundational traits that adapt based on feature flags,
//! allowing Lyxalraft to work in both multi-threaded and single-threaded environments.
//!
//! ## Key Traits
//!
//! - [`OptionalSend`] - `Send` when not `single-threaded`, empty otherwise
//! - [`OptionalSync`] - `Sync` when not `single-threaded`, empty otherwise
//! - [`OptionalSerde`] - Serde traits when `serde` feature enabled
//! - [`OptionalFeatures`] - Combines all optional traits
//!
//! ## Type Aliases
//!
//! - [`BoxFuture`] - Boxed future, optionally `Send`
//! - [`BoxAsyncOnceMut`] - Boxed async FnOnce with mutable access
//! - [`BoxOnce`] - Boxed FnOnce closure
//! - [`BoxAny`] - Boxed Any type
//!
//! ## Overview
//!
//! These types allow Lyxalraft to be used in:
//! - **Multi-threaded** contexts (default): Types are `Send` + `Sync`
//! - **Single-threaded** contexts (feature `single-threaded`): No `Send` + `Sync` bounds
//! - **With/without serde** (feature `serde`): Optional serialization support
//!
//! Applications rarely need to use these types directly - they're used internally
//! to make Lyxalraft flexible across different environments.

pub(crate) mod batch;
pub(crate) mod finalized;
pub(crate) mod histogram;
pub(crate) mod shared_id_generator;

pub(crate) use batch::Batch;
pub use lyxal_raft_rt::BoxAny;
pub use lyxal_raft_rt::BoxAsyncOnceMut;
pub use lyxal_raft_rt::BoxFuture;
pub use lyxal_raft_rt::BoxIterator;
pub use lyxal_raft_rt::BoxMaybeAsyncOnceMut;
pub use lyxal_raft_rt::BoxOnce;
pub use lyxal_raft_rt::BoxStream;
pub use lyxal_raft_rt::OptionalSend;
pub use lyxal_raft_rt::OptionalSync;
pub use serde_able::OptionalSerde;

#[cfg(not(feature = "serde"))]
mod serde_able {
	/// A trait that extends `Serialize` and `Deserialize` if the `serde` feature flag
	/// is enabled, otherwise it is an empty trait.
	pub trait OptionalSerde {}
	impl<T> OptionalSerde for T {}
}

#[cfg(feature = "serde")]
mod serde_able {
	/// A trait that extends `Serialize` and `Deserialize` if the `serde` feature flag
	/// is enabled, otherwise it is an empty trait.
	pub trait OptionalSerde: serde::Serialize + for<'a> serde::Deserialize<'a> {}
	impl<T> OptionalSerde for T where T: serde::Serialize + for<'a> serde::Deserialize<'a> {}
}

/// A trait that combines all optional features.
pub trait OptionalFeatures: OptionalSend + OptionalSync + OptionalSerde {}

impl<T> OptionalFeatures for T where T: OptionalSend + OptionalSync + OptionalSerde {}
