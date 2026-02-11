//! Lyxal IAM (Identity and Access Management) Module
//!
//! This module manages the core identity entities and their lifecycle:
//! - User management (CRUD, profiles)
//! - Organization/Tenant management
//! - Application registration and management
//! - Linkage between users, roles, and organizations

pub mod handlers;
pub mod models;

pub mod repository {
    pub mod application_repository;
    pub mod tenant_repository;
    pub mod user_repository;
}

pub mod services {
    pub mod application_service;
    pub mod tenant_service;
    pub mod user_service;
}

pub use handlers::IamState;
pub use services::application_service::ApplicationService;
pub use services::tenant_service::TenantService;
pub use services::user_service::UserService;

/// Result type for IAM operations
pub type Result<T> = std::result::Result<T, lyxal_core::CoreError>;

/// Represents the status of an identity entity
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum EntityStatus {
    Active,
    Suspended,
    PendingVerification,
    Archived,
}
