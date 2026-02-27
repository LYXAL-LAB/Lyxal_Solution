pub mod application_admin;
pub mod tenant_admin;
pub mod user_admin;

use crate::services::application_service::ApplicationService;
use crate::services::tenant_service::TenantService;
use crate::services::user_service::UserService;
use axum::Router;
use std::sync::Arc;

/// Shared application state for all IAM (Identity and Access Management) administration handlers.
/// This state is passed to each sub-router.
pub struct IamState {
    pub user_service: Arc<UserService>,
    pub tenant_service: Arc<TenantService>,
    pub application_service: Arc<ApplicationService>,
}

/// Creates the main IAM administration router by nesting sub-routers for
/// Users, Tenants, and Applications.
pub fn router(state: Arc<IamState>) -> Router {
    Router::new()
        .nest("/users", user_admin::router(state.clone()))
        .nest("/tenants", tenant_admin::router(state.clone()))
        .nest("/applications", application_admin::router(state))
}
