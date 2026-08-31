use crate::db::{surreal_query_opt, SurrealBookingStore};
use crate::web::middleware::csrf::verify_csrf_token;
use crate::web::state::AppState;
use axum::extract::{Form, Multipart, Path, Query, State};
use axum::http::HeaderMap;
use axum::response::{IntoResponse, Redirect};
use std::sync::Arc;
use serde::Deserialize;

#[derive(Deserialize)]
pub(crate) struct CsrfForm {
    pub _csrf: Option<String>,
}

#[derive(Deserialize)]
pub(crate) struct CsrfQuery {
    pub _csrf: Option<String>,
}

pub(crate) fn detect_image_ext(bytes: &[u8]) -> Option<&'static str> {
    if bytes.starts_with(&[0x89, 0x50, 0x4E, 0x47]) {
        Some("png")
    } else if bytes.starts_with(&[0xFF, 0xD8, 0xFF]) {
        Some("jpg")
    } else if bytes.starts_with(b"GIF87a") || bytes.starts_with(b"GIF89a") {
        Some("gif")
    } else if bytes.len() >= 12 && &bytes[0..4] == b"RIFF" && &bytes[8..12] == b"WEBP" {
        Some("webp")
    } else {
        None
    }
}

pub(crate) async fn serve_avatar(
    State(state): State<AppState>,
    Path(user_id): Path<String>,
) -> impl IntoResponse {
    let avatar_path: Option<String> = surreal_query_opt(
        state
            .store
            .client()
            .query("RETURN fn::booking_get_user_avatar_path($user_id);")
            .bind(("user_id", user_id.clone()))
            .await,
    )
    .ok()
    .flatten();

    let filename = match avatar_path {
        Some(f) => f,
        None => return (axum::http::StatusCode::NOT_FOUND, "").into_response(),
    };

    let full_path = state.data_dir.join("avatars").join(&filename);
    match tokio::fs::read(&full_path).await {
        Ok(bytes) => {
            let content_type = if filename.ends_with(".jpg") || filename.ends_with(".jpeg") {
                "image/jpeg"
            } else if filename.ends_with(".png") {
                "image/png"
            } else if filename.ends_with(".gif") {
                "image/gif"
            } else if filename.ends_with(".webp") {
                "image/webp"
            } else {
                "image/png"
            };
            axum::response::Response::builder()
                .status(200)
                .header("Content-Type", content_type)
                .header("Cache-Control", "public, max-age=3600")
                .body(axum::body::Body::from(bytes))
                .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
                .into_response()
        }
        Err(_) => (axum::http::StatusCode::NOT_FOUND, "").into_response(),
    }
}

pub(crate) async fn serve_team_avatar(
    State(state): State<AppState>,
    Path(team_id): Path<String>,
) -> impl IntoResponse {
    let filename: Option<(String,)> = surreal_query_opt(
        state
            .store
            .client()
            .query("SELECT avatar_path FROM teams WHERE id = ? AND avatar_path IS NOT NULL")
            .bind(team_id.clone())
            .await,
    )
    .ok()
    .flatten();

    let filename = match filename {
        Some((f,)) => f,
        None => return (axum::http::StatusCode::NOT_FOUND, "").into_response(),
    };

    let full_path = state.data_dir.join("avatars").join(&filename);
    match tokio::fs::read(&full_path).await {
        Ok(bytes) => {
            let content_type = if filename.ends_with(".jpg") || filename.ends_with(".jpeg") {
                "image/jpeg"
            } else if filename.ends_with(".png") {
                "image/png"
            } else if filename.ends_with(".gif") {
                "image/gif"
            } else if filename.ends_with(".webp") {
                "image/webp"
            } else {
                "image/png"
            };
            axum::response::Response::builder()
                .status(200)
                .header("Content-Type", content_type)
                .header("Cache-Control", "public, max-age=3600")
                .body(axum::body::Body::from(bytes))
                .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
                .into_response()
        }
        Err(_) => (axum::http::StatusCode::NOT_FOUND, "").into_response(),
    }
}

pub(crate) async fn serve_logo(State(state): State<AppState>) -> impl IntoResponse {
    let logo_path = state.data_dir.join("logo.png");
    match tokio::fs::read(&logo_path).await {
        Ok(bytes) => {
            let content_type = if logo_path.exists() {
                if bytes.starts_with(&[0x89, 0x50, 0x4E, 0x47]) {
                    "image/png"
                } else if bytes.starts_with(&[0xFF, 0xD8]) {
                    "image/jpeg"
                } else if bytes.starts_with(b"<svg") || bytes.starts_with(b"<?xml") {
                    "image/svg+xml"
                } else {
                    "image/png"
                }
            } else {
                "image/png"
            };
            axum::response::Response::builder()
                .status(200)
                .header("Content-Type", content_type)
                .header("Cache-Control", "public, max-age=3600")
                .body(axum::body::Body::from(bytes))
                .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
                .into_response()
        }
        Err(_) => (axum::http::StatusCode::NOT_FOUND, "").into_response(),
    }
}

pub(crate) async fn serve_accent_css(State(state): State<AppState>) -> impl IntoResponse {
    let css = state.theme_css.read().await.clone();
    axum::response::Response::builder()
        .status(200)
        .header("Content-Type", "text/css; charset=utf-8")
        .header("Cache-Control", "no-cache")
        .body(axum::body::Body::from(css))
        .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
        .into_response()
}

pub(crate) async fn serve_brand_logo() -> impl IntoResponse {
    static BRAND_LOGO: &[u8] = include_bytes!("../../assets/calrs.png");
    axum::response::Response::builder()
        .status(200)
        .header("Content-Type", "image/png")
        .header("Cache-Control", "public, max-age=86400")
        .body(axum::body::Body::from(BRAND_LOGO))
        .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
        .into_response()
}

pub(crate) async fn admin_upload_logo(
    State(state): State<AppState>,
    _admin: crate::auth::AdminUser,
    headers: HeaderMap,
    Query(csrf_query): Query<CsrfQuery>,
    mut multipart: Multipart,
) -> impl IntoResponse {
    if let Err(resp) = verify_csrf_token(&headers, &csrf_query._csrf) {
        return resp;
    }
    while let Ok(Some(field)) = multipart.next_field().await {
        if field.name() == Some("logo") {
            let content_type = field.content_type().unwrap_or("").to_string();
            if !content_type.starts_with("image/") {
                return Redirect::to("/dashboard/admin").into_response();
            }
            if let Ok(bytes) = field.bytes().await {
                if bytes.len() > 2 * 1024 * 1024 {
                    return Redirect::to("/dashboard/admin").into_response();
                }
                if detect_image_ext(&bytes).is_none() {
                    return Redirect::to("/dashboard/admin").into_response();
                }
                let logo_path = state.data_dir.join("logo.png");
                let _ = tokio::fs::write(&logo_path, &bytes).await;
            }
        }
    }
    Redirect::to("/dashboard/admin").into_response()
}

pub(crate) async fn admin_delete_logo(
    State(state): State<AppState>,
    _admin: crate::auth::AdminUser,
    headers: HeaderMap,
    Form(csrf): Form<CsrfForm>,
) -> impl IntoResponse {
    if let Err(resp) = verify_csrf_token(&headers, &csrf._csrf) {
        return resp;
    }
    let logo_path = state.data_dir.join("logo.png");
    let _ = tokio::fs::remove_file(&logo_path).await;
    Redirect::to("/dashboard/admin").into_response()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn detect_image_ext_recognizes_known_formats() {
        // PNG signature.
        assert_eq!(
            detect_image_ext(&[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0xff]),
            Some("png")
        );
        // JPEG SOI + APP marker.
        assert_eq!(
            detect_image_ext(&[0xFF, 0xD8, 0xFF, 0xE0, 0x00]),
            Some("jpg")
        );
        // GIF.
        assert_eq!(detect_image_ext(b"GIF89a..."), Some("gif"));
        assert_eq!(detect_image_ext(b"GIF87a..."), Some("gif"));
        // RIFF/WEBP.
        let mut webp = Vec::from(*b"RIFF\x00\x00\x00\x00WEBP");
        webp.extend_from_slice(b"VP8 ");
        assert_eq!(detect_image_ext(&webp), Some("webp"));
    }

    #[test]
    fn detect_image_ext_rejects_non_images() {
        // Empty input, plain text, HTML stub, executable header are all rejected.
        assert_eq!(detect_image_ext(b""), None);
        assert_eq!(detect_image_ext(b"not an image"), None);
        assert_eq!(detect_image_ext(b"<html><body>"), None);
        assert_eq!(detect_image_ext(b"\x7fELF"), None);
        // RIFF without the WEBP marker should not be accepted.
        let riff_wave = b"RIFF\x00\x00\x00\x00WAVEfmt ";
        assert_eq!(detect_image_ext(riff_wave), None);
    }
}
