/**
 * 🏛️ LYXAL OS — Redirections de Compatibilité pour les Anciens Liens E-mail
 * 
 * Remplace la logique de rendu HTML legacy de public_tokens.rs en fournissant
 * des redirections HTTP 307 vers les pages React publiques du Workspace.
 */

use std::collections::HashMap;
use axum::extract::{Path, Query};
use axum::response::{IntoResponse, Redirect, Response};
use axum::routing::get;
use axum::Router;

pub fn compatibility_router<S>() -> Router<S>
where
    S: Clone + Send + Sync + 'static,
{
    Router::new()
        .route("/booking/cancel/{token}", get(redirect_cancel))
        .route("/booking/reschedule/{token}", get(redirect_reschedule))
        .route("/booking/approve/{token}", get(redirect_approve))
        .route("/booking/decline/{token}", get(redirect_decline))
        .route("/booking/claim/{booking_id}", get(redirect_claim))
}

async fn redirect_cancel(Path(token): Path<String>) -> Response {
    Redirect::to(&format!("/workspace/public/bookings/cancel/{}", token)).into_response()
}

async fn redirect_reschedule(Path(token): Path<String>) -> Response {
    Redirect::to(&format!("/workspace/public/bookings/reschedule/{}", token)).into_response()
}

async fn redirect_approve(Path(token): Path<String>) -> Response {
    Redirect::to(&format!("/workspace/public/bookings/approve/{}", token)).into_response()
}

async fn redirect_decline(Path(token): Path<String>) -> Response {
    Redirect::to(&format!("/workspace/public/bookings/decline/{}", token)).into_response()
}

async fn redirect_claim(
    Path(booking_id): Path<String>,
    Query(params): Query<HashMap<String, String>>,
) -> Response {
    let target = if let Some(token) = params.get("token") {
        format!("/workspace/public/bookings/claim/{}?token={}", booking_id, token)
    } else {
        format!("/workspace/public/bookings/claim/{}", booking_id)
    };
    Redirect::to(&target).into_response()
}
