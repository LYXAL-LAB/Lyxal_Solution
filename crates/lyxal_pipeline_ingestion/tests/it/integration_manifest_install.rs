//! Le worker d'ingestion respecte la machine à états installée depuis le manifeste du module
//! (garde `evt_batch_guard` : RECEIVED -> PARSING -> VALIDATING -> STAGED), tel que l'installe
//! `lyxal_runtime` pour le serveur hôte.

use lyxal_pipeline_ingestion::models::IngestionBatch;
use lyxal_pipeline_ingestion::types::{BatchStatus, SourceFormat};
use lyxal_pipeline_ingestion::worker::IngestionWorker;
use lyxal_runtime::worker::CancellationToken;

fn batch(id: &str, statut: BatchStatus) -> IngestionBatch {
    IngestionBatch {
        id: Some(id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURNISSEUR_TEST".to_string(),
        nom_fichier: "test.csv".to_string(),
        file_hash_blake3: format!("{:0>64}", id.len()),
        taille_octets: 128,
        statut,
        cursor_offset: 0,
        chunk_size: 10,
        total_lignes: 0,
        lignes_verifiees: 0,
        lignes_a_confirmer: 0,
        lignes_rejetees: 0,
        transitions: Vec::new(),
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    }
}

#[tokio::test]
async fn worker_follows_installed_batch_state_machine() {
    let store = crate::support::installed_store().await;
    let mut csv = String::from("reference;designation;gtin;fabricant;unite;prix\n");
    for i in 1..=5 {
        csv.push_str(&format!("REF_{i};Plaque de plâtre {i};;Placo;M2;8.50\n"));
    }
    let worker = IngestionWorker::new(store.clone());
    let token = CancellationToken::new();

    store
        .create_batch(&batch("batch_manifest", BatchStatus::Received))
        .await
        .expect("lot");
    let report = worker
        .process_batch(
            "batch_manifest",
            csv.as_bytes(),
            SourceFormat::Csv,
            None,
            &token,
        )
        .await
        .expect("traitement");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(report.total_lignes, 5);

    // Un lot en échec est repris : FAILED -> PARSING -> VALIDATING -> STAGED.
    store
        .create_batch(&batch("batch_retry", BatchStatus::Failed))
        .await
        .expect("lot en échec");
    let report = worker
        .process_batch(
            "batch_retry",
            csv.as_bytes(),
            SourceFormat::Csv,
            None,
            &token,
        )
        .await
        .expect("reprise");
    assert_eq!(report.final_status, BatchStatus::Staged);
}

#[tokio::test]
async fn failed_batch_does_not_block_the_next_one() {
    let store = crate::support::installed_store().await;
    let csv = "reference;designation;gtin;fabricant;unite;prix\nREF_1;Plaque;;Placo;M2;8.50\n";
    let worker = IngestionWorker::new(store.clone());
    let token = CancellationToken::new();

    // Lot inconnu : le traitement échoue après la prise du verrou logique.
    let failure = worker
        .process_batch(
            "lot_absent",
            csv.as_bytes(),
            SourceFormat::Csv,
            None,
            &token,
        )
        .await;
    assert!(failure.is_err());

    // Le verrou a été libéré : un autre lot se traite normalement.
    store
        .create_batch(&batch("lot_suivant", BatchStatus::Received))
        .await
        .expect("lot");
    let report = worker
        .process_batch(
            "lot_suivant",
            csv.as_bytes(),
            SourceFormat::Csv,
            None,
            &token,
        )
        .await
        .expect("le lot suivant n'est pas bloqué");
    assert_eq!(report.final_status, BatchStatus::Staged);
}
