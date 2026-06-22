//! Lyxal IAM (Identity and Access Management) Module
//! Manages Users, Tenants, and Applications.

pub mod handlers;
pub mod models;
pub mod repository;
pub mod services;

pub use services::application_service::ApplicationService;
pub use services::tenant_service::TenantService;
pub use services::user_service::UserService;
pub use services::rbac_service::RbacService;

/// Result type for IAM operations
pub type Result<T> = std::result::Result<T, lyxal_core::error::CoreError>;
