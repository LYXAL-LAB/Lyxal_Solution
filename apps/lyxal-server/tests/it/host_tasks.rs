//! Tâches de fond de l'hôte exécutées par `lyxal_scheduler` (`modules::tasks`) : la purge de
//! `lyxal_auth`, le nettoyage de `lyxal_storage` et la maintenance de `lyxal_secrets` sont
//! déclarés et planifiés à l'installation, sans doublon au redémarrage ; une exécution déclenchée
//! fait le travail du module (moteur réel de l'hôte : planificateur et exécuteurs) ; la permission
//! propre de chaque tâche la réserve à la session système.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_scheduler::models::{
    Overlap, Run, RunRefParams, RunState, ScheduleListParams, ScheduleTriggerParams,
    SchedulerRecordId,
};
use lyxal_scheduler::SchedulerStore;
use lyxal_secrets::models::SecretCreateParams;
use lyxal_secrets::SecretsStore;
use lyxal_server::modules::tasks::{
    HostTask, AUTH_PURGE, HOST_TASKS, SECRETS_MAINTENANCE, STORAGE_CLEANUP,
};
use lyxal_server::{context::AppContext, http::build_router, modules::auth, runtime};
use lyxal_storage::models::{BucketCreateParams, ObjectBeginParams};
use lyxal_storage::StorageStore;
use lyxal_surreal::ToSql;
use serde_json::Value;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::auth_routes::crypto;
use crate::startup::{config_with, database};

async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .unwrap_or_else(|error| panic!("{query} : {error}"));
}

async fn count(client: &Surreal<Any>, query: &str) -> i64 {
    let mut response = client.query(query).await.expect("requête");
    let total: Option<i64> = response.take(0).expect("total");
    total.expect("total")
}

/// Planification de l'installation d'une tâche de fond de l'hôte.
pub(crate) async fn schedule_of(store: &SchedulerStore, task: HostTask) -> SchedulerRecordId {
    let page = store
        .schedule_list(ScheduleListParams {
            task: Some(task.task.to_string()),
            ..ScheduleListParams::default()
        })
        .await
        .expect("planifications");
    assert_eq!(page.total, 1, "{} : {:?}", task.task, page.items);
    assert_eq!(page.items[0].name, task.schedule);
    page.items[0].id.clone()
}

/// Déclenche la planification de la tâche en session système et attend la fin de l'exécution par
/// le moteur de l'hôte ; rend son résultat court.
async fn trigger(store: &SchedulerStore, task: HostTask) -> Value {
    let schedule = schedule_of(store, task).await;
    let run: Run = store
        .schedule_trigger(ScheduleTriggerParams {
            schedule,
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .unwrap_or_else(|error| panic!("déclenchement de {} : {error}", task.task));
    for _ in 0..300 {
        let current = store
            .run_get(RunRefParams {
                run: run.id.clone(),
                language: None,
            })
            .await
            .expect("exécution");
        match current.state {
            RunState::Completed => {
                return current
                    .result
                    .map(|value| value.into_json_value())
                    .unwrap_or(Value::Null)
            }
            RunState::Dead | RunState::Cancelled | RunState::Skipped => {
                panic!("{} : {:?} ({:?})", task.task, current.state, current.error)
            }
            _ => tokio::time::sleep(Duration::from_millis(100)).await,
        }
    }
    panic!("l'exécution de {} n'a pas abouti", task.task);
}

#[tokio::test]
async fn host_tasks_are_declared_and_scheduled_once() {
    let config = config_with("host_tasks_install", "");
    let client = database("host_tasks_install").await;
    let store = SchedulerStore::new(client.clone());

    let first = runtime::start(&config, &client)
        .await
        .expect("premier démarrage");
    // Handlers inscrits dans le registre du planificateur, avant le démarrage
    assert_eq!(
        first.scheduler.handlers().tasks(),
        vec!["auth.purge", "secrets.maintenance", "storage.cleanup"]
    );
    first.runtime.stop_all().await.expect("arrêt");
    drop(first);

    let declared = "RETURN count(SELECT * FROM scheduler_task
        WHERE id IN [scheduler_task:⟨auth.purge⟩, scheduler_task:⟨storage.cleanup⟩, scheduler_task:⟨secrets.maintenance⟩]
            AND executor = 'handler' AND target = record::id(id) AND scope = 'installation' AND state = 'active'
            AND queue = scheduler_queue:default AND retry.max_attempts = 3
            AND module = 'lyxal_' + string::split(record::id(id), '.')[0]
            AND permission = record::id(id) + '.run');";
    // Permission propre de chaque tâche : déclarée, attribuée à aucun rôle
    let permissions = "RETURN count(SELECT * FROM auth_permission
        WHERE code IN ['auth.purge.run', 'storage.cleanup.run', 'secrets.maintenance.run']
            AND scope = 'installation' AND module = 'lyxal_server'
            AND array::len(SELECT VALUE id FROM auth_role_grants WHERE out = $parent.id) = 0);";
    // Planifications de l'installation : rythme de chaque tâche, chevauchement `skip`
    let scheduled = "RETURN count(SELECT * FROM scheduler_schedule
        WHERE tenant IS NONE AND overlap = 'skip' AND state = 'active' AND !paused
            AND ((name = 'auth-purge' AND task = scheduler_task:⟨auth.purge⟩ AND spec.every = [15m])
              OR (name = 'storage-cleanup' AND task = scheduler_task:⟨storage.cleanup⟩ AND spec.every = [10m])
              OR (name = 'secrets-maintenance' AND task = scheduler_task:⟨secrets.maintenance⟩ AND spec.every = [10m])));";
    assert_eq!(count(&client, declared).await, 3);
    assert_eq!(count(&client, permissions).await, 3);
    assert_eq!(count(&client, scheduled).await, 3);
    let mut before = Vec::new();
    for task in HOST_TASKS {
        before.push(schedule_of(&store, task).await);
    }

    // Redémarrage sur la base installée : ni tâche ni planification en double, mêmes planifications
    let second = runtime::start(&config, &client).await.expect("redémarrage");
    second.runtime.stop_all().await.expect("arrêt");
    assert_eq!(count(&client, declared).await, 3);
    assert_eq!(count(&client, permissions).await, 3);
    assert_eq!(count(&client, scheduled).await, 3);
    let mut after = Vec::new();
    for task in HOST_TASKS {
        after.push(schedule_of(&store, task).await);
    }
    assert_eq!(before, after);
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT * FROM scheduler_schedule WHERE name IN ['auth-purge', 'storage-cleanup', 'secrets-maintenance']);"
        )
        .await,
        3
    );
}

#[tokio::test]
async fn a_triggered_host_task_does_the_work_of_its_module() {
    let folder = tempfile::tempdir().expect("dossier");
    let extra = format!(
        "[storage.disk]\nroot = {:?}\n",
        folder.path().join("fichiers").display().to_string()
    );
    let config = config_with("host_tasks_run", &extra);
    let client = database("host_tasks_run").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let store = SchedulerStore::new(client.clone());

    // lyxal_auth : une session expirée, encore marquée active
    run(
        &client,
        "CREATE auth_identity:claire CONTENT { schema: auth_identity_schema:default_v1, traits: { email: 'claire@exemple.fr' } };
         CREATE auth_session:vieille CONTENT { identity: auth_identity:claire, idle_expires_at: time::now() - 1h, expires_at: time::now() - 1s };",
    )
    .await;
    // lyxal_storage : une écriture ouverte puis abandonnée, délai dépassé
    let storage = StorageStore::new(client.clone());
    let bucket = storage
        .bucket_create(BucketCreateParams::named(None, "plans"))
        .await
        .expect("bucket")
        .id
        .to_sql();
    storage
        .object_begin(ObjectBeginParams {
            bucket,
            key: "abandon.bin".to_string(),
            filename: "abandon.bin".to_string(),
            declared_type: None,
            declared_size: None,
            resumable: false,
        })
        .await
        .expect("ouverture d'écriture");
    run(
        &client,
        "UPDATE storage_object SET pending_expires_at = time::now() - 1m WHERE state = 'pending';",
    )
    .await;
    // lyxal_secrets : un secret supprimé dont la date de purge est passée
    let secret = SecretsStore::new(client.clone())
        .secret_create(SecretCreateParams::new(None, "api/ancien", "api_key"))
        .await
        .expect("fiche")
        .id
        .to_sql();
    run(
        &client,
        &format!(
            "LET $deleted = fn::secrets_secret_delete({{ secret: '{secret}' }}); IF !$deleted.ok {{ THROW $deleted.error.code; }};
             UPDATE {secret} SET purge_at = time::now() - 1m;"
        ),
    )
    .await;
    assert_eq!(
        count(&client, "RETURN count(SELECT * FROM storage_object);").await,
        1
    );
    assert_eq!(
        count(&client, "RETURN count(SELECT * FROM secrets_secret);").await,
        1
    );

    // Purge : la session expirée est marquée
    let purge = trigger(&store, AUTH_PURGE).await;
    assert_eq!(purge["sessions_expired"], 1, "{purge}");
    assert!(purge.get("interrupted").is_none(), "{purge}");
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT * FROM auth_session:vieille WHERE state = 'expired');"
        )
        .await,
        1
    );

    // Nettoyage : l'écriture abandonnée est retirée
    let cleanup = trigger(&store, STORAGE_CLEANUP).await;
    assert_eq!(cleanup["expired"], 1, "{cleanup}");
    assert_eq!(cleanup["failed"], 0, "{cleanup}");
    assert_eq!(
        count(&client, "RETURN count(SELECT * FROM storage_object);").await,
        0
    );

    // Maintenance : le secret échu est purgé (sans clé maîtresse, la purge a lieu quand même)
    let maintenance = trigger(&store, SECRETS_MAINTENANCE).await;
    assert_eq!(maintenance["purged"], 1, "{maintenance}");
    assert_eq!(maintenance["failed"], 0, "{maintenance}");
    assert_eq!(
        count(&client, "RETURN count(SELECT * FROM secrets_secret);").await,
        0
    );

    started.runtime.stop_all().await.expect("arrêt");
}

/// Sans support de fichiers sur le nœud, le nettoyage se termine sans rien faire.
#[tokio::test]
async fn the_storage_cleanup_does_nothing_without_a_backend() {
    let config = config_with("host_tasks_no_backend", "");
    let client = database("host_tasks_no_backend").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let cleanup = trigger(&SchedulerStore::new(client.clone()), STORAGE_CLEANUP).await;
    assert_eq!(cleanup, serde_json::json!({ "skipped": "no_backend" }));
    started.runtime.stop_all().await.expect("arrêt");
}

async fn post(router: &axum::Router, uri: &str, token: &str) -> (StatusCode, Value) {
    let request = Request::builder()
        .method("POST")
        .uri(uri)
        .header("authorization", format!("Bearer {token}"))
        .header("content-type", "application/json")
        .body(Body::from("{}"))
        .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps");
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

/// Un administrateur de la plateforme gère les planifications de l'installation, mais ne fait
/// exécuter aucune tâche de fond de l'hôte : leur permission propre n'est attribuée à aucun rôle.
#[tokio::test]
async fn a_caller_without_the_task_permission_cannot_run_a_host_task() {
    let config = Arc::new(config_with(
        "host_tasks_rights",
        "[auth]\npublic_url = \"https://lyxal.test/\"\n",
    ));
    let client = database("host_tasks_rights").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let router = build_router(
        AppContext::new(
            config.clone(),
            Arc::new(client.clone()),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            Some(host.clone()),
            Default::default(),
        )
        .with_scheduler(started.scheduler.clone()),
    )
    .expect("routeur");
    run(
        &client,
        r#"CREATE auth_application:plateforme CONTENT { client_id: "lyxal-test-plateforme", name: "Plateforme", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
           RELATE auth_application:plateforme->auth_has_role->auth_role:platform_admin SET granted_at = time::now();"#,
    )
    .await;
    let token = host
        .access
        .internal_service_token("lyxal-test-plateforme")
        .await
        .expect("jeton")
        .access_token
        .expose_secret()
        .to_string();
    let store = SchedulerStore::new(client.clone());

    for task in HOST_TASKS {
        let schedule = schedule_of(&store, task).await;
        let key = schedule.to_sql();
        let key = key.trim_start_matches("scheduler_schedule:");
        // Déclenchement refusé : permission propre de la tâche
        let (status, body) = post(
            &router,
            &format!("/api/v1/scheduler/schedules/{key}/trigger"),
            &token,
        )
        .await;
        assert_eq!(status, StatusCode::FORBIDDEN, "{} : {body}", task.task);
        assert_eq!(
            body["error"]["code"], "SCHEDULER_PERMISSION_DENIED",
            "{} : {body}",
            task.task
        );
        // Le droit d'installation suffit pour ce qui arrête la tâche : mise en pause acceptée
        let (status, body) = post(
            &router,
            &format!("/api/v1/scheduler/schedules/{key}/pause"),
            &token,
        )
        .await;
        assert_eq!(status, StatusCode::OK, "{} : {body}", task.task);
        // Reprise refusée : elle ferait de nouveau exécuter la tâche
        let (status, body) = post(
            &router,
            &format!("/api/v1/scheduler/schedules/{key}/resume"),
            &token,
        )
        .await;
        assert_eq!(status, StatusCode::FORBIDDEN, "{} : {body}", task.task);
    }
    // Aucun déclenchement refusé n'a créé d'exécution (une échéance normale du planificateur,
    // d'origine `schedule`, peut tomber pendant l'essai : elle n'est pas comptée)
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT * FROM scheduler_run WHERE origin != 'schedule');"
        )
        .await,
        0
    );
    started.runtime.stop_all().await.expect("arrêt");
}
