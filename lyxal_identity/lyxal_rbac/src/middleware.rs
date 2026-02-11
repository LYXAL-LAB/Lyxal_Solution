use crate::services::role_service::RoleService;
use axum::{extract::Request, middleware::Next, response::Response};
use lyxal_core::{CoreError, Result};
use lyxal_session::middleware::AuthContext;
use uuid::Uuid;

/// Middleware to enforce that the authenticated user has a specific permission.
///
/// This middleware checks the current request's `AuthContext` (injected by the session middleware)
/// and verifies if the user has the required permission within the active tenant context.
pub struct RequirePermission {
    pub role_service: RoleService,
    pub permission: String,
}

impl RequirePermission {
    pub fn new(role_service: RoleService, permission: &str) -> Self {
        Self {
            role_service,
            permission: permission.to_string(),
        }
    }

    /// Executable logic for the middleware.
    pub async fn check(&self, request: Request, next: Next) -> Result<Response> {
        // 1. Get AuthContext from request extensions
        let auth_context = request
            .extensions()
            .get::<AuthContext>()
            .ok_or_else(|| CoreError::Unauthorized("No active session found".to_string()))?;

        // 2. Verify if the user has the required permission
        // Note: In a real-world scenario, we would have a cached "Enforcer" or a optimized
        // query to check user -> roles -> permissions.
        let has_permission = self
            .verify_user_permission(
                auth_context.user_id,
                auth_context.tenant_id,
                &self.permission,
            )
            .await?;

        if !has_permission {
            return Err(CoreError::Forbidden(format!(
                "Required permission '{}' is missing",
                self.permission
            )));
        }

        Ok(next.run(request).await)
    }

    /// Logic to verify if a user has a specific permission string.
    async fn verify_user_permission(
        &self,
        user_id: Uuid,
        tenant_id: Option<Uuid>,
        permission: &str,
    ) -> Result<bool> {
        // Placeholder for real DB check.
        // We would query the junction table `user_roles` -> `role_permissions` -> `permissions`
        // checking for the permission name.

        // For now, we return true to allow development, but this must be implemented
        // once the junction table queries are added to the repositories.
        tracing::debug!(
            "Checking permission '{}' for user '{}' in tenant '{:?}'",
            permission,
            user_id,
            tenant_id
        );

        Ok(true)
    }
}

/// Helper function to create a permission-check middleware for Axum routes.
pub async fn require_permission(
    request: Request,
    next: Next,
    // This is a simplified version, as Axum middleware usually takes fixed arguments.
    // Real implementation would use a closure or a custom layer.
) -> Result<Response> {
    // Standard implementation would extract the RoleService from request state
    // and the required permission from somewhere in the request or route metadata.
    Ok(next.run(request).await)
}
