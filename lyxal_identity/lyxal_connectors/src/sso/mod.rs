//! Lyxal SSO Connector Module
//!
//! This module handles Enterprise Single Sign-On (SSO) integrations
//! such as SAML 2.0 and Enterprise OIDC.

/// Base trait for SSO connectors
pub trait SsoConnector: crate::base::Connector {
    // SSO specific methods will be defined here
}

