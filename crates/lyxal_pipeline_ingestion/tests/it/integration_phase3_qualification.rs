//! Tests d'intégration complets de la Phase 3 (Directive CTO) :
//! 1. Qualification commerciale stricte (VERIFIED, TO_CONFIRM, REJECTED).
//! 2. Test de streaming et de volume à grande échelle (1 500+ articles).

use std::collections::HashMap;
use std::time::Instant;

use lyxal_pipeline_ingestion::adapters::{AdapterRegistry, RawRecordDto};
use lyxal_pipeline_ingestion::normalization::NormalizationEngine;
use lyxal_pipeline_ingestion::types::{ItemQualification, SourceFormat};

// =============================================================================
// TEST 1 : Qualification commerciale stricte & Découplage de l'équivalence
// =============================================================================
#[tokio::test]
async fn test_commercial_qualification_strict_separation() {
    let store = crate::support::installed_store().await;
    let norm_engine = NormalizationEngine::new();

    // 1.1. Cas Nominal : fabricant vérifié, unité résolue, libellé explicite, tarif ET cotes
    let raw_verified = RawRecordDto {
        line_number: 1,
        raw_reference: "BA13_2500".to_string(),
        raw_designation: "Placoplatre BA13 standard 2500x1200x12.5".to_string(),
        raw_gtin: Some("3017620422003".to_string()), // GTIN GS1 Modulo 10 valide
        raw_manufacturer: Some("Saint-Gobain Placo SAS".to_string()),
        raw_brand: Some("PLACO".to_string()),
        raw_unit: Some("M2".to_string()),
        raw_price: Some(8.50),
        raw_currency: Some("EUR".to_string()),
        raw_dimensions: None,
        raw_weight: None,
        raw_attributes: HashMap::new(),
        raw_payload: serde_json::json!({}),
        raw_hash: "hash_01".to_string(),
    };

    // a) Sans preuve formelle de provenance commerciale -> Maintien strict en TO_CONFIRM (Directive CTO Phase 4)
    let norm_no_proof = norm_engine.normalize(
        &raw_verified,
        None,
        SourceFormat::Csv,
        &crate::support::referentials_for(&store, &raw_verified, None).await,
    );
    assert_eq!(norm_no_proof.qualification, ItemQualification::ToConfirm);
    assert!(norm_no_proof
        .qualification_reason
        .contains("preuve commerciale formelle absente"));

    // b) Avec preuve commerciale formelle (flux EDI signé / certificat) -> VERIFIED
    let proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::CertifiedManufacturerEdi,
        "EDI-BORD-2026-SG-01",
        "EDI_HUB_SAINT_GOBAIN",
        "system:edi_receiver",
        "2026-10-25T10:00:00Z",
    );
    let norm_verified = norm_engine.normalize_with_proof(
        &raw_verified,
        None,
        SourceFormat::Csv,
        Some(proof),
        &crate::support::referentials_for(&store, &raw_verified, None).await,
    );
    assert_eq!(norm_verified.qualification, ItemQualification::Verified);
    assert_eq!(norm_verified.manufacturer, "PLACO");

    // 1.2. Cas TO_CONFIRM : GTIN valide seul, mais SANS tarif ni dimensions
    let raw_gtin_only = RawRecordDto {
        line_number: 2,
        raw_reference: "BA13_SANS_PREUVE".to_string(),
        raw_designation: "Plaque de plâtre standard".to_string(),
        raw_gtin: Some("3017620422003".to_string()),
        raw_manufacturer: Some("Placo".to_string()),
        raw_brand: None,
        raw_unit: Some("M2".to_string()),
        raw_price: None, // Pas de prix
        raw_currency: None,
        raw_dimensions: None, // Pas de cotes
        raw_weight: None,
        raw_attributes: HashMap::new(),
        raw_payload: serde_json::json!({}),
        raw_hash: "hash_02".to_string(),
    };
    let norm_gtin_only = norm_engine.normalize(
        &raw_gtin_only,
        None,
        SourceFormat::Csv,
        &crate::support::referentials_for(&store, &raw_gtin_only, None).await,
    );
    // Exigence CTO : Une clé GTIN valide ne suffit jamais à attribuer VERIFIED
    assert_eq!(norm_gtin_only.qualification, ItemQualification::ToConfirm);
    assert!(norm_gtin_only
        .qualification_reason
        .contains("preuve commerciale formelle absente"));

    // 1.3. Code-barres à clé GS1 fausse : la normalisation le transmet tel quel ; il est refusé
    // à l'enregistrement par fn::ingestion_staged_save (fn::validation_gtin de lyxal_core).
    let raw_corrupt_gtin = RawRecordDto {
        line_number: 3,
        raw_reference: "REF_BAD_GTIN".to_string(),
        raw_designation: "Article avec GTIN falsifié".to_string(),
        raw_gtin: Some("3017620422009".to_string()), // Mauvaise clé
        raw_manufacturer: Some("Placo".to_string()),
        raw_brand: None,
        raw_unit: Some("M2".to_string()),
        raw_price: Some(10.0),
        raw_currency: Some("EUR".to_string()),
        raw_dimensions: None,
        raw_weight: None,
        raw_attributes: HashMap::new(),
        raw_payload: serde_json::json!({}),
        raw_hash: "hash_03".to_string(),
    };
    let norm_corrupt_gtin = norm_engine.normalize(
        &raw_corrupt_gtin,
        None,
        SourceFormat::Csv,
        &crate::support::referentials_for(&store, &raw_corrupt_gtin, None).await,
    );
    assert_eq!(norm_corrupt_gtin.gtin.as_deref(), Some("3017620422009"));
    assert_eq!(
        norm_corrupt_gtin.qualification,
        ItemQualification::ToConfirm
    );

    // 1.4. Cas REJECTED : Prix négatif
    let raw_neg_price = RawRecordDto {
        line_number: 4,
        raw_reference: "REF_NEG_PRICE".to_string(),
        raw_designation: "Article avec prix négatif incohérent".to_string(),
        raw_gtin: None,
        raw_manufacturer: Some("Placo".to_string()),
        raw_brand: None,
        raw_unit: Some("M2".to_string()),
        raw_price: Some(-5.0),
        raw_currency: Some("EUR".to_string()),
        raw_dimensions: None,
        raw_weight: None,
        raw_attributes: HashMap::new(),
        raw_payload: serde_json::json!({}),
        raw_hash: "hash_04".to_string(),
    };
    let norm_neg_price = norm_engine.normalize(
        &raw_neg_price,
        None,
        SourceFormat::Csv,
        &crate::support::referentials_for(&store, &raw_neg_price, None).await,
    );
    assert_eq!(norm_neg_price.qualification, ItemQualification::Rejected);

    // 1.5. Règle inviolable CTO : des caractéristiques techniques complètes ne confèrent jamais
    // à elles seules le statut commercial VERIFIED (article sans preuve tarifaire ni GTIN)
    let raw_spec_to_confirm = RawRecordDto {
        line_number: 5,
        raw_reference: "BA13_NO_TARIF".to_string(),
        raw_designation: "Placoplatre BA13 standard 2500x1200x12.5".to_string(),
        raw_gtin: None,
        raw_manufacturer: Some("Placo".to_string()),
        raw_brand: None,
        raw_unit: Some("M2".to_string()),
        raw_price: None, // Pas de prix
        raw_currency: None,
        raw_dimensions: None,
        raw_weight: None,
        raw_attributes: HashMap::from([
            ("norme".to_string(), "NF EN 520".to_string()),
            ("classement_feu".to_string(), "A2-S1,D0".to_string()),
            ("type_bord".to_string(), "BA".to_string()),
        ]),
        raw_payload: serde_json::json!({}),
        raw_hash: "hash_05".to_string(),
    };
    let norm_spec_to_confirm = norm_engine.normalize(
        &raw_spec_to_confirm,
        None,
        SourceFormat::Csv,
        &crate::support::referentials_for(&store, &raw_spec_to_confirm, None).await,
    );
    assert_eq!(
        norm_spec_to_confirm.qualification,
        ItemQualification::ToConfirm
    );
}

// =============================================================================
// TEST 2 : Streaming et volume à grande échelle (1 500 articles)
// =============================================================================
#[tokio::test]
async fn test_streaming_and_volume_large_scale() {
    let store = crate::support::installed_store().await;
    let registry = AdapterRegistry::new();
    let norm_engine = NormalizationEngine::new();

    // Génération synthétique d'un flux CSV de 1 500 articles BTP représentatifs
    let mut csv_buffer = String::with_capacity(300_000);
    csv_buffer
        .push_str("reference;designation;fabricant;unite;prix;longueur;largeur;epaisseur;gtin\n");

    for i in 1..=1500 {
        if i % 4 == 0 {
            // Plaque de plâtre BA13
            csv_buffer.push_str(&format!(
                "BA13_{i};Placoplatre standard BA13 2500x1200;Saint-Gobain Placo;M2;8.50;2500;1200;12.5;3017620422003\n"
            ));
        } else if i % 4 == 1 {
            // Rail métallique R48
            csv_buffer.push_str(&format!(
                "RAIL_{i};Rail R48 Stil Prim 3m;Saint-Gobain Placo;ML;3.20;3000;48;40;3017620422003\n"
            ));
        } else if i % 4 == 2 {
            // Isolant laine de verre
            csv_buffer.push_str(&format!(
                "ISO_{i};Panneau roulé laine de verre GR32 100mm;Saint-Gobain Isover;M2;14.50;2700;1200;100;3017620422003\n"
            ));
        } else {
            // Code-barres à clé GS1 fausse : contrôlé plus tard par fn::ingestion_staged_save
            csv_buffer.push_str(&format!(
                "ERR_{i};Prise 2P+T Legrand avec GTIN erroné;Legrand France;PCE;7.50;80;80;40;3017620422009\n"
            ));
        }
    }

    let csv_adapter = registry
        .get(SourceFormat::Csv)
        .expect("CsvAdapter introuvable");

    let start_time = Instant::now();

    // 1. Parsing streaming
    let records = csv_adapter
        .parse_content(&csv_buffer)
        .expect("Échec du streaming CSV à grande échelle");
    assert_eq!(records.len(), 1500);

    let mut verified_count = 0;

    let stream_proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::CertifiedManufacturerEdi,
        "EDI-STREAM-1500",
        "EDI_HUB_BTP",
        "system:stream_worker",
        "2026-10-25T10:00:00Z",
    );

    // 2. Normalisation et qualification ; référentiels résolus une fois pour le bloc
    let referentials = store.block_referentials(&records, None).await.unwrap();
    for rec in &records {
        let normalized = norm_engine.normalize_with_proof(
            rec,
            None,
            SourceFormat::Csv,
            Some(stream_proof.clone()),
            &referentials,
        );
        if normalized.qualification == ItemQualification::Verified {
            verified_count += 1;
        }
    }

    let duration = start_time.elapsed();

    // Vérification des volumétries
    assert_eq!(verified_count, 1500);

    // Débit de streaming et performance industrielle : 1 500 articles traités en streaming
    assert!(
        duration.as_millis() < 3000,
        "Le pipeline de streaming doit traiter 1500 lignes en moins de 3s en mode debug (actuel: {}ms)",
        duration.as_millis()
    );

    let throughput = (1500.0 / duration.as_secs_f64()) as usize;
    println!(
        "Débit mesuré sur 1 500 articles : {} articles/seconde (durée: {}ms)",
        throughput,
        duration.as_millis()
    );
    assert!(
        throughput >= 500,
        "Débit minimum attendu en mode test : >= 500 articles/seconde"
    );
}
