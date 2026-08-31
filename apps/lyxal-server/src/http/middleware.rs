use crate::context::AppContext;
use axum::{
    body::Body,
    extract::{Request, State},
    http::{HeaderName, HeaderValue},
    middleware::Next,
    response::Response,
};
use uuid::Uuid;

static REQUEST_ID: HeaderName = HeaderName::from_static("x-request-id");

pub async fn request_context(
    State(context): State<AppContext>,
    mut request: Request<Body>,
    next: Next,
) -> Response {
    let request_id = request
        .headers()
        .get(&REQUEST_ID)
        .and_then(|value| value.to_str().ok())
        .map(ToOwned::to_owned)
        .unwrap_or_else(|| Uuid::new_v4().to_string());

    if let Ok(value) = HeaderValue::from_str(&request_id) {
        request.headers_mut().insert(REQUEST_ID.clone(), value);
    }

    context.metrics.request_started();
    let response = next.run(request).await;
    context
        .metrics
        .request_finished(response.status().is_server_error());

    let mut response = response;
    if let Ok(value) = HeaderValue::from_str(&request_id) {
        response.headers_mut().insert(REQUEST_ID.clone(), value);
    }
    response
}
