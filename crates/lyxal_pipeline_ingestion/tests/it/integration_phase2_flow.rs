//! Test d'intégration de bout en bout de la Phase 2 :
//! Parsing multiformat -> Normalisation universelle.

use lyxal_pipeline_ingestion::adapters::AdapterRegistry;
use lyxal_pipeline_ingestion::normalization::NormalizationEngine;
use lyxal_pipeline_ingestion::types::{ItemQualification, SourceFormat};

#[tokio::test]
async fn test_end_to_end_phase2_flow() {
    let store = crate::support::installed_store().await;
    // -------------------------------------------------------------------------
    // 1. Initialisation du registre d'adaptateurs et des moteurs
    // -------------------------------------------------------------------------
    let registry = AdapterRegistry::new();
    let norm_engine = NormalizationEngine::new();

    // -------------------------------------------------------------------------
    // 2. Flux FAB-DIS BTP multi-blocs (Placo BA13 + Rail R48)
    // -------------------------------------------------------------------------
    let fab_dis_content = r#"
C;BA13_2500;3017620422003;Placoplatre BA13 standard 2500x1200;SAINT GOBAIN PLACO;M2;8.50
L;BA13_2500;28.5;29.0;2500;1200;12.5
R;BA13_2500;EC001419;NF EN 520;A2-s1,d0
C;RAIL_R48_3M;3017620422003;Rail R48 Stil Prim longueur 3m;SAINT GOBAIN PLACO;ML;3.20
L;RAIL_R48_3M;1.5;1.6;3000;48;40
R;RAIL_R48_3M;EC000382;NF EN 14195;A1
"#;

    let fab_adapter = registry
        .get(SourceFormat::FabDis)
        .expect("FabDisAdapter introuvable");
    let raw_records = fab_adapter
        .parse_content(fab_dis_content)
        .expect("Échec du parsing FAB-DIS");
    assert_eq!(raw_records.len(), 2);

    // Preuve commerciale officielle de bordereau fabricant signé (Directive CTO Phase 4)
    let vendor_proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::CertifiedManufacturerEdi,
        "EDI-BORD-2026-SG-01",
        "EDI_HUB_SAINT_GOBAIN",
        "system:edi_receiver",
        "2026-10-25T10:00:00Z",
    );

    // Normalisation des articles FAB-DIS avec preuve commerciale
    let norm_ba13_placo = norm_engine.normalize_with_proof(
        &raw_records[0],
        None,
        SourceFormat::FabDis,
        Some(vendor_proof.clone()),
        &crate::support::referentials_for(&store, &raw_records[0], None).await,
    );
    assert_eq!(norm_ba13_placo.manufacturer, "PLACO");
    assert_eq!(norm_ba13_placo.manufacturer_ref, "BA13_2500");
    assert_eq!(norm_ba13_placo.unit_code, Some("M2".to_string()));
    assert_eq!(norm_ba13_placo.qualification, ItemQualification::Verified);

    let norm_rail_placo = norm_engine.normalize_with_proof(
        &raw_records[1],
        None,
        SourceFormat::FabDis,
        Some(vendor_proof),
        &crate::support::referentials_for(&store, &raw_records[1], None).await,
    );
    assert_eq!(norm_rail_placo.manufacturer, "PLACO");
    assert_eq!(norm_rail_placo.unit_code, Some("ML".to_string()));

    // -------------------------------------------------------------------------
    // 3. Flux CSV concurrent (Knauf KS13 2500x1200) avec preuve catalogue signée
    // -------------------------------------------------------------------------
    let csv_content = "ref;designation;fabricant;unite;prix;longueur;largeur;epaisseur;norme;classement_feu\nKS13_2500;Plaque Knauf Standard KS 13 2500x1200;Knauf SAS;M2;8.30;2500;1200;12.5;NF EN 520;A2-S1,D0\n";
    let csv_adapter = registry
        .get(SourceFormat::Csv)
        .expect("CsvAdapter introuvable");
    let raw_knauf = csv_adapter
        .parse_content(csv_content)
        .expect("Échec du parsing CSV");
    assert_eq!(raw_knauf.len(), 1);

    let knauf_proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::SignedVendorCatalog,
        "CAT-KNAUF-2026-V1",
        "KNAUF_PARTNER_PORTAL",
        "system:catalog_importer",
        "2026-10-25T10:00:00Z",
    );
    let norm_ba13_knauf = norm_engine.normalize_with_proof(
        &raw_knauf[0],
        None,
        SourceFormat::Csv,
        Some(knauf_proof),
        &crate::support::referentials_for(&store, &raw_knauf[0], None).await,
    );
    assert_eq!(norm_ba13_knauf.manufacturer, "KNAUF");
    assert_eq!(norm_ba13_knauf.manufacturer_ref, "KS13_2500");
    assert_eq!(norm_ba13_knauf.qualification, ItemQualification::Verified);

    // -------------------------------------------------------------------------
    // 4. Flux XML BMEcat concurrent (Siniat Pregyplac BA13 mais sans preuve feu)
    // -------------------------------------------------------------------------
    let xml_content = r#"<?xml version="1.0" encoding="UTF-8"?>
<BMECAT version="1.2">
  <T_NEW_CATALOG>
    <ARTICLE>
      <SUPPLIER_AID>SINIAT_BA13</SUPPLIER_AID>
      <DESCRIPTION_SHORT>Plaque Siniat Pregyplac BA13 2500x1200</DESCRIPTION_SHORT>
      <MANUFACTURER_NAME>Siniat France SAS</MANUFACTURER_NAME>
      <ORDER_UNIT>M2</ORDER_UNIT>
      <PRICE_AMOUNT>8.40</PRICE_AMOUNT>
    </ARTICLE>
  </T_NEW_CATALOG>
</BMECAT>"#;
    let xml_adapter = registry
        .get(SourceFormat::Xml)
        .expect("XmlAdapter introuvable");
    let raw_siniat = xml_adapter
        .parse_content(xml_content)
        .expect("Échec du parsing XML");
    let norm_ba13_siniat = norm_engine.normalize(
        &raw_siniat[0],
        None,
        SourceFormat::Xml,
        &crate::support::referentials_for(&store, &raw_siniat[0], None).await,
    );
    assert_eq!(norm_ba13_siniat.manufacturer, "SINIAT");

    // -------------------------------------------------------------------------
    // 5. Règle absolue d'anti-fusion : les références commerciales restent distinctes
    // -------------------------------------------------------------------------
    assert_eq!(norm_ba13_placo.manufacturer_ref, "BA13_2500");
    assert_eq!(norm_ba13_knauf.manufacturer_ref, "KS13_2500");
    assert_ne!(norm_ba13_placo.manufacturer, norm_ba13_knauf.manufacturer);
    assert_ne!(
        norm_ba13_placo.canonical_fingerprint,
        norm_ba13_knauf.canonical_fingerprint
    );
}
