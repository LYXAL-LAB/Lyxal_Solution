//! Envoi reprenable : fichier reçu en plusieurs requêtes, reprise après coupure, position tenue
//! par la base, assemblage contrôlé, abandon, expiration, retrait des parties par le worker.

use bytes::Bytes;
use futures::stream;
use lyxal_runtime::worker::CancellationToken;
use lyxal_storage::models::{ObjectGetParams, ObjectState};
use lyxal_storage::{
    ClamAvScanner, CleanupReport, ScannerConfig, StorageCleanupWorker, StorageError,
    StorageService, UploadRequest, PART_SIZE,
};
use lyxal_surreal::ToSql;
use std::sync::Arc;
use std::time::Duration;

use crate::content::{eicar, elf};
use crate::support::{bench, chunks, clamd, read_all, Bench, Clamd, Kind, KINDS};

fn upload(bucket: &str, key: &str, size: usize) -> UploadRequest {
    UploadRequest {
        bucket: bucket.to_string(),
        key: key.to_string(),
        filename: key.to_string(),
        content_type: None,
        size: size as u64,
    }
}

/// Contenu reconnaissable : chaque octet dépend de sa position.
fn data(size: usize) -> Vec<u8> {
    (0..size).map(|i| (i % 251) as u8).collect()
}

async fn pass(bench: &Bench) -> CleanupReport {
    StorageCleanupWorker::new(
        bench.store.clone(),
        bench.backends.clone(),
        Duration::from_secs(3600),
        10,
    )
    .expect("worker")
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

fn parts_of(paths: &[String]) -> usize {
    paths.iter().filter(|path| path.contains(".parts/")).count()
}

#[tokio::test]
async fn a_file_is_sent_in_several_requests_and_resumed_after_a_cut() {
    for kind in KINDS {
        let bench = bench(kind).await;
        bench
            .run("fn::storage_settings_set({ max_object_size: 20971520 });")
            .await;
        let bucket = bench.bucket("videos").await;
        let size = PART_SIZE + 2 * 1024 * 1024;
        let content = data(size);
        let first = PART_SIZE + 1024 * 1024;
        let cut = first + 512 * 1024;

        let status = bench
            .service
            .upload_create(upload(&bucket, "film.bin", size))
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(
            (status.offset, status.length, status.complete),
            (0, size as i64, false)
        );
        assert!(status.expires_at.is_some());
        let id = status.id.to_sql();

        // Première requête : plus d'une partie
        let appended = bench
            .service
            .upload_append(&id, 0, chunks(&[&content[..first]]))
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(appended.offset, first as u64);
        assert!(appended.object.is_none());
        assert_eq!(parts_of(&bench.stored_paths().await), 2, "{kind:?}");

        // Coupure en cours de requête : ce qui est reçu est conservé
        let interrupted = stream::iter(vec![
            Ok(Bytes::copy_from_slice(&content[first..cut])),
            Err("connexion coupée"),
        ]);
        let error = bench
            .service
            .upload_append(&id, first as u64, interrupted)
            .await
            .expect_err("coupure");
        assert_eq!(error.code(), "STORAGE_CONTENT_MISMATCH");
        let status = bench.service.upload_status(&id).await.expect("état");
        assert_eq!(status.offset, cut as i64, "{kind:?}");

        // Reprise à une mauvaise position : refus, la position courante est rendue
        let error = bench
            .service
            .upload_append(&id, first as u64, chunks(&[&content[first..]]))
            .await
            .expect_err("mauvaise position");
        assert!(
            matches!(error, StorageError::UploadOffsetMismatch(offset) if offset == cut as u64),
            "{error}"
        );

        // Trop d'octets : refus, rien n'est ajouté
        let mut excess = content[cut..].to_vec();
        excess.push(0);
        let error = bench
            .service
            .upload_append(&id, cut as u64, chunks(&[&excess]))
            .await
            .expect_err("dépassement");
        assert_eq!(error.code(), "STORAGE_CONTENT_MISMATCH");
        assert_eq!(
            bench.service.upload_status(&id).await.expect("état").offset,
            cut as i64
        );

        // Reprise à la bonne position : le fichier est assemblé et disponible
        let appended = bench
            .service
            .upload_append(&id, cut as u64, chunks(&[&content[cut..]]))
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(appended.offset, size as u64);
        let object = appended.object.expect("fichier");
        assert_eq!(object.state, ObjectState::Available);
        assert_eq!(object.size, Some(size as i64));
        assert_eq!(
            object.blake3.as_deref(),
            Some(lyxal_crypto::hash::blake3_hex(&content).as_str())
        );
        let opened = bench
            .service
            .open(ObjectGetParams::by_address(&bucket, "film.bin"), None)
            .await
            .expect("lecture");
        assert!(
            read_all(opened).await == content,
            "{kind:?} : contenu relu différent"
        );
        let status = bench.service.upload_status(&id).await.expect("état");
        assert_eq!(
            (status.state, status.offset, status.complete),
            (ObjectState::Available, size as i64, true)
        );

        // Les parties restent sur le support jusqu'au passage du worker, inscrit par la base :
        // un arrêt du serveur juste après la fin de l'envoi ne les oublie pas
        assert_eq!(count(&bench, "storage_upload_part").await, 0);
        assert_eq!(count(&bench, "storage_reclaim").await, 1);
        assert_eq!(parts_of(&bench.stored_paths().await), 4, "{kind:?}");
        assert_eq!(
            pass(&bench).await,
            CleanupReport {
                reclaimed: 1,
                ..CleanupReport::default()
            }
        );
        assert_eq!(
            bench.stored_paths().await,
            vec![object.path.clone()],
            "{kind:?}"
        );
        assert_eq!(count(&bench, "storage_reclaim").await, 0);
    }
}

#[tokio::test]
async fn two_requests_at_the_same_position_do_not_both_win() {
    let bench = bench(Kind::Memory).await;
    let bucket = bench.bucket("videos").await;
    let id = bench
        .service
        .upload_create(upload(&bucket, "a.bin", 200))
        .await
        .expect("envoi")
        .id
        .to_sql();
    let (first, second) = tokio::join!(
        bench.service.upload_append(&id, 0, chunks(&[&[1u8; 100]])),
        bench.service.upload_append(&id, 0, chunks(&[&[2u8; 100]])),
    );
    assert!(first.is_ok() != second.is_ok(), "{first:?} {second:?}");
    assert_eq!(
        bench.service.upload_status(&id).await.expect("état").offset,
        100
    );
    assert_eq!(count(&bench, "storage_upload_part").await, 1);
    // Les octets de la requête refusée ne restent pas sur le support
    assert_eq!(parts_of(&bench.stored_paths().await), 1);

    let winner = if first.is_ok() { 1u8 } else { 2u8 };
    bench
        .service
        .upload_append(&id, 100, chunks(&[&[9u8; 100]]))
        .await
        .expect("fin")
        .object
        .expect("fichier");
    let opened = bench
        .service
        .open(ObjectGetParams::by_address(&bucket, "a.bin"), None)
        .await
        .expect("lecture");
    let mut expected = vec![winner; 100];
    expected.extend_from_slice(&[9u8; 100]);
    assert_eq!(read_all(opened).await, expected);
}

fn scanner(address: &str) -> Arc<ClamAvScanner> {
    Arc::new(ClamAvScanner::new(
        ScannerConfig::Tcp {
            address: address.to_string(),
        },
        Duration::from_secs(5),
    ))
}

/// Envoie un contenu en deux requêtes ; rend l'identifiant de l'envoi et le résultat de la
/// dernière.
async fn send(
    service: &StorageService,
    bucket: &str,
    key: &str,
    content: &[u8],
) -> (String, Result<lyxal_storage::Appended, StorageError>) {
    let id = service
        .upload_create(upload(bucket, key, content.len()))
        .await
        .expect("envoi")
        .id
        .to_sql();
    let half = content.len() / 2;
    service
        .upload_append(&id, 0, chunks(&[&content[..half]]))
        .await
        .expect("première moitié");
    let last = service
        .upload_append(&id, half as u64, chunks(&[&content[half..]]))
        .await;
    (id, last)
}

#[tokio::test]
async fn the_assembled_file_goes_through_the_content_checks() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("libre").await;

        // Programme exécutable : refusé à l'assemblage, l'envoi n'existe plus
        let (id, last) = send(&bench.service, &bucket, "outil.bin", &elf()).await;
        assert_eq!(
            last.expect_err("exécutable").code(),
            "STORAGE_OBJECT_TYPE_REFUSED"
        );
        let error = bench
            .service
            .upload_status(&id)
            .await
            .expect_err("envoi retiré");
        assert_eq!(error.code(), "STORAGE_OBJECT_NOT_FOUND");

        // Fichier infecté : refusé par l'antivirus
        let address = clamd(Clamd::Scanning {
            stream_max_length: 1024 * 1024,
        })
        .await;
        let scanned = bench.service.clone().with_scanner(scanner(&address));
        let (_, last) = send(&scanned, &bucket, "virus.bin", &eicar()).await;
        assert_eq!(last.expect_err("virus").code(), "STORAGE_OBJECT_INFECTED");

        // Fichier sain : disponible
        let (_, last) = send(&scanned, &bucket, "sain.txt", b"nom;prix\nvis;0,12\n").await;
        assert_eq!(
            last.expect("sain").object.expect("fichier").state,
            ObjectState::Available
        );

        // Rien ne reste des envois refusés, après le passage du worker
        let report = pass(&bench).await;
        assert_eq!(
            (report.purged, report.reclaimed, report.failed),
            (2, 3, 0),
            "{kind:?}"
        );
        assert_eq!(bench.stored_paths().await.len(), 1, "{kind:?}");
        assert_eq!(count(&bench, "storage_upload_part").await, 0);
    }
}

#[tokio::test]
async fn an_interrupted_assembly_is_finished_by_the_worker() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("libre").await;

        // Antivirus injoignable pendant l'assemblage : échec passager, l'envoi reste complet
        let unreachable = bench.service.clone().with_scanner(scanner("127.0.0.1:1"));
        let content = b"plan de chantier";
        let (id, last) = send(&unreachable, &bucket, "plan.txt", content).await;
        let error = last.expect_err("antivirus injoignable");
        assert_eq!(error.code(), "STORAGE_SCANNER_UNAVAILABLE");
        assert!(error.is_retryable());
        let status = bench.service.upload_status(&id).await.expect("état");
        assert_eq!(
            (status.state, status.complete),
            (ObjectState::Pending, true),
            "{kind:?}"
        );

        // Le worker termine l'assemblage, puis retire les parties au passage suivant ou au même
        let report = pass(&bench).await;
        assert_eq!((report.assembled, report.failed), (1, 0), "{kind:?}");
        let opened = bench
            .service
            .open(ObjectGetParams::by_address(&bucket, "plan.txt"), None)
            .await
            .expect("lecture");
        assert_eq!(read_all(opened).await, content);
        pass(&bench).await;
        assert_eq!(bench.stored_paths().await.len(), 1, "{kind:?}");
        assert_eq!(pass(&bench).await, CleanupReport::default());
    }
}

#[tokio::test]
async fn an_abandoned_or_expired_upload_leaves_nothing() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("libre").await;

        // Abandon par le client
        let abandoned = bench
            .service
            .upload_create(upload(&bucket, "a.bin", 100))
            .await
            .expect("envoi")
            .id
            .to_sql();
        bench
            .service
            .upload_append(&abandoned, 0, chunks(&[&[1u8; 40]]))
            .await
            .expect("partie");
        bench
            .service
            .upload_terminate(&abandoned)
            .await
            .expect("abandon");
        let error = bench
            .service
            .upload_append(&abandoned, 40, chunks(&[&[1u8; 60]]))
            .await
            .expect_err("envoi abandonné");
        assert_eq!(error.code(), "STORAGE_OBJECT_NOT_FOUND");

        // Délai dépassé
        let expired = bench
            .service
            .upload_create(upload(&bucket, "b.bin", 100))
            .await
            .expect("envoi")
            .id
            .to_sql();
        bench
            .service
            .upload_append(&expired, 0, chunks(&[&[2u8; 40]]))
            .await
            .expect("partie");
        bench
            .run(&format!(
                "UPDATE {expired} SET pending_expires_at = time::now() - 1m;"
            ))
            .await;
        let error = bench
            .service
            .upload_append(&expired, 40, chunks(&[&[2u8; 60]]))
            .await
            .expect_err("envoi expiré");
        assert_eq!(error.code(), "STORAGE_UPLOAD_EXPIRED");

        assert_eq!(parts_of(&bench.stored_paths().await), 2, "{kind:?}");
        assert_eq!(
            pass(&bench).await,
            CleanupReport {
                expired: 1,
                purged: 2,
                reclaimed: 2,
                ..CleanupReport::default()
            },
            "{kind:?}"
        );
        assert!(bench.stored_paths().await.is_empty(), "{kind:?}");
        assert_eq!(count(&bench, "storage_object").await, 0);
        assert_eq!(count(&bench, "storage_upload_part").await, 0);
        assert_eq!(count(&bench, "storage_reclaim").await, 0);
    }
}
