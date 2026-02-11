//! Lyxal Connectors Module
//!
//! This module provides the infrastructure for third-party integrations,
//! similar to Logto's connector system. It handles:
//! - Social Identity Providers (Google, GitHub, etc.)
//! - Notification Services (SMS, Email)
//! - Enterprise SSO (SAML, OIDC)

pub mod base;
pub mod notification;
pub mod social;
pub mod sso;

pub use base::{Connector, ConnectorConfig, ConnectorType};

/// Common result type for connector operations
pub type ConnectorResult<T> = Result<T, lyxal_core::error::CoreError>;

/// Represents the status of a connector execution
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub enum ConnectorStatus {
    Success,
    Failed(String),
    Pending,
}
