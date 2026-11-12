//! Écriture et lecture en flux, échecs nettoyés, vérification d'intégrité.

use bytes::Bytes;
use futures::{stream, StreamExt};
use lyxal_storage::models::{
    BucketCreateParams, ObjectBeginParams, ObjectGetParams, ObjectListParams, ObjectState,
    QuarantineParams,
};
use lyxal_storage::{Backends, ByteRange, PutRequest, StorageError, StorageService, PART_SIZE};
use lyxal_surreal::ToSql;
use object_store::path::Path;
use object_store::ObjectStoreExt;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

use crate::support::{bench, chunks, read_all, request, Bench, Kind, KINDS};

async fn states(bench: &Bench, bucket: &str, state: ObjectState) -> usize {
    bench
        .store
        .object_list(ObjectListParams {
            bucket: bucket.to_string(),
            prefix: None,
            state,
            limit: 100,
            start: 0,
        })
        .await
        .expect("liste")
        .items
        .len()
}

#[tokio::test]
async fn a_file_is_written_then_read_back_identical() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("plans").await;
        let content = b"Plan du chantier, version 3".to_vec();
        let stored = bench
            .service
            .put(
                PutRequest {
                    content_type: Some("text/plain".to_string()),
                    size: Some(content.len() as u64),
                    ..request(&bucket, "2026/plan.txt")
                },
                chunks(&[&content[..4], &content[4..20], &content[20..]]),
            )
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(stored.state, ObjectState::Available);
        assert_eq!(stored.size, Some(content.len() as i64));
        assert_eq!(stored.content_type.as_deref(), Some("text/plain"));
        assert_eq!(
            stored.blake3.as_deref(),
            Some(lyxal_crypto::hash::blake3_hex(&content).as_str())
        );
        assert_eq!(bench.stored_paths().await, vec![stored.path.clone()]);

        let opened = bench
            .service
            .open(ObjectGetParams::by_address(&bucket, "2026/plan.txt"), None)
            .await
            .expect("ouverture");
        assert_eq!(opened.object.id, stored.id);
        assert_eq!(opened.range, 0..content.len() as u64);
        assert_eq!(read_all(opened).await, content);

        let part = bench
            .service
            .open(
                ObjectGetParams::by_id(stored.id.to_sql()),
                Some(ByteRange::FromTo(5, 11)),
            )
            .await
            .expect("plage");
        assert_eq!(part.range, 5..12);
        assert_eq!(read_all(part).await, &content[5..12]);

        // Fin et début ouverts ; fin au-delà du fichier ramenée à sa fin ; plages sans octet
        let size = content.len() as u64;
        for (range, expected) in [
            (ByteRange::From(20), 20..size),
            (ByteRange::Last(4), size - 4..size),
            (ByteRange::Last(1000), 0..size),
            (ByteRange::FromTo(10, 10_000), 10..size),
            (ByteRange::FromTo(0, 0), 0..1),
        ] {
            let part = bench
                .service
                .open(ObjectGetParams::by_id(stored.id.to_sql()), Some(range))
                .await
                .unwrap_or_else(|e| panic!("{range:?} : {e}"));
            assert_eq!(part.range, expected, "{range:?}");
            assert_eq!(
                read_all(part).await,
                &content[expected.start as usize..expected.end as usize]
            );
        }
        for range in [
            ByteRange::From(size),
            ByteRange::FromTo(size, size + 5),
            ByteRange::FromTo(8, 3),
            ByteRange::Last(0),
        ] {
            let error = bench
                .service
                .open(ObjectGetParams::by_id(stored.id.to_sql()), Some(range))
                .await
                .err()
                .unwrap_or_else(|| panic!("{range:?} accepté"));
            assert_eq!(error.code(), "STORAGE_RANGE_NOT_SATISFIABLE", "{range:?}");
            assert!(matches!(error, StorageError::RangeNotSatisfiable(s) if s == size));
        }
        assert_eq!(
            bench
                .service
                .stat(ObjectGetParams::by_id(stored.id.to_sql()))
                .await
                .expect("fiche")
                .id,
            stored.id
        );

        bench
            .service
            .verify(&stored.id.to_sql())
            .await
            .expect("fichier intact");
    }
}

#[tokio::test]
async fn an_empty_file_and_an_unannounced_type_are_accepted() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("vides").await;
        let stored = bench
            .service
            .put(request(&bucket, "vide.bin"), chunks(&[]))
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(stored.size, Some(0));
        assert_eq!(
            stored.content_type.as_deref(),
            Some("application/octet-stream")
        );
        let opened = bench
            .service
            .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
            .await
            .expect("ouverture");
        assert!(read_all(opened).await.is_empty());
    }
}

/// Tampon dont la libération est comptée : mesure des octets du flux encore en mémoire.
struct Tracked {
    data: Vec<u8>,
    live: Arc<AtomicUsize>,
}

impl AsRef<[u8]> for Tracked {
    fn as_ref(&self) -> &[u8] {
        &self.data
    }
}

impl Drop for Tracked {
    fn drop(&mut self) {
        self.live.fetch_sub(self.data.len(), Ordering::SeqCst);
    }
}

#[tokio::test]
async fn a_large_file_is_streamed_within_bounded_memory() {
    const CHUNK: usize = 1024 * 1024;
    const CHUNKS: usize = 64;
    let bench = bench(Kind::Disk).await;
    let bucket = bench.bucket("gros").await;
    let live = Arc::new(AtomicUsize::new(0));
    let peak = Arc::new(AtomicUsize::new(0));
    let mut expected = lyxal_crypto::hash::Blake3Hasher::new();
    for index in 0..CHUNKS {
        expected.update(&vec![index as u8; CHUNK]);
    }
    let source = {
        let (live, peak) = (live.clone(), peak.clone());
        stream::iter(0..CHUNKS).map(move |index| {
            let now = live.fetch_add(CHUNK, Ordering::SeqCst) + CHUNK;
            peak.fetch_max(now, Ordering::SeqCst);
            Ok::<_, std::convert::Infallible>(Bytes::from_owner(Tracked {
                data: vec![index as u8; CHUNK],
                live: live.clone(),
            }))
        })
    };
    let stored = bench
        .service
        .put(request(&bucket, "gros.bin"), source)
        .await
        .expect("écriture");
    assert_eq!(stored.size, Some((CHUNK * CHUNKS) as i64));
    assert_eq!(
        stored.blake3.as_deref(),
        Some(expected.finalize_hex().as_str())
    );
    assert_eq!(live.load(Ordering::SeqCst), 0, "tout est libéré");
    let peak = peak.load(Ordering::SeqCst);
    assert!(
        peak <= 3 * PART_SIZE,
        "{peak} octets du flux en mémoire au plus haut, pour un fichier de {} octets",
        CHUNK * CHUNKS
    );

    let mut opened = bench
        .service
        .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
        .await
        .expect("ouverture");
    let mut read = lyxal_crypto::hash::Blake3Hasher::new();
    let mut largest = 0;
    while let Some(chunk) = opened.content.next().await {
        let chunk = chunk.expect("lecture");
        largest = largest.max(chunk.len());
        read.update(&chunk);
    }
    assert_eq!(Some(read.finalize_hex()), stored.blake3);
    assert!(largest <= PART_SIZE, "lecture par morceaux ({largest})");
}

#[tokio::test]
async fn a_failed_write_leaves_no_bytes_and_no_available_file() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench
            .store
            .bucket_create(BucketCreateParams {
                max_object_size: Some(10),
                ..BucketCreateParams::named(None, "petits")
            })
            .await
            .expect("bucket")
            .id
            .to_sql();

        // Contenu plus grand que la limite du bucket, sans taille annoncée
        let error = bench
            .service
            .put(request(&bucket, "trop.bin"), chunks(&[b"123456", b"78901"]))
            .await
            .expect_err("dépassement");
        assert_eq!(error.code(), "STORAGE_CONTENT_MISMATCH", "{kind:?}");

        // Taille annoncée au-delà de la limite : refus avant toute écriture
        let error = bench
            .service
            .put(
                PutRequest {
                    size: Some(11),
                    ..request(&bucket, "annonce.bin")
                },
                chunks(&[b"12345678901"]),
            )
            .await
            .expect_err("annonce refusée");
        assert_eq!(error.code(), "STORAGE_OBJECT_TOO_LARGE");

        // Moins d'octets que l'annonce, puis plus d'octets que l'annonce
        for parts in [
            &[b"1234".as_slice()][..],
            &[b"1234".as_slice(), b"5678".as_slice()][..],
        ] {
            let error = bench
                .service
                .put(
                    PutRequest {
                        size: Some(6),
                        ..request(&bucket, "ecart.bin")
                    },
                    chunks(parts),
                )
                .await
                .expect_err("écart de taille");
            assert!(matches!(error, StorageError::ContentMismatch(_)));
            assert!(!error.is_retryable());
        }

        // Flux interrompu
        let broken = stream::iter(vec![
            Ok(Bytes::from_static(b"123")),
            Err("connexion coupée"),
        ]);
        let error = bench
            .service
            .put(request(&bucket, "coupe.bin"), broken)
            .await
            .expect_err("flux interrompu");
        assert_eq!(error.code(), "STORAGE_CONTENT_MISMATCH");

        assert!(bench.stored_paths().await.is_empty(), "{kind:?}");
        assert_eq!(states(&bench, &bucket, ObjectState::Available).await, 0);
        assert_eq!(states(&bench, &bucket, ObjectState::Pending).await, 0);
        // Chaque écriture ouverte puis en échec laisse une fiche supprimée, à purger
        assert_eq!(states(&bench, &bucket, ObjectState::Deleted).await, 4);

        // L'adresse est libre : la même clé s'écrit ensuite
        bench
            .service
            .put(request(&bucket, "coupe.bin"), chunks(&[b"123"]))
            .await
            .expect("écriture après échec");
    }
}

#[tokio::test]
async fn an_unconfigured_backend_refuses_the_write() {
    let bench = bench(Kind::Memory).await;
    let bucket = bench
        .store
        .bucket_create(BucketCreateParams {
            backend: "archive_froide".to_string(),
            ..BucketCreateParams::named(None, "froid")
        })
        .await
        .expect("bucket")
        .id
        .to_sql();
    let error = bench
        .service
        .put(request(&bucket, "a.bin"), chunks(&[b"abc"]))
        .await
        .expect_err("support inconnu");
    assert_eq!(error.code(), "STORAGE_BACKEND_UNKNOWN");
    assert_eq!(states(&bench, &bucket, ObjectState::Pending).await, 0);
    assert_eq!(states(&bench, &bucket, ObjectState::Deleted).await, 1);

    // Aucun support : refus avant toute fiche
    let empty = StorageService::new(bench.store.clone(), Arc::new(Backends::new()));
    let plans = bench.bucket("plans").await;
    let error = empty
        .put(request(&plans, "a.bin"), chunks(&[b"abc"]))
        .await
        .expect_err("aucun support");
    assert_eq!(error.code(), "STORAGE_BACKEND_UNKNOWN");
    assert_eq!(states(&bench, &plans, ObjectState::Deleted).await, 0);
}

#[tokio::test]
async fn only_an_available_file_is_served() {
    let bench = bench(Kind::Memory).await;
    let bucket = bench.bucket("plans").await;
    let pending = bench
        .store
        .object_begin(ObjectBeginParams {
            bucket: bucket.clone(),
            key: "en-cours.bin".to_string(),
            filename: "en-cours.bin".to_string(),
            declared_type: None,
            declared_size: None,
        })
        .await
        .expect("ouverture d'écriture");
    let error = bench
        .service
        .open(ObjectGetParams::by_id(pending.id.to_sql()), None)
        .await
        .err()
        .expect("fichier en attente");
    assert_eq!(error.code(), "STORAGE_OBJECT_NOT_AVAILABLE");

    let stored = bench
        .service
        .put(request(&bucket, "a.bin"), chunks(&[b"abc"]))
        .await
        .expect("écriture");
    bench
        .store
        .object_quarantine(QuarantineParams {
            object: stored.id.to_sql(),
            reason: "contenu suspect".to_string(),
        })
        .await
        .expect("quarantaine");
    let error = bench
        .service
        .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
        .await
        .err()
        .expect("fichier en quarantaine");
    assert_eq!(error.code(), "STORAGE_OBJECT_NOT_AVAILABLE");

    let deleted = bench
        .service
        .delete(&stored.id.to_sql())
        .await
        .expect("suppression");
    assert_eq!(deleted.state, ObjectState::Deleted);
    let error = bench
        .service
        .open(ObjectGetParams::by_address(&bucket, "a.bin"), None)
        .await
        .err()
        .expect("fichier supprimé");
    assert_eq!(error.code(), "STORAGE_OBJECT_NOT_FOUND");
}

#[tokio::test]
async fn an_altered_file_is_detected() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("plans").await;
        let stored = bench
            .service
            .put(request(&bucket, "a.bin"), chunks(&[b"contenu d'origine"]))
            .await
            .expect("écriture");
        let object = stored.id.to_sql();
        let backend = bench.backends.get("default").expect("support").store();
        let path = Path::parse(&stored.path).expect("emplacement");

        // Même taille, contenu différent
        backend
            .put(&path, Bytes::from_static(b"contenu d'0rigine").into())
            .await
            .expect("altération");
        let error = bench.service.verify(&object).await.expect_err("empreinte");
        assert_eq!(error.code(), "STORAGE_INTEGRITY_FAILED", "{kind:?}");

        // Taille différente
        backend
            .put(&path, Bytes::from_static(b"court").into())
            .await
            .expect("altération");
        let error = bench.service.verify(&object).await.expect_err("taille");
        assert!(matches!(error, StorageError::IntegrityFailed(_)));

        // Octets absents
        backend.delete(&path).await.expect("retrait");
        let error = bench.service.verify(&object).await.expect_err("absence");
        assert_eq!(error.code(), "STORAGE_INTEGRITY_FAILED");
    }
}
