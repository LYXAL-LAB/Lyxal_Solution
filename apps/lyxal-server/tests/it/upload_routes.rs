//! Routes `/api/v1/storage/uploads` de bout en bout (protocole tus 1.0) sur une base embarquée
//! et un support disque temporaire : capacités, création, position, envoi par morceaux, reprise,
//! refus du protocole, droits de l'appelant, abandon, fichier disponible par les routes
//! ordinaires.

use axum::body::{to_bytes, Body};
use axum::http::{HeaderMap, Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_server::{
    context::AppContext, health::HealthRegistry, http::build_router, metrics::Metrics,
    modules::auth, runtime,
};
use serde_json::Value;
use std::sync::Arc;

use crate::auth_routes::crypto;
use crate::startup::{config_with, database};

const TUS: (&str, &str) = ("tus-resumable", "1.0.0");
const PATCH_TYPE: (&str, &str) = ("content-type", "application/offset+octet-stream");

struct Reply {
    status: StatusCode,
    headers: HeaderMap,
    body: Vec<u8>,
}

impl Reply {
    fn code(&self) -> String {
        serde_json::from_slice::<Value>(&self.body)
            .ok()
            .and_then(|body| body["error"]["code"].as_str().map(str::to_string))
            .unwrap_or_default()
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
    body: &[u8],
) -> Reply {
    let mut request = Request::builder().method(method).uri(uri);
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    for (name, value) in headers {
        request = request.header(*name, *value);
    }
    let request = request.body(Body::from(body.to_vec())).expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let body = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps")
        .to_vec();
    Reply {
        status,
        headers,
        body,
    }
}

/// En-tête `Upload-Metadata` pour des paires clé, valeur.
fn metadata(pairs: &[(&str, &str)]) -> String {
    pairs
        .iter()
        .map(|(key, value)| format!("{key} {}", STANDARD.encode(value)))
        .collect::<Vec<_>>()
        .join(",")
}

#[tokio::test]
async fn a_file_is_sent_in_several_requests_through_the_tus_protocol() {
    let folder = tempfile::tempdir().expect("dossier");
    let extra = format!(
        "[auth]\npublic_url = \"https://lyxal.test/\"\n\n[storage.disk]\nroot = {:?}\n",
        folder.path().display().to_string()
    );
    let config = Arc::new(config_with("upload_routes", &extra));
    let client = database("upload_routes").await;
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
        started.storage.clone(),
    ))
    .expect("routeur");

    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_application:redacteur CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-redacteur-alpha", name: "Rédacteur", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:redacteur->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:second CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-second-alpha", name: "Second", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:second->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    let mut created = client
        .query(
            r#"
            RETURN <string> record::id(fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "videos" }).data.id);
            RETURN <string> record::id(fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "petits", max_object_size: 10 }).data.id);
            "#,
        )
        .await
        .expect("buckets");
    let videos: Option<String> = created.take(0).expect("bucket");
    let small: Option<String> = created.take(1).expect("bucket");
    let (videos, small) = (videos.expect("bucket"), small.expect("bucket"));
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
    let writer = token("lyxal-test-redacteur-alpha").await;
    let second = token("lyxal-test-second-alpha").await;
    let uploads = "/api/v1/storage/uploads";
    let content: Vec<u8> = (0u8..30).collect();
    let film = metadata(&[
        ("bucket", &videos),
        ("key", "2026/film.bin"),
        ("filename", "Film été.bin"),
        ("filetype", "application/octet-stream"),
    ]);

    // --- Capacités : sans authentification ---------------------------------------------------
    let capabilities = send(&router, "OPTIONS", uploads, None, &[], b"").await;
    assert_eq!(capabilities.status, StatusCode::NO_CONTENT);
    assert_eq!(capabilities.header("tus-resumable"), "1.0.0");
    assert_eq!(capabilities.header("tus-version"), "1.0.0");
    assert_eq!(
        capabilities.header("tus-extension"),
        "creation,termination,expiration"
    );
    assert_eq!(capabilities.header("tus-max-size"), "5368709120");

    // --- Création ------------------------------------------------------------------------------
    let length = ("upload-length", "30");
    let film_metadata = ("upload-metadata", film.as_str());
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[length, film_metadata],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::PRECONDITION_FAILED);
    assert_eq!(refused.code(), "STORAGE_UPLOAD_VERSION_UNSUPPORTED");
    assert_eq!(refused.header("tus-version"), "1.0.0");
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[("tus-resumable", "0.2.2"), length, film_metadata],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::PRECONDITION_FAILED);

    let refused = send(
        &router,
        "POST",
        uploads,
        None,
        &[TUS, length, film_metadata],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::UNAUTHORIZED);
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, film_metadata],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::BAD_REQUEST);
    assert_eq!(refused.code(), "STORAGE_UPLOAD_INVALID_REQUEST");
    let no_bucket = metadata(&[("key", "a.bin")]);
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, length, ("upload-metadata", &no_bucket)],
        b"",
    )
    .await;
    assert_eq!(refused.code(), "STORAGE_UPLOAD_INVALID_REQUEST");
    let too_large = metadata(&[("bucket", &small), ("key", "gros.bin")]);
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, length, ("upload-metadata", &too_large)],
        b"",
    )
    .await;
    assert_eq!(refused.code(), "STORAGE_OBJECT_TOO_LARGE");

    let created = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, length, film_metadata],
        b"",
    )
    .await;
    assert_eq!(created.status, StatusCode::CREATED, "{}", created.code());
    assert_eq!(created.header("tus-resumable"), "1.0.0");
    assert!(created.header("upload-expires").ends_with("GMT"));
    assert!(created.body.is_empty());
    let location = created.header("location").to_string();
    assert!(
        location.starts_with("/api/v1/storage/uploads/"),
        "{location}"
    );

    // Adresse déjà réservée par cet envoi
    let refused = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, length, film_metadata],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::CONFLICT);
    assert_eq!(refused.code(), "STORAGE_OBJECT_EXISTS");

    // --- Position ------------------------------------------------------------------------------
    let head = send(&router, "HEAD", &location, Some(&writer), &[TUS], b"").await;
    assert_eq!(head.status, StatusCode::OK);
    assert_eq!(head.header("upload-offset"), "0");
    assert_eq!(head.header("upload-length"), "30");
    assert_eq!(head.header("cache-control"), "no-store");
    assert!(head.header("upload-expires").ends_with("GMT"));

    // Réservé à l'auteur de l'envoi
    let refused = send(&router, "HEAD", &location, Some(&second), &[TUS], b"").await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN);
    let refused = send(&router, "HEAD", &location, None, &[TUS], b"").await;
    assert_eq!(refused.status, StatusCode::UNAUTHORIZED);
    let refused = send(
        &router,
        "PATCH",
        &location,
        Some(&second),
        &[TUS, PATCH_TYPE, ("upload-offset", "0")],
        &content[..10],
    )
    .await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN);

    // --- Morceaux ------------------------------------------------------------------------------
    let refused = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[
            TUS,
            ("content-type", "application/octet-stream"),
            ("upload-offset", "0"),
        ],
        &content[..10],
    )
    .await;
    assert_eq!(refused.status, StatusCode::UNSUPPORTED_MEDIA_TYPE);
    let refused = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[TUS, PATCH_TYPE],
        &content[..10],
    )
    .await;
    assert_eq!(refused.code(), "STORAGE_UPLOAD_INVALID_REQUEST");

    let patched = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "0")],
        &content[..10],
    )
    .await;
    assert_eq!(patched.status, StatusCode::NO_CONTENT, "{}", patched.code());
    assert_eq!(patched.header("upload-offset"), "10");
    assert!(patched.header("upload-expires").ends_with("GMT"));

    // Reprise à une mauvaise position : refus, la position courante est rendue
    let refused = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "0")],
        &content[..10],
    )
    .await;
    assert_eq!(refused.status, StatusCode::CONFLICT);
    assert_eq!(refused.code(), "STORAGE_UPLOAD_OFFSET_MISMATCH");
    assert_eq!(refused.header("upload-offset"), "10");

    // Plus d'octets que la taille annoncée
    let refused = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "10")],
        &[0u8; 21],
    )
    .await;
    assert_eq!(refused.code(), "STORAGE_CONTENT_MISMATCH");

    // Le client demande où en est l'envoi, puis le termine
    let head = send(&router, "HEAD", &location, Some(&writer), &[TUS], b"").await;
    assert_eq!(head.header("upload-offset"), "10");
    let patched = send(
        &router,
        "PATCH",
        &location,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "10")],
        &content[10..],
    )
    .await;
    assert_eq!(patched.status, StatusCode::NO_CONTENT, "{}", patched.code());
    assert_eq!(patched.header("upload-offset"), "30");

    // --- Fichier disponible par les routes ordinaires ------------------------------------------
    let object = format!("/api/v1/storage/buckets/{videos}/objects/2026/film.bin");
    let got = send(&router, "GET", &object, Some(&second), &[], b"").await;
    assert_eq!(got.status, StatusCode::OK);
    assert_eq!(got.body, content);
    let record = send(
        &router,
        "GET",
        &format!("{object}?metadata"),
        Some(&second),
        &[],
        b"",
    )
    .await;
    let record: Value = serde_json::from_slice(&record.body).expect("fiche");
    assert_eq!(record["data"]["filename"], "Film été.bin");
    assert_eq!(record["data"]["state"], "available");
    assert_eq!(record["data"]["size"], 30);
    assert_eq!(
        record["data"]["blake3"],
        lyxal_crypto::hash::blake3_hex(&content).as_str()
    );
    let head = send(&router, "HEAD", &location, Some(&writer), &[TUS], b"").await;
    assert_eq!(head.status, StatusCode::OK);
    assert_eq!(head.header("upload-offset"), "30");
    assert_eq!(head.header("upload-length"), "30");

    // --- Abandon -------------------------------------------------------------------------------
    let other = metadata(&[("bucket", &videos), ("key", "abandon.bin")]);
    let created = send(
        &router,
        "POST",
        uploads,
        Some(&writer),
        &[TUS, length, ("upload-metadata", &other)],
        b"",
    )
    .await;
    assert_eq!(created.status, StatusCode::CREATED);
    let abandoned = created.header("location").to_string();
    let patched = send(
        &router,
        "PATCH",
        &abandoned,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "0")],
        &content[..10],
    )
    .await;
    assert_eq!(patched.status, StatusCode::NO_CONTENT);
    let refused = send(&router, "DELETE", &abandoned, Some(&second), &[TUS], b"").await;
    assert_eq!(refused.status, StatusCode::FORBIDDEN);
    let deleted = send(&router, "DELETE", &abandoned, Some(&writer), &[TUS], b"").await;
    assert_eq!(deleted.status, StatusCode::NO_CONTENT);
    assert_eq!(deleted.header("tus-resumable"), "1.0.0");
    let gone = send(&router, "HEAD", &abandoned, Some(&writer), &[TUS], b"").await;
    assert_eq!(gone.status, StatusCode::NOT_FOUND);
    let gone = send(
        &router,
        "PATCH",
        &abandoned,
        Some(&writer),
        &[TUS, PATCH_TYPE, ("upload-offset", "10")],
        &content[10..],
    )
    .await;
    assert_eq!(gone.status, StatusCode::NOT_FOUND);

    // Identifiant d'envoi mal formé
    let refused = send(
        &router,
        "HEAD",
        &format!("{uploads}/a:b"),
        Some(&writer),
        &[TUS],
        b"",
    )
    .await;
    assert_eq!(refused.status, StatusCode::BAD_REQUEST);
}
