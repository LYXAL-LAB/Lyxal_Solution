//! Essai réel sur un service S3 (Bunny Storage en référence). Ignoré par défaut : il demande un
//! bucket de test et ses identifiants, fournis par l'environnement, jamais par le dépôt.
//!
//! ```text
//! LYXAL_TEST_S3_ENDPOINT           https://de-s3.storage.bunnycdn.com
//! LYXAL_TEST_S3_REGION             de
//! LYXAL_TEST_S3_BUCKET             nom de la zone de test
//! LYXAL_TEST_S3_ACCESS_KEY_ID      nom de la zone de test
//! LYXAL_TEST_S3_SECRET_ACCESS_KEY  mot de passe de la zone de test
//! cargo test -p lyxal_storage --test it real_s3 -- --ignored
//! ```
//!
//! Les octets écrits sont retirés à la fin.

use futures::{stream, StreamExt};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::worker::CancellationToken;
use lyxal_runtime::ModuleContext;
use lyxal_storage::models::{BucketRefParams, ObjectGetParams, SettingsSetParams};
use lyxal_storage::{
    BackendConfig, Backends, ByteRange, CleanupReport, StorageCleanupWorker, StorageHealthCheck,
    StorageService, StorageStore, MODULE_ID, PART_SIZE,
};
use lyxal_surreal::{SecretString, ToSql};
use std::sync::Arc;
use std::time::Duration;

use crate::support::{chunks, installed_client, read_all, request};

fn variable(name: &str) -> String {
    std::env::var(name).unwrap_or_else(|_| panic!("{name} requis pour l'essai réel"))
}

#[tokio::test]
#[ignore = "essai réel : demande un bucket S3 de test (variables LYXAL_TEST_S3_*)"]
async fn real_s3_service_stores_serves_and_cleans() {
    let backends = Arc::new(
        Backends::new()
            .with(
                "default",
                BackendConfig::S3 {
                    endpoint: variable("LYXAL_TEST_S3_ENDPOINT"),
                    region: variable("LYXAL_TEST_S3_REGION"),
                    bucket: variable("LYXAL_TEST_S3_BUCKET"),
                    access_key_id: variable("LYXAL_TEST_S3_ACCESS_KEY_ID"),
                    secret_access_key: SecretString::new(variable(
                        "LYXAL_TEST_S3_SECRET_ACCESS_KEY",
                    ))
                    .expect("clé secrète"),
                    path_style: true,
                    allow_http: false,
                },
            )
            .expect("support"),
    );
    let store = StorageStore::new(installed_client().await);
    let service = StorageService::new(store.clone(), backends.clone());
    let worker = StorageCleanupWorker::new(
        store.clone(),
        backends.clone(),
        Duration::from_secs(3600),
        50,
    )
    .expect("worker");
    let context = ModuleContext::new(MODULE_ID);

    // Sonde : fichier témoin écrit, relu et retiré
    let probe = StorageHealthCheck::new(store.clone(), backends.clone())
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(probe.status, HealthStatus::Healthy, "{probe:?}");

    store
        .settings_set(SettingsSetParams {
            deleted_retention_days: Some(0),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglages");
    let bucket = store
        .bucket_create(lyxal_storage::models::BucketCreateParams::named(
            None,
            "essai-reel",
        ))
        .await
        .expect("bucket")
        .id
        .to_sql();

    // Petit fichier : relecture à l'identique, plage d'octets, intégrité
    let content = b"Essai reel du support S3 de Lyxal".to_vec();
    let small = service
        .put(request(&bucket, "petit.txt"), chunks(&[&content]))
        .await
        .expect("écriture");
    let opened = service
        .open(ObjectGetParams::by_id(small.id.to_sql()), None)
        .await
        .expect("lecture");
    assert_eq!(read_all(opened).await, content);
    let part = service
        .open(
            ObjectGetParams::by_id(small.id.to_sql()),
            Some(ByteRange::FromTo(6, 9)),
        )
        .await
        .expect("plage");
    assert_eq!(read_all(part).await, &content[6..10]);
    service.verify(&small.id.to_sql()).await.expect("intégrité");

    // Fichier envoyé en plusieurs parties (trois parties de 8 Mo)
    let chunk = bytes::Bytes::from(vec![42u8; 1024 * 1024]);
    let parts = 2 * PART_SIZE / chunk.len() + 4;
    let large = service
        .put(
            request(&bucket, "dossier/gros.bin"),
            stream::repeat(chunk.clone())
                .take(parts)
                .map(Ok::<_, std::convert::Infallible>),
        )
        .await
        .expect("écriture en plusieurs parties");
    assert_eq!(large.size, Some((parts * chunk.len()) as i64));
    service.verify(&large.id.to_sql()).await.expect("intégrité");

    // Suppression puis purge : octets du petit fichier retirés
    service
        .delete(&small.id.to_sql())
        .await
        .expect("suppression");
    let report = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("nettoyage");
    assert_eq!(
        report,
        CleanupReport {
            purged: 1,
            ..CleanupReport::default()
        }
    );

    // Bucket supprimé : son préfixe est retiré du service
    service
        .delete(&large.id.to_sql())
        .await
        .expect("suppression");
    worker
        .run_once(&CancellationToken::new())
        .await
        .expect("nettoyage");
    store
        .bucket_delete(BucketRefParams {
            bucket: bucket.clone(),
        })
        .await
        .expect("bucket supprimé");
    let report = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("nettoyage");
    assert_eq!(report.reclaimed, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");

    // Rien ne reste sous le préfixe de l'installation écrit par cet essai
    let backend = backends.get("default").expect("support").store();
    let prefix = object_store::path::Path::parse(
        small
            .path
            .rsplit_once('/')
            .map_or(small.path.as_str(), |(prefix, _)| prefix),
    )
    .expect("préfixe");
    let left: Vec<_> = backend.list(Some(&prefix)).collect().await;
    assert!(left.is_empty(), "{} fichier(s) laissé(s)", left.len());
}
