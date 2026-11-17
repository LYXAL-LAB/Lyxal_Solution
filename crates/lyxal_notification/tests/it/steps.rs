//! Parcours à étapes de bout en bout, avec le vrai moteur de `lyxal_scheduler` (planificateur
//! élu et exécuteur de la file `default`), le worker d'étapes et le worker d'envoi, conduits
//! comme par le runtime (annulation coopérative) sur la base embarquée et un serveur SMTP de
//! test : attente réellement reprise par le planificateur, regroupement de trois déclenchements
//! en un e-mail, annulation pendant une attente ; planification de la purge créée une seule
//! fois ; aperçu d'une étape.

use lyxal_notification::models::{
    CancelParams, DigestVars, StepPreviewParams, SubscriberInput, TriggerParams, TriggerTarget,
};
use lyxal_notification::{
    ensure_purge_schedule, EmailWorkerSettings, NotificationEmailWorker, NotificationModule,
    NotificationPreview, NotificationStepWorker, NotificationStore, SecretCodec,
    StepWorkerSettings, PURGE_SCHEDULE,
};
use lyxal_runtime::lock::{NodeId, SurrealLeaderLeaseManager};
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext};
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use lyxal_scheduler::{
    ExecutorTiming, HandlerRegistry, LeaderTiming, SchedulerClient, SchedulerEngine,
    SchedulerExecutorWorker, SchedulerLeaderWorker, SchedulerStore,
};
use lyxal_surreal::{RecordId, SurrealValue};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::task::JoinHandle;

use crate::flow::decoded;
use crate::smtp_server::TestSmtpServer;
use crate::support::{crypto, dispatcher, installed_client, smtp_relay, vault};

/// Worker conduit comme par le runtime : son jeton d'annulation et sa tâche.
struct Running {
    token: CancellationToken,
    handle: JoinHandle<Result<(), RuntimeError>>,
}

fn start(worker: Arc<dyn LyxalWorker>) -> Running {
    let descriptor = worker.descriptor().clone();
    let token = CancellationToken::new();
    let context = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new(descriptor.module_id.clone()),
        token.clone(),
    );
    Running {
        token,
        handle: tokio::spawn(async move { worker.run(context).await }),
    }
}

/// Planificateur, exécuteur, worker d'étapes et worker d'envoi, à rythmes réduits.
struct Engine {
    workers: Vec<Running>,
}

impl Engine {
    async fn start(client: &Surreal<Any>, server: &TestSmtpServer) -> Self {
        let engine = SchedulerEngine::new(
            SchedulerStore::new(client.clone()),
            HandlerRegistry::new(),
            NodeId::new("noeud-essai"),
        );
        let leader = SchedulerLeaderWorker::with_timing(
            engine.clone(),
            SurrealLeaderLeaseManager::new(client.clone()),
            LeaderTiming {
                tick: Duration::from_millis(100),
                lease_ttl: Duration::from_secs(2),
                lease_renew: Duration::from_millis(300),
                rescue_every: Duration::from_millis(500),
                prune_every: Duration::from_secs(3600),
            },
        )
        .expect("planificateur");
        let executor = SchedulerExecutorWorker::with_timing(
            engine,
            "default",
            4,
            ExecutorTiming {
                poll: Duration::from_millis(50),
                max_heartbeat: Duration::from_millis(300),
                shutdown_grace: Duration::from_millis(500),
                cancel_grace: Duration::from_millis(200),
            },
        )
        .expect("exécuteur");
        let store = NotificationStore::new(client.clone());
        let steps = NotificationStepWorker::new(
            store.clone(),
            StepWorkerSettings {
                busy_interval: Duration::from_millis(100),
                idle_interval: Duration::from_millis(100),
                batch_size: 100,
            },
        )
        .expect("worker d'étapes");
        let vault = vault(client);
        smtp_relay(client, &vault, server.port).await;
        let email = NotificationEmailWorker::new(
            store,
            SecretCodec::new(crypto()),
            dispatcher(&vault, None),
            EmailWorkerSettings {
                poll_interval: Duration::from_millis(100),
                ..EmailWorkerSettings::default()
            },
        )
        .expect("worker d'envoi");
        Self {
            workers: vec![
                start(Arc::new(leader)),
                start(Arc::new(executor)),
                start(Arc::new(steps)),
                start(Arc::new(email)),
            ],
        }
    }

    async fn stop(self) {
        for worker in self.workers {
            worker.token.cancel();
            tokio::time::timeout(Duration::from_secs(10), worker.handle)
                .await
                .expect("arrêt du worker dans le délai")
                .expect("tâche du worker")
                .expect("worker");
        }
    }
}

async fn setup(client: &Surreal<Any>, sql: &str) {
    client
        .query(sql)
        .await
        .and_then(|r| r.check())
        .unwrap_or_else(|e| panic!("préparation : {e}"));
}

async fn value<T: SurrealValue>(client: &Surreal<Any>, sql: &str) -> T {
    client
        .query(sql)
        .await
        .and_then(|mut r| r.take::<Option<T>>(0))
        .unwrap_or_else(|e| panic!("{sql} : {e}"))
        .unwrap_or_else(|| panic!("{sql} : aucune valeur"))
}

fn trigger(workflow: &str, key: &str, email: &str) -> TriggerParams {
    TriggerParams {
        tenant: None,
        workflow_key: Some(workflow.to_string()),
        trigger_event: None,
        idempotency_key: key.to_string(),
        event_id: None,
        to: TriggerTarget::Subscriber(SubscriberInput {
            email: Some(email.to_string()),
            ..SubscriberInput::id(format!("email:{email}"))
        }),
        actor: None,
        exclude_actor: None,
        overrides: None,
        payload: serde_json::json!({ "projet": "Tour B" }),
        secret: None,
        expires_at: None,
    }
}

/// Attend `count` messages reçus par le serveur SMTP de test.
async fn wait_messages(server: &TestSmtpServer, count: usize, within: Duration) {
    let deadline = tokio::time::Instant::now() + within;
    while server.received().len() < count {
        assert!(
            tokio::time::Instant::now() < deadline,
            "{count} messages attendus, {} reçus",
            server.received().len()
        );
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
}

/// Attend que la requête `sql` (un texte, `''` si absent) rende `expected`.
async fn wait_value(client: &Surreal<Any>, sql: &str, expected: &str, within: Duration) {
    let deadline = tokio::time::Instant::now() + within;
    loop {
        let current: String = value(client, sql).await;
        if current == expected {
            return;
        }
        assert!(
            tokio::time::Instant::now() < deadline,
            "{expected} attendu, encore {current} : {sql}"
        );
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
}

/// Attend l'état `status` du déclenchement de clé `key`.
async fn wait_run(client: &Surreal<Any>, key: &str, status: &str, within: Duration) {
    let sql = format!("RETURN (SELECT VALUE status FROM ONLY notification_run WHERE idempotency_key = '{key}' LIMIT 1) ?? '';");
    wait_value(client, &sql, status, within).await;
}

/// Appel rejoué après un conflit d'écriture passager de SurrealDB (les workers écrivent en même
/// temps les mêmes tables), comme le fait le consommateur d'événements par sa redistribution.
async fn retried<T, F, Fut>(call: F) -> T
where
    F: Fn() -> Fut,
    Fut: std::future::Future<Output = Result<T, lyxal_surreal::LyxalSurrealError>>,
{
    for _ in 0..20 {
        match call().await {
            Ok(value) => return value,
            Err(error) if error.is_transient_conflict() => {
                tokio::time::sleep(Duration::from_millis(20)).await;
            }
            Err(error) => panic!("appel : {error}"),
        }
    }
    panic!("appel : conflits répétés");
}

async fn trigger_now(store: &NotificationStore, params: TriggerParams) {
    retried(|| store.trigger(params.clone())).await;
}

/// Reprise d'une attente ou d'un regroupement par l'appel que fait le planificateur à son
/// échéance (exécuteur `function`, session système) : les tests de regroupement et
/// d'annulation attendent une heure, pour qu'aucune fenêtre ne se ferme d'elle-même sur une
/// machine lente ; la reprise réelle par le moteur est prouvée par le test du délai.
async fn resume_now(client: &Surreal<Any>, key: &str, step: &str) -> String {
    let sql = format!(
        "LET $run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = '{key}' LIMIT 1); \
         RETURN fn::notification_run_resume({{ args: {{ run: <string> $run, step_key: '{step}' }} }}).data.status;"
    );
    for _ in 0..20 {
        match client
            .query(sql.as_str())
            .await
            .and_then(|mut r| r.take::<Option<String>>(1))
        {
            Ok(Some(status)) => return status,
            Ok(None) => panic!("reprise sans résultat : {sql}"),
            Err(_) => tokio::time::sleep(Duration::from_millis(50)).await,
        }
    }
    panic!("reprise impossible : {sql}");
}

const PAUSE_JOB: &str = "RETURN (SELECT VALUE status FROM ONLY notification_job WHERE step_key = 'pause' LIMIT 1) ?? '';";
const RESUME_RUN: &str = "RETURN (SELECT VALUE state FROM ONLY scheduler_run WHERE task = scheduler_task:⟨notification.run_resume⟩ LIMIT 1) ?? '';";

#[tokio::test]
async fn a_delay_is_really_resumed_by_the_scheduler_engine() {
    let client = installed_client().await;
    setup(
        &client,
        r#"
        CREATE notification_workflow:suite CONTENT { scope_key: "installation", key: "suite", name: "Suite", status: "active", steps: [
            { key: "premier", type: "email" },
            { key: "pause", type: "delay", amount: 10, unit: "seconds" },
            { key: "rappel", type: "email" }
        ] };
        CREATE notification_template CONTENT { workflow: notification_workflow:suite, step_key: "premier", subject: "Premier", html_body: "<p>1</p>", text_body: "1" };
        CREATE notification_template CONTENT { workflow: notification_workflow:suite, step_key: "rappel", subject: "Rappel", html_body: "<p>2</p>", text_body: "2" };
        "#,
    )
    .await;
    let server = TestSmtpServer::start().await;
    let engine = Engine::start(&client, &server).await;
    let store = NotificationStore::new(client.clone());
    trigger_now(&store, trigger("suite", "suite-1", "claire@exemple.fr")).await;
    wait_messages(&server, 1, Duration::from_secs(10)).await;
    // L'attente est confiée au planificateur : exécution différée de notification.run_resume
    wait_run(&client, "suite-1", "waiting", Duration::from_secs(5)).await;
    wait_value(&client, PAUSE_JOB, "waiting", Duration::from_secs(20)).await;
    let delayed: String = value(
        &client,
        "RETURN (SELECT VALUE scheduler_run FROM ONLY notification_job WHERE step_key = 'pause' LIMIT 1) ?? '';",
    )
    .await;
    assert!(delayed.starts_with("scheduler_run:"), "{delayed}");
    assert_eq!(server.received().len(), 1, "rien avant la fin de l'attente");
    wait_messages(&server, 2, Duration::from_secs(40)).await;
    wait_run(&client, "suite-1", "completed", Duration::from_secs(5)).await;
    let subjects: Vec<String> = server
        .received()
        .iter()
        .map(|message| decoded(&message.data))
        .collect();
    assert!(subjects[0].contains("Subject: Premier"), "{}", subjects[0]);
    assert!(subjects[1].contains("Subject: Rappel"), "{}", subjects[1]);
    wait_value(&client, RESUME_RUN, "completed", Duration::from_secs(5)).await;
    engine.stop().await;
}

#[tokio::test]
async fn three_triggers_are_digested_into_one_email() {
    let client = installed_client().await;
    setup(
        &client,
        r#"
        CREATE notification_workflow:lot CONTENT { scope_key: "installation", key: "lot", name: "Lot", status: "active", steps: [
            { key: "lot", type: "digest", window: { amount: 1, unit: "hours" }, group_by: "payload.projet" },
            { key: "email", type: "email" }
        ] };
        CREATE notification_template CONTENT { workflow: notification_workflow:lot, step_key: "email",
            subject: "{{ digest.count }} events for {{ payload.projet }}",
            html_body: "<ul>{% for e in digest.events %}<li>{{ e.payload.n }}</li>{% endfor %}</ul>",
            text_body: "{% for e in digest.events %}event {{ e.payload.n }}\n{% endfor %}" };
        "#,
    )
    .await;
    let server = TestSmtpServer::start().await;
    let engine = Engine::start(&client, &server).await;
    let store = NotificationStore::new(client.clone());
    for n in 1..=3 {
        let mut params = trigger("lot", &format!("lot-{n}"), "claire@exemple.fr");
        params.payload = serde_json::json!({ "projet": "Tour B", "n": n });
        trigger_now(&store, params).await;
    }
    wait_run(&client, "lot-3", "merged", Duration::from_secs(20)).await;
    assert!(
        server.received().is_empty(),
        "rien avant la fin de la fenêtre"
    );
    assert_eq!(resume_now(&client, "lot-1", "lot").await, "resumed");
    wait_messages(&server, 1, Duration::from_secs(30)).await;
    wait_run(&client, "lot-1", "completed", Duration::from_secs(5)).await;
    // Aucun autre message après la fin de la fenêtre
    tokio::time::sleep(Duration::from_secs(1)).await;
    let received = server.received();
    assert_eq!(received.len(), 1);
    let body = decoded(&received[0].data);
    assert!(body.contains("Subject: 3 events for Tour B"), "{body}");
    assert!(
        body.contains("event 1") && body.contains("event 2") && body.contains("event 3"),
        "{body}"
    );
    let merged: i64 = value(
        &client,
        "RETURN count(SELECT id FROM notification_run WHERE status = 'merged');",
    )
    .await;
    assert_eq!(merged, 2);
    engine.stop().await;
}

#[tokio::test]
async fn a_run_canceled_during_its_wait_sends_nothing() {
    let client = installed_client().await;
    setup(
        &client,
        r#"
        CREATE notification_workflow:rappel CONTENT { scope_key: "installation", key: "rappel", name: "Rappel", status: "active", steps: [
            { key: "pause", type: "delay", amount: 1, unit: "hours" },
            { key: "email", type: "email" }
        ] };
        CREATE notification_template CONTENT { workflow: notification_workflow:rappel, step_key: "email", subject: "Rappel", html_body: "<p>R</p>", text_body: "R" };
        "#,
    )
    .await;
    let server = TestSmtpServer::start().await;
    let engine = Engine::start(&client, &server).await;
    let store = NotificationStore::new(client.clone());
    trigger_now(&store, trigger("rappel", "rappel-1", "claire@exemple.fr")).await;
    // Attente confiée au planificateur, puis annulée
    wait_value(&client, PAUSE_JOB, "waiting", Duration::from_secs(20)).await;
    let canceled = retried(|| {
        store.cancel(CancelParams {
            tenant: None,
            idempotency_key: "rappel-1".to_string(),
        })
    })
    .await;
    assert_eq!(canceled.canceled, 1);
    // La reprise à l'échéance ne fait rien
    assert_eq!(resume_now(&client, "rappel-1", "pause").await, "ignored");
    tokio::time::sleep(Duration::from_millis(500)).await;
    assert!(
        server.received().is_empty(),
        "aucun e-mail après l'annulation"
    );
    wait_run(&client, "rappel-1", "canceled", Duration::from_secs(1)).await;
    engine.stop().await;
}

#[tokio::test]
async fn the_purge_schedule_is_created_once_at_install() {
    let client = installed_client().await;
    let module = NotificationModule::new(client.clone());
    let context = ModuleContext::new(module.descriptor().id.clone());
    module.install(&context).await.expect("installation");
    module
        .install(&context)
        .await
        .expect("installation rejouée");
    let scheduler = SchedulerClient::new(SchedulerStore::new(client.clone()));
    assert!(!ensure_purge_schedule(&scheduler)
        .await
        .expect("planification"));
    let schedules: Vec<serde_json::Value> = client
        .query("SELECT name, record::id(task) AS task, spec.cron AS cron, overlap FROM scheduler_schedule")
        .await
        .and_then(|mut r| r.take(0))
        .expect("planifications");
    assert_eq!(
        schedules,
        vec![
            serde_json::json!({ "name": PURGE_SCHEDULE, "task": "notification.purge", "cron": ["0 * * * *"], "overlap": "skip" })
        ]
    );
}

#[tokio::test]
async fn the_purge_runs_through_the_scheduler_function_executor() {
    let client = installed_client().await;
    setup(
        &client,
        "CREATE notification_delivery_log CONTENT { run: notification_run:ancien, job: notification_job:ancien, attempt: 1, status: 'sent', purge_after: time::now() - 1s };",
    )
    .await;
    let scheduler = SchedulerStore::new(client.clone());
    let run = scheduler
        .run_enqueue(lyxal_scheduler::models::RunEnqueueParams::new(
            "notification.purge",
        ))
        .await
        .expect("exécution immédiate");
    let server = TestSmtpServer::start().await;
    let engine = Engine::start(&client, &server).await;
    let deadline = tokio::time::Instant::now() + Duration::from_secs(10);
    let id: RecordId = run.id;
    loop {
        let state: String = client
            .query("RETURN (SELECT VALUE state FROM ONLY $run) ?? '';")
            .bind(("run", id.clone()))
            .await
            .and_then(|mut r| r.take::<Option<String>>(0))
            .expect("état")
            .unwrap_or_default();
        if state == "completed" {
            break;
        }
        assert!(
            tokio::time::Instant::now() < deadline,
            "purge encore {state}"
        );
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
    let left: i64 = value(
        &client,
        "RETURN count(SELECT id FROM notification_delivery_log);",
    )
    .await;
    assert_eq!(left, 0);
    engine.stop().await;
}

#[tokio::test]
async fn a_step_is_previewed_with_sample_data_and_no_secret() {
    let client = installed_client().await;
    setup(
        &client,
        r#"
        CREATE notification_workflow:apercu CONTENT { scope_key: "installation", key: "apercu", name: "Aperçu", status: "draft", steps: [{ key: "email", type: "email" }] };
        CREATE notification_template CONTENT { workflow: notification_workflow:apercu, step_key: "email",
            subject: "{{ t(\"notification.common.greeting\") }} {{ payload.projet }}",
            html_body: "<p>{{ payload.projet }} {{ secret.code }}{% if digest %} ({{ digest.count }}){% endif %}</p>",
            text_body: "{{ payload.projet }}",
            keys: ["notification.common.greeting"] };
        "#,
    )
    .await;
    let runs_before: i64 = value(&client, "RETURN count(SELECT id FROM notification_run);").await;
    let preview = NotificationPreview::new(NotificationStore::new(client.clone()));
    let rendered = preview
        .render(StepPreviewParams {
            workflow: "notification_workflow:apercu".to_string(),
            step_key: "email".to_string(),
            payload: serde_json::json!({ "projet": "<Tour B>" }),
            locale: Some("en-GB".to_string()),
            digest: Some(DigestVars {
                count: 3,
                events: serde_json::json!([]),
            }),
        })
        .await
        .expect("aperçu");
    assert_eq!(rendered.subject, "Hello, <Tour B>");
    // Échappement HTML ; secret absent affiché vide
    assert_eq!(rendered.html, "<p>&lt;Tour B&gt;  (3)</p>");
    assert_eq!(rendered.text, "<Tour B>");
    let runs_after: i64 = value(&client, "RETURN count(SELECT id FROM notification_run);").await;
    assert_eq!(runs_before, runs_after, "aucune écriture");
    let refused = preview
        .render(StepPreviewParams {
            workflow: "notification_workflow:apercu".to_string(),
            step_key: "inconnue".to_string(),
            payload: serde_json::json!({}),
            locale: None,
            digest: None,
        })
        .await
        .expect_err("étape inconnue");
    assert_eq!(refused.code(), "NOTIFICATION_NOT_FOUND");
}
