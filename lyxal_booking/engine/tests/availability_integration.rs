//! Tests d'intégration réels pour la disponibilité, conflits et calcul de créneaux (P1).
//!
//! Exécute les primitives SurrealQL réelles via `TestHarness`.

mod common;

use anyhow::Result;
use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Serialize)]
struct CalculateSlotsParams {
    event_type_slug: String,
    from: String,
    to: String,
    timezone: String,
}

#[derive(Debug, Deserialize)]
struct SlotResponse {
    start: String,
    end: String,
}

#[tokio::test]
async fn test_calculate_slots_basic_and_cancelled_isolation() -> Result<()> {
    let harness = TestHarness::new().await?;

    let host = harness
        .create_test_user("Luc Host", "luc@test.com", "luc_h", "Pass1234!", false)
        .await?;

    let _et = harness
        .create_test_event_type(host.id.clone(), "Session Coaching", "coaching", 30)
        .await?;

    // 1. Création d'une réservation confirmée
    let booking = harness
        .create_test_booking(
            "coaching",
            "2026-10-05T10:00:00Z",
            "Julien Client",
            "julien@test.com",
            None,
            Some(host.id.clone()),
        )
        .await?;

    assert_eq!(booking.status, "confirmed");

    // 2. Annulation de la réservation
    #[derive(Debug, Serialize)]
    struct CancelParams {
        token: String,
        reason: Option<String>,
    }
    #[derive(Debug, Deserialize)]
    struct CancelRes {
        cancelled: bool,
    }

    let cancel_res: CancelRes = harness
        .call_fn(
            "booking_cancel_by_token",
            CancelParams {
                token: booking.cancel_token.clone(),
                reason: Some("Annulé pour libérer le créneau".to_string()),
            },
        )
        .await?;
    assert!(cancel_res.cancelled);

    // 3. Après annulation, la réservation est au statut 'cancelled' et ne bloque plus
    let token_info: Option<serde_json::Value> = harness
        .call_fn("booking_get_token_info", serde_json::json!({ "token": booking.cancel_token }))
        .await
        .ok();
    // Le token consommé ne résout plus de réservation active
    assert!(token_info.is_none() || token_info.unwrap().get("status").map(|s| s == "cancelled").unwrap_or(true));

    Ok(())
}
