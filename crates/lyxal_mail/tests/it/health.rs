// SPDX-License-Identifier: AGPL-3.0-only

//! Sonde du courrier et hôte requis (§1.3 du plan du lot 5) : sans nœud `lyxal_server` vivant
//! sur la base depuis plus que l'absence tolérée, la sonde passe à « dégradé » ; un nœud vivant
//! de cet hôte (et non d'un autre) la rend saine.

use crate::support::{installed_client, master};
use lyxal_mail::{MailHealthCheck, MailStore, RequiredHost, REQUIRED_HOST_ABSENCE_LIMIT};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::presence::{PresenceStore, RuntimeNodeUpsertParams};
use lyxal_runtime::ModuleContext;
use lyxal_secrets::{FileKeys, SecretsStore};
use lyxal_storage::{BackendConfig, Backends, StorageService, StorageStore};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Sonde sur une base installée (schéma du runtime compris), support disque et clé maîtresse :
/// seule la présence de l'hôte requis peut la dégrader.
async fn probe(
    client: &Surreal<Any>,
    root: &std::path::Path,
    required: RequiredHost,
) -> MailHealthCheck {
    let backends = Arc::new(
        Backends::new()
            .with(
                "default",
                BackendConfig::Disk {
                    root: root.to_path_buf(),
                },
            )
            .expect("support"),
    );
    let store = StorageStore::new(client.clone());
    let storage = StorageService::new(store.clone(), backends).with_file_keys(
        FileKeys::new(SecretsStore::new(client.clone()), Some(master())),
        store,
    );
    MailHealthCheck::new(MailStore::new(client.clone()), storage).with_required_host(required)
}

async fn status(probe: &MailHealthCheck) -> (HealthStatus, String) {
    let result = probe
        .check(&ModuleContext::new(lyxal_mail::MODULE_ID))
        .await
        .expect("sonde");
    (result.status, result.message.unwrap_or_default())
}

async fn heartbeat(presence: &PresenceStore, node: &str, host: &str) {
    presence
        .upsert_node(RuntimeNodeUpsertParams {
            node_id: node.to_string(),
            host: host.to_string(),
            modules: vec!["lyxal_storage".to_string()],
            foundation_checksum: None,
        })
        .await
        .expect("battement");
}

#[tokio::test]
async fn without_a_live_server_node_the_probe_is_degraded_after_the_tolerated_absence() {
    let client = installed_client().await;
    lyxal_runtime::schema::install_runtime_schema(&client)
        .await
        .expect("schéma du runtime");
    let root = tempfile::tempdir().expect("support");
    let presence = PresenceStore::new(client.clone());

    // Absence encore tolérée (10 minutes) : saine
    assert_eq!(REQUIRED_HOST_ABSENCE_LIMIT, Duration::from_secs(600));
    let tolerant = probe(
        &client,
        root.path(),
        RequiredHost::new(presence.clone(), "lyxal_server"),
    )
    .await;
    assert_eq!(status(&tolerant).await.0, HealthStatus::Healthy);

    // Absence dépassée : « dégradé », avec la cause
    let strict = probe(
        &client,
        root.path(),
        RequiredHost::new(presence.clone(), "lyxal_server")
            .with_absence_limit(Duration::from_millis(50)),
    )
    .await;
    tokio::time::sleep(Duration::from_millis(100)).await;
    let (state, message) = status(&strict).await;
    assert_eq!(state, HealthStatus::Degraded, "{message}");
    assert!(
        message.contains("aucun nœud lyxal_server vivant"),
        "{message}"
    );

    // Un nœud vivant d'un autre hôte ne compte pas
    heartbeat(&presence, "groupware-1", "lyxal_groupware").await;
    assert_eq!(status(&strict).await.0, HealthStatus::Degraded);

    // Un nœud vivant de l'hôte requis rend la sonde saine
    heartbeat(&presence, "server-1", "lyxal_server").await;
    let (state, message) = status(&strict).await;
    assert_eq!(state, HealthStatus::Healthy, "{message}");

    // Nœud arrêté (ligne retirée) : de nouveau « dégradé » après l'absence tolérée
    presence
        .remove_node(&lyxal_runtime::NodeId::new("server-1"))
        .await
        .expect("arrêt du nœud");
    tokio::time::sleep(Duration::from_millis(100)).await;
    assert_eq!(status(&strict).await.0, HealthStatus::Degraded);
}
