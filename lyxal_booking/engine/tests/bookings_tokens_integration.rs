//! Tests d'intégration réels pour les réservations, tokens, annulation et reprogrammation (P0).
//!
//! Exécute les primitives SurrealQL réelles via `TestHarness`.

mod common;

use anyhow::Result;
use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Serialize)]
struct TokenParams {
    token: String,
}

#[derive(Debug, Serialize)]
struct CancelTokenParams {
    token: String,
    reason: Option<String>,
}

#[derive(Debug, Serialize)]
struct RescheduleTokenParams {
    token: String,
    expected_start_at: String,
    expected_end_at: String,
    new_start_at: String,
    new_end_at: String,
}

#[derive(Debug, Deserialize)]
struct TokenInfo {
    booking_id: RecordId,
    status: String,
    guest_name: String,
    guest_email: String,
}

#[derive(Debug, Deserialize)]
struct CancelResult {
    cancelled: bool,
}

#[derive(Debug, Deserialize)]
struct RescheduleResult {
    id: RecordId,
    status: String,
}

#[tokio::test]
async fn test_booking_creation_and_token_lookup() -> Result<()> {
    let harness = TestHarness::new().await?;

    let host = harness
        .create_test_user("Dr Smith", "smith@test.com", "dr_smith", "Pass1234!", false)
        .await?;

    let _et = harness
        .create_test_event_type(host.id.clone(), "Consultation", "consultation", 30)
        .await?;

    let booking = harness
        .create_test_booking(
            "consultation",
            "2026-09-10T10:00:00Z",
            "Marc Dupont",
            "marc@client.com",
            Some("Première consultation".to_string()),
            Some(host.id.clone()),
        )
        .await?;

    assert_eq!(booking.guest_name, "Marc Dupont");
    assert_eq!(booking.guest_email, "marc@client.com");
    assert!(!booking.cancel_token.is_empty());
    assert!(!booking.reschedule_token.is_empty());

    // Vérification de la résolution du token public
    let info: TokenInfo = harness
        .call_fn(
            "booking_get_token_info",
            TokenParams {
                token: booking.cancel_token.clone(),
            },
        )
        .await?;

    assert_eq!(info.booking_id, booking.id);
    assert_eq!(info.guest_name, "Marc Dupont");

    Ok(())
}

#[tokio::test]
async fn test_booking_cancel_by_token_lifecycle() -> Result<()> {
    let harness = TestHarness::new().await?;

    let host = harness
        .create_test_user("Sophie Host", "sophie@test.com", "sophie_h", "Pass1234!", false)
        .await?;

    let _et = harness
        .create_test_event_type(host.id.clone(), "Entretien", "entretien", 45)
        .await?;

    let booking = harness
        .create_test_booking(
            "entretien",
            "2026-09-15T14:00:00Z",
            "Claire Martin",
            "claire@candidat.com",
            None,
            Some(host.id.clone()),
        )
        .await?;

    // 1. Annulation réussie via token invité
    let cancel_res: CancelResult = harness
        .call_fn(
            "booking_cancel_by_token",
            CancelTokenParams {
                token: booking.cancel_token.clone(),
                reason: Some("Indisponibilité imprévue".to_string()),
            },
        )
        .await?;
    assert!(cancel_res.cancelled, "La réservation doit être marquée annulée");

    // 2. Seconde tentative d'utilisation du token -> doit échouer (token déjà consommé)
    let second_try: Result<CancelResult, _> = harness
        .call_fn(
            "booking_cancel_by_token",
            CancelTokenParams {
                token: booking.cancel_token.clone(),
                reason: Some("Re-tentative".to_string()),
            },
        )
        .await;
    assert!(second_try.is_err(), "Un token déjà consommé doit être rejeté");

    Ok(())
}

#[tokio::test]
async fn test_booking_reschedule_by_token_lifecycle() -> Result<()> {
    let harness = TestHarness::new().await?;

    let host = harness
        .create_test_user("Pierre Host", "pierre@test.com", "pierre_h", "Pass1234!", false)
        .await?;

    let _et = harness
        .create_test_event_type(host.id.clone(), "Bilan", "bilan", 30)
        .await?;

    let booking = harness
        .create_test_booking(
            "bilan",
            "2026-09-20T09:00:00Z",
            "Paul Durand",
            "paul@client.com",
            None,
            Some(host.id.clone()),
        )
        .await?;

    // Reprogrammation via token
    let reschedule_res: RescheduleResult = harness
        .call_fn(
            "booking_reschedule_by_token",
            RescheduleTokenParams {
                token: booking.reschedule_token.clone(),
                expected_start_at: "2026-09-20T09:00:00Z".to_string(),
                expected_end_at: "2026-09-20T09:30:00Z".to_string(),
                new_start_at: "2026-09-21T11:00:00Z".to_string(),
                new_end_at: "2026-09-21T11:30:00Z".to_string(),
            },
        )
        .await?;

    assert_eq!(reschedule_res.id, booking.id);
    assert_eq!(reschedule_res.status, "confirmed");

    Ok(())
}
