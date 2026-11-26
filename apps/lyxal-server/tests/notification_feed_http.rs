//! Fil de `lyxal_notification` sur l'hôte (base embarquée, runtime démarré) : fil dans
//! l'application et son temps réel. Flux SSE ouvert avec la session `lyxal_auth` de la
//! personne : compteurs d'abord, puis le nouveau message et ses compteurs, à elle seule (une
//! collègue connectée ne reçoit que les siens) ; compteurs poussés après « lu » ; routes du fil
//! (liste, compteurs, états, sommeil, bouton, suppression) au nom de la personne, une autre
//! personne reçoit 404 ; 5 flux au plus par personne, une place libérée quand un client part ;
//! session sans compte refusée ; signe de vie qui revérifie la session et ferme le flux à son
//! expiration ; requête `LIVE SELECT` coupée (`KILL`) puis reprise par le worker du hub.
//!
//! Aucun délai réel n'est mesuré : les signes de vie sont donnés à la main (`FeedTicks`), et
//! chaque attente porte sur un événement attendu, avec une limite large.

use axum::body::Body;
use axum::http::{Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use futures::StreamExt;
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_notification::{NotificationChannelWorker, NotificationStore, SendWorkerSettings};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext, WorkerId};
use lyxal_runtime::ModuleContext;
use lyxal_server::modules::notification_feed::{FeedHub, FeedHubWorker, FeedSettings, FeedTicks};
use lyxal_server::{
    config::AppConfig, context::AppContext, http::build_router, modules::auth, runtime,
};
use serde_json::{json, Value};
use std::fs;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

/// Limite large d'une attente d'événement (jamais une fenêtre mesurée).
const PATIENCE: Duration = Duration::from_secs(90);

fn ephemeral_key() -> String {
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    STANDARD.encode(&bytes)
}

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
max_concurrency = 64
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "notification_fil"
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

async fn call(
    router: &axum::Router,
    method: &str,
    uri: &str,
    token: Option<&str>,
    body: Option<Value>,
) -> (StatusCode, Value) {
    let mut request = Request::builder().method(method).uri(uri);
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let request = match body {
        Some(body) => request
            .header("content-type", "application/json")
            .body(Body::from(body.to_string())),
        None => request.body(Body::empty()),
    }
    .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let status = response.status();
    let bytes = axum::body::to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

/// Trame d'un flux SSE.
#[derive(Debug, PartialEq)]
enum Frame {
    Event(String, Value),
    Comment(String),
}

/// Lecteur d'un flux SSE de l'hôte.
struct Sse {
    body: axum::body::BodyDataStream,
    buffer: String,
}

impl Sse {
    async fn open(router: &axum::Router, token: &str) -> Result<Self, (StatusCode, Value)> {
        let request = Request::builder()
            .method("GET")
            .uri("/api/v1/notification/feed/stream")
            .header("authorization", format!("Bearer {token}"))
            .body(Body::empty())
            .expect("requête");
        let response = tower::ServiceExt::oneshot(router.clone(), request)
            .await
            .expect("réponse");
        let status = response.status();
        if status != StatusCode::OK {
            let bytes = axum::body::to_bytes(response.into_body(), 1024 * 1024)
                .await
                .expect("corps");
            return Err((
                status,
                serde_json::from_slice(&bytes).unwrap_or(Value::Null),
            ));
        }
        assert_eq!(
            response.headers()["content-type"],
            "text/event-stream",
            "type du flux"
        );
        Ok(Self {
            body: response.into_body().into_data_stream(),
            buffer: String::new(),
        })
    }

    /// Prochaine trame ; `None` à la fin du flux.
    async fn next(&mut self) -> Option<Frame> {
        loop {
            if let Some(end) = self.buffer.find("\n\n") {
                let block: String = self.buffer.drain(..end + 2).collect();
                let mut name = None;
                let mut data = String::new();
                let mut comment = None;
                for line in block.lines() {
                    if let Some(value) = line.strip_prefix("event:") {
                        name = Some(value.trim().to_string());
                    } else if let Some(value) = line.strip_prefix("data:") {
                        data.push_str(value.trim_start());
                    } else if let Some(value) = line.strip_prefix(':') {
                        comment = Some(value.trim().to_string());
                    }
                }
                return Some(match (name, comment) {
                    (Some(name), _) => {
                        Frame::Event(name, serde_json::from_str(&data).unwrap_or(Value::Null))
                    }
                    (None, Some(comment)) => Frame::Comment(comment),
                    (None, None) => continue,
                });
            }
            let chunk = tokio::time::timeout(PATIENCE, self.body.next())
                .await
                .expect("trame attendue avant la limite")?;
            self.buffer
                .push_str(&String::from_utf8_lossy(&chunk.expect("trame lisible")));
        }
    }

    /// Prochain signe de vie (les événements en attente sont passés).
    async fn keep_alive(&mut self) {
        loop {
            match self.next().await.expect("flux ouvert") {
                Frame::Comment(comment) => {
                    assert_eq!(comment, "keep-alive");
                    return;
                }
                Frame::Event(..) => continue,
            }
        }
    }

    /// Fin du flux, sans signe de vie avant elle (les événements en attente sont passés).
    async fn closed(&mut self) {
        while let Some(frame) = self.next().await {
            assert!(
                matches!(frame, Frame::Event(..)),
                "signe de vie reçu au lieu de la fermeture"
            );
        }
    }

    /// Prochain événement nommé (les signes de vie sont ignorés).
    async fn event(&mut self) -> (String, Value) {
        loop {
            match self.next().await.expect("flux ouvert") {
                Frame::Event(name, data) => return (name, data),
                Frame::Comment(_) => continue,
            }
        }
    }
}

/// Attend une reprise de la requête `LIVE SELECT` du hub (limite large).
async fn live_generation(hub: &FeedHub, at_least: u64) {
    let deadline = tokio::time::Instant::now() + PATIENCE;
    while hub.generation() < at_least || hub.live_query().is_none() {
        assert!(
            tokio::time::Instant::now() < deadline,
            "requête LIVE jamais ouverte : génération {}, requête {:?}",
            hub.generation(),
            hub.live_query()
        );
        tokio::time::sleep(Duration::from_millis(20)).await;
    }
}

struct Harness {
    client: Surreal<Any>,
    host: Arc<auth::AuthHost>,
    router: axum::Router,
    hub: FeedHub,
    ticks: FeedTicks,
    cancel: CancellationToken,
    worker: NotificationChannelWorker<StaticKeyResolver>,
}

impl Harness {
    /// Déclenche le parcours `devis` pour `subscriber_id` puis livre l'étape du fil.
    async fn deliver(&self, key: &str, subscriber_id: &str, n: &str) {
        let mut response = self
            .client
            .query("RETURN fn::notification_trigger({ tenant: 'auth_organization:alpha', workflow_key: 'devis', idempotency_key: $key, to: { subscriber_id: $subscriber }, payload: { n: $n } }).ok")
            .bind(("key", key.to_string()))
            .bind(("subscriber", subscriber_id.to_string()))
            .bind(("n", n.to_string()))
            .await
            .expect("déclenchement");
        let ok: Option<bool> = response.take(0).expect("résultat");
        assert_eq!(ok, Some(true));
        // Le worker du runtime peut aussi prendre l'étape : livrée par l'un ou l'autre
        let deadline = tokio::time::Instant::now() + PATIENCE;
        loop {
            self.worker
                .run_once(&CancellationToken::new())
                .await
                .expect("tour du worker");
            let mut response = self
                .client
                .query("RETURN count(SELECT id FROM notification_inbox WHERE run.idempotency_key = $key) = 1")
                .bind(("key", key.to_string()))
                .await
                .expect("requête");
            let done: Option<bool> = response.take(0).expect("booléen");
            if done == Some(true) {
                return;
            }
            assert!(
                tokio::time::Instant::now() < deadline,
                "message jamais livré"
            );
            tokio::time::sleep(Duration::from_millis(50)).await;
        }
    }
}

async fn token(router: &axum::Router, api_key: &str) -> (String, String) {
    let (status, exchanged) = call(
        router,
        "POST",
        "/api/v1/auth/api-keys/exchange",
        None,
        Some(json!({ "api_key": api_key })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{exchanged}");
    (
        exchanged["data"]["access_token"]
            .as_str()
            .expect("jeton")
            .to_string(),
        exchanged["data"]["session"]
            .as_str()
            .expect("session")
            .to_string(),
    )
}

async fn harness() -> Harness {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_fil")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    let host = auth::host(&client.clone().into(), &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    // Hub de l'essai : signes de vie donnés à la main, reprise rapide de la requête LIVE
    let (hub, ticks) = FeedHub::with_manual_ticks(FeedSettings {
        reconnect_delay: Duration::from_millis(20),
        // Relecture périodique des compteurs hors de l'essai (aucune fenêtre de temps réelle)
        counts_interval: Duration::from_secs(24 * 3600),
        ..FeedSettings::default()
    });
    let cancel = CancellationToken::new();
    let module_id = ModuleId::new("lyxal_notification");
    let feed_worker = FeedHubWorker::new(hub.clone(), client.clone()).expect("worker du hub");
    let context = WorkerContext::new(
        module_id.clone(),
        WorkerId::new(&module_id, "feed_hub_test").expect("identifiant"),
        ModuleContext::new(module_id.clone()),
        cancel.clone(),
    );
    tokio::spawn(async move { feed_worker.run(context).await });
    let router = build_router(
        AppContext::new(
            config.clone(),
            client.clone().into(),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            Some(host.clone()),
            Default::default(),
        )
        .with_notification(lyxal_server::modules::notification::NotificationHost {
            feed: Some(hub.clone()),
            ..started.notification.clone()
        }),
    )
    .expect("routeur");
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            FOR $name IN ["personne", "collegue"] {
                CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test"), locale: "fr" } };
                RELATE (type::record("auth_identity", $name))->auth_member_of->auth_organization:alpha;
                fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: string::concat("auth:", $name), identity: type::record("auth_identity", $name) }, must_exist: false });
            };
            RELATE auth_identity:personne->auth_member_of->auth_organization:beta;
            CREATE auth_application:robot CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-fil-robot", name: "Robot", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:robot->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", tags: ["devis"], severity: "high", steps: [{ key: "fil", type: "in_app" }] };
            CREATE notification_template:devis_fil CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "fil",
                subject: "Devis {{ payload.n }}", text_body: "Le devis {{ payload.n }} est prêt", redirect: "/devis/{{ payload.n }}",
                actions: [{ kind: "primary", label: "Valider", url: "/devis/{{ payload.n }}/valider" }] };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    for (name, identity, organization) in [
        ("personne", "personne", "alpha"),
        ("personne-bis", "personne", "alpha"),
        ("personne-beta", "personne", "beta"),
        ("collegue", "collegue", "alpha"),
    ] {
        client
            .query("CREATE auth_api_key CONTENT { identity: type::record('auth_identity', $identity), organization: type::record('auth_organization', $organization), name: $name, key_hash: $hash, prefix: 'lyxk_fil', permissions: [] }")
            .bind(("identity", identity.to_string()))
            .bind(("organization", organization.to_string()))
            .bind(("name", name.to_string()))
            .bind(("hash", lyxal_crypto::hash::blake3_hex(format!("lyxk_fil-essai-{name}").as_bytes())))
            .await
            .expect("clé d'API")
            .check()
            .expect("clé d'API créée");
    }
    live_generation(&hub, 1).await;
    let worker = NotificationChannelWorker::in_app(
        NotificationStore::new(client.clone()),
        SendWorkerSettings::default(),
    )
    .expect("worker du fil");
    Harness {
        client,
        host,
        router,
        hub,
        ticks,
        cancel,
        worker,
    }
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn the_feed_is_streamed_to_its_owner_only_and_its_routes_are_personal() {
    let h = harness().await;
    let (personne, personne_session) = token(&h.router, "lyxk_fil-essai-personne").await;
    let (collegue, _) = token(&h.router, "lyxk_fil-essai-collegue").await;
    let (ailleurs, _) = token(&h.router, "lyxk_fil-essai-personne-beta").await;

    // Flux : compteurs d'abord
    let mut mine = Sse::open(&h.router, &personne).await.expect("flux ouvert");
    let mut theirs = Sse::open(&h.router, &collegue).await.expect("flux ouvert");
    let mut elsewhere = Sse::open(&h.router, &ailleurs).await.expect("flux ouvert");
    let zero = json!({ "unseen": 0, "unread": 0, "total": 0 });
    assert_eq!(mine.event().await, ("counts".to_string(), zero.clone()));
    assert_eq!(theirs.event().await, ("counts".to_string(), zero.clone()));
    assert_eq!(
        elsewhere.event().await,
        ("counts".to_string(), zero.clone())
    );

    // Déclenchement → message du fil → événement SSE pour la personne seulement
    h.deliver("devis-1", "auth:personne", "D-1").await;
    let (name, item) = mine.event().await;
    assert_eq!(name, "notification");
    assert_eq!(
        (
            item["title"].as_str(),
            item["redirect"].as_str(),
            item["workflow"].as_str()
        ),
        (Some("Devis D-1"), Some("/devis/D-1"), Some("devis"))
    );
    assert_eq!(item["actions"][0]["status"], "pending");
    let id = item["id"].as_str().expect("identifiant").to_string();
    assert_eq!(
        mine.event().await,
        (
            "counts".to_string(),
            json!({ "unseen": 1, "unread": 1, "total": 1 })
        )
    );
    // La collègue (même organisation) et la même personne dans une autre organisation ne
    // reçoivent pas ce message : leur premier événement est le leur
    h.deliver("devis-2", "auth:collegue", "D-2").await;
    let (name, item) = theirs.event().await;
    assert_eq!(
        (name.as_str(), item["title"].as_str()),
        ("notification", Some("Devis D-2"))
    );

    // Routes : liste et compteurs de la personne ; « lu » pousse les compteurs
    let (status, page) = call(
        &h.router,
        "GET",
        "/api/v1/notification/feed",
        Some(&personne),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{page}");
    assert_eq!(page["data"]["items"].as_array().map(Vec::len), Some(1));
    assert_eq!(page["data"]["items"][0]["id"], id.as_str());
    let (status, counts) = call(
        &h.router,
        "GET",
        "/api/v1/notification/feed/counts?tags=devis&archived=false",
        Some(&personne),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{counts}");
    assert_eq!(
        counts["data"],
        json!({ "unseen": 1, "unread": 1, "total": 1 })
    );
    // Une autre personne : 404, rien ne change
    let (status, refused) = call(
        &h.router,
        "POST",
        "/api/v1/notification/feed/mark",
        Some(&collegue),
        Some(json!({ "ids": [id], "state": "read" })),
    )
    .await;
    assert_eq!(status, StatusCode::NOT_FOUND, "{refused}");
    assert_eq!(refused["error"]["code"], "NOTIFICATION_FEED_ITEM_NOT_FOUND");
    for (uri, body) in [
        (
            "/api/v1/notification/feed/snooze".to_string(),
            json!({ "id": id, "until": (chrono::Utc::now() + chrono::Duration::hours(1)).to_rfc3339() }),
        ),
        (
            "/api/v1/notification/feed/delete".to_string(),
            json!({ "id": id }),
        ),
        (
            format!("/api/v1/notification/feed/{id}/action"),
            json!({ "action": "primary", "status": "done" }),
        ),
    ] {
        let (status, refused) = call(&h.router, "POST", &uri, Some(&collegue), Some(body)).await;
        assert_eq!(status, StatusCode::NOT_FOUND, "{uri} : {refused}");
    }
    let (_, page) = call(
        &h.router,
        "GET",
        "/api/v1/notification/feed",
        Some(&collegue),
        None,
    )
    .await;
    assert!(page["data"]["items"]
        .as_array()
        .expect("liste")
        .iter()
        .all(|item| item["id"] != id.as_str()));
    let (status, _) = call(&h.router, "GET", "/api/v1/notification/feed", None, None).await;
    assert_eq!(status, StatusCode::UNAUTHORIZED);
    // La personne marque son message lu : compteurs poussés sur son flux
    let (status, marked) = call(
        &h.router,
        "POST",
        "/api/v1/notification/feed/mark",
        Some(&personne),
        Some(json!({ "ids": [id], "state": "read" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{marked}");
    assert_eq!(
        mine.event().await,
        (
            "counts".to_string(),
            json!({ "unseen": 0, "unread": 0, "total": 1 })
        )
    );
    // Bouton, sommeil (bornes), réveil
    let (status, done) = call(
        &h.router,
        "POST",
        &format!("/api/v1/notification/feed/{id}/action"),
        Some(&personne),
        Some(json!({ "action": "primary", "status": "done" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{done}");
    assert_eq!(done["data"]["actions"][0]["status"], "done");
    let (status, refused) = call(
        &h.router,
        "POST",
        "/api/v1/notification/feed/snooze",
        Some(&personne),
        Some(json!({ "id": id, "until": "2099-01-01T00:00:00Z" })),
    )
    .await;
    assert_eq!(status, StatusCode::BAD_REQUEST, "{refused}");
    assert_eq!(refused["error"]["code"], "NOTIFICATION_SNOOZE_INVALID");
    let (status, woken) = call(
        &h.router,
        "POST",
        "/api/v1/notification/feed/snooze",
        Some(&personne),
        Some(json!({ "id": id })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{woken}");
    // La personne dans une autre organisation n'a rien reçu : son prochain élément est un
    // signe de vie
    h.ticks.tick();
    assert_eq!(
        elsewhere.next().await,
        Some(Frame::Comment("keep-alive".to_string()))
    );

    // Limite : 5 flux par personne ; une place se libère quand un client part
    let (bis, _) = token(&h.router, "lyxk_fil-essai-personne-bis").await;
    let mut more = Vec::new();
    for _ in 0..3 {
        more.push(Sse::open(&h.router, &bis).await.expect("flux ouvert"));
    }
    // mine + elsewhere + 3 = 5 flux pour ce compte
    assert_eq!(h.hub.connections_of("auth_identity:personne"), 5);
    let (status, refused) = Sse::open(&h.router, &bis).await.err().expect("flux refusé");
    assert_eq!(status, StatusCode::TOO_MANY_REQUESTS, "{refused}");
    assert_eq!(refused["error"]["code"], "NOTIFICATION_FEED_STREAM_LIMIT");
    drop(more.pop());
    assert_eq!(h.hub.connections_of("auth_identity:personne"), 4);
    more.push(Sse::open(&h.router, &bis).await.expect("place libérée"));
    // Session sans compte (compte de service) : pas de fil
    let robot = h
        .host
        .access
        .internal_service_token("lyxal-test-fil-robot")
        .await
        .expect("jeton du compte de service")
        .access_token
        .expose_secret()
        .to_string();
    let (status, refused) = Sse::open(&h.router, &robot)
        .await
        .err()
        .expect("flux refusé");
    assert_eq!(status, StatusCode::FORBIDDEN, "{refused}");
    assert_eq!(refused["error"]["code"], "NOTIFICATION_FEED_NO_ACCOUNT");
    let (status, refused) = call(
        &h.router,
        "GET",
        "/api/v1/notification/feed",
        Some(&robot),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::FORBIDDEN, "{refused}");

    // Expiration de la session : au signe de vie suivant, le flux se ferme ; les autres
    // reçoivent leur signe de vie
    h.client
        .query("UPDATE <record> $expiring SET expires_at = time::now() - 1s")
        .bind(("expiring", personne_session.clone()))
        .await
        .expect("session expirée")
        .check()
        .expect("session modifiée");
    h.ticks.tick();
    mine.closed().await;
    theirs.keep_alive().await;
    assert!(h.hub.connections_of("auth_identity:personne") < 5);

    // Coupure de la requête LIVE : le worker du hub la rouvre, les événements reprennent
    let before = h.hub.generation();
    let live = h.hub.live_query().expect("requête LIVE en cours");
    h.client
        .query(format!(
            "KILL u\"{}\"",
            live.chars()
                .filter(|c| c.is_ascii_hexdigit() || *c == '-')
                .collect::<String>()
        ))
        .await
        .expect("KILL")
        .check()
        .expect("requête LIVE coupée");
    // La base ne signale pas la suppression au flux : le contrôle du worker la constate
    h.hub.probe_live();
    live_generation(&h.hub, before + 1).await;
    assert_ne!(h.hub.live_query().as_deref(), Some(live.as_str()));
    // Reprise : compteurs relus pour tous, puis le nouveau message arrive
    h.deliver("devis-3", "auth:collegue", "D-3").await;
    loop {
        let (name, data) = theirs.event().await;
        if name == "notification" {
            assert_eq!(data["title"], "Devis D-3");
            break;
        }
    }

    // Arrêt du worker : tous les flux se ferment
    h.cancel.cancel();
    loop {
        match theirs.next().await {
            None => break,
            Some(_) => continue,
        }
    }
    assert!(h.hub.is_closed());
    drop(more);
}
