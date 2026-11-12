//! Contrôle du contenu : type réel enregistré, types refusés, antivirus dans le même passage que
//! l'écriture.

use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::ModuleContext;
use lyxal_storage::models::{BucketCreateParams, ObjectListParams, ObjectState};
use lyxal_storage::{
    ClamAvScanner, PutRequest, ScannerConfig, StorageHealthCheck, StorageService, MODULE_ID,
};
use lyxal_surreal::ToSql;
use std::sync::Arc;
use std::time::Duration;

use crate::support::{bench, chunks, clamd, request, Bench, Clamd, Kind, KINDS};

const PNG: &[u8] = b"\x89PNG\r\n\x1a\n\0\0\0\rIHDR\0\0\0\x01\0\0\0\x01\x08\x06\0\0\0";
const TEXT: &[u8] = b"nom;prix\nvis;0,12\n";

/// Début d'un programme Linux (ELF exécutable).
fn elf() -> Vec<u8> {
    let mut program = vec![0u8; 64];
    program[..7].copy_from_slice(b"\x7fELF\x02\x01\x01");
    program[16] = 2;
    program
}

async fn count(bench: &Bench, bucket: &str, state: ObjectState) -> usize {
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

fn announced(bucket: &str, key: &str, content_type: &str) -> PutRequest {
    PutRequest {
        content_type: Some(content_type.to_string()),
        ..request(bucket, key)
    }
}

#[tokio::test]
async fn the_real_type_is_recorded_and_ruled() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("libre").await;
        for (key, declared, content, expected) in [
            ("image.png", "image/png", PNG, "image/png"),
            ("image.txt", "text/plain", PNG, "image/png"),
            ("faux.png", "image/png", TEXT, "application/octet-stream"),
            ("prix.csv", "text/csv", TEXT, "text/csv"),
        ] {
            let stored = bench
                .service
                .put(announced(&bucket, key, declared), chunks(&[content]))
                .await
                .unwrap_or_else(|e| panic!("{kind:?} {key} : {e}"));
            assert_eq!(stored.content_type.as_deref(), Some(expected), "{key}");
            assert_eq!(stored.declared_type.as_deref(), Some(declared), "{key}");
        }
        let before = bench.stored_paths().await.len();

        // Programme exécutable annoncé comme une image : refusé par les réglages, rien ne reste
        let error = bench
            .service
            .put(
                announced(&bucket, "outil.png", "image/png"),
                chunks(&[&elf()]),
            )
            .await
            .expect_err("programme exécutable");
        assert_eq!(error.code(), "STORAGE_OBJECT_TYPE_REFUSED", "{kind:?}");

        // Bucket réservé aux PDF : une image annoncée PDF est jugée sur son type réel
        let pdf_only = bench
            .store
            .bucket_create(BucketCreateParams {
                allowed_types: vec!["application/pdf".to_string()],
                ..BucketCreateParams::named(None, "pdf")
            })
            .await
            .expect("bucket")
            .id
            .to_sql();
        let error = bench
            .service
            .put(
                announced(&pdf_only, "faux.pdf", "application/pdf"),
                chunks(&[PNG]),
            )
            .await
            .expect_err("image annoncée PDF");
        assert_eq!(error.code(), "STORAGE_OBJECT_TYPE_REFUSED");
        bench
            .service
            .put(
                announced(&pdf_only, "vrai.pdf", "text/plain"),
                chunks(&[b"%PDF-1.7\n1 0 obj\n"]),
            )
            .await
            .expect("PDF annoncé texte");

        assert_eq!(bench.stored_paths().await.len(), before + 1, "{kind:?}");
        assert_eq!(count(&bench, &bucket, ObjectState::Available).await, 4);
        assert_eq!(count(&bench, &pdf_only, ObjectState::Available).await, 1);
    }
}

fn scanner(address: &str, timeout: Duration) -> Arc<ClamAvScanner> {
    Arc::new(ClamAvScanner::new(
        ScannerConfig::Tcp {
            address: address.to_string(),
        },
        timeout,
    ))
}

/// Signature de test EICAR, assemblée ici pour ne pas figurer telle quelle dans le dépôt.
fn eicar() -> Vec<u8> {
    [
        &b"X5O!P%@AP[4\\PZX54(P^)7CC)7}$"[..],
        b"EICAR-STANDARD-",
        b"ANTIVIRUS-TEST-FILE",
        b"!$H+H*",
    ]
    .concat()
}

#[tokio::test]
async fn the_antivirus_scans_during_the_write() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let bucket = bench.bucket("plans").await;
        let address = clamd(Clamd::Scanning {
            stream_max_length: 1024 * 1024,
        })
        .await;
        let scanning = bench
            .service
            .clone()
            .with_scanner(scanner(&address, Duration::from_secs(10)));

        // Fichier sain, en plusieurs morceaux
        let clean = scanning
            .put(
                request(&bucket, "sain.txt"),
                chunks(&[b"contenu ", b"sain"]),
            )
            .await
            .unwrap_or_else(|e| panic!("{kind:?} : {e}"));
        assert_eq!(clean.state, ObjectState::Available);
        assert_eq!(clean.size, Some(12));

        // Signature de test au milieu du fichier : refusé, rien n'est conservé
        let infected = eicar();
        let error = scanning
            .put(
                request(&bucket, "infecte.bin"),
                chunks(&[b"debut ", &infected[..20], &infected[20..], b" fin"]),
            )
            .await
            .expect_err("fichier infecté");
        assert_eq!(error.code(), "STORAGE_OBJECT_INFECTED", "{kind:?}");
        assert!(error.to_string().contains("Eicar-Test-Signature"));
        assert!(!error.is_retryable());

        // Fichier au-delà de la limite de l'antivirus : refusé, à réessayer après réglage
        let large = vec![b'a'; 2 * 1024 * 1024];
        let error = scanning
            .put(
                request(&bucket, "gros.bin"),
                chunks(&[&large[..1024 * 1024], &large[1024 * 1024..]]),
            )
            .await
            .expect_err("limite de l'antivirus");
        assert_eq!(error.code(), "STORAGE_SCANNER_UNAVAILABLE", "{kind:?}");
        assert!(error.is_retryable());

        assert_eq!(bench.stored_paths().await, vec![clean.path.clone()]);
        assert_eq!(count(&bench, &bucket, ObjectState::Available).await, 1);
        assert_eq!(count(&bench, &bucket, ObjectState::Pending).await, 0);
    }
}

#[tokio::test]
async fn an_antivirus_that_does_not_answer_refuses_the_upload() {
    let bench = bench(Kind::Memory).await;
    let bucket = bench.bucket("plans").await;
    let context = ModuleContext::new(MODULE_ID);

    // Service injoignable (port fermé)
    let closed = {
        let listener = std::net::TcpListener::bind("127.0.0.1:0").expect("port");
        listener.local_addr().expect("adresse").to_string()
    };
    // Service muet : la connexion s'ouvre, aucune réponse
    let silent = clamd(Clamd::Silent).await;
    for address in [&closed, &silent] {
        let scanner = scanner(address, Duration::from_secs(1));
        let service: StorageService = bench.service.clone().with_scanner(scanner.clone());
        let error = service
            .put(request(&bucket, "a.txt"), chunks(&[b"abc"]))
            .await
            .expect_err("antivirus en échec");
        assert_eq!(error.code(), "STORAGE_SCANNER_UNAVAILABLE", "{address}");
        let probe = StorageHealthCheck::new(bench.store.clone(), bench.backends.clone())
            .with_scanner(scanner)
            .check(&context)
            .await
            .expect("sonde");
        assert_eq!(probe.status, HealthStatus::Degraded, "{address}");
        assert!(probe
            .message
            .as_deref()
            .is_some_and(|m| m.contains("STORAGE_SCANNER_UNAVAILABLE")));
    }
    assert!(bench.stored_paths().await.is_empty());
    assert_eq!(count(&bench, &bucket, ObjectState::Available).await, 0);

    // Service qui répond : sonde saine
    let address = clamd(Clamd::Scanning {
        stream_max_length: 1024,
    })
    .await;
    let probe = StorageHealthCheck::new(bench.store.clone(), bench.backends.clone())
        .with_scanner(scanner(&address, Duration::from_secs(5)))
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(probe.status, HealthStatus::Healthy, "{probe:?}");
}
