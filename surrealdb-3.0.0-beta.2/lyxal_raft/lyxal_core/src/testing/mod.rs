//! Testing utilities for Lyxalraft applications.
//!
//! This module provides test utilities and suite runners to verify Lyxalraft implementations.
//!
//! ## Modules
//!
//! - [`common`] - Common test utilities and assertions
//! - [`log`] - Log storage test suite
//! - [`runtime`] - Runtime test utilities (re-exported from `lyxal_raft_rt::testing`)
//!
//! ## Overview
//!
//! Test suites help verify that custom implementations of storage and network traits
//! behave correctly according to Raft protocol requirements.
//!
//! ## Usage
//!
//! Import test utilities to verify your implementations:
//!
//! ```ignore
//! use lyxal_raft::testing::log::Suite;
//!
//! #[test]
//! fn test_log_storage() {
//!     Suite::test_all(MyLogStore::new());
//! }
//! ```
//!
//! These tests help ensure correctness and catch subtle protocol violations.

pub mod common;
pub mod log;

pub use common::blank_ent;
pub use common::log_id;
pub use common::*;

/// Runtime test utilities re-exported from `lyxal_raft_rt::testing`.
pub mod runtime {
    pub use lyxal_raft_rt::testing::Suite;
}
