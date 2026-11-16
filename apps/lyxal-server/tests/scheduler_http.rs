//! Routes `/api/v1/scheduler/*` de bout en bout sur l'hôte (base embarquée, runtime démarré,
//! moteur du planificateur actif) : réglages, tâches, files, calendrier, planification contrôlée
//! (règle fausse refusée avec la règle en cause), contrôle d'une règle, prévision, pause, reprise,
//! déclenchement immédiat, rejeu d'une période (exécutions à identifiant composé lues par leur
//! forme texte), exécution différée exécutée par le moteur de l'hôte (handler d'essai), annulée
//! puis relancée ; droits (sans jeton, sans permission, permission propre de la tâche, autre
//! organisation) ; `no-store` sur chaque réponse ; aucune route du moteur.

use async_trait::async_trait;
use axum::body::{to_bytes, Body};
use axum::http::{HeaderMap, Request, StatusCode};
use base64::engine::general_purpose::{STANDARD, URL_SAFE_NO_PAD};
use base64::Engine;
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_scheduler::{RunContext, TaskFailure, TaskHandler, TaskOutput};
use lyxal_server::{
    config::AppConfig, context::AppContext, health::HealthRegistry, http::build_router,
    metrics::Metrics, modules::auth, runtime,
};
use serde_json::{json, Value};
use std::fs;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;

/// Clé éphémère : 32 octets aléatoires, Base64 canonique (jamais une vraie clé).
fn ephemeral_key() -> String {
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    STANDARD.encode(&bytes)
}

/// Trousseau applicatif éphémère du service de connexion.
fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("server-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))))
}

fn config() -> AppConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    fs::write(
        directory.path().join("default.toml"),
        r#"
[application]
name = "Lyxal Test"
environment = "test"
instance_id = "test"
version = "0.1.0"

[server]
host = "127.0.0.1"
port = 0
request_timeout_seconds = 30
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "planificateur_http"
connect_timeout_seconds = 5

[runtime]
module_install_timeout_seconds = 60
module_start_timeout_seconds = 10
module_stop_timeout_seconds = 10

[observability]
log_filter = "info"
json_logs = false
include_target = false
include_thread_ids = false

[cors]
enabled = false
allow_credentials = false
allowed_origins = []
allowed_methods = []
allowed_headers = []

[auth]
public_url = "https://lyxal.test/"

[secrets]
master_key_id = "vault-test"
"#,
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

struct Reply {
    status: StatusCode,
    headers: HeaderMap,
    body: String,
}

impl Reply {
    fn json(&self) -> Value {
        serde_json::from_str(&self.body).unwrap_or(Value::Null)
    }

    fn data(&self) -> Value {
        self.json()["data"].clone()
    }

    fn code(&self) -> String {
        self.json()["error"]["code"]
            .as_str()
            .unwrap_or_default()
            .to_string()
    }

    fn header(&self, name: &str) -> &str {
        self.headers
            .get(name)
            .and_then(|value| value.to_str().ok())
            .unwrap_or_default()
    }
}

/// Requête sur une route du planificateur ; chaque réponse d'une route existante doit porter
/// `Cache-Control: no-store` (X4).
async fn send(
    router: &axum::Router,
    method: &str,
    path: &str,
    token: Option<&str>,
    body: Option<Value>,
) -> Reply {
    let reply = raw(router, method, path, token, body.map(|b| b.to_string())).await;
    assert_eq!(
        reply.header("cache-control"),
        "no-store",
        "{method} {path} : {}",
        reply.body
    );
    assert_eq!(reply.header("pragma"), "no-cache", "{method} {path}");
    reply
}

async fn raw(
    router: &axum::Router,
    method: &str,
    path: &str,
    token: Option<&str>,
    body: Option<String>,
) -> Reply {
    let mut request = Request::builder()
        .method(method)
        .uri(format!("/api/v1/scheduler{path}"))
        .header("content-type", "application/json");
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let body = body.map_or_else(Body::empty, Body::from);
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(body).expect("requête"))
        .await
        .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    Reply {
        status,
        headers,
        body: String::from_utf8_lossy(&bytes).to_string(),
    }
}

/// Lit une exécution par sa forme texte jusqu'à ce qu'elle atteigne l'état `state` (moteur de
/// l'hôte : planificateur et exécuteurs réels).
async fn wait_state(router: &axum::Router, token: &str, run: &str, state: &str) -> Value {
    for _ in 0..150 {
        let reply = send(router, "GET", &format!("/runs/{run}"), Some(token), None).await;
        assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
        if reply.data()["state"] == state {
            return reply.data();
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    panic!("l'exécution {run} n'a pas atteint l'état {state}");
}

/// Handler de la tâche d'essai, inscrit par le test dans le registre de l'hôte : rend le format
/// demandé et compte ses appels.
struct ReportHandler {
    calls: Arc<AtomicUsize>,
}

#[async_trait]
impl TaskHandler for ReportHandler {
    fn task(&self) -> &str {
        "essai.rapport"
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        self.calls.fetch_add(1, Ordering::SeqCst);
        let mut result = surrealdb::types::Object::new();
        let format = match &ctx.args {
            surrealdb::types::Value::Object(args) => args.get("format").cloned(),
            _ => None,
        };
        result.insert("format", format.unwrap_or_default());
        Ok(TaskOutput::with_result(surrealdb::types::Value::Object(
            result,
        )))
    }
}

/// Forme texte (X1) d'un identifiant SurrealQL.
fn run_ref(sql: &str) -> String {
    URL_SAFE_NO_PAD.encode(sql)
}

#[tokio::test]
async fn the_scheduler_is_used_through_http_on_behalf_of_the_caller() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("planificateur_http")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let calls = Arc::new(AtomicUsize::new(0));
    started
        .scheduler
        .handlers()
        .register(Arc::new(ReportHandler {
            calls: calls.clone(),
        }))
        .expect("handler d'essai");
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

    // Organisations ; tâche d'essai (seed d'un module fictif) avec sa permission propre ; comptes
    // de service : administrateur d'alpha avec la permission de la tâche, administrateur d'alpha
    // sans elle, membre d'alpha sans permission, administrateur de beta
    client
        .query(
            r#"
            fn::runtime_module_upsert({ module_id: "lyxal_essai", name: "Essai" });
            fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.1.0", manifest_version: 1, status: "Installed" });
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_permission:⟨essai.rapport.run⟩ CONTENT { code: "essai.rapport.run", module: "lyxal_essai", scope: "organization", description: { fr: "Lancer le rapport", en: "Run the report" } };
            CREATE auth_role:essai_rapport CONTENT { scope_key: "installation", key: "essai_rapport", name: "Rapport", scope: "organization", system: true };
            RELATE auth_role:essai_rapport->auth_role_grants->auth_permission:⟨essai.rapport.run⟩;
            CREATE scheduler_task:⟨essai.rapport⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.rapport", permission: "essai.rapport.run",
                description: { fr: "Rapport", en: "Report" },
                args_schema: { fields: { format: { pipeline: [{ rule: "enum", options: { allowed: ["pdf", "csv"], case_sensitive: true } }], required: true } }, unknown_keys: "reject" },
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }, timeout: 1m
            };
            CREATE scheduler_task:⟨essai.unique⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.unique", unique_for: 1h,
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }, timeout: 1m
            };
            CREATE auth_application:admin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-planif-admin", name: "Admin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:admin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            RELATE auth_application:admin->auth_has_role->auth_role:essai_rapport SET granted_at = time::now();
            CREATE auth_application:sanstache CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-planif-sanstache", name: "Sans tâche", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:sanstache->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:membre CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-planif-membre", name: "Membre", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "lyxal-test-planif-voisin", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            RELATE auth_application:voisin->auth_has_role->auth_role:essai_rapport SET granted_at = time::now();
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    let token = |client_id: &'static str| {
        let host = host.clone();
        async move {
            host.access
                .internal_service_token(client_id)
                .await
                .expect("jeton")
                .access_token
                .expose_secret()
                .to_string()
        }
    };
    let admin = token("lyxal-test-planif-admin").await;
    let without_task = token("lyxal-test-planif-sanstache").await;
    let member = token("lyxal-test-planif-membre").await;
    let neighbour = token("lyxal-test-planif-voisin").await;
    let admin_token = admin;
    let admin = Some(admin_token.as_str());
    const ALPHA: &str = "auth_organization:alpha";

    // --- Sans jeton : refusé --------------------------------------------------------------
    let anonymous = send(&router, "GET", "/tasks", None, None).await;
    assert!(!anonymous.status.is_success(), "{}", anonymous.body);
    assert_eq!(
        anonymous.code(),
        "AUTH_SESSION_REQUIRED",
        "{}",
        anonymous.body
    );

    // --- Réglages, tâches, files -----------------------------------------------------------
    let settings = send(
        &router,
        "PUT",
        "/settings",
        admin,
        Some(json!({ "tenant": ALPHA, "catchup_window": "2h" })),
    )
    .await;
    assert_eq!(settings.status, StatusCode::OK, "{}", settings.body);
    let settings = send(
        &router,
        "GET",
        &format!("/settings?tenant={ALPHA}"),
        admin,
        None,
    )
    .await;
    assert_eq!(settings.status, StatusCode::OK, "{}", settings.body);
    assert_eq!(settings.data()["effective"]["catchup_window"], "2h");

    let tasks = send(&router, "GET", "/tasks?module=lyxal_essai", admin, None).await;
    assert_eq!(tasks.status, StatusCode::OK, "{}", tasks.body);
    assert_eq!(tasks.data()["total"], 2);
    let task = send(&router, "GET", "/tasks/essai.rapport", admin, None).await;
    assert_eq!(task.status, StatusCode::OK, "{}", task.body);
    assert_eq!(task.data()["permission"], "essai.rapport.run");
    let queues = send(&router, "GET", "/queues", admin, None).await;
    assert_eq!(queues.status, StatusCode::OK, "{}", queues.body);
    assert!(queues.data().as_array().is_some_and(|q| q.len() >= 2));
    // Pause d'une file : droit d'installation, refusé à l'administrateur d'une organisation
    let paused = send(
        &router,
        "POST",
        "/queues/default/pause",
        admin,
        Some(json!({ "reason": "essai" })),
    )
    .await;
    assert_eq!(paused.status, StatusCode::FORBIDDEN, "{}", paused.body);
    assert_eq!(paused.code(), "SCHEDULER_PERMISSION_DENIED");
    let resumed = send(&router, "POST", "/queues/default/resume", admin, None).await;
    assert_eq!(
        resumed.code(),
        "SCHEDULER_PERMISSION_DENIED",
        "{}",
        resumed.body
    );

    // --- Calendrier ------------------------------------------------------------------------
    let calendar = send(
        &router,
        "POST",
        "/calendars",
        admin,
        Some(json!({
            "tenant": ALPHA,
            "name": "feries",
            "rules": [{ "mode": "exclude", "kind": "dates", "values": ["2026-12-25"] }],
        })),
    )
    .await;
    assert_eq!(calendar.status, StatusCode::CREATED, "{}", calendar.body);
    let calendar_id = calendar.data()["id"]
        .as_str()
        .expect("calendrier")
        .to_string();
    let updated = send(
        &router,
        "PATCH",
        &format!("/calendars/{calendar_id}"),
        admin,
        Some(json!({ "description": "Jours fériés" })),
    )
    .await;
    assert_eq!(updated.status, StatusCode::OK, "{}", updated.body);
    assert_eq!(updated.data()["description"], "Jours fériés");
    let listed = send(
        &router,
        "GET",
        &format!("/calendars?tenant={ALPHA}"),
        admin,
        None,
    )
    .await;
    assert_eq!(listed.data()["total"], 1, "{}", listed.body);

    // --- Contrôle d'une règle sans écriture ------------------------------------------------
    let wrong_spec = json!({ "cron": ["61 * * * *"], "timezone": "Europe/Paris" });
    let checked = send(
        &router,
        "POST",
        "/specs/validate",
        admin,
        Some(json!({ "tenant": ALPHA, "spec": wrong_spec })),
    )
    .await;
    assert_eq!(checked.status, StatusCode::BAD_REQUEST, "{}", checked.body);
    assert_eq!(checked.code(), "SCHEDULER_SPEC_INVALID");
    assert_eq!(
        checked.json()["error"]["details"]["fields"]["rule"],
        "cron[0]"
    );
    assert_eq!(
        checked.json()["error"]["details"]["fields"]["reason"],
        "cron_syntax"
    );
    let checked = send(
        &router,
        "POST",
        "/specs/validate",
        admin,
        Some(json!({
            "tenant": ALPHA,
            "spec": { "cron": ["0 9 * * *"], "timezone": "Europe/Paris", "at": null, "jitter": null },
            "calendars": [calendar_id],
        })),
    )
    .await;
    assert_eq!(checked.status, StatusCode::OK, "{}", checked.body);
    assert_eq!(checked.data()["valid"], true);
    // Mêmes règles de forme que l'écriture : 11 expressions (10 au plus) refusées
    let checked = send(
        &router,
        "POST",
        "/specs/validate",
        admin,
        Some(json!({ "tenant": ALPHA, "spec": { "cron": vec!["0 9 * * *"; 11], "timezone": "UTC" } })),
    )
    .await;
    assert_eq!(checked.status, StatusCode::BAD_REQUEST, "{}", checked.body);
    assert_eq!(checked.code(), "SCHEDULER_SPEC_INVALID");

    // --- Planification contrôlée : règle fausse refusée avec la règle en cause --------------
    let schedule_body = |spec: Value| {
        json!({
            "tenant": ALPHA,
            "name": "rapport-quotidien",
            "task": "essai.rapport",
            "args": { "format": "pdf" },
            "spec": spec,
            "calendars": [calendar_id],
            "overlap": "allow_all",
            "catchup": "none",
        })
    };
    let refused = send(
        &router,
        "POST",
        "/schedules",
        admin,
        Some(schedule_body(wrong_spec.clone())),
    )
    .await;
    assert_eq!(refused.status, StatusCode::BAD_REQUEST, "{}", refused.body);
    assert_eq!(refused.code(), "SCHEDULER_SPEC_INVALID");
    assert_eq!(
        refused.json()["error"]["details"]["fields"]["rule"],
        "cron[0]"
    );
    let created = send(
        &router,
        "POST",
        "/schedules",
        admin,
        Some(schedule_body(
            json!({ "cron": ["0 9 * * *"], "timezone": "Europe/Paris" }),
        )),
    )
    .await;
    assert_eq!(created.status, StatusCode::CREATED, "{}", created.body);
    let schedule = created.data()["id"]
        .as_str()
        .expect("planification")
        .to_string();
    assert!(schedule.starts_with("scheduler_schedule:"), "{schedule}");
    // Permission propre de la tâche : exigée en plus de l'écriture
    let denied = send(
        &router,
        "POST",
        "/schedules",
        Some(&without_task),
        Some(schedule_body(
            json!({ "cron": ["0 10 * * *"], "timezone": "Europe/Paris" }),
        )),
    )
    .await;
    assert_eq!(denied.status, StatusCode::FORBIDDEN, "{}", denied.body);
    assert_eq!(denied.code(), "SCHEDULER_PERMISSION_DENIED");
    // Modification contrôlée : règle fausse refusée, règle correcte enregistrée
    let patched = send(
        &router,
        "PATCH",
        &format!("/schedules/{schedule}"),
        admin,
        Some(json!({ "spec": { "cron": ["0 9 * * 8"], "timezone": "Europe/Paris" } })),
    )
    .await;
    assert_eq!(patched.code(), "SCHEDULER_SPEC_INVALID", "{}", patched.body);
    assert_eq!(
        patched.json()["error"]["details"]["fields"]["rule"],
        "cron[0]"
    );
    let patched = send(
        &router,
        "PATCH",
        &format!("/schedules/{schedule}"),
        admin,
        Some(json!({ "spec": { "cron": ["30 8 * * 1-5"], "timezone": "Europe/Paris" } })),
    )
    .await;
    assert_eq!(patched.status, StatusCode::OK, "{}", patched.body);
    assert_eq!(patched.data()["spec"]["cron"][0], "30 8 * * 1-5");

    // Prévision : 3 échéances, heure locale dans le fuseau ; 100 au plus
    let forecast = send(
        &router,
        "GET",
        &format!("/schedules/{schedule}/forecast?count=3"),
        admin,
        None,
    )
    .await;
    assert_eq!(forecast.status, StatusCode::OK, "{}", forecast.body);
    let items = forecast.data()["items"]
        .as_array()
        .cloned()
        .unwrap_or_default();
    assert_eq!(items.len(), 3, "{}", forecast.body);
    assert!(items.iter().all(|item| item["local"]
        .as_str()
        .is_some_and(|local| local.contains("08:30:00") && local.ends_with("[Europe/Paris]"))));
    let forecast = send(
        &router,
        "GET",
        &format!("/schedules/{schedule}/forecast?count=500"),
        admin,
        None,
    )
    .await;
    assert_eq!(forecast.data()["items"].as_array().map(Vec::len), Some(100));
    let forecast = send(
        &router,
        "GET",
        &format!("/schedules/{schedule}/forecast?count=beaucoup"),
        admin,
        None,
    )
    .await;
    assert_eq!(
        forecast.code(),
        "SERVER_INVALID_REQUEST",
        "{}",
        forecast.body
    );

    // Pause, reprise
    let paused = send(
        &router,
        "POST",
        &format!("/schedules/{schedule}/pause"),
        admin,
        Some(json!({ "reason": "congés" })),
    )
    .await;
    assert_eq!(paused.status, StatusCode::OK, "{}", paused.body);
    assert_eq!(paused.data()["paused"], true);
    let resumed = send(
        &router,
        "POST",
        &format!("/schedules/{schedule}/resume"),
        admin,
        None,
    )
    .await;
    assert_eq!(resumed.status, StatusCode::OK, "{}", resumed.body);
    assert_eq!(resumed.data()["paused"], false);

    // Déclenchement immédiat : exécution réelle par le moteur de l'hôte
    let triggered = send(
        &router,
        "POST",
        &format!("/schedules/{schedule}/trigger"),
        admin,
        None,
    )
    .await;
    assert_eq!(triggered.status, StatusCode::CREATED, "{}", triggered.body);
    let triggered_run = triggered.data()["id"]
        .as_str()
        .expect("exécution")
        .to_string();
    assert!(!triggered_run.contains(':'), "{triggered_run}");
    let done = wait_state(&router, &admin_token, &triggered_run, "completed").await;
    assert_eq!(done["result"]["format"], "pdf");

    // Rejeu d'une période passée : exécutions [planification, date] créées par le moteur, lues
    // par leur forme texte
    let now = chrono::Utc::now();
    let backfill = send(
        &router,
        "POST",
        &format!("/schedules/{schedule}/backfill"),
        admin,
        Some(json!({
            "from": (now - chrono::Duration::days(8)).to_rfc3339(),
            "to": (now - chrono::Duration::days(1)).to_rfc3339(),
        })),
    )
    .await;
    assert_eq!(backfill.status, StatusCode::CREATED, "{}", backfill.body);
    let mut replayed = Vec::new();
    for _ in 0..150 {
        let runs = send(
            &router,
            "GET",
            &format!("/runs?tenant={ALPHA}&schedule={schedule}&limit=50"),
            admin,
            None,
        )
        .await;
        assert_eq!(runs.status, StatusCode::OK, "{}", runs.body);
        replayed = runs.data()["items"]
            .as_array()
            .cloned()
            .unwrap_or_default()
            .into_iter()
            .filter(|run| run["origin"] == "backfill")
            .collect();
        if !replayed.is_empty() {
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    let composite = replayed
        .first()
        .and_then(|run| run["id"].as_str())
        .expect("exécution du rejeu")
        .to_string();
    let decoded =
        String::from_utf8(URL_SAFE_NO_PAD.decode(&composite).expect("base64url")).expect("UTF-8");
    assert!(
        decoded.starts_with(&format!("scheduler_run:[{schedule}, d'")),
        "{decoded}"
    );
    let read = send(&router, "GET", &format!("/runs/{composite}"), admin, None).await;
    assert_eq!(read.status, StatusCode::OK, "{}", read.body);
    assert_eq!(read.data()["id"], composite.as_str());
    assert_eq!(read.data()["origin"], "backfill");
    let schedule_read = send(
        &router,
        "GET",
        &format!("/schedules/{schedule}"),
        admin,
        None,
    )
    .await;
    assert_eq!(
        schedule_read.status,
        StatusCode::OK,
        "{}",
        schedule_read.body
    );
    let recent = schedule_read.data()["recent_runs"]
        .as_array()
        .cloned()
        .unwrap_or_default();
    assert!(
        recent.iter().all(|run| run["id"]
            .as_str()
            .is_some_and(|id| URL_SAFE_NO_PAD.decode(id).is_ok())),
        "{}",
        schedule_read.body
    );

    // --- Exécution différée exécutée par le moteur de l'hôte -------------------------------
    let before = calls.load(Ordering::SeqCst);
    let enqueued = send(
        &router,
        "POST",
        "/runs",
        admin,
        Some(json!({ "tenant": ALPHA, "task": "essai.rapport", "args": { "format": "csv" }, "delay": "1s" })),
    )
    .await;
    assert_eq!(enqueued.status, StatusCode::CREATED, "{}", enqueued.body);
    assert_eq!(enqueued.data()["state"], "queued");
    let deferred = enqueued.data()["id"]
        .as_str()
        .expect("exécution")
        .to_string();
    let completed = wait_state(&router, &admin_token, &deferred, "completed").await;
    assert_eq!(completed["id"], deferred.as_str());
    assert_eq!(completed["result"]["format"], "csv");
    assert!(calls.load(Ordering::SeqCst) > before);

    // Exécution différée d'une heure : lue par son identifiant texte, annulée, relancée, puis
    // exécutée par le moteur
    let later = send(
        &router,
        "POST",
        "/runs",
        admin,
        Some(json!({ "tenant": ALPHA, "task": "essai.rapport", "args": { "format": "pdf" }, "delay": "1h" })),
    )
    .await;
    assert_eq!(later.status, StatusCode::CREATED, "{}", later.body);
    let later = later.data()["id"].as_str().expect("exécution").to_string();
    let read = send(&router, "GET", &format!("/runs/{later}"), admin, None).await;
    assert_eq!(read.data()["state"], "queued", "{}", read.body);
    let cancelled = send(
        &router,
        "POST",
        &format!("/runs/{later}/cancel"),
        admin,
        Some(json!({ "reason": "inutile" })),
    )
    .await;
    assert_eq!(cancelled.status, StatusCode::OK, "{}", cancelled.body);
    assert_eq!(cancelled.data()["state"], "cancelled");
    assert_eq!(cancelled.data()["cancel_reason"], "inutile");
    let again = send(
        &router,
        "POST",
        &format!("/runs/{later}/cancel"),
        admin,
        None,
    )
    .await;
    assert_eq!(again.status, StatusCode::CONFLICT, "{}", again.body);
    assert_eq!(again.code(), "SCHEDULER_RUN_STATE_INVALID");
    let retried = send(
        &router,
        "POST",
        &format!("/runs/{later}/retry"),
        admin,
        None,
    )
    .await;
    assert_eq!(retried.status, StatusCode::CREATED, "{}", retried.body);
    assert_eq!(retried.data()["origin"], "retry");
    assert_eq!(retried.data()["retry_of"], later.as_str());
    let retry = retried.data()["id"].as_str().expect("relance").to_string();
    let completed = wait_state(&router, &admin_token, &retry, "completed").await;
    assert_eq!(completed["result"]["format"], "pdf");

    // --- Unicité : l'exécution existante est rendue avec 200, rien n'est créé (A9) ----------
    let unique =
        json!({ "tenant": ALPHA, "task": "essai.unique", "unique_key": "lot-1", "delay": "1h" });
    let first = send(&router, "POST", "/runs", admin, Some(unique.clone())).await;
    assert_eq!(first.status, StatusCode::CREATED, "{}", first.body);
    assert_eq!(first.data()["duplicate"], false);
    let again = send(&router, "POST", "/runs", admin, Some(unique)).await;
    assert_eq!(again.status, StatusCode::OK, "{}", again.body);
    assert_eq!(again.data()["duplicate"], true);
    assert_eq!(again.data()["id"], first.data()["id"]);

    // --- Identifiants d'exécution : aucune autre forme acceptée -----------------------------
    let plain = send(&router, "GET", "/runs/scheduler_run:abc", admin, None).await;
    assert_eq!(plain.status, StatusCode::BAD_REQUEST, "{}", plain.body);
    assert_eq!(plain.code(), "SCHEDULER_INVALID_PARAMETERS");
    let other_table = send(
        &router,
        "GET",
        &format!("/runs/{}", run_ref(&schedule)),
        admin,
        None,
    )
    .await;
    assert_eq!(
        other_table.code(),
        "SCHEDULER_INVALID_PARAMETERS",
        "{}",
        other_table.body
    );
    let missing = send(
        &router,
        "GET",
        &format!("/runs/{}", run_ref("scheduler_run:inconnue")),
        admin,
        None,
    )
    .await;
    assert_eq!(missing.status, StatusCode::NOT_FOUND, "{}", missing.body);
    assert_eq!(missing.code(), "SCHEDULER_RUN_NOT_FOUND");

    // --- Requêtes illisibles ----------------------------------------------------------------
    let unreadable = raw(&router, "POST", "/runs", admin, Some("[1, 2]".to_string())).await;
    assert_eq!(
        unreadable.status,
        StatusCode::BAD_REQUEST,
        "{}",
        unreadable.body
    );
    assert_eq!(unreadable.code(), "SERVER_INVALID_REQUEST");
    assert_eq!(unreadable.header("cache-control"), "no-store");
    let bad_delay = send(
        &router,
        "POST",
        "/runs",
        admin,
        Some(json!({ "tenant": ALPHA, "task": "essai.rapport", "args": { "format": "pdf" }, "delay": "deux heures" })),
    )
    .await;
    assert_eq!(
        bad_delay.code(),
        "SERVER_INVALID_REQUEST",
        "{}",
        bad_delay.body
    );
    let bad_args = send(
        &router,
        "POST",
        "/runs",
        admin,
        Some(json!({ "tenant": ALPHA, "task": "essai.rapport", "args": { "format": "doc" } })),
    )
    .await;
    assert_eq!(
        bad_args.code(),
        "SCHEDULER_ARGS_INVALID",
        "{}",
        bad_args.body
    );

    // --- Droits -----------------------------------------------------------------------------
    // Sans permission
    let refused = send(
        &router,
        "GET",
        &format!("/schedules?tenant={ALPHA}"),
        Some(&member),
        None,
    )
    .await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN, "{}", refused.body);
    assert_eq!(refused.code(), "SCHEDULER_PERMISSION_DENIED");
    // Permission propre de la tâche absente : exécution différée refusée
    let refused = send(
        &router,
        "POST",
        "/runs",
        Some(&without_task),
        Some(json!({ "tenant": ALPHA, "task": "essai.rapport", "args": { "format": "pdf" } })),
    )
    .await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN, "{}", refused.body);
    assert_eq!(refused.code(), "SCHEDULER_PERMISSION_DENIED");
    // ... mais lecture permise
    let listed = send(
        &router,
        "GET",
        &format!("/runs?tenant={ALPHA}"),
        Some(&without_task),
        None,
    )
    .await;
    assert_eq!(listed.status, StatusCode::OK, "{}", listed.body);
    // Autre organisation : portée refusée, exécution et planification introuvables
    let refused = send(
        &router,
        "GET",
        &format!("/runs?tenant={ALPHA}"),
        Some(&neighbour),
        None,
    )
    .await;
    assert_eq!(
        refused.code(),
        "SCHEDULER_PERMISSION_DENIED",
        "{}",
        refused.body
    );
    let hidden = send(
        &router,
        "GET",
        &format!("/runs/{deferred}"),
        Some(&neighbour),
        None,
    )
    .await;
    assert_eq!(hidden.status, StatusCode::NOT_FOUND, "{}", hidden.body);
    assert_eq!(hidden.code(), "SCHEDULER_RUN_NOT_FOUND");
    assert!(!hidden.body.contains("csv"));
    let hidden = send(
        &router,
        "GET",
        &format!("/schedules/{schedule}"),
        Some(&neighbour),
        None,
    )
    .await;
    assert_eq!(
        hidden.code(),
        "SCHEDULER_SCHEDULE_NOT_FOUND",
        "{}",
        hidden.body
    );
    let refused = send(
        &router,
        "POST",
        &format!("/runs/{retry}/retry"),
        Some(&neighbour),
        None,
    )
    .await;
    assert!(!refused.status.is_success(), "{}", refused.body);
    assert!(refused.code().starts_with("SCHEDULER_"), "{}", refused.body);

    // --- Journal : exécutions sous leur forme texte ------------------------------------------
    let audit = send(
        &router,
        "GET",
        &format!("/audit?tenant={ALPHA}&limit=200"),
        admin,
        None,
    )
    .await;
    assert_eq!(audit.status, StatusCode::OK, "{}", audit.body);
    let entries = audit.data()["items"]
        .as_array()
        .cloned()
        .unwrap_or_default();
    assert!(!entries.is_empty(), "{}", audit.body);
    assert!(entries
        .iter()
        .filter_map(|entry| entry["run"].as_str())
        .all(|run| !run.contains(':') && URL_SAFE_NO_PAD.decode(run).is_ok()));
    assert!(entries
        .iter()
        .any(|entry| entry["run"].as_str() == Some(later.as_str())));

    // --- Aucune route du moteur (X2) ------------------------------------------------------------
    for (method, path) in [
        ("GET", "/due".to_string()),
        ("POST", "/due".to_string()),
        ("POST", "/runs/claim".to_string()),
        ("POST", "/runs/rescue".to_string()),
        ("POST", "/runs/prune".to_string()),
        ("POST", format!("/runs/{deferred}/heartbeat")),
        ("POST", format!("/runs/{deferred}/complete")),
        ("POST", format!("/runs/{deferred}/fail")),
        ("POST", format!("/runs/{deferred}/publish")),
        ("POST", format!("/schedules/{schedule}/fire")),
        ("POST", format!("/schedules/{schedule}/next")),
        ("POST", "/backfills/x/fire".to_string()),
        ("POST", "/tasks/essai.rapport/state".to_string()),
        ("PUT", "/tasks/essai.rapport".to_string()),
        ("GET", "/health".to_string()),
    ] {
        let reply = raw(&router, method, &path, admin, Some("{}".to_string())).await;
        assert!(
            matches!(
                reply.status,
                StatusCode::NOT_FOUND | StatusCode::METHOD_NOT_ALLOWED
            ),
            "{method} {path} : {} {}",
            reply.status,
            reply.body
        );
        // Adresse inconnue aussi marquée `no-store` (A10)
        assert_eq!(reply.header("cache-control"), "no-store", "{method} {path}");
    }

    // --- Suppressions -------------------------------------------------------------------------
    let in_use = send(
        &router,
        "DELETE",
        &format!("/calendars/{calendar_id}"),
        admin,
        None,
    )
    .await;
    assert_eq!(
        in_use.code(),
        "SCHEDULER_CALENDAR_IN_USE",
        "{}",
        in_use.body
    );
    let deleted = send(
        &router,
        "DELETE",
        &format!("/schedules/{schedule}"),
        admin,
        None,
    )
    .await;
    assert_eq!(deleted.status, StatusCode::OK, "{}", deleted.body);
    assert_eq!(deleted.data()["deleted"], schedule.as_str());
    let deleted = send(
        &router,
        "DELETE",
        &format!("/calendars/{calendar_id}"),
        admin,
        None,
    )
    .await;
    assert_eq!(deleted.status, StatusCode::OK, "{}", deleted.body);

    started.runtime.stop_all().await.expect("arrêt");
}
