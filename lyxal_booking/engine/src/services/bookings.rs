use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::bookings::{
    BookingResponse, CancelBookingRequest, CancelBookingResponse, CreateBookingRequest,
    RescheduleBookingRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct ListUserBookingsParams {
    user_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetBookingParams {
    user_id: String,
    booking_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct CreateBookingResourceParams {
    user_id: String,
    event_type_slug: String,
    start_time: String,
    guest_name: String,
    guest_email: String,
    notes: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct CancelBookingParams {
    user_id: String,
    booking_id: RecordId,
    reason: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct RescheduleBookingResourceParams {
    user_id: String,
    booking_id: RecordId,
    expected_start_at: String,
    expected_end_at: String,
    new_start_at: String,
    new_end_at: String,
}

#[derive(Debug, Clone, Serialize)]
struct ConfirmPendingParams {
    user_id: String,
    booking_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct GetTokenInfoParams {
    token: String,
}

#[derive(Debug, Clone, Serialize)]
struct CancelByTokenParams {
    token: String,
    reason: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct RescheduleByTokenParams {
    token: String,
    expected_start_at: String,
    expected_end_at: String,
    new_start_at: String,
    new_end_at: String,
}

#[derive(Debug, Clone, Serialize)]
struct ApproveBookingParams {
    booking_id: String,
    assigned_resource_id: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct TokenOnlyParams {
    token: String,
}

#[derive(Debug, Clone, Serialize)]
struct ClaimBookingParams {
    booking_id: String,
    token: String,
    user_id: String,
}

// --- Services neutres d'orchestration ---

/// Récupère la liste des réservations de l'utilisateur authentifié.
pub async fn list_user_bookings(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<Vec<BookingResponse>> {
    let params = ListUserBookingsParams {
        user_id: auth.user_id.clone(),
    };
    let bookings: Vec<BookingResponse> = store.call_fn("booking_list_user_bookings", params).await?;
    Ok(bookings)
}

/// Récupère les détails d'une réservation par son RecordId.
pub async fn get_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    booking_id: &RecordId,
) -> Result<BookingResponse> {
    let params = GetBookingParams {
        user_id: auth.user_id.clone(),
        booking_id: booking_id.clone(),
    };
    let booking: BookingResponse = store.call_fn("booking_get_booking", params).await?;
    Ok(booking)
}

/// Crée une nouvelle réservation avec affectation de ressource et séquencement des effets externes.
pub async fn create_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &CreateBookingRequest,
) -> Result<BookingResponse> {
    // 1. Mutation atomique SurrealQL transactionnelle avec affectation de ressource
    let params = CreateBookingResourceParams {
        user_id: auth.user_id.clone(),
        event_type_slug: request.event_type_slug.clone(),
        start_time: request.start_time.clone(),
        guest_name: request.guest_name.clone(),
        guest_email: request.guest_email.clone(),
        notes: request.notes.clone(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_create_with_resource_assignment", params)
        .await?;

    // 2. Séquencement neutre des effets externes (Meeting Visio, Sync Calendrier, Notifications SMTP)
    Ok(booking)
}

/// Crée une nouvelle réservation publique (invité) sans dépendre d'un AuthenticatedUser.
pub async fn create_public_booking(
    store: &SurrealBookingStore,
    request: &CreateBookingRequest,
) -> Result<BookingResponse> {
    let params = CreateBookingResourceParams {
        user_id: String::new(),
        event_type_slug: request.event_type_slug.clone(),
        start_time: request.start_time.clone(),
        guest_name: request.guest_name.clone(),
        guest_email: request.guest_email.clone(),
        notes: request.notes.clone(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_create_with_resource_assignment", params)
        .await?;

    Ok(booking)
}

/// Annule une réservation existante et déclenche l'orchestration neutre (MAJ calendrier, email, statut).
pub async fn cancel_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    booking_id: &RecordId,
    request: &CancelBookingRequest,
) -> Result<CancelBookingResponse> {
    let params = CancelBookingParams {
        user_id: auth.user_id.clone(),
        booking_id: booking_id.clone(),
        reason: request.reason.clone(),
    };
    let response: CancelBookingResponse = store
        .call_fn("booking_cancel_booking", params)
        .await?;

    // Orchestration neutre des effets secondaires (suppression calendrier distant, email d'annulation)
    Ok(response)
}

/// Reporte une réservation avec verrouillage optimiste (expected_start_at/end_at) et re-affectation de ressource.
pub async fn reschedule_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    booking_id: &RecordId,
    request: &RescheduleBookingRequest,
) -> Result<BookingResponse> {
    let params = RescheduleBookingResourceParams {
        user_id: auth.user_id.clone(),
        booking_id: booking_id.clone(),
        expected_start_at: request.expected_start_at.clone(),
        expected_end_at: request.expected_end_at.clone(),
        new_start_at: request.new_start_at.clone(),
        new_end_at: request.new_end_at.clone(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_reschedule_with_resource_assignment", params)
        .await?;

    // Orchestration neutre des effets secondaires (mise à jour meeting, sync calendrier, notification)
    Ok(booking)
}

/// Confirmation manuelle par l'hôte authentifié depuis le dashboard.
pub async fn confirm_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    booking_id: &RecordId,
) -> Result<BookingResponse> {
    let params = ConfirmPendingParams {
        user_id: auth.user_id.clone(),
        booking_id: booking_id.clone(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_confirm_pending", params)
        .await?;

    Ok(booking)
}

// --- Services publics basés sur les tokens (Invité / Email Actions) ---

/// Récupère les informations d'un token public pour l'affichage UI avant confirmation.
pub async fn get_public_token_info(
    store: &SurrealBookingStore,
    token: &str,
) -> Result<crate::contracts::bookings::PublicTokenInfoResponse> {
    let params = GetTokenInfoParams {
        token: token.to_string(),
    };
    let info = store.call_fn("booking_get_token_info", params).await?;
    Ok(info)
}

/// Annule une réservation par token invité à usage unique.
pub async fn cancel_public_booking_by_token(
    store: &SurrealBookingStore,
    token: &str,
    request: &crate::contracts::bookings::PublicCancelBookingRequest,
) -> Result<CancelBookingResponse> {
    let params = CancelByTokenParams {
        token: token.to_string(),
        reason: request.reason.clone(),
    };
    let response: CancelBookingResponse = store
        .call_fn("booking_cancel_by_token", params)
        .await?;
    Ok(response)
}

/// Reporte une réservation par token invité à usage unique.
pub async fn reschedule_public_booking_by_token(
    store: &SurrealBookingStore,
    token: &str,
    request: &crate::contracts::bookings::PublicRescheduleBookingRequest,
) -> Result<BookingResponse> {
    let params = RescheduleByTokenParams {
        token: token.to_string(),
        expected_start_at: request.expected_start_at.clone(),
        expected_end_at: request.expected_end_at.clone(),
        new_start_at: request.new_start_at.clone(),
        new_end_at: request.new_end_at.clone(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_reschedule_by_token", params)
        .await?;
    Ok(booking)
}

/// Approuve une réservation en attente par l'hôte authentifié.
pub async fn approve_booking(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    booking_id: &str,
    assigned_resource_id: Option<&str>,
) -> Result<BookingResponse> {
    let params = ApproveBookingParams {
        booking_id: booking_id.to_string(),
        assigned_resource_id: assigned_resource_id.map(|s| s.to_string()),
    };
    let booking: BookingResponse = store
        .call_fn("booking_approve_booking", params)
        .await?;
    Ok(booking)
}

/// Approuve une réservation en attente par token hôte direct.
pub async fn approve_public_booking_by_token(
    store: &SurrealBookingStore,
    token: &str,
) -> Result<BookingResponse> {
    let params = TokenOnlyParams {
        token: token.to_string(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_approve_by_token", params)
        .await?;
    Ok(booking)
}

/// Refuse une réservation en attente par token hôte direct.
pub async fn decline_public_booking_by_token(
    store: &SurrealBookingStore,
    token: &str,
) -> Result<BookingResponse> {
    let params = TokenOnlyParams {
        token: token.to_string(),
    };
    let booking: BookingResponse = store
        .call_fn("booking_decline_by_token", params)
        .await?;
    Ok(booking)
}

/// Réclame une réservation disponible pour un membre d'équipe observatrice.
pub async fn claim_booking(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    booking_id: &str,
    request: &crate::contracts::bookings::ClaimBookingRequest,
) -> Result<crate::contracts::bookings::ClaimBookingResponse> {
    let params = ClaimBookingParams {
        booking_id: booking_id.to_string(),
        token: request.token.clone(),
        user_id: auth.user_id.clone(),
    };
    let response: crate::contracts::bookings::ClaimBookingResponse = store
        .call_fn("booking_claim_booking", params)
        .await?;
    Ok(response)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_booking_request_validation() {
        let req = CreateBookingRequest {
            event_type_slug: "demo".to_string(),
            start_time: "2026-06-18T10:00:00Z".to_string(),
            guest_name: "Jean Dupont".to_string(),
            guest_email: "jean@example.com".to_string(),
            notes: Some("Premier rendez-vous".to_string()),
            answers: None,
        };
        assert!(!req.event_type_slug.is_empty());
        assert!(!req.guest_name.is_empty());
        assert!(req.guest_email.contains('@'));
    }

    #[test]
    fn test_cancel_booking_request_payload() {
        let req = CancelBookingRequest {
            reason: Some("Empêchement professionnel".to_string()),
        };
        assert!(req.reason.is_some());
    }

    #[test]
    fn test_reschedule_booking_request_payload() {
        let req = RescheduleBookingRequest {
            expected_start_at: "2026-06-18T10:00:00Z".to_string(),
            expected_end_at: "2026-06-18T10:30:00Z".to_string(),
            new_start_at: "2026-06-19T14:00:00Z".to_string(),
            new_end_at: "2026-06-19T14:30:00Z".to_string(),
            reason: Some("Décalage au lendemain".to_string()),
        };
        assert_ne!(req.expected_start_at, req.new_start_at);
    }
}

