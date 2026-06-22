use axum::{extract::Request, middleware::Next, response::Response};
use lyxal_core::{CoreError, Result};
use uuid::Uuid;

/// Key used in the session data to store the user's unique identifier.
pub const USER_ID_KEY: &str = "uid";
/// Key used in the session data to store the tenant identifier if applicable.
pub const TENANT_ID_KEY: &str = "tid";

/// Middleware to require an active session for a route.
/// If no user ID is found in the session, it returns a 401 Unauthorized response.
pub async fn require_auth(
    session: tower_sessions::Session,
    request: Request,
    next: Next,
) -> Result<Response> {
    let user_id: Option<Uuid> = session
        .get(USER_ID_KEY)
        .await
        .map_err(|e| CoreError::Internal(anyhow::anyhow!("Session error: {}", e)))?;

    if user_id.is_none() {
        return Err(CoreError::Unauthorized(
            "Authentication required".to_string(),
        ));
    }

    Ok(next.run(request).await)
}

/// Middleware to inject user information into the request extensions
/// if a session exists, without enforcing authentication.
pub async fn optional_auth(
    session: tower_sessions::Session,
    mut request: Request,
    next: Next,
) -> Response {
    if let Ok(Some(user_id)) = session.get::<Uuid>(USER_ID_KEY).await {
        request.extensions_mut().insert(AuthContext {
            user_id,
            tenant_id: session.get(TENANT_ID_KEY).await.unwrap_or(None),
        });
    }

    next.run(request).await
}

/// Context structure containing authentication information for the current request.
#[derive(Debug, Clone)]
pub struct AuthContext {
    pub user_id: Uuid,
    pub tenant_id: Option<Uuid>,
}

/// Helper functions to manage session data.
pub struct SessionHelper;

impl SessionHelper {
    /// Log in a user by setting their ID in the session.
    pub async fn login(session: &tower_sessions::Session, user_id: Uuid) -> Result<()> {
        session.insert(USER_ID_KEY, user_id).await.map_err(|e| {
            CoreError::Internal(anyhow::anyhow!("Failed to insert into session: {}", e))
        })
    }

    /// Set the tenant context for the current session.
    pub async fn set_tenant(session: &tower_sessions::Session, tenant_id: Uuid) -> Result<()> {
        session.insert(TENANT_ID_KEY, tenant_id).await.map_err(|e| {
            CoreError::Internal(anyhow::anyhow!("Failed to set tenant in session: {}", e))
        })
    }

    /// Log out a user by clearing the session data.
    pub async fn logout(session: &tower_sessions::Session) -> Result<()> {
        session.clear().await;
        Ok(())
    }
}
