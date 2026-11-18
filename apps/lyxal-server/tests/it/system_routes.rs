//! Routes d'administration de l'installation `/api/v1/system/migrations/*` : liste des migrations
//! interrompues et décision de reprise ou d'abandon, réservées au droit
//! `server.installation.manage` ; refus sans jeton, sans droit, sur requête illisible, quand la
//! migration n'est pas interrompue et quand le bail d'installation est détenu ailleurs ; auteur
//! de la décision tracé au journal du runtime.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_server::{
    context::AppContext, health::HealthRegistry, http::build_router, metrics::Metrics,
    modules::auth, runtime,
};
use serde_json::{json, Value};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::auth_routes::crypto;
use crate::startup::{config_with, database};

const INTERRUPTED: &str = "/api/v1/system/migrations/interrupted";
const RESOLVE: &str = "/api/v1/system/migrations/resolve";

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

async fn send(
    router: &axum::Router,
    method: &str,
    uri: &str,
    token: Option<&str>,
    body: Option<String>,
) -> (StatusCode, Value) {
    let mut request = Request::builder()
        .method(method)
        .uri(uri)
        .header("content-type", "application/json");
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let request = request
        .body(body.map_or_else(Body::empty, Body::from))
        .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let status = response.status();
    if status != StatusCode::PAYLOAD_TOO_LARGE {
        assert_eq!(
            response
                .headers()
                .get("cache-control")
                .and_then(|v| v.to_str().ok()),
            Some("no-store"),
            "{method} {uri}"
        );
    }
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

fn decision(action: &str, reason: &str) -> Option<String> {
    Some(
        json!({ "module": "lyxal_essai", "migration": "0001_initial", "action": action, "reason": reason })
            .to_string(),
    )
}

async fn migration_status(client: &Surreal<Any>) -> Value {
    value(
        client,
        "RETURN (SELECT VALUE status FROM ONLY runtime_migration:['lyxal_essai', '0001_initial']);",
    )
    .await
}

#[tokio::test]
async fn interrupted_migrations_are_listed_and_resolved_by_an_installation_administrator() {
    let config = Arc::new(config_with(
        "system_routes",
        "[auth]\npublic_url = \"https://lyxal.test/\"\n",
    ));
    let client = database("system_routes").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let router = build_router(AppContext::new(
        config.clone(),
        Arc::new(client.clone()),
        HealthRegistry::default(),
        Metrics::default(),
        started.runtime.clone(),
        Some(host.clone()),
        Default::default(),
    ))
    .expect("routeur");

    // Administrateur de la plateforme (le seed de l'hôte lui attribue le droit), compte sans
    // droit, et migration d'un module laissée « en cours » par un nœud arrêté
    run(
        &client,
        r#"CREATE auth_application:plateforme CONTENT { client_id: "lyxal-test-systeme-admin", name: "Plateforme", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
           RELATE auth_application:plateforme->auth_has_role->auth_role:platform_admin SET granted_at = time::now();
           CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
           CREATE auth_application:voisin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-systeme-voisin", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
           RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
           fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0001_initial", module_version: "0.1.0", checksum: string::repeat("a", 64), status: "Applying", applied_at: 0, duration_ms: 0, script: "migrations/0001_initial.surql", node_id: "node-arrete" });"#,
    )
    .await;
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
    let admin = token("lyxal-test-systeme-admin").await;
    let neighbour = token("lyxal-test-systeme-voisin").await;

    // --- Sans jeton, sans droit : refusé, rien n'est lu ni écrit ---------------------------
    for (method, uri, body) in [
        ("GET", INTERRUPTED, None),
        ("POST", RESOLVE, decision("retry", "sans droit")),
    ] {
        let (status, reply) = send(&router, method, uri, None, body.clone()).await;
        assert_eq!(status, StatusCode::UNAUTHORIZED, "{reply}");
        assert_eq!(reply["error"]["code"], "AUTH_SESSION_REQUIRED", "{reply}");
        let (status, reply) = send(&router, method, uri, Some(&neighbour), body).await;
        assert_eq!(status, StatusCode::FORBIDDEN, "{reply}");
        assert_eq!(reply["ok"], false);
        assert!(reply["data"].is_null(), "{reply}");
        assert_eq!(reply["error"]["code"], "AUTH_PERMISSION_DENIED", "{reply}");
    }
    assert_eq!(migration_status(&client).await, "Applying");

    // --- Liste ---------------------------------------------------------------------------
    let (status, reply) = send(&router, "GET", INTERRUPTED, Some(&admin), None).await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    assert_eq!(reply["ok"], true);
    let listed = reply["data"].as_array().expect("liste");
    assert_eq!(listed.len(), 1, "{reply}");
    assert_eq!(listed[0]["module"], "lyxal_essai");
    assert_eq!(listed[0]["migration"], "0001_initial");
    assert_eq!(listed[0]["version"], "0.1.0");
    assert_eq!(listed[0]["script"], "migrations/0001_initial.surql");
    assert_eq!(listed[0]["node"], "node-arrete");
    assert_eq!(listed[0]["state"], "interrupted");
    assert!(listed[0]["started_at"].is_string(), "{reply}");
    let (status, reply) = send(
        &router,
        "GET",
        &format!("{INTERRUPTED}?module=lyxal_auth"),
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    assert_eq!(reply["data"], json!([]));
    let (status, reply) = send(
        &router,
        "GET",
        &format!("{INTERRUPTED}?inconnu=1"),
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::BAD_REQUEST, "{reply}");
    assert_eq!(reply["error"]["code"], "SERVER_INVALID_REQUEST", "{reply}");

    // --- Requêtes illisibles ou invalides -------------------------------------------------
    for body in [
        "pas du JSON".to_string(),
        json!({ "module": "lyxal_essai", "migration": "0001_initial", "action": "retry" })
            .to_string(),
        json!({ "module": "lyxal_essai", "migration": "0001_initial", "action": "retry", "reason": "x", "actor": "auth_identity:autre" }).to_string(),
        json!({ "module": "lyxal_essai", "migration": "0001_initial", "action": "oublier", "reason": "x" }).to_string(),
    ] {
        let (status, reply) = send(&router, "POST", RESOLVE, Some(&admin), Some(body)).await;
        assert_eq!(status, StatusCode::BAD_REQUEST, "{reply}");
        assert_eq!(reply["error"]["code"], "SERVER_INVALID_REQUEST", "{reply}");
    }
    // Motif vide ou trop long : refusé par la fonction du runtime, sans détail interne
    for reason in ["  ".to_string(), "x".repeat(1001)] {
        let (status, reply) = send(
            &router,
            "POST",
            RESOLVE,
            Some(&admin),
            decision("retry", &reason),
        )
        .await;
        assert_eq!(status, StatusCode::BAD_REQUEST, "{reply}");
        assert_eq!(
            reply["error"]["code"], "RUNTIME_INVALID_PARAMETERS",
            "{reply}"
        );
        assert_eq!(
            reply["error"]["details"]
                .as_object()
                .map(|details| details.keys().cloned().collect::<Vec<_>>()),
            Some(vec!["trace_id".to_string()]),
            "{reply}"
        );
    }
    // Corps au-delà de la limite du serveur
    let (status, _) = send(
        &router,
        "POST",
        RESOLVE,
        Some(&admin),
        decision("retry", &"x".repeat(2 * 1024 * 1024)),
    )
    .await;
    assert_eq!(status, StatusCode::PAYLOAD_TOO_LARGE);
    assert_eq!(migration_status(&client).await, "Applying");

    // --- Bail d'installation détenu par un autre nœud : refusé ----------------------------
    run(
        &client,
        r#"fn::runtime_lease_acquire({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "node-autre", ttl_seconds: 60 });"#,
    )
    .await;
    let (status, reply) = send(
        &router,
        "POST",
        RESOLVE,
        Some(&admin),
        decision("abandon", "bail pris"),
    )
    .await;
    assert_eq!(status, StatusCode::PRECONDITION_FAILED, "{reply}");
    assert_eq!(reply["error"]["code"], "RUNTIME_LEASE_FENCED", "{reply}");
    assert!(!reply.to_string().contains("node-autre"), "{reply}");
    assert_eq!(migration_status(&client).await, "Applying");
    run(
        &client,
        "UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'installation' AND key = 'lyxal_essai:0.1.0';",
    )
    .await;

    // --- Abandon, puis reprise -------------------------------------------------------------
    let (status, reply) = send(
        &router,
        "POST",
        RESOLVE,
        Some(&admin),
        decision("abandon", "état partiel à examiner"),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    assert_eq!(reply["data"]["status"], "Abandoned", "{reply}");
    assert_eq!(reply["data"]["previous_status"], "Applying");
    let (_, reply) = send(&router, "GET", INTERRUPTED, Some(&admin), None).await;
    assert_eq!(reply["data"][0]["state"], "abandoned", "{reply}");
    assert_eq!(
        reply["data"][0]["resolution"]["actor"],
        "auth_application:plateforme"
    );
    assert_eq!(
        reply["data"][0]["resolution"]["reason"],
        "état partiel à examiner"
    );

    let (status, reply) = send(
        &router,
        "POST",
        RESOLVE,
        Some(&admin),
        decision("abandon", "doublon"),
    )
    .await;
    assert_eq!(status, StatusCode::CONFLICT, "{reply}");
    assert_eq!(
        reply["error"]["code"], "RUNTIME_MIGRATION_NOT_INTERRUPTED",
        "{reply}"
    );

    let (status, reply) = send(
        &router,
        "POST",
        RESOLVE,
        Some(&admin),
        decision("retry", "base vérifiée"),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    assert_eq!(reply["data"]["status"], "RetryRequested", "{reply}");
    assert_eq!(migration_status(&client).await, "RetryRequested");
    let (_, reply) = send(&router, "GET", INTERRUPTED, Some(&admin), None).await;
    assert_eq!(reply["data"], json!([]));

    // --- Trace au journal du runtime : les deux décisions, leur auteur et leur motif -------
    let traces = value(
        &client,
        "RETURN (SELECT VALUE payload.data FROM runtime_event_journal WHERE module_id = 'lyxal_essai' AND kind = 'migration' ORDER BY sequence ASC);",
    )
    .await;
    let traces = traces.as_array().expect("traces");
    assert_eq!(traces.len(), 2, "{traces:?}");
    assert_eq!(traces[0]["event"], "resolved");
    assert_eq!(traces[0]["action"], "abandon");
    assert_eq!(traces[0]["actor"], "auth_application:plateforme");
    assert_eq!(traces[0]["reason"], "état partiel à examiner");
    assert_eq!(traces[1]["action"], "retry");
    assert_eq!(traces[1]["reason"], "base vérifiée");

    started.runtime.stop_all().await.expect("arrêt");
}
