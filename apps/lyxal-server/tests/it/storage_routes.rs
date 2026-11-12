//! Routes `/api/v1/storage/*` de bout en bout sur une base embarquée et un support disque
//! temporaire : envoi, téléchargement (entier, plage, conditionnel), fiche, liste, suppression,
//! droits de l'appelant (sessions de comptes de service), limites, flux interrompu, service ou
//! support absent.

use axum::body::{to_bytes, Body};
use axum::http::{HeaderMap, Request, StatusCode};
use lyxal_server::{
    context::AppContext, health::HealthRegistry, http::build_router, metrics::Metrics,
    modules::auth, runtime,
};
use serde_json::Value;
use std::sync::Arc;

use crate::auth_routes::crypto;
use crate::startup::{config_with, database};

struct Reply {
    status: StatusCode,
    headers: HeaderMap,
    body: Vec<u8>,
}

impl Reply {
    fn json(&self) -> Value {
        serde_json::from_slice(&self.body).unwrap_or(Value::Null)
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

async fn send(
    router: &axum::Router,
    method: &str,
    uri: &str,
    token: Option<&str>,
    headers: &[(&str, &str)],
    body: Body,
) -> Reply {
    let mut request = Request::builder().method(method).uri(uri);
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    for (name, value) in headers {
        request = request.header(*name, *value);
    }
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(body).expect("requête"))
        .await
        .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let body = to_bytes(response.into_body(), 64 * 1024 * 1024)
        .await
        .expect("corps")
        .to_vec();
    Reply {
        status,
        headers,
        body,
    }
}

/// Fichiers présents sous un dossier, fichiers d'écriture en cours compris.
fn files(directory: &std::path::Path) -> Vec<std::path::PathBuf> {
    let mut found = Vec::new();
    for entry in std::fs::read_dir(directory).expect("dossier").flatten() {
        let path = entry.path();
        if path.is_dir() {
            found.extend(files(&path));
        } else {
            found.push(path);
        }
    }
    found
}

#[tokio::test]
async fn files_are_sent_served_and_protected_through_http() {
    let folder = tempfile::tempdir().expect("dossier");
    let root = folder.path().join("fichiers");
    let extra = format!(
        "[auth]\npublic_url = \"https://lyxal.test/\"\n\n[storage.disk]\nroot = {:?}\n",
        root.display().to_string()
    );
    let config = Arc::new(config_with("storage_routes", &extra));
    let client = database("storage_routes").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let context = |auth, storage| {
        build_router(AppContext::new(
            config.clone(),
            Arc::new(client.clone()),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            auth,
            storage,
        ))
        .expect("routeur")
    };
    let router = context(Some(host.clone()), started.storage.clone());

    // Organisations, comptes de service (rédacteur et lecteur d'alpha, rédacteur de beta), buckets
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_role:storage_reader CONTENT { scope_key: "installation", key: "storage_reader", name: "Lecteur des fichiers", scope: "organization", system: true };
            RELATE auth_role:storage_reader->auth_role_grants->auth_permission:⟨storage.object.read⟩;
            CREATE auth_application:redacteur CONTENT { tenant: auth_organization:alpha, client_id: "redacteur-alpha", name: "Rédacteur", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:redacteur->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:lecteur CONTENT { tenant: auth_organization:alpha, client_id: "lecteur-alpha", name: "Lecteur", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:lecteur->auth_has_role->auth_role:storage_reader SET granted_at = time::now();
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "redacteur-beta", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    let mut created = client
        .query(
            r#"
            RETURN <string> record::id(fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "plans" }).data.id);
            RETURN <string> record::id(fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "petits", max_object_size: 10 }).data.id);
            "#,
        )
        .await
        .expect("buckets");
    let plans: Option<String> = created.take(0).expect("bucket");
    let small: Option<String> = created.take(1).expect("bucket");
    let (plans, small) = (plans.expect("bucket"), small.expect("bucket"));
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
    let writer = token("redacteur-alpha").await;
    let reader = token("lecteur-alpha").await;
    let neighbour = token("redacteur-beta").await;
    let object = format!("/api/v1/storage/buckets/{plans}/objects/2026/plan.txt");

    // --- Envoi ----------------------------------------------------------------------------
    let content = b"Plan du chantier, version 3".to_vec();
    let sent = send(
        &router,
        "PUT",
        &object,
        Some(&writer),
        &[
            ("content-type", "text/plain; charset=utf-8"),
            ("content-length", &content.len().to_string()),
            ("x-lyxal-filename", "Plan%20%C3%A9t%C3%A9.txt"),
        ],
        Body::from(content.clone()),
    )
    .await;
    assert_eq!(sent.status, StatusCode::CREATED, "{}", sent.json());
    let record = sent.json()["data"].clone();
    assert_eq!(record["key"], "2026/plan.txt");
    assert_eq!(record["filename"], "Plan été.txt");
    assert_eq!(record["content_type"], "text/plain");
    assert_eq!(record["size"], content.len());
    assert_eq!(record["state"], "available");
    assert_eq!(
        record["blake3"],
        lyxal_crypto::hash::blake3_hex(&content).as_str()
    );
    assert!(record.get("path").is_none() && record.get("backend").is_none());

    // Adresse occupée
    let again = send(&router, "PUT", &object, Some(&writer), &[], Body::from("x")).await;
    assert_eq!(again.status, StatusCode::CONFLICT, "{}", again.json());
    assert_eq!(again.code(), "STORAGE_OBJECT_EXISTS");

    // --- Téléchargement -------------------------------------------------------------------
    let got = send(&router, "GET", &object, Some(&reader), &[], Body::empty()).await;
    assert_eq!(got.status, StatusCode::OK);
    assert_eq!(got.body, content);
    assert_eq!(got.header("content-type"), "text/plain");
    assert_eq!(got.header("content-length"), content.len().to_string());
    assert_eq!(got.header("accept-ranges"), "bytes");
    assert_eq!(got.header("x-content-type-options"), "nosniff");
    assert_eq!(got.header("cache-control"), "private, no-store");
    assert!(got.header("content-disposition").starts_with(
        "attachment; filename=\"Plan _t_.txt\"; filename*=UTF-8''Plan%20%C3%A9t%C3%A9"
    ));
    assert!(got.header("last-modified").ends_with(" GMT"));
    let etag = got.header("etag").to_string();
    assert_eq!(
        etag,
        format!("\"{}\"", lyxal_crypto::hash::blake3_hex(&content))
    );

    let head = send(&router, "HEAD", &object, Some(&reader), &[], Body::empty()).await;
    assert_eq!(head.status, StatusCode::OK);
    assert!(head.body.is_empty());
    assert_eq!(head.header("content-length"), content.len().to_string());
    assert_eq!(head.header("etag"), etag);

    let part = send(
        &router,
        "GET",
        &object,
        Some(&reader),
        &[("range", "bytes=5-11")],
        Body::empty(),
    )
    .await;
    assert_eq!(part.status, StatusCode::PARTIAL_CONTENT);
    assert_eq!(part.body, &content[5..12]);
    assert_eq!(
        part.header("content-range"),
        format!("bytes 5-11/{}", content.len())
    );
    assert_eq!(part.header("content-length"), "7");

    let outside = send(
        &router,
        "GET",
        &object,
        Some(&reader),
        &[("range", "bytes=999-")],
        Body::empty(),
    )
    .await;
    assert_eq!(outside.status, StatusCode::RANGE_NOT_SATISFIABLE);
    assert_eq!(outside.code(), "STORAGE_RANGE_NOT_SATISFIABLE");
    assert_eq!(
        outside.header("content-range"),
        format!("bytes */{}", content.len())
    );

    let unchanged = send(
        &router,
        "GET",
        &object,
        Some(&reader),
        &[("if-none-match", &etag)],
        Body::empty(),
    )
    .await;
    assert_eq!(unchanged.status, StatusCode::NOT_MODIFIED);
    assert!(unchanged.body.is_empty());

    // `If-Range` d'une autre version : la plage est ignorée, le fichier entier est servi
    let stale = send(
        &router,
        "GET",
        &object,
        Some(&reader),
        &[("range", "bytes=0-3"), ("if-range", "\"autre\"")],
        Body::empty(),
    )
    .await;
    assert_eq!(stale.status, StatusCode::OK);
    assert_eq!(stale.body, content);

    // --- Fiche et liste -------------------------------------------------------------------
    let metadata = send(
        &router,
        "GET",
        &format!("{object}?metadata"),
        Some(&reader),
        &[],
        Body::empty(),
    )
    .await;
    assert_eq!(metadata.status, StatusCode::OK);
    assert_eq!(metadata.json()["data"]["id"], record["id"]);
    let listed = send(
        &router,
        "GET",
        &format!("/api/v1/storage/buckets/{plans}/objects?prefix=2026"),
        Some(&reader),
        &[],
        Body::empty(),
    )
    .await;
    assert_eq!(listed.status, StatusCode::OK, "{}", listed.json());
    assert_eq!(listed.json()["data"]["total"], 1);
    assert_eq!(listed.json()["data"]["items"][0]["key"], "2026/plan.txt");

    // --- Droits ---------------------------------------------------------------------------
    let anonymous = send(&router, "GET", &object, None, &[], Body::empty()).await;
    assert_eq!(anonymous.status, StatusCode::UNAUTHORIZED);
    assert_eq!(anonymous.code(), "AUTH_SESSION_REQUIRED");
    let forged = send(
        &router,
        "GET",
        &object,
        Some("faux.jeton"),
        &[],
        Body::empty(),
    )
    .await;
    assert!(forged.status.is_client_error(), "{}", forged.json());

    let refused = send(
        &router,
        "PUT",
        &format!("/api/v1/storage/buckets/{plans}/objects/lecteur.txt"),
        Some(&reader),
        &[],
        Body::from("x"),
    )
    .await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN, "{}", refused.json());
    assert_eq!(refused.code(), "STORAGE_PERMISSION_DENIED");
    let refused = send(
        &router,
        "DELETE",
        &object,
        Some(&reader),
        &[],
        Body::empty(),
    )
    .await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN, "{}", refused.json());

    // Une autre organisation ne voit ni le fichier ni le bucket ; message dans sa langue
    let hidden = send(
        &router,
        "GET",
        &object,
        Some(&neighbour),
        &[("accept-language", "en")],
        Body::empty(),
    )
    .await;
    assert_eq!(hidden.status, StatusCode::NOT_FOUND, "{}", hidden.json());
    assert_eq!(hidden.code(), "STORAGE_OBJECT_NOT_FOUND");
    assert_eq!(hidden.json()["error"]["label"], "File not found");
    let hidden = send(
        &router,
        "PUT",
        &format!("/api/v1/storage/buckets/{plans}/objects/intrus.txt"),
        Some(&neighbour),
        &[],
        Body::from("x"),
    )
    .await;
    assert_eq!(hidden.status, StatusCode::NOT_FOUND, "{}", hidden.json());

    // --- Limites --------------------------------------------------------------------------
    // 4 Mo : au-delà de la limite générale du corps (1 Mo dans cette configuration)
    let large = vec![7u8; 4 * 1024 * 1024];
    let big = format!("/api/v1/storage/buckets/{plans}/objects/gros.bin");
    let sent = send(
        &router,
        "PUT",
        &big,
        Some(&writer),
        &[],
        Body::from(large.clone()),
    )
    .await;
    assert_eq!(sent.status, StatusCode::CREATED, "{}", sent.json());
    let got = send(&router, "GET", &big, Some(&writer), &[], Body::empty()).await;
    assert_eq!(got.body.len(), large.len());
    assert!(got.body == large);
    // La limite générale vaut toujours pour les autres routes
    let limited = send(
        &router,
        "POST",
        "/api/v1/auth/login",
        None,
        &[
            ("content-type", "application/json"),
            ("content-length", &large.len().to_string()),
        ],
        Body::from(large.clone()),
    )
    .await;
    assert_eq!(limited.status, StatusCode::PAYLOAD_TOO_LARGE);

    // Plus grand que la limite du bucket : refus à l'annonce, ou arrêt pendant l'écriture
    let before = files(&root).len();
    let too_large = format!("/api/v1/storage/buckets/{small}/objects/trop.bin");
    let announced = send(
        &router,
        "PUT",
        &too_large,
        Some(&writer),
        &[("content-length", "11")],
        Body::from("12345678901"),
    )
    .await;
    assert_eq!(
        announced.status,
        StatusCode::PAYLOAD_TOO_LARGE,
        "{}",
        announced.json()
    );
    assert_eq!(announced.code(), "STORAGE_OBJECT_TOO_LARGE");
    let unannounced = send(
        &router,
        "PUT",
        &too_large,
        Some(&writer),
        &[],
        Body::from("12345678901"),
    )
    .await;
    assert_eq!(
        unannounced.status,
        StatusCode::UNPROCESSABLE_ENTITY,
        "{}",
        unannounced.json()
    );
    assert_eq!(unannounced.code(), "STORAGE_CONTENT_MISMATCH");

    // Flux interrompu : aucun fichier disponible, aucun octet laissé
    let broken = futures::stream::iter(vec![
        Ok::<_, std::io::Error>(bytes::Bytes::from_static(b"123")),
        Err(std::io::Error::other("connexion coupée")),
    ]);
    let interrupted = send(
        &router,
        "PUT",
        &too_large,
        Some(&writer),
        &[],
        Body::from_stream(broken),
    )
    .await;
    assert_eq!(interrupted.code(), "STORAGE_CONTENT_MISMATCH");
    let missing = send(
        &router,
        "GET",
        &too_large,
        Some(&writer),
        &[],
        Body::empty(),
    )
    .await;
    assert_eq!(missing.status, StatusCode::NOT_FOUND);
    assert_eq!(files(&root).len(), before, "aucun octet laissé");

    // --- Suppression ----------------------------------------------------------------------
    let deleted = send(
        &router,
        "DELETE",
        &object,
        Some(&writer),
        &[],
        Body::empty(),
    )
    .await;
    assert_eq!(deleted.status, StatusCode::OK, "{}", deleted.json());
    assert_eq!(deleted.json()["data"]["state"], "deleted");
    let gone = send(&router, "GET", &object, Some(&writer), &[], Body::empty()).await;
    assert_eq!(gone.status, StatusCode::NOT_FOUND);

    // --- Service ou support absent ----------------------------------------------------------
    let no_backend = context(Some(host.clone()), Default::default());
    let unavailable = send(
        &no_backend,
        "PUT",
        &format!("/api/v1/storage/buckets/{plans}/objects/sans-support.txt"),
        Some(&writer),
        &[],
        Body::from("x"),
    )
    .await;
    assert_eq!(
        unavailable.status,
        StatusCode::SERVICE_UNAVAILABLE,
        "{}",
        unavailable.json()
    );
    assert_eq!(unavailable.code(), "STORAGE_BACKEND_UNKNOWN");
    let no_auth = context(None, started.storage.clone());
    let disabled = send(&no_auth, "GET", &big, Some(&writer), &[], Body::empty()).await;
    assert_eq!(disabled.status, StatusCode::SERVICE_UNAVAILABLE);
    assert_eq!(disabled.code(), "SERVER_AUTH_DISABLED");

    started.runtime.stop_all().await.expect("arrêt");
}
