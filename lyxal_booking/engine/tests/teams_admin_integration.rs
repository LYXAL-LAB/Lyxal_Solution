//! Tests d'intégration réels pour les équipes, membres et administration tenant/plateforme (P2).
//!
//! Exécute les primitives SurrealQL réelles via `TestHarness`.

mod common;

use anyhow::Result;
use common::TestHarness;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Serialize)]
struct CreateTeamParams {
    user_id: RecordId,
    name: String,
    slug: String,
}

#[derive(Debug, Deserialize)]
struct TeamDetails {
    id: RecordId,
    name: String,
    slug: String,
}

#[derive(Debug, Serialize)]
struct AddMemberParams {
    user_id: RecordId,
    team_id: RecordId,
    role: String,
}

#[derive(Debug, Deserialize)]
struct MemberResult {
    id: RecordId,
    role: String,
}

#[tokio::test]
async fn test_team_lifecycle_and_member_addition() -> Result<()> {
    let harness = TestHarness::new().await?;

    let admin = harness
        .create_test_user("Team Leader", "leader@test.com", "leader", "Pass1234!", false)
        .await?;
    let member = harness
        .create_test_user("Team Member", "member@test.com", "member", "Pass1234!", false)
        .await?;

    // 1. Création d'équipe
    let team: TeamDetails = harness
        .call_fn(
            "booking_create_team",
            CreateTeamParams {
                user_id: admin.id.clone(),
                name: "Équipe Support".to_string(),
                slug: "equipe-support".to_string(),
            },
        )
        .await?;

    assert_eq!(team.name, "Équipe Support");
    assert_eq!(team.slug, "equipe-support");

    // 2. Ajout de membre à l'équipe
    let add_res: MemberResult = harness
        .call_fn(
            "booking_add_team_member",
            AddMemberParams {
                user_id: member.id.clone(),
                team_id: team.id.clone(),
                role: "member".to_string(),
            },
        )
        .await?;

    assert_eq!(add_res.role, "member");

    Ok(())
}
