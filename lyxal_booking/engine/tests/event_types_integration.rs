//! Tests d'intégration réels pour les permissions et types d'événements (P0).
//!
//! Exécute les primitives SurrealQL réelles via `TestHarness`.

mod common;

use anyhow::Result;
use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Serialize)]
struct CanManageParams {
    account_id: RecordId,
    event_type_id: RecordId,
}

#[derive(Debug, Serialize)]
struct FindManageableParams {
    account_id: RecordId,
    slug: String,
}

#[derive(Debug, Deserialize)]
struct EventTypeRecord {
    id: RecordId,
    slug: String,
    title: String,
}

#[tokio::test]
async fn test_can_manage_event_type_personal_owner_vs_stranger() -> Result<()> {
    let harness = TestHarness::new().await?;

    let owner = harness
        .create_test_user("Alice Owner", "alice@owner.com", "alice_o", "Pass1234!", false)
        .await?;
    let stranger = harness
        .create_test_user("Bob Stranger", "bob@stranger.com", "bob_s", "Pass1234!", false)
        .await?;

    let et = harness
        .create_test_event_type(owner.id.clone(), "Consultation 30m", "consult-30m", 30)
        .await?;

    // 1. Owner personnel -> autorisé (true)
    let can_owner: bool = harness
        .call_fn(
            "booking_can_manage_event_type",
            CanManageParams {
                account_id: owner.id.clone(),
                event_type_id: et.id.clone(),
            },
        )
        .await?;
    assert!(can_owner, "Le propriétaire doit pouvoir gérer son type d'événement");

    // 2. Stranger -> refusé (false)
    let can_stranger: bool = harness
        .call_fn(
            "booking_can_manage_event_type",
            CanManageParams {
                account_id: stranger.id.clone(),
                event_type_id: et.id.clone(),
            },
        )
        .await?;
    assert!(!can_stranger, "Un étranger ne doit pas pouvoir gérer le type d'événement");

    Ok(())
}

#[tokio::test]
async fn test_find_manageable_event_type_by_slug() -> Result<()> {
    let harness = TestHarness::new().await?;

    let user = harness
        .create_test_user("Charlie User", "charlie@test.com", "charlie_u", "Pass1234!", false)
        .await?;

    let _et = harness
        .create_test_event_type(user.id.clone(), "Démo Produit", "demo-produit", 45)
        .await?;

    // Recherche par slug
    let found: Option<EventTypeRecord> = harness
        .call_fn(
            "booking_find_manageable_event_type_by_slug",
            FindManageableParams {
                account_id: user.id.clone(),
                slug: "demo-produit".to_string(),
            },
        )
        .await?;

    assert!(found.is_some(), "Le type d'événement doit être résolu par slug");
    let rec = found.unwrap();
    assert_eq!(rec.slug, "demo-produit");
    assert_eq!(rec.title, "Démo Produit");

    // Recherche inexistant -> None
    let not_found: Option<EventTypeRecord> = harness
        .call_fn(
            "booking_find_manageable_event_type_by_slug",
            FindManageableParams {
                account_id: user.id.clone(),
                slug: "inexistant-slug".to_string(),
            },
        )
        .await?;
    assert!(not_found.is_none(), "Un slug inexistant doit retourner None");

    Ok(())
}
