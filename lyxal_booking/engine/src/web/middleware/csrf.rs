use axum::http::HeaderMap;
use axum::response::{IntoResponse, Response};
use subtle::ConstantTimeEq;

pub const CSRF_COOKIE_NAME: &str = "__Host-calrs_csrf";

pub fn generate_csrf_token() -> String {
    uuid::Uuid::new_v4().to_string()
}

pub fn csrf_cookie_value(token: &str) -> String {
    csrf_cookie_value_for(token, false)
}

pub fn csrf_cookie_value_for(token: &str, cross_site: bool) -> String {
    let same_site = if cross_site { "None" } else { "Lax" };
    let partitioned = if cross_site { "; Partitioned" } else { "" };
    format!(
        "{}={}; Path=/; Secure; SameSite={}; Max-Age=86400{}",
        CSRF_COOKIE_NAME, token, same_site, partitioned
    )
}

/// Extract the CSRF cookie value from request headers.
pub fn csrf_token_from_headers(headers: &HeaderMap) -> Option<String> {
    let prefix = format!("{}=", CSRF_COOKIE_NAME);
    headers
        .get_all(axum::http::header::COOKIE)
        .iter()
        .filter_map(|v| v.to_str().ok())
        .flat_map(|s| s.split(';'))
        .find_map(|part| {
            let part = part.trim();
            part.strip_prefix(&prefix).map(|v| v.to_string())
        })
}

/// Verify that the CSRF form field matches the cookie value.
#[allow(clippy::result_large_err)]
pub fn verify_csrf_token(
    headers: &HeaderMap,
    form_token: &Option<String>,
) -> Result<(), Response> {
    let cookie_token = csrf_token_from_headers(headers);
    let (cookie, form) = match (cookie_token, form_token) {
        (Some(c), Some(f)) => (c, f.clone()),
        _ => {
            return Err((
                axum::http::StatusCode::FORBIDDEN,
                "CSRF token missing or invalid",
            )
                .into_response());
        }
    };

    if cookie.len() != form.len() {
        return Err((
            axum::http::StatusCode::FORBIDDEN,
            "CSRF token mismatch",
        )
            .into_response());
    }

    let is_valid = cookie.as_bytes().ct_eq(form.as_bytes());
    if is_valid.into() {
        Ok(())
    } else {
        Err((
            axum::http::StatusCode::FORBIDDEN,
            "CSRF token mismatch",
        )
            .into_response())
    }
}

/// Middleware that ensures a CSRF cookie (`__Host-calrs_csrf`) is set on outgoing responses if missing.
/// It only sets the cookie header and does NOT block GET/POST requests or Bearer token auth.
pub async fn csrf_cookie_middleware(
    request: axum::extract::Request,
    next: axum::middleware::Next,
) -> Response {
    let has_cookie = csrf_token_from_headers(request.headers()).is_some();
    let token = if has_cookie {
        None
    } else {
        Some(generate_csrf_token())
    };
    let mut response = next.run(request).await;
    if let Some(tok) = token {
        let cookie = csrf_cookie_value(&tok);
        if let Ok(val) = axum::http::HeaderValue::from_str(&cookie) {
            response
                .headers_mut()
                .append(axum::http::header::SET_COOKIE, val);
        }
    }
    response
}
