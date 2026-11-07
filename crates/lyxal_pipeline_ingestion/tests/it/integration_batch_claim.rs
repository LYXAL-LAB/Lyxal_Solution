//! Réservation des lots : une seule exécution de traitement à la fois, toutes exécutions, tous
//! workers et toutes instances confondus (`fn::ingestion_batch_claim`), libération quelle que
//! soit l'issue, reprise d'une réservation expirée.

use lyxal_pipeline_ingestion::error::{IngestionError, IngestionResult};
use lyxal_pipeline_ingestion::storage::{IngestionStore, NewBatch};
use lyxal_pipeline_ingestion::types::{BatchStatus, SourceFormat};
use lyxal_pipeline_ingestion::worker::{BatchProcessingReport, IngestionWorker};
use lyxal_runtime::worker::CancellationToken;

fn batch(id: &str) -> NewBatch {
    NewBatch {
        id: Some(id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURNISSEUR_TEST".to_string(),
        nom_fichier: format!("{id}.csv"),
        file_hash_blake3: lyxal_crypto::blake3_hex(id.as_bytes()),
        taille_octets: 4096,
        chunk_size: 5,
        provenance_details: serde_json::json!({}),
    }
}

fn csv(lines: usize) -> String {
    let mut csv = String::from("reference;designation;gtin;fabricant;unite;prix\n");
    for i in 1..=lines {
        csv.push_str(&format!("REF_{i};Plaque de plâtre {i};;Placo;M2;8.50\n"));
    }
    csv
}

/// Réservation en base d'un lot : (jeton, génération).
async fn claim_state(store: &IngestionStore, batch_id: &str) -> (Option<String>, i64) {
    let mut res = store
        .client()
        .query(
            "SELECT claim_owner, claim_generation FROM ONLY type::record('ingestion_batch', $id)",
        )
        .bind(("id", batch_id.to_string()))
        .await
        .expect("lecture de la réservation");
    let state: Option<serde_json::Value> = res.take(0).expect("réservation");
    let state = state.expect("lot");
    (
        state["claim_owner"].as_str().map(str::to_string),
        state["claim_generation"].as_i64().expect("génération"),
    )
}

/// Nombre d'événements `ingestion.batch.staged` émis pour le lot.
async fn staged_events(store: &IngestionStore, batch_id: &str) -> usize {
    let events: Vec<serde_json::Value> = store
        .client()
        .query("SELECT VALUE payload FROM event_outbox WHERE event_type = 'ingestion.batch.staged' AND payload.batch_id = $batch")
        .bind(("batch", format!("ingestion_batch:{batch_id}")))
        .await
        .expect("outbox")
        .take(0)
        .expect("événements");
    events.len()
}

/// Deux traitements simultanés du même lot : un seul le traite. L'autre est refusé
/// (réservation active) ou, s'il arrive après la fin du premier, trouve le lot déjà `STAGED`
/// sans rien réécrire ; le lot n'est mis en staging qu'une fois et la réservation est libérée.
async fn assert_processed_once(
    store: &IngestionStore,
    batch_id: &str,
    results: [IngestionResult<BatchProcessingReport>; 2],
) {
    let mut processed = 0;
    for result in results {
        match result {
            Ok(report) => {
                assert_eq!(report.final_status, BatchStatus::Staged);
                assert!(!report.interrupted);
                processed += 1;
            }
            Err(IngestionError::BatchAlreadyClaimed { batch_id: refused }) => {
                assert_eq!(refused, batch_id);
            }
            Err(other) => panic!("seul le refus de réservation est attendu : {other}"),
        }
    }
    assert!(processed >= 1, "une exécution traite le lot");

    let lot = store
        .get_batch(batch_id)
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(lot.statut, BatchStatus::Staged);
    assert_eq!(lot.total_lignes, 30);
    assert_eq!(
        lot.transitions
            .iter()
            .filter(|t| t.to_state == "STAGED")
            .count(),
        1,
        "une seule mise en staging"
    );
    assert_eq!(lot.lignes_a_confirmer, 30, "aucune ligne comptée deux fois");
    assert_eq!(
        staged_events(store, batch_id).await,
        1,
        "un seul ingestion.batch.staged"
    );
    assert_eq!(
        claim_state(store, batch_id).await.0,
        None,
        "réservation libérée"
    );
}

#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn same_worker_concurrent_calls_process_the_batch_once() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch("lot_meme_worker"))
        .await
        .expect("lot");
    let worker = IngestionWorker::new(store.clone()).expect("worker");
    let source = csv(30);
    let token = CancellationToken::new();

    let (first, second) = tokio::join!(
        worker.process_batch(
            "lot_meme_worker",
            source.as_bytes(),
            SourceFormat::Csv,
            None,
            &token
        ),
        worker.process_batch(
            "lot_meme_worker",
            source.as_bytes(),
            SourceFormat::Csv,
            None,
            &token
        ),
    );
    assert_processed_once(&store, "lot_meme_worker", [first, second]).await;
}

#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn two_workers_process_the_batch_once() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch("lot_deux_workers"))
        .await
        .expect("lot");
    let worker_a = IngestionWorker::new(store.clone()).expect("worker A");
    let worker_b = IngestionWorker::new(store.clone()).expect("worker B");
    let source = csv(30);
    let token = CancellationToken::new();

    let (first, second) = tokio::join!(
        worker_a.process_batch(
            "lot_deux_workers",
            source.as_bytes(),
            SourceFormat::Csv,
            None,
            &token
        ),
        worker_b.process_batch(
            "lot_deux_workers",
            source.as_bytes(),
            SourceFormat::Csv,
            None,
            &token
        ),
    );
    assert_processed_once(&store, "lot_deux_workers", [first, second]).await;
}

#[tokio::test]
async fn refused_execution_neither_writes_nor_releases_the_other_claim() {
    let store = crate::support::installed_store().await;
    // Une autre exécution (autre worker, autre instance) détient le lot.
    let claim = crate::support::claimed_batch(&store, &batch("lot_tenu")).await;
    let worker = IngestionWorker::new(store.clone()).expect("worker");

    let refused = worker
        .process_batch(
            "lot_tenu",
            csv(5).as_bytes(),
            SourceFormat::Csv,
            None,
            &CancellationToken::new(),
        )
        .await;
    assert!(
        matches!(refused, Err(IngestionError::BatchAlreadyClaimed { .. })),
        "lot réservé : traitement refusé"
    );
    let lot = store
        .get_batch("lot_tenu")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(
        lot.statut,
        BatchStatus::Received,
        "ni traité ni marqué FAILED"
    );
    assert_eq!(
        claim_state(&store, "lot_tenu").await,
        (Some(claim.owner.clone()), claim.generation),
        "la réservation de l'autre exécution est intacte"
    );
}

#[tokio::test]
async fn expired_claim_is_taken_over_and_the_old_execution_is_fenced() {
    let store = crate::support::installed_store().await;
    let old = crate::support::claimed_batch(&store, &batch("lot_expire")).await;
    // L'ancienne exécution s'est arrêtée sans libérer : sa réservation expire.
    store
        .client()
        .query("UPDATE ingestion_batch:lot_expire SET claim_until = time::now() - 1s")
        .await
        .expect("expiration")
        .check()
        .expect("réservation expirée");

    let worker = IngestionWorker::new(store.clone()).expect("worker");
    let report = worker
        .process_batch(
            "lot_expire",
            csv(5).as_bytes(),
            SourceFormat::Csv,
            None,
            &CancellationToken::new(),
        )
        .await
        .expect("reprise de la réservation expirée");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(
        claim_state(&store, "lot_expire").await,
        (None, old.generation + 1),
        "reprise à la génération suivante, puis libérée"
    );

    // L'ancienne exécution ne peut plus rien écrire, ni libérer.
    let write = store
        .save_checkpoint(&old, "lot_expire", 0, 5, 0, 0, 0)
        .await
        .expect_err("écriture refusée");
    assert!(write.is_claim_lost(), "{write}");
    let release = store
        .release_batch("lot_expire", &old)
        .await
        .expect_err("libération refusée");
    assert!(release.is_claim_lost(), "{release}");
    let lot = store
        .get_batch("lot_expire")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(lot.cursor_offset, 5, "le point de reprise n'a pas reculé");
}

#[tokio::test]
async fn claim_is_released_after_failure_and_interruption() {
    let store = crate::support::installed_store().await;
    store.create_batch(&batch("lot_casse")).await.expect("lot");
    let worker = IngestionWorker::new(store.clone()).expect("worker");

    // Échec : le lot passe en FAILED pendant que la réservation est détenue, puis est libéré.
    let failure = worker
        .process_batch(
            "lot_casse",
            &[0xff, 0xfe, 0xfd],
            SourceFormat::Csv,
            None,
            &CancellationToken::new(),
        )
        .await
        .expect_err("contenu non UTF-8");
    assert_eq!(failure.code(), "INGESTION_ADAPTER_ERROR");
    let lot = store
        .get_batch("lot_casse")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(lot.statut, BatchStatus::Failed);
    assert_eq!(claim_state(&store, "lot_casse").await, (None, 1));

    // Interruption : point de reprise enregistré, réservation libérée.
    let cancelled = CancellationToken::new();
    cancelled.cancel();
    let report = worker
        .process_batch(
            "lot_casse",
            csv(10).as_bytes(),
            SourceFormat::Csv,
            None,
            &cancelled,
        )
        .await
        .expect("interruption");
    assert!(report.interrupted);
    assert_eq!(claim_state(&store, "lot_casse").await, (None, 2));

    // Nouvelle exécution : le lot est de nouveau réservable et va au bout.
    let report = worker
        .process_batch(
            "lot_casse",
            csv(10).as_bytes(),
            SourceFormat::Csv,
            None,
            &CancellationToken::new(),
        )
        .await
        .expect("reprise");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(claim_state(&store, "lot_casse").await, (None, 3));
}
