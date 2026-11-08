//! Lecture des sources par `lyxal_parsing` à travers le worker (constat A05 de l'audit) :
//! champs multilignes, éléments rejetés consignés en quarantaine, entités XML décodées,
//! encodage déclaré du lot, source illisible, reprise avec rejet.

use lyxal_pipeline_ingestion::storage::{BatchProgress, IngestionStore, NewBatch};
use lyxal_pipeline_ingestion::types::{BatchStatus, SourceEncoding, SourceFormat};
use lyxal_pipeline_ingestion::worker::IngestionWorker;
use lyxal_runtime::worker::CancellationToken;

fn batch(id: &str, format: SourceFormat, encoding: SourceEncoding, chunk_size: i64) -> NewBatch {
    NewBatch {
        id: Some(id.to_string()),
        source_type: format,
        source_format_version: "1.0".to_string(),
        source_encoding: encoding,
        fournisseur_id: "FOURN_TEST".to_string(),
        nom_fichier: format!("{id}.src"),
        file_hash_blake3: lyxal_crypto::blake3_hex(id.as_bytes()),
        taille_octets: 512,
        chunk_size,
        provenance_details: serde_json::json!({}),
    }
}

async fn process(
    store: &IngestionStore,
    id: &str,
    format: SourceFormat,
    source: &[u8],
) -> lyxal_pipeline_ingestion::IngestionResult<
    lyxal_pipeline_ingestion::worker::BatchProcessingReport,
> {
    IngestionWorker::new(store.clone())
        .expect("worker")
        .process_batch(id, source, format, None, &CancellationToken::new())
        .await
}

async fn labels(store: &IngestionStore, id: &str) -> Vec<(usize, String)> {
    let mut items: Vec<(usize, String)> = store
        .get_staged_items_by_batch(id)
        .await
        .expect("articles")
        .into_iter()
        .map(|item| (item.ligne_numero, item.libelle_commercial))
        .collect();
    items.sort();
    items
}

#[tokio::test]
async fn csv_designation_over_several_lines_is_one_article() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch(
            "lot_multiligne",
            SourceFormat::Csv,
            SourceEncoding::Utf8,
            10,
        ))
        .await
        .expect("lot");
    let source = "reference;designation;fabricant;unite;prix\nBA13;\"Plaque\nde plâtre\nstandard\";Placo;M2;8,50\nBA18;Plaque BA18;Placo;M2;9,10\n";
    let report = process(
        &store,
        "lot_multiligne",
        SourceFormat::Csv,
        source.as_bytes(),
    )
    .await
    .expect("traitement");
    assert_eq!(report.total_lignes, 2, "deux articles, pas cinq lignes");
    let labels = labels(&store, "lot_multiligne").await;
    assert_eq!(labels.len(), 2);
    assert_eq!(labels[0], (1, "Plaque\nde plâtre\nstandard".to_string()));
}

#[tokio::test]
async fn json_element_that_is_not_an_object_is_quarantined() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch(
            "lot_json",
            SourceFormat::Json,
            SourceEncoding::Utf8,
            10,
        ))
        .await
        .expect("lot");
    let source = br#"[{"ref":"A1","designation":"Article A","fabricant":"Placo","unite":"M2"}, 42, {"ref":"B2","designation":"Article B","fabricant":"Placo","unite":"M2"}]"#;
    let report = process(&store, "lot_json", SourceFormat::Json, source)
        .await
        .expect("traitement");
    assert_eq!(report.final_status, BatchStatus::Staged);
    assert_eq!(report.total_lignes, 3);
    assert_eq!(report.rejected_count, 1);
    let numbers: Vec<usize> = labels(&store, "lot_json")
        .await
        .into_iter()
        .map(|(n, _)| n)
        .collect();
    assert_eq!(numbers, vec![1, 3], "l'élément rejeté garde son numéro");

    let anomalies = store
        .get_quarantine_by_batch("lot_json")
        .await
        .expect("quarantaine");
    assert_eq!(anomalies.len(), 1);
    let anomaly = &anomalies[0];
    assert_eq!(anomaly.code_erreur, "INGESTION_SOURCE_RECORD_REJECTED");
    assert_eq!(anomaly.ligne_numero, 2);
    assert_eq!(anomaly.raw_record, "lot_json_2");
    assert_eq!(
        anomaly.valeur_fautive.as_ref().map(|v| v["code"].clone()),
        Some(serde_json::json!("PARSING_JSON_NOT_OBJECT"))
    );
    assert!(anomaly
        .cause_detaillee
        .starts_with("PARSING_JSON_NOT_OBJECT"));
}

#[tokio::test]
async fn xml_entities_are_decoded_in_staging() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch(
            "lot_xml",
            SourceFormat::Xml,
            SourceEncoding::Utf8,
            10,
        ))
        .await
        .expect("lot");
    let source = r#"<?xml version="1.0"?>
<BMECAT><T_NEW_CATALOG>
  <ARTICLE>
    <SUPPLIER_AID>BA13</SUPPLIER_AID>
    <ARTICLE_DETAILS>
      <DESCRIPTION_SHORT>Plaque &#233;paisseur 12,5 &amp; bords amincis</DESCRIPTION_SHORT>
      <MANUFACTURER_NAME>Placo</MANUFACTURER_NAME>
    </ARTICLE_DETAILS>
    <ARTICLE_ORDER_DETAILS><ORDER_UNIT>M2</ORDER_UNIT></ARTICLE_ORDER_DETAILS>
  </ARTICLE>
</T_NEW_CATALOG></BMECAT>"#;
    process(&store, "lot_xml", SourceFormat::Xml, source.as_bytes())
        .await
        .expect("traitement");
    assert_eq!(
        labels(&store, "lot_xml").await,
        vec![(1, "Plaque épaisseur 12,5 & bords amincis".to_string())]
    );
}

#[tokio::test]
async fn declared_windows_1252_batch_is_decoded() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch(
            "lot_excel",
            SourceFormat::Csv,
            SourceEncoding::Windows1252,
            10,
        ))
        .await
        .expect("lot");
    let lot = store
        .get_batch("lot_excel")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(lot.source_encoding, SourceEncoding::Windows1252);
    let source = b"reference;designation;fabricant;unite\nBA13;Plaque pl\xE2tre \xE9paisseur 12,5;Placo;M2\n";
    process(&store, "lot_excel", SourceFormat::Csv, source)
        .await
        .expect("traitement");
    assert_eq!(
        labels(&store, "lot_excel").await,
        vec![(1, "Plaque plâtre épaisseur 12,5".to_string())]
    );
}

#[tokio::test]
async fn unreadable_source_fails_the_batch_before_staging() {
    let store = crate::support::installed_store().await;
    store
        .create_batch(&batch(
            "lot_casse",
            SourceFormat::Xml,
            SourceEncoding::Utf8,
            1,
        ))
        .await
        .expect("lot");
    let source = b"<BMECAT><ARTICLE><SUPPLIER_AID>A</SUPPLIER_AID></ARTICLE>\n<ARTICLE><SUPPLIER_AID>B</X></ARTICLE></BMECAT>";
    let error = process(&store, "lot_casse", SourceFormat::Xml, source)
        .await
        .expect_err("source illisible");
    assert_eq!(error.code(), "INGESTION_SOURCE_INVALID");
    let lot = store
        .get_batch("lot_casse")
        .await
        .expect("lecture")
        .expect("lot");
    assert_eq!(lot.statut, BatchStatus::Failed);
    let last = lot.transitions.last().expect("transition");
    assert!(last.reason.contains("PARSING_SYNTAX"), "{}", last.reason);
    assert!(
        labels(&store, "lot_casse").await.is_empty(),
        "aucun article en staging, même ceux lus avant l'erreur"
    );
}

#[tokio::test]
async fn resume_keeps_numbers_after_a_rejection() {
    let store = crate::support::installed_store().await;
    // Blocs de deux éléments : [A, rejet], [C, D] ; reprise après le premier bloc
    let claim = crate::support::claimed_batch(
        &store,
        &batch("lot_reprise", SourceFormat::Json, SourceEncoding::Utf8, 2),
    )
    .await;
    store
        .save_checkpoint(
            &claim,
            "lot_reprise",
            &BatchProgress {
                cursor_offset: 2,
                total_lignes: 4,
                verified: 0,
                to_confirm: 1,
                rejected: 1,
            },
        )
        .await
        .expect("point de reprise");
    store
        .release_batch("lot_reprise", &claim)
        .await
        .expect("libération");

    let source = br#"[{"ref":"A","designation":"A","fabricant":"Placo","unite":"M2"}, "x", {"ref":"C","designation":"C","fabricant":"Placo","unite":"M2"}, {"ref":"D","designation":"D","fabricant":"Placo","unite":"M2"}]"#;
    let report = process(&store, "lot_reprise", SourceFormat::Json, source)
        .await
        .expect("reprise");
    assert_eq!(report.total_lignes, 4);
    assert_eq!(
        report.rejected_count, 1,
        "le rejet du premier bloc n'est pas recompté"
    );
    let numbers: Vec<usize> = labels(&store, "lot_reprise")
        .await
        .into_iter()
        .map(|(n, _)| n)
        .collect();
    assert_eq!(
        numbers,
        vec![3, 4],
        "les éléments repris gardent leur numéro dans la source"
    );
}
