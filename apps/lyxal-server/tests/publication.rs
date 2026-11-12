//! Publication de bout en bout vers le catalogue par le compte de service `lyxal_auth`.
//!
//! Exécutable de tests séparé : il fournit la clé applicative par
//! `LYXAL__CRYPTO__APPLICATION_KEY` (variable d'environnement du processus), ce qui changerait
//! la configuration des autres tests de l'hôte s'ils tournaient dans le même processus.
#![cfg(feature = "module-ingestion")]

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_server::{config::AppConfig, runtime};
use lyxal_storage::models::BucketListParams;
use lyxal_storage::{BackendConfig, Backends, PutRequest, StorageService, StorageStore};
use lyxal_surreal::ToSql;
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

const KEY_VAR: &str = "LYXAL__CRYPTO__APPLICATION_KEY";
const KEY_ID_VAR: &str = "LYXAL__CRYPTO__APPLICATION_KEY_ID";

/// Configuration de test, avec ou sans service de connexion (`auth.public_url`).
fn config(with_auth: bool) -> AppConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    let auth = if with_auth {
        "[auth]\npublic_url = \"https://lyxal.test/\"\n"
    } else {
        ""
    };
    fs::write(
        directory.path().join("default.toml"),
        format!(
            r#"
[application]
name = "Lyxal Test"
environment = "test"
instance_id = "test"
version = "0.1.0"

[server]
host = "127.0.0.1"
port = 0
request_timeout_seconds = 10
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "publication"
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
{auth}"#
        ),
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

/// Envoie un fichier source dans le bucket de l'ingestion, créé par l'hôte au démarrage, sur un
/// support en mémoire propre au test (l'hôte n'a pas de support configuré : son worker laisse le
/// lot au test) ; rend sa fiche `storage_object:<clé>`.
async fn source_object(client: &Surreal<Any>, name: &str, content: &[u8]) -> String {
    let backends = Backends::new()
        .with("default", BackendConfig::Memory)
        .expect("support mémoire");
    let service = StorageService::new(StorageStore::new(client.clone()), Arc::new(backends));
    let bucket = service
        .store()
        .bucket_list(BucketListParams {
            tenant: None,
            limit: 100,
            start: 0,
        })
        .await
        .expect("buckets")
        .items
        .into_iter()
        .find(|bucket| bucket.name == lyxal_pipeline_ingestion::SOURCE_BUCKET)
        .expect("bucket des fichiers sources créé au démarrage")
        .id;
    let chunk: Result<bytes::Bytes, std::convert::Infallible> =
        Ok(bytes::Bytes::copy_from_slice(content));
    service
        .put(
            PutRequest {
                bucket: bucket.to_sql(),
                key: name.to_string(),
                filename: name.to_string(),
                content_type: None,
                size: Some(content.len() as u64),
            },
            futures::stream::iter([chunk]),
        )
        .await
        .expect("fichier source")
        .id
        .to_sql()
}

/// Hôte configuré (clé applicative et `auth.public_url`) → abonnement actif ; l'approbation
/// d'un manifeste publie ses articles au catalogue sous une session du compte de service
/// `lyxal-catalogue-sync`, sans clé de signature partagée.
#[tokio::test]
async fn approved_manifest_is_published_by_the_sync_service_account() {
    // Clé applicative éphémère (32 octets aléatoires, Base64 canonique)
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    std::env::set_var(KEY_VAR, STANDARD.encode(&bytes));
    std::env::set_var(KEY_ID_VAR, "app-test");

    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("publication")
        .await
        .expect("ns/db");
    let started = runtime::start(&config(true), &client)
        .await
        .expect("démarrage");
    assert!(started.auth.is_some(), "service de connexion configuré");
    let runtime = started.runtime;

    // Aucun accès JWT dédié : seuls les accès de lyxal_auth existent
    let mut info = client.query("INFO FOR DB").await.expect("INFO FOR DB");
    let info: Option<serde_json::Value> = info.take(0).expect("infos");
    assert!(
        info.as_ref()
            .and_then(|i| i["accesses"]["lyxal_catalogue_sync"].as_str())
            .is_none(),
        "{info:?}"
    );
    let mut sub = client
        .query("SELECT VALUE [event_pattern, handler_name, is_active] FROM event_subscription WHERE name = 'ingestion_manifest_publication'")
        .await
        .expect("abonnement");
    let sub: Vec<serde_json::Value> = sub.take(0).expect("abonnement");
    assert_eq!(
        sub,
        vec![serde_json::json!([
            "ingestion.manifest.approved",
            "ingestion.manifest_publisher",
            true
        ])]
    );

    // Lot, article vérifié avec preuve éligible, manifeste scellé puis approuvé (session système)
    let fingerprint = lyxal_crypto::blake3_hex(b"lot_srv:BA13");
    let source = source_object(&client, "srv.csv", b"srv.csv").await;
    client
        .query(
            "RETURN fn::ingestion_batch_create({ id: 'lot_srv', source_type: 'CSV', fournisseur_id: 'FOURN_PLACO', source_object: $source }).ok;
             RETURN fn::ingestion_batch_claim({ id: 'lot_srv', owner: 'test' }).ok;
             RETURN fn::ingestion_staged_save({ claim: { owner: 'test', generation: 1 }, batch_id: 'lot_srv', rules_version: '1', items: [{ ligne_numero: 1, canonical_fingerprint: $fp, fabricant: 'PLACO', reference_fabricant: 'BA13', libelle_commercial: 'Plaque BA13', unite_reference: 'M2', conditionnement: { unite_vente: 'PCE', quantite_par_colis: 1.0 }, qualification: 'VERIFIED', commercial_proof: { proof_type: 'CERTIFIED_MANUFACTURER_EDI', proof_reference: 'EDI-2026-PLACO-001', source_authority: 'EDI_HUB_SAINT_GOBAIN', verified_by: 'system:edi_receiver', verified_at: '2026-10-25T10:00:00Z' } }] }).data[0].ok;
             RETURN fn::ingestion_manifest_save({ manifest_ref: 'MAN-SRV', batch_id: 'lot_srv', statut: 'SEALED', nb_articles_insert: 1 }).ok;
             RETURN fn::ingestion_manifest_approve({ manifest_ref: 'MAN-SRV', justification: 'Manifeste contrôlé avant publication' }).ok;",
        )
        .bind(("fp", fingerprint))
        .bind(("source", source))
        .await
        .expect("préparation")
        .check()
        .expect("préparation réussie");

    // Le moteur d'événements livre ingestion.manifest.approved au consommateur de publication
    let mut statut = String::new();
    for _ in 0..200 {
        let mut res = client
            .query("SELECT VALUE statut FROM ONLY ingestion_publication_manifest WHERE manifest_ref = 'MAN-SRV' LIMIT 1")
            .await
            .expect("manifeste");
        statut = res
            .take::<Option<String>>(0)
            .expect("statut")
            .unwrap_or_default();
        if statut == "COMMITTED" {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(50)).await;
    }
    assert_eq!(statut, "COMMITTED");
    let mut item = client
        .query("SELECT VALUE [master_id, is_custom, reference_fabricant] FROM catalogue_item")
        .await
        .expect("catalogue");
    let items: Vec<serde_json::Value> = item.take(0).expect("articles");
    assert_eq!(items.len(), 1);
    assert_eq!(items[0][1], false);
    assert_eq!(items[0][2], "BA13");

    // Exécution enregistrée par le compte de service, session ouverte sous son application
    let mut trace = client
        .query("SELECT VALUE transitions[WHERE to_state = 'COMMITTED'][0].triggered_by FROM ONLY ingestion_publication_manifest WHERE manifest_ref = 'MAN-SRV' LIMIT 1;
                SELECT VALUE kind FROM auth_session WHERE application = auth_application:catalogue_sync;")
        .await
        .expect("trace");
    let triggered_by: Option<String> = trace.take(0).expect("opérateur");
    let kinds: Vec<String> = trace.take(1).expect("sessions");
    assert_eq!(
        triggered_by.as_deref(),
        Some("auth_application:catalogue_sync")
    );
    assert!(
        !kinds.is_empty() && kinds.iter().all(|k| k == "service"),
        "{kinds:?}"
    );

    runtime.stop_all().await.expect("arrêt");

    // Redémarrage sans service de connexion : abonnement suspendu
    std::env::remove_var(KEY_VAR);
    std::env::remove_var(KEY_ID_VAR);
    let without_auth = runtime::start(&config(false), &client)
        .await
        .expect("redémarrage sans service de connexion")
        .runtime;
    let mut state = client
        .query("SELECT VALUE is_active FROM event_subscription WHERE name = 'ingestion_manifest_publication'")
        .await
        .expect("état");
    let active: Vec<bool> = state.take(0).expect("abonnement");
    assert_eq!(active, vec![false]);
    without_auth.stop_all().await.expect("arrêt");
}
