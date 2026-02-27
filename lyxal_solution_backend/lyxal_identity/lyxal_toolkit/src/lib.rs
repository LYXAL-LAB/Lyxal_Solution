//! Lyxal Toolkit - 1:1 Logto Toolkit Parity
//! Specialized helpers for OIDC, Connectors, and Core logic.

pub mod oidc_helper;
pub mod connector_helper;

use serde::{Deserialize, Serialize};

/// 1:1 with Logto's conditional logic in toolkit
pub fn conditional<T>(condition: bool, value: T) -> Option<T> {
    if condition { Some(value) } else { None }
}

/// 1:1 Mapping of Logto ConnectorErrorCodes
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum ConnectorErrorCode {
    General,
    InvalidMetadata,
    UnexpectedType,
    InvalidConfigGuard,
    InvalidRequestParameters,
    InsufficientRequestParameters,
    InvalidConfig,
    InvalidCertificate,
    InvalidResponse,
    TemplateNotFound,
    TemplateNotSupported,
    RateLimitExceeded,
    NotImplemented,
    SocialAuthCodeInvalid,
    SocialAccessTokenInvalid,
    SocialIdTokenInvalid,
    AuthorizationFailed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectorError {
    pub code: ConnectorErrorCode,
    pub data: Option<serde_json::Value>,
}

impl std::fmt::Display for ConnectorError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "ConnectorError: {:?}", self.code)
    }
}

impl std::error::Error for ConnectorError {}
