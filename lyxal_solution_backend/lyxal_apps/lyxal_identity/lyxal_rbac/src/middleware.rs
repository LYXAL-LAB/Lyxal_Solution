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
        let tenant_id_str = tenant_id.map(|id| id.to_string()).unwrap_or_else(|| "default".to_string());

        let has_permission = sqlx::query!(
            r#"
            SELECT EXISTS (
                SELECT 1 FROM user_roles ur
                JOIN role_scopes rs ON ur.role_id = rs.role_id
                JOIN scopes s ON rs.scope_id = s.id
                WHERE ur.user_id = $1 
                AND ur.tenant_id = $2
                AND s.name = $3
            ) as "exists!"
            "#,
            user_id.to_string(),
            tenant_id_str,
            permission
        )
        .fetch_one(self.role_service.pool())
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?;

        Ok(has_permission.exists)
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
