pub mod jwks;
pub mod jwt;
use axum::{Json, response::IntoResponse, Extension};
use std::sync::Arc;
use crate::tokens::jwks::JwksService;

pub async fn get_jwks(
    Extension(jwks_service): Extension<Arc<JwksService>>
) -> impl IntoResponse {
    Json(jwks_service.get_public_jwks())
}
