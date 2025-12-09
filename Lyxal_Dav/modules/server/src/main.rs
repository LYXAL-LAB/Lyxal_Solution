use axum::{
    extract::{Path, Request, State},
    response::{Html, IntoResponse, Response},
    routing::{any, get},
    Router, body::Body, http::{StatusCode, HeaderMap},
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use std::sync::Arc;
use tokio::net::TcpListener;
use lyxal_dav_core::{DavContext, process};
use tower_http::trace::TraceLayer;

mod mem_backend;
use mem_backend::InMemoryBackend;

struct AppState {
    backend: Arc<InMemoryBackend>,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "lyxal_dav_server=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let backend = Arc::new(InMemoryBackend::new());
    
    // Seed backend with a calendar
    backend.add_resource(lyxal_dav_core::backend::Resource {
        path: "/calendar".to_string(),
        kind: lyxal_dav_core::backend::ResourceKind::Calendar,
        mime_type: "".into(),
        etag: "root".into(),
        content: None,
        properties: std::collections::HashMap::from([
             ("D:displayname".to_string(), "Test Calendar".to_string())
        ]),
    }).await;

    let state = Arc::new(AppState { backend });

    let app = Router::new()
        .route("/", get(idx))
        .route("/calendar/*path", any(dav_handler))
        .route("/calendar", any(dav_handler)) // Handle root of calendar too
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let listener = TcpListener::bind("127.0.0.1:3000").await.unwrap();
    tracing::info!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

async fn idx() -> Html<&'static str> {
    Html("<h1>Lyxal DAV Server</h1><p>Use CalDAV client at /calendar</p>")
}

async fn dav_handler(
    State(state): State<Arc<AppState>>,
    req: Request,
) -> impl IntoResponse {
    // 1. Convert Request
    let (parts, body) = req.into_parts();
    let method = parts.method.to_string();
    let path_uri = parts.uri.path().to_string(); // Use full URI path
    
    // Convert headers
    let mut headers = std::collections::HashMap::new();
    for (k, v) in parts.headers.iter() {
        if let Ok(s) = v.to_str() {
            headers.insert(k.as_str().to_string(), s.to_string());
        }
    }

    // Read body
    let bytes = match axum::body::to_bytes(body, usize::MAX).await {
        Ok(b) => b.to_vec(),
        Err(e) => return (StatusCode::BAD_REQUEST, format!("Body error: {}", e)).into_response(),
    };

    // 2. Create Context
    let ctx = DavContext::new(
        method,
        path_uri,
        bytes,
        headers,
        state.backend.clone(),
    );

    // 3. Process
    match process(ctx).await {
        Ok(body_str) => {
            // Determine status code?
            // `process` currently returns String (body).
            // We need status code control from `process`.
            // For now, if OK, assume 207 MultiStatus (common for propfind/report) or 200/201/204.
            // The `process` function in `lib.rs` returns `Result<String, DavError>`.
            // The `DavError` maps to error codes.
            // The success usually returns XML.
            // TODO: Enhance `process` to return (StatusCode, String).
            // For MVP, look at method.
            // PROPFIND/REPORT -> 207 MultiStatus
            // GET -> 200
            // PUT -> 201 Created / 204 No Content
            // DELETE -> 204
            
            // Hack for MVP: check if XML starts with multistatus
            let status = if body_str.contains("multistatus") {
                StatusCode::MULTI_STATUS
            } else if body_str.is_empty() {
                StatusCode::NO_CONTENT
            } else {
                StatusCode::OK
            };

            let mut resp = Response::new(Body::from(body_str));
            *resp.status_mut() = status;
            
            // Add DAV headers
            resp.headers_mut().insert("DAV", "1, 2, calendar-access".parse().unwrap());
            if status == StatusCode::MULTI_STATUS || status == StatusCode::OK {
                 resp.headers_mut().insert("Content-Type", "application/xml; charset=utf-8".parse().unwrap());
            }

            resp
        },
        Err(e) => {
            // Map DavError to StatusCode
            let code = match e {
                lyxal_dav_core::error::DavError::NotFound => StatusCode::NOT_FOUND,
                lyxal_dav_core::error::DavError::Forbidden => StatusCode::FORBIDDEN,
                lyxal_dav_core::error::DavError::MethodNotAllowed => StatusCode::METHOD_NOT_ALLOWED,
                lyxal_dav_core::error::DavError::Internal(_) => StatusCode::INTERNAL_SERVER_ERROR,
                _ => StatusCode::INTERNAL_SERVER_ERROR,
            };
            (code, format!("Error: {}", e)).into_response()
        }
    }
}
