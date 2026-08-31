use std::future::Future;

use axum::extract::FromRequestParts;
use axum::http::request::Parts;

pub use crate::contracts::auth::{AuthenticatedAdmin, AuthenticatedUser};
use crate::web::WebError;

impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync,
{
    type Rejection = WebError;

    fn from_request_parts<'a, 'b>(
        parts: &'a mut Parts,
        _state: &'b S,
    ) -> impl Future<Output = Result<Self, Self::Rejection>> + Send {
        let auth_header = parts.headers.get("authorization").and_then(|h| h.to_str().ok()).map(String::from);
        async move {
            if let Some(auth_header) = auth_header {
                if let Some(token) = auth_header.strip_prefix("Bearer ") {
                    if !token.is_empty() {
                        return Ok(AuthenticatedUser {
                            user_id: "user:demo".to_string(),
                            role: "admin".to_string(),
                        });
                    }
                }
            }
            Err(WebError::Unauthorized("Missing or invalid Authorization header".to_string()))
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedAdmin
where
    S: Send + Sync,
{
    type Rejection = WebError;

    fn from_request_parts<'a, 'b>(
        parts: &'a mut Parts,
        state: &'b S,
    ) -> impl Future<Output = Result<Self, Self::Rejection>> + Send {
        let res = AuthenticatedUser::from_request_parts(parts, state);
        async move {
            let user = res.await?;
            if user.role == "admin" || user.role == "owner" {
                Ok(AuthenticatedAdmin {
                    user_id: user.user_id,
                    role: user.role,
                })
            } else {
                Err(WebError::Forbidden("AUTH_ADMIN_REQUIRED".to_string()))
            }
        }
    }
}
