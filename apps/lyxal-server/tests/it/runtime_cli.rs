//! Commandes `lyxal-server runtime migrations list|resolve`, serveur arrêté : sur une base où la
//! migration d'un module hébergé est restée « en cours » sans bail vivant, le démarrage de l'hôte
//! échoue ; la liste la montre, `abandon` laisse le démarrage refusé, `retry` le débloque et la
//! migration est rejouée ; refus (rien d'interrompu, motif invalide, bail d'installation détenu
//! ailleurs) et trace au journal du runtime sous l'auteur `cli:<instance>`.
//!
//! Les fonctions des commandes sont appelées directement : une base embarquée (`mem://`) n'est
//! pas partagée entre deux connexions, le passage par `cli::execute` (qui ouvre la sienne) n'est
//! donc pas exercé ici.

use async_trait::async_trait;
use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::migration::{MigrationResolveAction, MigrationResolveParams};
use lyxal_runtime::resource::EmbeddedResourceProvider;
use lyxal_runtime::{LyxalModule, ModuleContext, ModuleDescriptor, ModulePackage, RuntimeError};
use lyxal_server::config::AppConfig;
use lyxal_server::error::ServerError;
use lyxal_server::{cli, modules, runtime};
use serde_json::{json, Value};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::startup::{config_with, database};

const MODULE: &str = "lyxal_essai";
const MIGRATION: &str = "0001_initial";

/// Module d'essai hébergé avec les modules embarqués : il déclare une migration.
const MANIFEST: &str = r#"
manifest_version = 1
id = "lyxal_essai"
name = "Lyxal Essai"
version = "0.1.0"
description = "Module d'essai de la reprise d'une migration"
capabilities = []

[runtime]
min_version = ">=0.1.0"

[resources]
schemas = []
functions = []
error_definitions = []
events = []
seeds = []
migrations = ["migrations/0001_initial.surql"]
"#;

const FILES: &[(&str, &str)] = &[(
    "migrations/0001_initial.surql",
    "DEFINE TABLE OVERWRITE essai_reprise SCHEMAFULL;",
)];

struct Essai(ModuleDescriptor);

#[async_trait]
impl LyxalModule for Essai {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.0
    }
    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

fn package() -> ModulePackage {
    let manifest = ManifestParser::parse_str(MANIFEST).expect("manifeste");
    let module = Essai(manifest.to_descriptor().expect("descripteur"));
    ModulePackage::new(manifest, Arc::new(EmbeddedResourceProvider::new(FILES)))
        .with_module_impl(Arc::new(module))
}

/// Démarrage de l'hôte : modules embarqués et module d'essai.
async fn start(config: &AppConfig, client: &Surreal<Any>) -> Result<runtime::Started, ServerError> {
    runtime::start_with(config, &client.clone().into(), vec![package()]).await
}

/// Le démarrage de l'hôte échoue sur l'installation du module d'essai.
async fn start_refused(config: &AppConfig, client: &Surreal<Any>) -> String {
    match start(config, client).await {
        Err(ServerError::ModuleInstall { module, message }) => {
            assert_eq!(module, MODULE, "{message}");
            message
        }
        Err(other) => panic!("échec d'installation attendu, obtenu {other}"),
        Ok(_) => panic!("le démarrage aurait dû échouer"),
    }
}

async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .expect("requête refusée");
}

async fn value(client: &Surreal<Any>, query: &str) -> Value {
    let mut response = client.query(query).await.expect("requête");
    let value: surrealdb::types::Value = response.take(0).expect("valeur");
    value.into_json_value()
}

async fn migration_status(client: &Surreal<Any>) -> Value {
    value(
        client,
        "RETURN (SELECT VALUE status FROM ONLY runtime_migration:['lyxal_essai', '0001_initial']);",
    )
    .await
}

fn decision(
    config: &AppConfig,
    action: MigrationResolveAction,
    reason: &str,
) -> MigrationResolveParams {
    MigrationResolveParams {
        module: MODULE.to_string(),
        migration: MIGRATION.to_string(),
        action,
        reason: reason.to_string(),
        actor: cli::cli_actor(config),
    }
}

/// La commande échoue (`SERVER_COMMAND_FAILED`) et son message commence par le code du runtime.
fn refused(result: Result<String, ServerError>, code: &str) {
    match result {
        Err(error @ ServerError::CommandFailed { .. }) => {
            assert_eq!(error.code(), "SERVER_COMMAND_FAILED");
            assert!(
                error.to_string().contains(&format!(": {code} (")),
                "{error}"
            );
        }
        Err(other) => panic!("refus {code} attendu, obtenu {other}"),
        Ok(text) => panic!("refus {code} attendu, obtenu {text}"),
    }
}

#[tokio::test]
async fn an_interrupted_migration_is_resolved_from_the_command_line_while_the_server_is_stopped() {
    let config = config_with("runtime_cli", "");
    let client = database("runtime_cli").await;
    assert_eq!(cli::cli_actor(&config), "cli:test");

    // Un nœud a commencé la migration du module puis s'est arrêté : elle reste « en cours »,
    // sans bail de migration vivant
    modules::install_foundation(&client, &lyxal_runtime::NodeId::generate())
        .await
        .expect("socle");
    run(
        &client,
        r#"fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0001_initial", module_version: "0.1.0", checksum: string::repeat("a", 64), status: "Applying", applied_at: 0, duration_ms: 0, script: "migrations/0001_initial.surql", node_id: "node-arrete" });"#,
    )
    .await;

    // --- Le serveur seul ne démarre pas ----------------------------------------------------
    let cause = start_refused(&config, &client).await;
    assert!(cause.contains("'Applying' state"), "{cause}");
    assert_eq!(migration_status(&client).await, "Applying");

    // --- Liste, serveur arrêté -------------------------------------------------------------
    let listed = cli::migrations_list(&client, None).await.expect("liste");
    assert!(
        listed.starts_with(
            "Migrations interrompues ou abandonnées : 1\n\
             - module lyxal_essai, migration 0001_initial, version 0.1.0\n  \
             script : migrations/0001_initial.surql\n  nœud : node-arrete\n  \
             état : interrompue\n  début : "
        ),
        "{listed}"
    );
    assert!(
        listed.ends_with("  dernière décision : aucune\n"),
        "{listed}"
    );
    assert_eq!(
        cli::migrations_list(&client, Some("lyxal_auth".to_string()))
            .await
            .expect("liste filtrée"),
        "Aucune migration interrompue ou abandonnée.\n"
    );

    // --- Refus : motif vide ou trop long, bail d'installation détenu par un autre nœud ------
    for reason in ["  ".to_string(), "x".repeat(1001)] {
        refused(
            cli::migrations_resolve(
                &client,
                decision(&config, MigrationResolveAction::Retry, &reason),
            )
            .await,
            "RUNTIME_INVALID_PARAMETERS",
        );
    }
    run(
        &client,
        r#"fn::runtime_lease_acquire({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "node-autre", ttl_seconds: 60 });"#,
    )
    .await;
    refused(
        cli::migrations_resolve(
            &client,
            decision(&config, MigrationResolveAction::Retry, "bail pris"),
        )
        .await,
        "RUNTIME_LEASE_FENCED",
    );
    assert_eq!(migration_status(&client).await, "Applying");
    run(
        &client,
        "UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'installation' AND key = 'lyxal_essai:0.1.0';",
    )
    .await;

    // --- Abandon : tracé, et le démarrage reste refusé --------------------------------------
    let abandoned = cli::migrations_resolve(
        &client,
        decision(
            &config,
            MigrationResolveAction::Abandon,
            "état partiel à examiner",
        ),
    )
    .await
    .expect("abandon");
    assert!(
        abandoned.contains("elle est abandonnée")
            && abandoned.contains("État précédent : Applying ; nouvel état : Abandoned.")
            && abandoned.contains("auteur cli:test"),
        "{abandoned}"
    );
    let cause = start_refused(&config, &client).await;
    assert!(cause.contains("Abandonnée par l'exploitant"), "{cause}");
    let listed = cli::migrations_list(&client, None).await.expect("liste");
    assert!(listed.contains("  état : abandonnée\n"), "{listed}");
    assert!(
        listed.contains("  dernière décision : abandon par cli:test depuis le nœud node-")
            && listed.ends_with(" — état partiel à examiner\n"),
        "{listed}"
    );
    refused(
        cli::migrations_resolve(
            &client,
            decision(&config, MigrationResolveAction::Abandon, "doublon"),
        )
        .await,
        "RUNTIME_MIGRATION_NOT_INTERRUPTED",
    );

    // --- Reprise : le serveur démarre et rejoue la migration --------------------------------
    let retried = cli::migrations_resolve(
        &client,
        decision(&config, MigrationResolveAction::Retry, "base vérifiée"),
    )
    .await
    .expect("reprise");
    assert!(
        retried.contains("elle sera rejouée au prochain démarrage du serveur")
            && retried.contains("État précédent : Abandoned ; nouvel état : RetryRequested."),
        "{retried}"
    );
    assert_eq!(
        cli::migrations_list(&client, None).await.expect("liste"),
        "Aucune migration interrompue ou abandonnée.\n"
    );
    let started = start(&config, &client).await.expect("démarrage");
    assert_eq!(migration_status(&client).await, "Applied");
    assert_eq!(
        value(
            &client,
            "RETURN (INFO FOR DB).tables.essai_reprise != NONE;"
        )
        .await,
        json!(true)
    );
    started.runtime.stop_all().await.expect("arrêt");

    // Plus rien à décider
    refused(
        cli::migrations_resolve(
            &client,
            decision(&config, MigrationResolveAction::Retry, "encore"),
        )
        .await,
        "RUNTIME_MIGRATION_NOT_INTERRUPTED",
    );

    // --- Trace au journal du runtime : les deux décisions, leur auteur et leur motif --------
    let traces = value(
        &client,
        "RETURN (SELECT VALUE payload.data FROM runtime_event_journal WHERE module_id = 'lyxal_essai' AND kind = 'migration' AND payload.data.event = 'resolved' ORDER BY sequence ASC);",
    )
    .await;
    let traces = traces.as_array().expect("traces");
    assert_eq!(traces.len(), 2, "{traces:?}");
    assert_eq!(traces[0]["action"], "abandon");
    assert_eq!(traces[0]["actor"], "cli:test");
    assert_eq!(traces[0]["reason"], "état partiel à examiner");
    assert_eq!(traces[1]["action"], "retry");
    assert_eq!(traces[1]["actor"], "cli:test");
    assert_eq!(traces[1]["reason"], "base vérifiée");
}

#[tokio::test]
async fn nothing_is_resolved_when_no_migration_is_interrupted() {
    // Base jamais démarrée : la commande installe elle-même le socle dont elle a besoin
    let config = config_with("runtime_cli_vide", "");
    let client = database("runtime_cli_vide").await;
    assert_eq!(
        cli::migrations_list(&client, None).await.expect("liste"),
        "Aucune migration interrompue ou abandonnée.\n"
    );
    refused(
        cli::migrations_resolve(
            &client,
            decision(&config, MigrationResolveAction::Retry, "rien à reprendre"),
        )
        .await,
        "RUNTIME_MIGRATION_NOT_INTERRUPTED",
    );

    // Installation démarrée et saine : rien à lister, rien à décider, et le serveur redémarre
    let started = start(&config, &client).await.expect("démarrage");
    started.runtime.stop_all().await.expect("arrêt");
    assert_eq!(migration_status(&client).await, "Applied");
    assert_eq!(
        cli::migrations_list(&client, None).await.expect("liste"),
        "Aucune migration interrompue ou abandonnée.\n"
    );
    for action in [
        MigrationResolveAction::Retry,
        MigrationResolveAction::Abandon,
    ] {
        refused(
            cli::migrations_resolve(&client, decision(&config, action, "migration appliquée"))
                .await,
            "RUNTIME_MIGRATION_NOT_INTERRUPTED",
        );
    }
    assert_eq!(migration_status(&client).await, "Applied");
    let started = start(&config, &client).await.expect("redémarrage");
    started.runtime.stop_all().await.expect("arrêt");
}
