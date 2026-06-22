//! Lyxal Core
//!
//! This crate contains shared logic, utilities, and base traits for the Lyxal Identity project.
//! It serves as the foundation for other modules like `lyxal_auth`, `lyxal_oauth`, and `lyxal_iam`.

pub mod config;
pub mod crypto;
pub mod database;
pub mod error;
pub mod utils;

/// Re-exporting common types for convenience across the workspace
pub use config::Config as LyxalConfig;
pub use crypto::Crypto;
pub use database::Database;
pub use error::CoreError;

/// Generic Result type alias for Lyxal
pub type Result<T> = std::result::Result<T, CoreError>;
