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
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod sqlite_backend;

use lyxal_dav_core::backend::DavBackend;
use sqlite_backend::SqliteBackend;

struct AppState {
    backend: Arc<dyn DavBackend>,
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "lyxal_dav_server=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let backend = init_backend().await?;

    // Seed demo calendar/event (idempotent)
    let _ = backend.create_collection("/calendar", ResourceKind::Calendar).await;
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

    let state = Arc::new(AppState { backend });

    let app = Router::new()
        .route("/", get(idx))
        .route("/calendar/*path", any(dav_handler))
        .route("/calendar", any(dav_handler))
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let listener = TcpListener::bind("127.0.0.1:3000").await?;
    tracing::info!("listening on {}", listener.local_addr()?);
    axum::serve(listener, app).await?;
    Ok(())
}

async fn init_backend() -> anyhow::Result<Arc<dyn DavBackend>> {
    let db_url = std::env::var("DAV_SQLITE_URL").unwrap_or_else(|_| "sqlite://dav.db".to_string());
    let sqlite = SqliteBackend::new(&db_url).await?;
    Ok(Arc::new(sqlite))
}

async fn idx() -> Html<&'static str> {
    Html("<h1>Lyxal DAV Server</h1><p>Use CalDAV client at /calendar</p>")
}

async fn dav_handler(State(state): State<Arc<AppState>>, req: Request) -> impl IntoResponse {
    let (parts, body) = req.into_parts();
    let method = parts.method.to_string();
    let path_uri = parts.uri.path().to_string();

    let mut headers = std::collections::HashMap::new();
    for (k, v) in parts.headers.iter() {
        if let Ok(s) = v.to_str() {
            headers.insert(k.as_str().to_string(), s.to_string());
        }
    }

    let bytes = match axum::body::to_bytes(body, usize::MAX).await {
        Ok(b) => b.to_vec(),
        Err(e) => return (StatusCode::BAD_REQUEST, format!("Body error: {}", e)).into_response(),
    };

    let ctx = DavContext::new(method, path_uri, bytes, headers, state.backend.clone());

    match lyxal_dav_core::process(ctx).await {
        Ok(resp) => map_response(resp),
        Err(e) => map_error(e),
    }
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
    let (status, body) = match &err {
        DavError::NotFound => (StatusCode::NOT_FOUND, "Not Found".to_string()),
        DavError::Forbidden => (StatusCode::FORBIDDEN, "Forbidden".to_string()),
        DavError::MethodNotAllowed => (StatusCode::METHOD_NOT_ALLOWED, "Method Not Allowed".to_string()),
        DavError::PreconditionFailed => (StatusCode::PRECONDITION_FAILED, "Precondition Failed".to_string()),
        DavError::NotModified => (StatusCode::NOT_MODIFIED, String::new()),
        DavError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg.clone()),
        DavError::XmlError(_) => (StatusCode::BAD_REQUEST, "XML Error".to_string()),
        DavError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, msg.clone()),
    };

    Response::builder()
        .status(status)
        .body(Body::from(body))
        .unwrap_or_else(|_| Response::builder().status(StatusCode::INTERNAL_SERVER_ERROR).body(Body::from("response build error")).unwrap())
}
