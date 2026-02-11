//! Credential management module
//!
//! Provides encryption/decryption for credentials stored in the database.
//! Uses AES-256-GCM for authenticated encryption.

mod crypto;
mod error;
mod types;

pub use crypto::{encrypt_credential, decrypt_credential, derive_key};
pub use error::CredentialError;
pub use types::*;
