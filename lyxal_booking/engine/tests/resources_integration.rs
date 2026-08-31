//! Tests d'intégration réels pour les ressources physiques et l'allocation (P1).
//!
//! Exécute les primitives SurrealQL réelles via `TestHarness`.

mod common;

use anyhow::Result;
use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Serialize)]
struct GetResourceParams {
    resource_id: RecordId,
}

#[derive(Debug, Serialize)]
struct DeleteResourceParams {
    resource_id: RecordId,
}

#[derive(Debug, Deserialize)]
struct ResourceDetails {
    id: RecordId,
    name: String,
    capacity: Option<i32>,
    location: Option<String>,
}

#[derive(Debug, Deserialize)]
struct DeleteResourceResult {
    deleted: bool,
}

#[tokio::test]
async fn test_resource_lifecycle_create_get_delete() -> Result<()> {
    let harness = TestHarness::new().await?;

    // 1. Création d'une ressource
    let res = harness
        .create_test_resource(
            "Studio Enregistrement A",
            Some(4),
            Some("Bâtiment 2".to_string()),
            Some("Équipé micros podcast".to_string()),
        )
        .await?;

    assert!(res.created);

    // 2. Lecture des détails de la ressource
    let details: ResourceDetails = harness
        .call_fn(
            "booking_get_resource",
            GetResourceParams {
                resource_id: res.id.clone(),
            },
        )
        .await?;

    assert_eq!(details.name, "Studio Enregistrement A");
    assert_eq!(details.capacity, Some(4));
    assert_eq!(details.location.as_deref(), Some("Bâtiment 2"));

    // 3. Suppression de la ressource
    let del: DeleteResourceResult = harness
        .call_fn(
            "booking_delete_resource",
            DeleteResourceParams {
                resource_id: res.id.clone(),
            },
        )
        .await?;

    assert!(del.deleted, "La ressource doit être marquée supprimée");

    Ok(())
}
