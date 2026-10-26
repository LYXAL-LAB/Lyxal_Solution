//! Test d'intégration de bout en bout de la Phase 2 :
//! Parsing multiformat -> Normalisation universelle -> Regroupement technique multi-niveaux.

use lyxal_pipeline_ingestion::adapters::AdapterRegistry;
use lyxal_pipeline_ingestion::normalization::NormalizationEngine;
use lyxal_pipeline_ingestion::technical_grouping::{TechnicalGroupLevel, TechnicalGroupingEngine};
use lyxal_pipeline_ingestion::types::{ItemQualification, SourceFormat};

#[test]
fn test_end_to_end_phase2_flow() {
    // -------------------------------------------------------------------------
    // 1. Initialisation du registre d'adaptateurs et des moteurs
    // -------------------------------------------------------------------------
    let registry = AdapterRegistry::new();
    let norm_engine = NormalizationEngine::new();
    let mut grouping_engine = TechnicalGroupingEngine::new();

    // Enregistrement d'une substitution certifiée officielle (Avis Technique CSTB)
    grouping_engine.register_certified_substitution("PLACO", "BA13_2500", "KNAUF", "KS13_2500");

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

    let fab_adapter = registry.get(SourceFormat::FabDis).expect("FabDisAdapter introuvable");
    let raw_records = fab_adapter.parse_content(fab_dis_content).expect("Échec du parsing FAB-DIS");
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
    let norm_ba13_placo = norm_engine.normalize_with_proof(&raw_records[0], None, SourceFormat::FabDis, Some(vendor_proof.clone()));
    assert_eq!(norm_ba13_placo.manufacturer, "PLACO");
    assert_eq!(norm_ba13_placo.manufacturer_ref, "BA13_2500");
    assert_eq!(norm_ba13_placo.unit_code, Some("M2".to_string()));
    assert_eq!(norm_ba13_placo.qualification, ItemQualification::Verified);

    let norm_rail_placo = norm_engine.normalize_with_proof(&raw_records[1], None, SourceFormat::FabDis, Some(vendor_proof));
    assert_eq!(norm_rail_placo.manufacturer, "PLACO");
    assert_eq!(norm_rail_placo.unit_code, Some("ML".to_string()));

    // -------------------------------------------------------------------------
    // 3. Flux CSV concurrent (Knauf KS13 2500x1200) avec preuve catalogue signée
    // -------------------------------------------------------------------------
    let csv_content = "ref;designation;fabricant;unite;prix;longueur;largeur;epaisseur;norme;classement_feu\nKS13_2500;Plaque Knauf Standard KS 13 2500x1200;Knauf SAS;M2;8.30;2500;1200;12.5;NF EN 520;A2-S1,D0\n";
    let csv_adapter = registry.get(SourceFormat::Csv).expect("CsvAdapter introuvable");
    let raw_knauf = csv_adapter.parse_content(csv_content).expect("Échec du parsing CSV");
    assert_eq!(raw_knauf.len(), 1);

    let knauf_proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::SignedVendorCatalog,
        "CAT-KNAUF-2026-V1",
        "KNAUF_PARTNER_PORTAL",
        "system:catalog_importer",
        "2026-10-25T10:00:00Z",
    );
    let norm_ba13_knauf = norm_engine.normalize_with_proof(&raw_knauf[0], None, SourceFormat::Csv, Some(knauf_proof));
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
    let xml_adapter = registry.get(SourceFormat::Xml).expect("XmlAdapter introuvable");
    let raw_siniat = xml_adapter.parse_content(xml_content).expect("Échec du parsing XML");
    let norm_ba13_siniat = norm_engine.normalize(&raw_siniat[0], None, SourceFormat::Xml);
    assert_eq!(norm_ba13_siniat.manufacturer, "SINIAT");

    // -------------------------------------------------------------------------
    // 5. Évaluation du regroupement technique et des 4 niveaux
    // -------------------------------------------------------------------------

    // A. Placo BA13 vs Spécification générique patronne
    let dec_placo_spec = grouping_engine.evaluate_item(&norm_ba13_placo);
    assert_eq!(dec_placo_spec.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
    assert_eq!(dec_placo_spec.qualification, ItemQualification::Verified);

    // B. Placo BA13 vs Knauf KS13 (substitution certifiée préalable)
    let dec_placo_knauf = grouping_engine.compare_items(&norm_ba13_placo, &norm_ba13_knauf);
    // Atteint le Niveau 4 (Substitution autorisée) car enregistré dans certified_substitutions !
    assert_eq!(dec_placo_knauf.reached_level, TechnicalGroupLevel::AuthorizedSubstitution);
    assert_eq!(dec_placo_knauf.confidence_score, 1.0);
    assert_eq!(dec_placo_knauf.qualification, ItemQualification::Verified);

    // C. Placo BA13 vs Siniat BA13 (Siniat n'a pas de preuve de classement feu dans son XML)
    let dec_placo_siniat = grouping_engine.compare_items(&norm_ba13_placo, &norm_ba13_siniat);
    // Doit être cantonné au Niveau 2 (Spécification) avec qualification TO_CONFIRM
    // car la similitude de libellé ne suffit jamais !
    assert_eq!(dec_placo_siniat.reached_level, TechnicalGroupLevel::Specification);
    assert_eq!(dec_placo_siniat.qualification, ItemQualification::ToConfirm);
    assert!(dec_placo_siniat.missing_evidence.iter().any(|m| m.contains("feu")));

    // D. Placo BA13 vs Placo Rail R48 (familles différentes : cloison vs ossature)
    let dec_diff_family = grouping_engine.compare_items(&norm_ba13_placo, &norm_rail_placo);
    assert_eq!(dec_diff_family.qualification, ItemQualification::Rejected);

    // E. Règle absolue d'anti-fusion : vérification que les références commerciales restent distinctes
    assert_eq!(norm_ba13_placo.manufacturer_ref, "BA13_2500");
    assert_eq!(norm_ba13_knauf.manufacturer_ref, "KS13_2500");
    assert_ne!(norm_ba13_placo.manufacturer, norm_ba13_knauf.manufacturer);
    assert_ne!(norm_ba13_placo.canonical_fingerprint, norm_ba13_knauf.canonical_fingerprint);
}
