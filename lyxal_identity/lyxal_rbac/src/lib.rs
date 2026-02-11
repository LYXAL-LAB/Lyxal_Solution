//! Lyxal RBAC (Role-Based Access Control) Module
//!
//! This module manages permissions, roles, and access control policies.
//! It is responsible for:
//! - Defining and managing roles
//! - Associating permissions with resources
//! - Assigning roles to users and organizations
//! - Validating access scopes for API requests

pub mod access_control;
pub mod middleware;
pub mod models;

pub mod repository {
    pub mod rbac_repository;
}

pub mod services {
    pub mod permission_service;
    pub mod role_service;
}

pub use access_control::Enforcer;
pub use middleware::require_permission;
pub use repository::rbac_repository::RbacRepository;
pub use services::permission_service::PermissionService;
pub use services::role_service::RoleService;

/// Result type for RBAC operations
pub type Result<T> = std::result::Result<T, lyxal_core::CoreError>;

/// Represents an access scope (e.g., "read:users", "write:applications")
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
pub struct Scope {
    pub resource: String,
    pub action: String,
}

impl std::fmt::Display for Scope {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}:{}", self.resource, self.action)
    }
}
