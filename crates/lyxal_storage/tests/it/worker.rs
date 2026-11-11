//! Worker de nettoyage et sonde de santé.

use bytes::Bytes;
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext};
use lyxal_runtime::ModuleContext;
use lyxal_storage::models::{
    BucketCreateParams, ObjectBeginParams, ObjectGetParams, SettingsSetParams,
};
use lyxal_storage::{Backends, CleanupReport, StorageCleanupWorker, StorageHealthCheck, MODULE_ID};
use lyxal_surreal::ToSql;
use object_store::path::Path;
use object_store::ObjectStoreExt;
use std::sync::Arc;
use std::time::Duration;

use crate::support::{bench, chunks, request, Bench, Kind, KINDS};

fn worker(bench: &Bench) -> StorageCleanupWorker {
    StorageCleanupWorker::new(
        bench.store.clone(),
        bench.backends.clone(),
        Duration::from_secs(3600),
        2,
    )
    .expect("worker")
}

async fn pass(bench: &Bench) -> CleanupReport {
    worker(bench)
        .run_once(&CancellationToken::new())
        .await
        .expect("passage")
}

async fn count(bench: &Bench, table: &str) -> usize {
    let mut response = bench
        .client
        .query(format!("RETURN count(SELECT id FROM {table});"))
        .await
        .expect("requête");
    let total: Option<i64> = response.take(0).expect("total");
    usize::try_from(total.expect("total")).expect("total")
}

#[tokio::test]
async fn abandoned_writes_and_deleted_files_are_removed() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("plans").await;
        // Conservation nulle : un fichier supprimé est purgé au passage suivant
        bench
            .store
            .settings_set(SettingsSetParams {
                deleted_retention_days: Some(0),
                ..SettingsSetParams::default()
            })
            .await
            .expect("réglages");

        // Trois écritures abandonnées après l'envoi d'octets (plus que la taille d'un paquet)
        let backend = bench.backends.get("default").expect("support");
        for index in 0..3 {
            let begun = bench
                .store
                .object_begin(ObjectBeginParams {
                    bucket: bucket.clone(),
                    key: format!("abandon-{index}.bin"),
                    filename: "abandon.bin".to_string(),
                    declared_type: None,
                    declared_size: None,
                })
                .await
                .expect("ouverture d'écriture");
            backend
                .put(
                    &Path::parse(&begun.path).expect("emplacement"),
                    Bytes::from_static(b"octets orphelins").into(),
                )
                .await
                .expect("octets");
        }
        let kept = bench
            .service
            .put(request(&bucket, "garde.bin"), chunks(&[b"a conserver"]))
            .await
            .expect("écriture");
        let removed = bench
            .service
            .put(request(&bucket, "retire.bin"), chunks(&[b"a retirer"]))
            .await
            .expect("écriture");
        bench
            .service
            .delete(&removed.id.to_sql())
            .await
            .expect("suppression");

        // Rien n'est dû pour les écritures en attente : seul le fichier supprimé part
        assert_eq!(
            pass(&bench).await,
            CleanupReport {
                purged: 1,
                ..CleanupReport::default()
            },
            "{kind:?}"
        );
        assert_eq!(bench.stored_paths().await.len(), 4);

        bench
            .run("UPDATE storage_object SET pending_expires_at = time::now() - 1m WHERE state = 'pending';")
            .await;
        assert_eq!(
            pass(&bench).await,
            CleanupReport {
                expired: 3,
                purged: 3,
                ..CleanupReport::default()
            },
            "{kind:?}"
        );
        assert_eq!(bench.stored_paths().await, vec![kept.path.clone()]);
        assert_eq!(count(&bench, "storage_object").await, 1);

        // Rejeu : rien à faire, aucune erreur
        assert_eq!(pass(&bench).await, CleanupReport::default());
    }
}

#[tokio::test]
async fn the_bytes_of_a_purged_organization_are_removed() {
    for kind in KINDS {
        let bench = bench(kind).await;
        bench
            .run("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };")
            .await;
        let installation = bench.bucket("communs").await;
        let kept = bench
            .service
            .put(
                request(&installation, "commun.bin"),
                chunks(&[b"installation"]),
            )
            .await
            .expect("écriture");
        for name in ["plans", "photos"] {
            let bucket = bench
                .store
                .bucket_create(BucketCreateParams::named(
                    Some("auth_organization:alpha".to_string()),
                    name,
                ))
                .await
                .expect("bucket")
                .id
                .to_sql();
            for key in ["a.bin", "dossier/b.bin"] {
                bench
                    .service
                    .put(request(&bucket, key), chunks(&[b"organisation"]))
                    .await
                    .expect("écriture");
            }
        }
        assert_eq!(bench.stored_paths().await.len(), 5);

        bench.run("DELETE auth_organization:alpha;").await;
        assert_eq!(
            count(&bench, "storage_object").await,
            1,
            "fiches en cascade"
        );
        assert_eq!(
            bench.stored_paths().await.len(),
            5,
            "octets encore présents"
        );

        assert_eq!(
            pass(&bench).await,
            CleanupReport {
                reclaimed: 2,
                ..CleanupReport::default()
            },
            "{kind:?}"
        );
        assert_eq!(bench.stored_paths().await, vec![kept.path.clone()]);
        assert_eq!(count(&bench, "storage_reclaim").await, 0);
        assert_eq!(pass(&bench).await, CleanupReport::default());

        // Le fichier de l'installation est intact
        bench
            .service
            .verify(&kept.id.to_sql())
            .await
            .expect("fichier intact");
    }
}

#[tokio::test]
async fn a_failing_item_is_kept_and_does_not_stop_the_others() {
    let bench = bench(Kind::Memory).await;
    let unknown = bench
        .store
        .bucket_create(BucketCreateParams {
            backend: "archive_froide".to_string(),
            ..BucketCreateParams::named(None, "froid")
        })
        .await
        .expect("bucket")
        .id
        .to_sql();
    // Fiche supprimée sur un support que ce serveur ne connaît pas
    bench
        .service
        .put(request(&unknown, "a.bin"), chunks(&[b"abc"]))
        .await
        .expect_err("support inconnu");
    let plans = bench.bucket("plans").await;
    bench
        .service
        .put(
            lyxal_storage::PutRequest {
                size: Some(9),
                ..request(&plans, "b.bin")
            },
            chunks(&[b"abc"]),
        )
        .await
        .expect_err("écart de taille");

    let report = pass(&bench).await;
    assert_eq!(
        report,
        CleanupReport {
            purged: 1,
            failed: 1,
            ..CleanupReport::default()
        }
    );
    // La fiche du support inconnu attend ; elle n'est pas perdue
    assert_eq!(count(&bench, "storage_object").await, 1);
    let waiting = bench
        .store
        .object_get(ObjectGetParams::by_id(
            bench
                .store
                .object_purge_list(lyxal_storage::models::BatchParams { limit: 10 })
                .await
                .expect("liste")
                .items[0]
                .id
                .to_sql(),
        ))
        .await
        .expect("fiche");
    assert_eq!(waiting.backend, "archive_froide");
}

#[tokio::test]
async fn the_worker_stops_on_cancellation() {
    let bench = bench(Kind::Memory).await;
    let bucket = bench.bucket("plans").await;
    bench
        .service
        .put(
            lyxal_storage::PutRequest {
                size: Some(9),
                ..request(&bucket, "b.bin")
            },
            chunks(&[b"abc"]),
        )
        .await
        .expect_err("écart de taille");

    // Annulation avant le passage : rien n'est fait
    let cancelled = CancellationToken::new();
    cancelled.cancel();
    let worker = worker(&bench);
    assert_eq!(
        worker.run_once(&cancelled).await.expect("passage"),
        CleanupReport::default()
    );
    assert_eq!(count(&bench, "storage_object").await, 1);

    // Boucle du worker : un passage, puis arrêt sur annulation pendant l'attente
    let descriptor = worker.descriptor().clone();
    let cancellation = CancellationToken::new();
    let context = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new(descriptor.module_id.clone()),
        cancellation.clone(),
    );
    let stopper = async {
        while count(&bench, "storage_object").await > 0 {
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        cancellation.cancel();
    };
    let (ran, ()) = tokio::time::timeout(Duration::from_secs(30), async {
        tokio::join!(worker.run(context), stopper)
    })
    .await
    .expect("arrêt du worker");
    ran.expect("worker");
}

#[tokio::test]
async fn the_probe_reports_each_backend() {
    let context = ModuleContext::new(MODULE_ID);
    for kind in KINDS {
        let bench = bench(kind).await;
        let healthy = StorageHealthCheck::new(bench.store.clone(), bench.backends.clone())
            .check(&context)
            .await
            .expect("sonde");
        assert_eq!(healthy.status, HealthStatus::Healthy, "{kind:?}");
        assert!(
            bench.stored_paths().await.is_empty(),
            "fichier témoin retiré"
        );

        let degraded = StorageHealthCheck::new(bench.store.clone(), Arc::new(Backends::new()))
            .check(&context)
            .await
            .expect("sonde");
        assert_eq!(degraded.status, HealthStatus::Degraded);
        assert!(degraded
            .message
            .as_deref()
            .is_some_and(|m| m.contains("STORAGE_BACKEND_UNKNOWN")));
    }
}
