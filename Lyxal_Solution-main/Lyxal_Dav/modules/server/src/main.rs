use axum::{
    body::Body,
    extract::{Request, State},
    http::{HeaderValue, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::{any, get},
    Router,
};
use anyhow::Result;
use lyxal_dav_core::{backend::ResourceKind, error::DavError, DavContext, DavResponse};
use std::sync::Arc;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;
use tower_http::timeout::TimeoutLayer;
use std::time::Duration;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use base64::Engine;
use base64::engine::general_purpose::STANDARD as BASE64;
use clap::Parser;

mod sqlite_backend;
// mod surreal_backend;

use lyxal_dav_core::backend::DavBackend;
use sqlite_backend::SqliteBackend;
// use surreal_backend::SurrealBackend;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Storage connection string (sqlite:// or surreal://)
    #[arg(long, default_value = "sqlite://dav.db")]
    storage: String,
    
    /// Host to bind to
    #[arg(long, default_value = "127.0.0.1")]
    host: String,
    
    /// Port to bind to
    #[arg(long, default_value_t = 3000)]
    port: u16,
    
    /// Global body size limit in bytes
    #[arg(long, default_value_t = 52428800)] // 50MB
    limit: usize,
    
    /// Request timeout in seconds
    #[arg(long, default_value_t = 60)]
    timeout: u64,
}

struct AppState {
    backend: Arc<dyn DavBackend>,
    limit: usize,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "lyxal_dav_server=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let backend = init_backend(&args.storage).await?;

    // Seed demo calendar/event (idempotent)
    let _ = backend.create_collection("/calendar", ResourceKind::Calendar).await;
    let _ = backend.ensure_calendar_owner("/calendar", "user").await;
    let demo_event = r#"BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:demo-1
SUMMARY:Demo event
DTSTART:20250101T100000Z
DTEND:20250101T110000Z
END:VEVENT
END:VCALENDAR"#;
    let _ = backend.put_resource(
        "/calendar/demo.ics",
        demo_event.as_bytes(),
        "text/calendar; charset=utf-8",
    ).await;

    let state = Arc::new(AppState { 
        backend,
        limit: args.limit,
    });

    let app = Router::new()
        .route("/", get(idx))
        .route("/calendar/*path", any(dav_handler))
        .route("/calendar", any(dav_handler))
        .route("/principals/*path", any(dav_handler))
        .route("/principals", any(dav_handler))
        .route("/dav/*path", any(dav_handler))
        .layer(TimeoutLayer::new(Duration::from_secs(args.timeout)))
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let addr = format!("{}:{}", args.host, args.port);
    let listener = TcpListener::bind(&addr).await?;
    tracing::info!("listening on {}", listener.local_addr()?);
    axum::serve(listener, app).await?;
    Ok(())
}

async fn init_backend(storage_url: &str) -> anyhow::Result<Arc<dyn DavBackend>> {
    if storage_url.starts_with("sqlite://") {
        let sqlite = SqliteBackend::new(storage_url).await?;
        return Ok(Arc::new(sqlite));
    } /* else if storage_url.starts_with("surreal://") {
        let surreal = SurrealBackend::new(storage_url).await?;
        return Ok(Arc::new(surreal));
    } */
    Err(anyhow::anyhow!("Unsupported storage scheme: {}", storage_url))
}

async fn idx() -> Html<&'static str> {
    Html("<h1>Lyxal DAV Server</h1><p>Use CalDAV client at /calendar</p>")
}

async fn dav_handler(State(state): State<Arc<AppState>>, req: Request) -> impl IntoResponse {
    let (parts, body) = req.into_parts();
    let method = parts.method.to_string();
    let raw_path = parts.uri.path();
    
    // D6.3 Path Normalization / Security
    if raw_path.contains("..") || raw_path.contains("//") {
        return (StatusCode::BAD_REQUEST, "Invalid path").into_response();
    }
    let path_uri = raw_path.to_string();

    let mut headers = std::collections::HashMap::new();
    for (k, v) in parts.headers.iter() {
        if let Ok(s) = v.to_str() {
            headers.insert(k.as_str().to_string(), s.to_string());
        }
    }

    let principal = match extract_principal(&state.backend, parts.headers.get("authorization"), &path_uri).await {
        Ok(p) => p,
        Err(resp) => return resp.into_response(),
    };

    if principal.is_none() && path_uri != "/" {
        return unauthorized_response().into_response();
    }

    let bytes = match axum::body::to_bytes(body, state.limit).await {
        Ok(b) => b.to_vec(),
        Err(e) => return (StatusCode::PAYLOAD_TOO_LARGE, format!("Body too large or error: {}", e)).into_response(),
    };

    let ctx = DavContext::new(method, path_uri, bytes, headers, state.backend.clone(), principal);

    match lyxal_dav_core::process(ctx).await {
        Ok(resp) => map_response(resp),
        Err(e) => map_error(e),
    }
}

async fn extract_principal(
    backend: &Arc<dyn DavBackend>,
    auth_header: Option<&HeaderValue>,
    path: &str,
) -> Result<Option<String>, Response> {
    let tenant = if path.starts_with("/dav/") {
        let parts: Vec<&str> = path.split('/').collect();
        if parts.len() >= 3 {
            Some(parts[2])
        } else {
            None
        }
    } else {
        None
    };

    if let Some(hv) = auth_header {
        if let Ok(header) = hv.to_str() {
            let parts: Vec<&str> = header.splitn(2, ' ').collect();
            if parts.len() == 2 {
                match parts[0].to_ascii_lowercase().as_str() {
                    "basic" => {
                        if let Ok(decoded) = BASE64.decode(parts[1]) {
                            if let Some((user, pass)) = String::from_utf8_lossy(&decoded).split_once(':') {
                                if let Ok(Some(p)) = backend.authenticate_basic(tenant, user, pass).await {
                                    return Ok(Some(p.username));
                                }
                            }
                        }
                    }
                    "bearer" => {
                        if let Ok(Some(p)) = backend.authenticate_bearer(tenant, parts[1]).await {
                            return Ok(Some(p.username));
                        }
                    }
                    _ => {}
                }
            }
        }
        return Err(unauthorized_response());
    }
    Ok(None)
}

fn unauthorized_response() -> Response {
    Response::builder()
        .status(StatusCode::UNAUTHORIZED)
        .header("WWW-Authenticate", r#"Basic realm="LyxalDAV""#)
        .body(Body::from("Unauthorized"))
        .unwrap_or_else(|_| Response::builder().status(StatusCode::UNAUTHORIZED).body(Body::from("Unauthorized")).unwrap())
}

fn map_response(resp: DavResponse) -> Response {
    let mut builder = Response::builder().status(resp.status);
    let mut has_dav = false;

    for (k, v) in resp.headers.iter() {
        if let Ok(hv) = HeaderValue::from_str(v) {
            if k.eq_ignore_ascii_case("dav") {
                has_dav = true;
            }
            builder = builder.header(k, hv);
        }
    }

    if !has_dav {
        builder = builder.header("DAV", HeaderValue::from_static("1, 2, calendar-access"));
    }

    builder
        .body(Body::from(resp.body))
        .unwrap_or_else(|_| Response::builder().status(StatusCode::INTERNAL_SERVER_ERROR).body(Body::from("response build error")).unwrap())
}

fn map_error(err: DavError) -> Response {
    if let DavError::Unauthorized = err {
        return unauthorized_response();
    }
    let (status, body) = match &err {
        DavError::NotFound => (StatusCode::NOT_FOUND, "Not Found".to_string()),
        DavError::Forbidden => (StatusCode::FORBIDDEN, "Forbidden".to_string()),
        DavError::Unauthorized => (StatusCode::UNAUTHORIZED, "Unauthorized".to_string()),
        DavError::MethodNotAllowed => (StatusCode::METHOD_NOT_ALLOWED, "Method Not Allowed".to_string()),
        DavError::PreconditionFailed => (StatusCode::PRECONDITION_FAILED, "Precondition Failed".to_string()),
        DavError::NotModified => (StatusCode::NOT_MODIFIED, String::new()),
        DavError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg.clone()),
        DavError::XmlError(_) => (StatusCode::BAD_REQUEST, "XML Error".to_string()),
        DavError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, msg.clone()),
        DavError::Locked => (StatusCode::LOCKED, "Locked".to_string()),
        DavError::Conflict => (StatusCode::CONFLICT, "Conflict".to_string()),
        DavError::PayloadTooLarge => (StatusCode::PAYLOAD_TOO_LARGE, "Payload Too Large".to_string()),
    };

    Response::builder()
        .status(status)
        .body(Body::from(body))
        .unwrap_or_else(|_| Response::builder().status(StatusCode::INTERNAL_SERVER_ERROR).body(Body::from("response build error")).unwrap())
}
