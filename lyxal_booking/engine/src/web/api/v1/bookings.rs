use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{get, post};
use axum::Json;
use axum::Router;
use surrealdb::RecordId;

use crate::contracts::bookings::{
    BookingResponse, CancelBookingRequest, CancelBookingResponse, CreateBookingRequest,
    PublicCancelBookingRequest, PublicRescheduleBookingRequest, PublicTokenInfoResponse,
    RescheduleBookingRequest,
};

use crate::services::bookings;
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_user_bookings).post(create_booking))
        .route("/{id}", get(get_booking))
        .route("/{id}/cancel", post(cancel_booking))
        .route("/{id}/reschedule", post(reschedule_booking))
        .route("/{id}/confirm", post(confirm_booking))
}


pub fn public_router() -> Router<AppState> {
    Router::new()
        .route("/users/{username}/event-types/{slug}/bookings", post(public_create_user_booking))
        .route("/teams/{team_slug}/event-types/{slug}/bookings", post(public_create_team_booking))
        .route("/bookings/token/{token}", get(public_get_token_info))
        .route(
            "/bookings/cancel/{token}",
            get(public_get_token_info).post(public_cancel_booking_by_token),
        )
        .route(
            "/bookings/reschedule/{token}",
            get(public_get_token_info).post(public_reschedule_booking_by_token),
        )
        .route(
            "/bookings/approve/{token}",
            get(public_get_token_info).post(public_approve_booking_by_token),
        )
        .route(
            "/bookings/decline/{token}",
            get(public_get_token_info).post(public_decline_booking_by_token),
        )
        .route("/bookings/claim/{booking_id}", post(public_claim_booking))
}


pub fn parse_booking_id(raw: &str) -> Result<RecordId, WebError> {
    let clean = raw.trim();

    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking" || id.is_empty() {
            return Err(WebError::BadRequest(
                "INVALID_BOOKING_ID: Expected booking:<id>".to_string(),
            ));
        }
        return Ok(RecordId::from(("booking", id)));
    }

    if clean.is_empty() {
        return Err(WebError::BadRequest(
            "INVALID_BOOKING_ID: Booking identifier is required".to_string(),
        ));
    }

    Ok(RecordId::from(("booking", clean)))
}

pub async fn list_user_bookings(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<Vec<BookingResponse>>, WebError> {
    let bookings = bookings::list_user_bookings(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to list user bookings: {}", e)))?;

    Ok(Json(bookings))
}

pub async fn create_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateBookingRequest>,
) -> Result<Response, WebError> {
    if request.guest_name.trim().is_empty() {
        return Err(WebError::BadRequest("Guest name cannot be empty".to_string()));
    }
    crate::web::api::v1::users::validate_email(&request.guest_email)?;
    crate::web::api::v1::event_types::validate_slug(&request.event_type_slug)?;

    let booking = bookings::create_booking(&state.store, &auth, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to create booking: {}", e)))?;

    Ok((StatusCode::CREATED, Json(booking)).into_response())
}

pub async fn public_create_booking(
    State(state): State<AppState>,
    Path(slug): Path<String>,
    Json(mut request): Json<CreateBookingRequest>,
) -> Result<Response, WebError> {
    request.event_type_slug = slug;
    if request.guest_name.trim().is_empty() {
        return Err(WebError::BadRequest("Guest name cannot be empty".to_string()));
    }
    crate::web::api::v1::users::validate_email(&request.guest_email)?;
    crate::web::api::v1::event_types::validate_slug(&request.event_type_slug)?;

    let booking = bookings::create_public_booking(&state.store, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to create public booking: {}", e)))?;

    Ok((StatusCode::CREATED, Json(booking)).into_response())
}

pub async fn public_create_user_booking(
    State(state): State<AppState>,
    Path((_username, slug)): Path<(String, String)>,
    Json(mut request): Json<CreateBookingRequest>,
) -> Result<Response, WebError> {
    request.event_type_slug = slug;
    if request.guest_name.trim().is_empty() {
        return Err(WebError::BadRequest("Guest name cannot be empty".to_string()));
    }
    crate::web::api::v1::users::validate_email(&request.guest_email)?;
    crate::web::api::v1::event_types::validate_slug(&request.event_type_slug)?;

    let booking = bookings::create_public_booking(&state.store, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to create public user booking: {}", e)))?;

    Ok((StatusCode::CREATED, Json(booking)).into_response())
}

pub async fn public_create_team_booking(
    State(state): State<AppState>,
    Path((_team_slug, slug)): Path<(String, String)>,
    Json(mut request): Json<CreateBookingRequest>,
) -> Result<Response, WebError> {
    request.event_type_slug = slug;
    if request.guest_name.trim().is_empty() {
        return Err(WebError::BadRequest("Guest name cannot be empty".to_string()));
    }
    crate::web::api::v1::users::validate_email(&request.guest_email)?;
    crate::web::api::v1::event_types::validate_slug(&request.event_type_slug)?;

    let booking = bookings::create_public_booking(&state.store, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to create public team booking: {}", e)))?;

    Ok((StatusCode::CREATED, Json(booking)).into_response())
}

pub async fn get_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking_rec = parse_booking_id(&id)?;

    let booking = bookings::get_booking(&state.store, &auth, &booking_rec)
        .await
        .map_err(|e| WebError::NotFound(format!("Failed to retrieve booking: {}", e)))?;

    Ok(Json(booking))
}

pub async fn cancel_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<CancelBookingRequest>,
) -> Result<Json<CancelBookingResponse>, WebError> {
    let booking_rec = parse_booking_id(&id)?;

    let response = bookings::cancel_booking(
        &state.store,
        &auth,
        &booking_rec,
        &request,
    )
    .await
    .map_err(|e| WebError::Internal(format!("Failed to cancel booking: {}", e)))?;

    if !response.cancelled {
        return Err(WebError::Conflict(
            "BOOKING_CANCEL_FORBIDDEN: Booking cannot be cancelled (already cancelled or past)".to_string(),
        ));
    }

    Ok(Json(response))
}

pub async fn reschedule_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<RescheduleBookingRequest>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking_rec = parse_booking_id(&id)?;

    let booking = bookings::reschedule_booking(
        &state.store,
        &auth,
        &booking_rec,
        &request,
    )
    .await
    .map_err(|e| WebError::Conflict(format!("BOOKING_VERSION_CONFLICT: {}", e)))?;

    Ok(Json(booking))
}

pub async fn confirm_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking_rec = parse_booking_id(&id)?;

    let booking = bookings::confirm_booking(&state.store, &auth, &booking_rec)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_CONFIRM_BOOKING: {}", e)))?;

    Ok(Json(booking))
}


pub async fn public_get_token_info(
    State(state): State<AppState>,
    Path(token): Path<String>,
) -> Result<Json<PublicTokenInfoResponse>, WebError> {
    let info = bookings::get_public_token_info(&state.store, &token)
        .await
        .map_err(|e| WebError::NotFound(format!("INVALID_OR_EXPIRED_TOKEN: {}", e)))?;

    Ok(Json(info))
}

pub async fn public_cancel_booking_by_token(
    State(state): State<AppState>,
    Path(token): Path<String>,
    Json(request): Json<PublicCancelBookingRequest>,
) -> Result<Json<CancelBookingResponse>, WebError> {
    let response = bookings::cancel_public_booking_by_token(&state.store, &token, &request)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_CANCEL_BY_TOKEN: {}", e)))?;

    Ok(Json(response))
}

pub async fn public_reschedule_booking_by_token(
    State(state): State<AppState>,
    Path(token): Path<String>,
    Json(request): Json<PublicRescheduleBookingRequest>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking = bookings::reschedule_public_booking_by_token(&state.store, &token, &request)
        .await
        .map_err(|e| WebError::Conflict(format!("FAILED_RESCHEDULE_BY_TOKEN: {}", e)))?;

    Ok(Json(booking))
}

pub async fn public_approve_booking_by_token(
    State(state): State<AppState>,
    Path(token): Path<String>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking = bookings::approve_public_booking_by_token(&state.store, &token)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_APPROVE_BY_TOKEN: {}", e)))?;

    Ok(Json(booking))
}

pub async fn public_decline_booking_by_token(
    State(state): State<AppState>,
    Path(token): Path<String>,
) -> Result<Json<BookingResponse>, WebError> {
    let booking = bookings::decline_public_booking_by_token(&state.store, &token)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_DECLINE_BY_TOKEN: {}", e)))?;

    Ok(Json(booking))
}

pub async fn public_claim_booking(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(booking_id): Path<String>,
    Json(request): Json<crate::contracts::bookings::ClaimBookingRequest>,
) -> Result<Json<crate::contracts::bookings::ClaimBookingResponse>, WebError> {
    let booking_rec = parse_booking_id(&booking_id)?;
    let response = bookings::claim_booking(&state.store, &auth, &booking_rec.to_string(), &request)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_CLAIM_BOOKING: {}", e)))?;

    Ok(Json(response))
}

#[cfg(test)]

mod tests {
    use super::*;

    #[test]
    fn test_parse_booking_id_valid() {
        let parsed = parse_booking_id("booking:res123").unwrap();
        assert_eq!(parsed.to_string(), "booking:res123");
    }

    #[test]
    fn test_parse_booking_id_rejects_legacy_table() {
        let err = parse_booking_id("booking_reservation:res123");
        assert!(err.is_err());
    }

    #[test]
    fn test_parse_booking_id_rejects_other_table() {
        let err = parse_booking_id("booking_account:admin");
        assert!(err.is_err());
    }
}
