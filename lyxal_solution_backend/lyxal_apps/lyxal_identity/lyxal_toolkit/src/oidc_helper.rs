//! OIDC Helper - 1:1 Logto core-kit/openid.ts Parity
//! Specialized utilities for OIDC claim and scope processing.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum UserScope {
    Openid,
    Profile,
    Email,
    Phone,
    Address,
    OfflineAccess,
    Roles,
    Organizations,
    OrganizationRoles,
}

pub const DEFAULT_USER_SCOPES: &[UserScope] = &[
    UserScope::Openid,
    UserScope::Profile,
    UserScope::Email,
];

/// 1:1 Logto logic for parsing scopes string to vector
pub fn parse_scopes(scope_string: &str) -> Vec<String> {
    scope_string.split_whitespace().map(String::from).collect()
}
