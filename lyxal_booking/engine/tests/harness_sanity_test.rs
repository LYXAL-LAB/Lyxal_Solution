//! Test de fumée et validation du nouveau TestHarness SurrealDB commun.

mod common;

use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Clone, Serialize)]
struct GetUserProfileParams {
    user_id: RecordId,
}

#[derive(Debug, Clone, Deserialize)]
struct UserProfileResult {
    id: String,
    name: String,
    email: String,
    role: String,
    enabled: bool,
}

#[tokio::test]
async fn test_harness_initialization_and_fixtures() -> anyhow::Result<()> {
    // 1. Initialisation d'une instance in-memory SurrealDB avec les 209 .surql chargés
    let harness = TestHarness::new().await?;

    // 2. Création d'un utilisateur de test via la primitive canonique fn::booking_create_local_account
    let user = harness
        .create_test_user(
            "Alice Dupont",
            "alice@example.com",
            "alicedupont",
            "SecureP@ssw0rd!2026",
            true,
        )
        .await?;

    assert_eq!(user.name, "Alice Dupont");
    assert_eq!(user.email, "alice@example.com");
    assert_eq!(user.username, "alicedupont");
    assert_eq!(user.role, "admin");
    assert!(user.enabled);

    // 3. Appel d'une primitive de lecture métier (booking_get_user_profile) via call_fn typé
    let profile: UserProfileResult = harness
        .call_fn(
            "booking_get_user_profile",
            GetUserProfileParams {
                user_id: user.id.clone(),
            },
        )
        .await?;

    assert_eq!(profile.name, "Alice Dupont");
    assert_eq!(profile.email, "alice@example.com");
    assert!(profile.enabled);

    // 4. Création d'une ressource de test (salle de réunion)
    let resource = harness
        .create_test_resource(
            "Salle Titan",
            Some(12),
            Some("Bâtiment A, 2ème étage".to_string()),
            Some("Grande salle équipée visio".to_string()),
        )
        .await?;

    assert!(resource.created);

    // 5. Création d'un type d'événement
    let event_type = harness
        .create_test_event_type(
            user.id.clone(),
            "Consultation Stratégique",
            "consultation-strategique",
            45,
        )
        .await?;

    assert!(event_type.created);

    println!("=== HARNESS SANITY TEST PASSED AVEC SUCCES ===");
    Ok(())
}
