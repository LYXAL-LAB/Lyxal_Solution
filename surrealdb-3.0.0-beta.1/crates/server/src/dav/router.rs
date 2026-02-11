//! DAV Router
//!
//! Axum router configuration for DAV endpoints.

use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{HeaderMap, Method, StatusCode},
    response::{IntoResponse, Response},
    routing::any,
    Router,
};
use std::sync::Arc;
use surrealdb_core::dav::DavBackend;

use super::context::DavContext;
use super::handlers::process;

/// Shared state for DAV router
#[derive(Clone)]
pub struct DavState {
    pub backend: Arc<dyn DavBackend>,
}

/// Create the DAV router
pub fn dav_router(backend: Arc<dyn DavBackend>) -> Router {
    let state = DavState { backend };
    
    Router::new()
        .route("/dav/*path", any(handle_dav_request))
        .route("/dav/", any(handle_dav_request))
        .route("/realms/{realm}/dav/*path", any(handle_dav_request))
        .route("/realms/{realm}/dav/", any(handle_dav_request))
        .with_state(state)
}

/// Handle incoming DAV request
async fn handle_dav_request(
    State(state): State<DavState>,
    method: Method,
    headers: HeaderMap,
    Path(path): Path<String>,
    body: Bytes,
) -> Response {
    // Extract principal from Authorization header
    let principal = extract_principal(&headers);
    
    // Convert headers to HashMap
    let headers_map: std::collections::HashMap<String, String> = headers
        .iter()
        .filter_map(|(k, v)| {
            v.to_str()
                .ok()
                .map(|val| (k.as_str().to_string(), val.to_string()))
        })
        .collect();

    // Build context
    let ctx = DavContext::new(
        method.to_string(),
        format!("/{}", path),
        body.to_vec(),
        headers_map,
        state.backend.clone(),
        principal,
    );

    // Process request
    match process(ctx).await {
        Ok(resp) => {
            let status = StatusCode::from_u16(resp.status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
            let mut response = Response::builder().status(status);
            
            for (key, value) in resp.headers {
                response = response.header(key, value);
            }
            
            response.body(axum::body::Body::from(resp.body)).unwrap()
        }
        Err(e) => {
            let status = StatusCode::from_u16(e.status_code()).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
            (status, e.to_string()).into_response()
        }
    }
}

/// Extract principal from Authorization header
fn extract_principal(headers: &HeaderMap) -> Option<String> {
    let auth_header = headers.get("authorization")?.to_str().ok()?;
    
    if auth_header.starts_with("Basic ") {
        // Decode Basic auth
        let encoded = auth_header.strip_prefix("Basic ")?;
        let decoded = base64::Engine::decode(
            &base64::engine::general_purpose::STANDARD,
            encoded,
        )
        .ok()?;
        let decoded_str = String::from_utf8(decoded).ok()?;
        let username = decoded_str.split(':').next()?;
        Some(username.to_string())
    } else if auth_header.starts_with("Bearer ") {
        // For Bearer tokens, we'd need to validate the token
        // For now, just return None to indicate further auth is needed
        None
    } else {
        None
    }
}
