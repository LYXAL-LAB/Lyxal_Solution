//! Le worker d'ingestion respecte la machine à états installée depuis le manifeste du module
//! (garde `evt_batch_guard` : RECEIVED -> PARSING -> VALIDATING -> STAGED), tel que l'installe
//! `lyxal_runtime` pour le serveur hôte.

use lyxal_pipeline_ingestion::storage::NewBatch;
use lyxal_pipeline_ingestion::types::{BatchStatus, SourceFormat};
use lyxal_pipeline_ingestion::worker::IngestionWorker;
use lyxal_runtime::worker::CancellationToken;

fn batch(id: &str) -> NewBatch {
    NewBatch {
        id: Some(id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        source_encoding: lyxal_pipeline_ingestion::types::SourceEncoding::Utf8,
        fournisseur_id: "FOURNISSEUR_TEST".to_string(),
        source_object: crate::support::source(&store, "test.csv", id.as_bytes()).await,
        chunk_size: 10,
        provenance_details: serde_json::json!({}),
    }
        commercial_proof: None,
    }

#[tokio::test]
async fn worker_follows_installed_batch_state_machine() {
    let store = crate::support::installed_store().await;
    let mut csv = String::from("reference;designation;gtin;fabricant;unite;prix\n");
    for i in 1..=5 {
        csv.push_str(&format!("REF_{i};Plaque de plâtre {i};;Placo;M2;8.50\n"));
    }
    let worker = crate::support::worker(&store);
    let token = CancellationToken::new();

    store
        .create_batch(&batch("batch_manifest"))
        .await
        .expect("lot");
    let report = worker
        .process_batch("batch_manifest", &token)
        .await
        .expect("traitement");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(report.total_lignes, 5);

    // Un lot en échec est repris : FAILED -> PARSING -> VALIDATING -> STAGED.
    let claim = crate::support::claimed_batch(&store, &batch("batch_retry")).await;
    store
        .fail_batch(
            &claim,
            "batch_retry",
            "INGESTION_TEST_FAILURE",
            "Échec simulé",
        )
        .await
        .expect("lot en échec");
    store
        .release_batch("batch_retry", &claim)
        .await
        .expect("réservation libérée");
    let report = worker
        .process_batch("batch_retry", &token)
        .await
        .expect("reprise");
    assert_eq!(report.final_status, BatchStatus::Staged);
}

#[tokio::test]
async fn failed_batch_does_not_block_the_next_one() {
    let store = crate::support::installed_store().await;
    let csv = "reference;designation;gtin;fabricant;unite;prix\nREF_1;Plaque;;Placo;M2;8.50\n";
    let worker = crate::support::worker(&store);
    let token = CancellationToken::new();

    // Lot inconnu : la réservation est refusée, rien n'est écrit.
    let failure = worker
        .process_batch("lot_absent", &token)
        .await;
    assert!(failure.is_err());

    // Le worker n'est pas bloqué : un autre lot se traite normalement.
    store
        .create_batch(&batch("lot_suivant"))
        .await
        .expect("lot");
    let report = worker
        .process_batch("lot_suivant", &token)
        .await
        .expect("le lot suivant n'est pas bloqué");
    assert_eq!(report.final_status, BatchStatus::Staged);
}

#[tokio::test]
async fn invalid_barcode_line_goes_to_quarantine() {
    let store = crate::support::installed_store().await;
    let csv = "reference;designation;gtin;fabricant;unite;prix\n\
               REF_OK;Plaque de plâtre BA13;3017620422003;Placo;M2;8.50\n\
               REF_KO;Plaque de plâtre BA18;3017620422009;Placo;M2;9.50\n";
    let worker = crate::support::worker(&store);
    store.create_batch(&batch("lot_gtin")).await.expect("lot");

    let report = worker
        .process_batch("lot_gtin", &CancellationToken::new())
        .await
        .expect("traitement");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(report.rejected_count, 1);
    assert_eq!(report.to_confirm_count, 1);

    // Le code-barres est contrôlé par fn::validation_gtin (lyxal_core) : la ligne fautive n'entre
    // pas en staging et son anomalie est consignée avec la valeur refusée.
    let staged = store
        .get_staged_items_by_batch("lot_gtin")
        .await
        .expect("articles");
    assert_eq!(staged.len(), 1);
    assert_eq!(staged[0].code_barre_gtin.as_deref(), Some("3017620422003"));
    let anomalies = store
        .get_quarantine_by_batch("lot_gtin")
        .await
        .expect("quarantaine");
    assert_eq!(anomalies.len(), 1);
    assert_eq!(anomalies[0].code_erreur, "INGESTION_GTIN_INVALID");
    assert_eq!(anomalies[0].ligne_numero, 2);
    assert_eq!(anomalies[0].raw_record, "lot_gtin_2");
    assert_eq!(
        anomalies[0].valeur_fautive,
        Some(serde_json::json!("3017620422009"))
    );
}

#[tokio::test]
async fn failed_batch_does_not_stop_the_worker() {
    use lyxal_runtime::worker::{LyxalWorker, WorkerContext};
    use lyxal_runtime::ModuleContext;
    use std::sync::Arc;

    let store = crate::support::installed_store().await;
    let worker = Arc::new(crate::support::worker(&store));
    store
        .create_batch(&batch("lot_illisible"))
        .await
        .expect("lot 1");
    store
        .create_batch(&batch("lot_valide"))
        .await
        .expect("lot 2");
    // Premier lot : contenu non décodable en UTF-8, source illisible ; second lot : valide.
    worker
        .enqueue_batch(
            "lot_illisible".to_string(),
            vec![0xff, 0xfe, 0xfd],
            SourceFormat::Csv,
            None,
        )
        .await;
    worker
        .enqueue_batch(
            "lot_valide".to_string(),
            b"reference;designation;gtin;fabricant;unite;prix\nREF_1;Plaque;;Placo;M2;8.50\n"
                .to_vec(),
            SourceFormat::Csv,
            None,
        )
        .await;

    let token = CancellationToken::new();
    let descriptor = worker.descriptor().clone();
    let ctx = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new("lyxal_pipeline_ingestion"),
        token.clone(),
    );
    let running = tokio::spawn({
        let worker = worker.clone();
        async move { worker.run(ctx).await }
    });

    let mut staged = false;
    for _ in 0..200 {
        let lot = store
            .get_batch("lot_valide")
            .await
            .expect("lecture")
            .expect("lot");
        if lot.statut == BatchStatus::Staged {
            staged = true;
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(50)).await;
    }
    token.cancel();
    running
        .await
        .expect("tâche")
        .expect("le worker s'arrête sans erreur");

    assert!(
        staged,
        "le lot suivant est traité malgré l'échec du premier"
    );
    let failed = store
        .get_batch("lot_illisible")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(failed.statut, BatchStatus::Failed);
    let last = failed.transitions.last().expect("transition");
    assert_eq!(last.to_state, "FAILED");
    assert!(
        last.reason.contains("PARSING_HEADER_INVALID"),
        "motif de l'échec journalisé : {}",
        last.reason
    );
}
