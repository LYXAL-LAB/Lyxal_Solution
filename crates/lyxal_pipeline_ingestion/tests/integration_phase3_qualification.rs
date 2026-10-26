//! Tests d'intégration complets de la Phase 3 (Directive CTO) :
//! 1. Qualification commerciale stricte (VERIFIED, TO_CONFIRM, REJECTED).
//! 2. Rapprochement technique des 4 familles (Plaques, Rails, Électricité, Isolants) & non-confusion groupe/filiales.
//! 3. Substitution autorisée contextualisée (CSTB/Avis Technique) et révocable.
//! 4. Quarantaine industrielle, classification des anomalies, audit trail et requalification steward_admin.
//! 5. Test de streaming et de volume à grande échelle (1 500+ articles).

use std::collections::HashMap;
use std::time::Instant;

use lyxal_pipeline_ingestion::adapters::{AdapterRegistry, RawRecordDto};
use lyxal_pipeline_ingestion::normalization::{
    normalize_manufacturer, CanonicalDimensions, NormalizationEngine, NormalizedItemDto,
};
use lyxal_pipeline_ingestion::quarantine::{
    AnomalyCategory, AnomalySeverity, QuarantineEngine, QuarantineStatus,
};
use lyxal_pipeline_ingestion::technical_grouping::{
    ContextualSubstitutionRule, TechnicalGroupLevel, TechnicalGroupingEngine,
};
use lyxal_pipeline_ingestion::types::{ItemQualification, SourceFormat};

/// Helper de construction d'un article normalisé de test
fn create_test_item(
    mfg: &str,
    reference: &str,
    label: &str,
    unit: Option<&str>,
    price: Option<f64>,
    gtin: Option<&str>,
    is_gtin_valid: bool,
    dims: Option<CanonicalDimensions>,
    features: HashMap<String, String>,
    qual: ItemQualification,
) -> NormalizedItemDto {
    NormalizedItemDto {
        line_number: 1,
        source_format: SourceFormat::FabDis,
        manufacturer_ref: reference.to_string(),
        manufacturer: mfg.to_string(),
        brand: Some(mfg.to_string()),
        commercial_label: label.to_string(),
        gtin: gtin.map(|g| g.to_string()),
        is_gtin_valid,
        unit_code: unit.map(|u| u.to_string()),
        price,
        currency: "EUR".to_string(),
        dimensions: dims,
        weight: None,
        technical_features: features,
        commercial_proof: None,
        qualification: qual,
        qualification_reason: "Initial qualification".to_string(),
        canonical_fingerprint: "hash_test".to_string(),
        raw_payload: serde_json::json!({}),
        raw_hash: "raw_hash_test".to_string(),
        rules_engine_version: "2026.1".to_string(),
    }
}

// =============================================================================
// TEST 1 : Qualification commerciale stricte & Découplage de l'équivalence
// =============================================================================
#[test]
fn test_commercial_qualification_strict_separation() {
    let norm_engine = NormalizationEngine::new();
    let grouping_engine = TechnicalGroupingEngine::new();

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
    let norm_no_proof = norm_engine.normalize(&raw_verified, None, SourceFormat::Csv);
    assert_eq!(norm_no_proof.qualification, ItemQualification::ToConfirm);
    assert!(norm_no_proof.qualification_reason.contains("preuve commerciale formelle absente"));

    // b) Avec preuve commerciale formelle (flux EDI signé / certificat) -> VERIFIED
    let proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::CertifiedManufacturerEdi,
        "EDI-BORD-2026-SG-01",
        "EDI_HUB_SAINT_GOBAIN",
        "system:edi_receiver",
        "2026-10-25T10:00:00Z",
    );
    let norm_verified = norm_engine.normalize_with_proof(&raw_verified, None, SourceFormat::Csv, Some(proof));
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
    let norm_gtin_only = norm_engine.normalize(&raw_gtin_only, None, SourceFormat::Csv);
    // Exigence CTO : Une clé GTIN valide ne suffit jamais à attribuer VERIFIED
    assert_eq!(norm_gtin_only.qualification, ItemQualification::ToConfirm);
    assert!(norm_gtin_only.qualification_reason.contains("preuve commerciale formelle absente"));

    // 1.3. Cas REJECTED : Code GTIN avec checksum corrompu (Modulo 10 faux)
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
    let norm_corrupt_gtin = norm_engine.normalize(&raw_corrupt_gtin, None, SourceFormat::Csv);
    assert_eq!(norm_corrupt_gtin.qualification, ItemQualification::Rejected);
    assert!(norm_corrupt_gtin.qualification_reason.contains("GTIN"));

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
    let norm_neg_price = norm_engine.normalize(&raw_neg_price, None, SourceFormat::Csv);
    assert_eq!(norm_neg_price.qualification, ItemQualification::Rejected);

    // 1.5. Règle inviolable CTO : Une équivalence technique ne confère jamais à elle seule le statut commercial VERIFIED
    // a) Article GTIN seul sans cotes -> Niveau Famille, qualification reste TO_CONFIRM
    let dec_family = grouping_engine.evaluate_item(&norm_gtin_only);
    assert_eq!(dec_family.reached_level, TechnicalGroupLevel::Family);
    assert_eq!(dec_family.qualification, ItemQualification::ToConfirm);

    // b) Article avec géométrie concordante mais sans preuve tarifaire ni GTIN (TO_CONFIRM)
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
    let norm_spec_to_confirm = norm_engine.normalize(&raw_spec_to_confirm, None, SourceFormat::Csv);
    assert_eq!(norm_spec_to_confirm.qualification, ItemQualification::ToConfirm);

    // Évaluation technique : atteint le Niveau 3 (FunctionalEquivalence) grâce aux caractéristiques techniques complètes
    let dec_equiv = grouping_engine.evaluate_item(&norm_spec_to_confirm);
    assert_eq!(dec_equiv.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
    // MAIS son statut reste TO_CONFIRM car commercialement non vérifié (RÈGLE INVIOLABLE CTO)
    assert_eq!(dec_equiv.qualification, ItemQualification::ToConfirm);
}

// =============================================================================
// TEST 2 : Regroupement technique des 4 familles & Distinction des filiales
// =============================================================================
#[test]
fn test_technical_grouping_four_families_and_entity_distinction() {
    let engine = TechnicalGroupingEngine::new();

    // -------------------------------------------------------------------------
    // 2.1. Famille 1 : Plaques de plâtre (BA13 Placo vs KS13 Knauf)
    // -------------------------------------------------------------------------
    let mut feat_ba13 = HashMap::new();
    feat_ba13.insert("edge_type".to_string(), "BA".to_string());
    feat_ba13.insert("fire_rating".to_string(), "A2-S1,D0".to_string());

    let placo_ba13 = create_test_item(
        "PLACO",
        "BA13_2500",
        "Plaque Placoplatre BA13 2500x1200",
        Some("M2"),
        Some(8.50),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) }),
        feat_ba13.clone(),
        ItemQualification::Verified,
    );

    let knauf_ks13 = create_test_item(
        "KNAUF",
        "KS13_2500",
        "Plaque Knauf Standard KS 13 2500x1200",
        Some("M2"),
        Some(8.30),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) }),
        feat_ba13,
        ItemQualification::Verified,
    );

    let dec_plaques = engine.compare_items(&placo_ba13, &knauf_ks13);
    assert_eq!(dec_plaques.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
    assert_eq!(dec_plaques.confidence_score, 0.90);

    // -------------------------------------------------------------------------
    // 2.2. Famille 2 : Rails et montants métalliques (R48 Placo vs R48 Knauf)
    // -------------------------------------------------------------------------
    let mut feat_rail = HashMap::new();
    feat_rail.insert("fire_rating".to_string(), "A1".to_string());

    let rail_placo = create_test_item(
        "PLACO",
        "RAIL_R48",
        "Rail R48 Stil Prim 3m",
        Some("ML"),
        Some(3.20),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(3000.0), width_mm: Some(48.0), height_mm: Some(40.0) }),
        feat_rail.clone(),
        ItemQualification::Verified,
    );

    let rail_knauf = create_test_item(
        "KNAUF",
        "RAIL_KNAUF_R48",
        "Rail R48 Knauf profilé 3m",
        Some("ML"),
        Some(3.10),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(3000.0), width_mm: Some(48.0), height_mm: Some(40.0) }),
        feat_rail,
        ItemQualification::Verified,
    );

    let dec_rails = engine.compare_items(&rail_placo, &rail_knauf);
    assert_eq!(dec_rails.reached_level, TechnicalGroupLevel::FunctionalEquivalence);

    // -------------------------------------------------------------------------
    // 2.3. Famille 3 : Prises et appareillages électriques (Legrand Céliane vs Schneider Odace)
    // -------------------------------------------------------------------------
    let mut feat_prise = HashMap::new();
    feat_prise.insert("current_rating_a".to_string(), "16".to_string());
    feat_prise.insert("mounting_type".to_string(), "ENCASTRE".to_string());

    let prise_legrand = create_test_item(
        "LEGRAND",
        "CELIANE_067111",
        "Prise de courant 2P+T 16A encastré Legrand Céliane",
        Some("PCE"),
        Some(7.90),
        Some("3017620422003"),
        true,
        None,
        feat_prise.clone(),
        ItemQualification::Verified,
    );

    let prise_schneider = create_test_item(
        "SCHNEIDER ELECTRIC",
        "ODACE_S520059",
        "Prise de courant 2P+T 16A encastré Schneider Odace",
        Some("PCE"),
        Some(6.80),
        Some("3017620422003"),
        true,
        None,
        feat_prise,
        ItemQualification::Verified,
    );

    let dec_prises = engine.compare_items(&prise_legrand, &prise_schneider);
    // Même famille électricité
    assert!(dec_prises.matched_criteria.iter().any(|m| m.contains("famille")));

    // -------------------------------------------------------------------------
    // 2.4. Famille 4 : Isolants thermiques (Laine de verre vs Laine de roche)
    // Matériaux incompatibles -> Doit refuser l'équivalence fonctionnelle
    // -------------------------------------------------------------------------
    let mut feat_verre = HashMap::new();
    feat_verre.insert("insulation_material".to_string(), "LAINE_DE_VERRE".to_string());
    feat_verre.insert("thermal_lambda".to_string(), "0.032".to_string());

    let isover_gr32 = create_test_item(
        "ISOVER",
        "GR32_100",
        "Panneau laine de verre Isover GR32 100mm",
        Some("M2"),
        Some(14.50),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(2700.0), width_mm: Some(1200.0), height_mm: Some(100.0) }),
        feat_verre,
        ItemQualification::Verified,
    );

    let mut feat_roche = HashMap::new();
    feat_roche.insert("insulation_material".to_string(), "LAINE_DE_ROCHE".to_string());
    feat_roche.insert("thermal_lambda".to_string(), "0.035".to_string());

    let rockwool_plus = create_test_item(
        "ROCKWOOL",
        "ROCKPLUS_100",
        "Panneau rigide laine de roche Rockwool 100mm",
        Some("M2"),
        Some(16.00),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(1200.0), width_mm: Some(600.0), height_mm: Some(100.0) }),
        feat_roche,
        ItemQualification::Verified,
    );

    let dec_isolants = engine.compare_items(&isover_gr32, &rockwool_plus);
    assert_eq!(dec_isolants.reached_level, TechnicalGroupLevel::Family);
    assert!(dec_isolants.missing_evidence.iter().any(|m| m.contains("incompatibles")));

    // -------------------------------------------------------------------------
    // 2.5. Empêcher les faux regroupements entre familles différentes
    // (Plaque de plâtre vs Rail métallique)
    // -------------------------------------------------------------------------
    let dec_cross = engine.compare_items(&placo_ba13, &rail_placo);
    assert_eq!(dec_cross.reached_level, TechnicalGroupLevel::Family);
    assert_eq!(dec_cross.qualification, ItemQualification::Rejected);
    assert_eq!(dec_cross.technical_identity_key, "DIFF_FAMILIES");

    // -------------------------------------------------------------------------
    // 2.6. Distinction stricte des filiales au sein d'un même groupe industriel
    // -------------------------------------------------------------------------
    assert_eq!(normalize_manufacturer("Saint-Gobain Placo"), "PLACO");
    assert_eq!(normalize_manufacturer("Saint-Gobain Isover"), "ISOVER");
    assert_eq!(normalize_manufacturer("Saint-Gobain Weber"), "WEBER");
    assert_eq!(normalize_manufacturer("Saint-Gobain PAM Pont-à-Mousson"), "PAM");
    assert_eq!(normalize_manufacturer("Saint-Gobain"), "SAINT-GOBAIN (INDETERMINE)");

    // Marques électriques du groupe Legrand
    assert_eq!(normalize_manufacturer("Legrand France"), "LEGRAND");
    assert_eq!(normalize_manufacturer("Bticino"), "BTICINO");
    assert_eq!(normalize_manufacturer("Legrand Bticino"), "BTICINO");

    // Marques du groupe Schneider Electric
    assert_eq!(normalize_manufacturer("Schneider Electric France"), "SCHNEIDER ELECTRIC");
    assert_eq!(normalize_manufacturer("Merlin Gerin"), "MERLIN GERIN");
    assert_eq!(normalize_manufacturer("Telemecanique"), "TELEMECANIQUE");
}

// =============================================================================
// TEST 3 : Substitution autorisée contextualisée & Révocable (Directive CTO)
// =============================================================================
#[test]
fn test_contextual_and_revocable_substitution() {
    let mut engine = TechnicalGroupingEngine::new();

    let placo = create_test_item(
        "PLACO",
        "BA13_2500",
        "Placoplatre BA13 2500x1200",
        Some("M2"),
        Some(8.50),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) }),
        HashMap::from([("edge_type".to_string(), "BA".to_string()), ("fire_rating".to_string(), "A2-S1,D0".to_string())]),
        ItemQualification::Verified,
    );

    let knauf = create_test_item(
        "KNAUF",
        "KS13_2500",
        "Knauf Standard KS 13 2500x1200",
        Some("M2"),
        Some(8.30),
        Some("3017620422003"),
        true,
        Some(CanonicalDimensions { length_mm: Some(2500.0), width_mm: Some(1200.0), height_mm: Some(12.5) }),
        HashMap::from([("edge_type".to_string(), "BA".to_string()), ("fire_rating".to_string(), "A2-S1,D0".to_string())]),
        ItemQualification::Verified,
    );

    // 1. Sans règle enregistrée -> Reste au Niveau 3 (Équivalence fonctionnelle)
    let dec_before = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
    assert_eq!(dec_before.reached_level, TechnicalGroupLevel::FunctionalEquivalence);

    // 2. Enregistrement d'une règle contextualisée CSTB sur le scope "SYSTEME_CLOISON_72_48"
    engine.register_contextual_substitution(ContextualSubstitutionRule {
        rule_id: "CSTB-ATE-2026-01".to_string(),
        source_manufacturer: "PLACO".to_string(),
        source_ref: "BA13_2500".to_string(),
        target_manufacturer: "KNAUF".to_string(),
        target_ref: "KS13_2500".to_string(),
        system_scope: "SYSTEME_CLOISON_72_48".to_string(),
        certification_body: "CSTB".to_string(),
        certification_reference: "Avis Technique n° 9/21-1050_V1".to_string(),
        valid_until: "2028-12-31".to_string(),
        is_revoked: false,
        revocation_reason: None,
    });

    // 3. Évaluation avec le système conforme -> Promotion Niveau 4 (AuthorizedSubstitution)
    let dec_valid_context = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
    assert_eq!(dec_valid_context.reached_level, TechnicalGroupLevel::AuthorizedSubstitution);
    assert_eq!(dec_valid_context.confidence_score, 1.0);
    assert!(dec_valid_context.matched_criteria.iter().any(|m| m.contains("Avis Technique")));

    // 4. Évaluation avec un système constructif différent -> Rejet du Niveau 4 (hors périmètre)
    let dec_wrong_context = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_PLAFOND_SUSPENDU"));
    assert_eq!(dec_wrong_context.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
    assert!(dec_wrong_context.missing_evidence.iter().any(|m| m.contains("hors périmètre")));

    // 5. Révocation formelle de l'Avis Technique
    let revoked = engine.revoke_substitution("CSTB-ATE-2026-01", "Avis Technique suspendu pour non-conformité procès-verbal");
    assert!(revoked);

    let dec_after_revocation = engine.compare_items_in_context(&placo, &knauf, Some("SYSTEME_CLOISON_72_48"));
    assert_eq!(dec_after_revocation.reached_level, TechnicalGroupLevel::FunctionalEquivalence);
    assert!(dec_after_revocation.missing_evidence.iter().any(|m| m.contains("révoquée")));
}

// =============================================================================
// TEST 4 : Quarantaine industrielle, classification et requalification steward_admin
// =============================================================================
#[test]
fn test_quarantine_engine_lifecycle_and_audit() {
    let quarantine = QuarantineEngine::new();

    // 4.1. Enregistrement d'une anomalie GTIN invalide
    let inserted1 = quarantine.log_anomaly(
        "batch_20261025_01",
        42,
        "raw_hash_42",
        Some("REF-42"),
        Some("PLACO"),
        AnomalySeverity::Error,
        AnomalyCategory::InvalidGtin,
        "INGESTION_GTIN_CHECKSUM_INVALID",
        "Clé de contrôle GS1 Modulo 10 erronée",
        Some("gtin"),
        Some("3017620422009"),
        serde_json::json!({"ref": "REF-42", "gtin": "3017620422009"}),
        ItemQualification::Rejected,
    );
    assert!(inserted1);
    assert_eq!(quarantine.len(), 1);

    // 4.2. Test d'idempotence : double insertion identique ignorée
    let inserted_dup = quarantine.log_anomaly(
        "batch_20261025_01",
        42,
        "raw_hash_42",
        Some("REF-42"),
        Some("PLACO"),
        AnomalySeverity::Error,
        AnomalyCategory::InvalidGtin,
        "INGESTION_GTIN_CHECKSUM_INVALID",
        "Clé de contrôle GS1 Modulo 10 erronée",
        Some("gtin"),
        Some("3017620422009"),
        serde_json::json!({"ref": "REF-42", "gtin": "3017620422009"}),
        ItemQualification::Rejected,
    );
    assert!(!inserted_dup);
    assert_eq!(quarantine.len(), 1);

    // 4.3. Enregistrement d'une seconde anomalie MissingCommercialProof
    quarantine.log_anomaly(
        "batch_20261025_01",
        43,
        "raw_hash_43",
        Some("REF-43"),
        Some("KNAUF"),
        AnomalySeverity::Warning,
        AnomalyCategory::MissingCommercialProof,
        "INGESTION_PRICE_MISSING",
        "Absence de tarif fournisseur dans le bordereau",
        Some("price"),
        None,
        serde_json::json!({"ref": "REF-43"}),
        ItemQualification::ToConfirm,
    );
    assert_eq!(quarantine.len(), 2);

    let entries = quarantine.list_by_batch("batch_20261025_01");
    assert_eq!(entries.len(), 2);
    let entry_to_requalify = &entries[1];

    // 4.4. Tentative de requalification non autorisée (rôle insuffisant)
    let res_unauth = quarantine.requalify_entry(
        &entry_to_requalify.entry_id,
        ItemQualification::Verified,
        "agent:qualification_worker",
        "qualification_agent",
        "Je valide sans droit d'administration",
    );
    assert!(res_unauth.is_err());
    assert!(res_unauth.unwrap_err().contains("steward_admin"));

    // 4.5. Tentative de requalification avec justification trop courte (< 10 caractères)
    let res_short_justif = quarantine.requalify_entry(
        &entry_to_requalify.entry_id,
        ItemQualification::Verified,
        "user:chief_steward",
        "steward_admin",
        "ok",
    );
    assert!(res_short_justif.is_err());
    assert!(res_short_justif.unwrap_err().contains("au moins 10 caractères"));

    // 4.6. Requalification formelle valide par steward_admin
    let res_ok = quarantine.requalify_entry(
        &entry_to_requalify.entry_id,
        ItemQualification::Verified,
        "user:chief_steward",
        "steward_admin",
        "Avenant tarifaire officiel n°2026-B validé et signé par le fabricant Knauf",
    );
    assert!(res_ok.is_ok());

    let updated = res_ok.unwrap();
    assert_eq!(updated.status, QuarantineStatus::Requalified);
    assert_eq!(updated.resulting_qualification, ItemQualification::Verified);
    assert_eq!(updated.audit_trail.len(), 2);
    assert_eq!(updated.audit_trail[1].to_statut, "Verified");
    assert!(updated.audit_trail[1].transition_by.contains("chief_steward"));

    // 4.7. Statistiques de quarantaine
    let stats = quarantine.get_stats_for_batch("batch_20261025_01");
    assert_eq!(stats.total_anomalies, 2);
    assert_eq!(stats.error_count, 1);
    assert_eq!(stats.warning_count, 1);
    assert_eq!(stats.requalified_count, 1);
}

// =============================================================================
// TEST 5 : Streaming et volume à grande échelle (1 500+ articles réels)
// =============================================================================
#[test]
fn test_streaming_and_volume_large_scale() {
    let registry = AdapterRegistry::new();
    let norm_engine = NormalizationEngine::new();
    let quarantine = QuarantineEngine::new();

    // Génération synthétique d'un flux CSV de 1 500 articles BTP représentatifs
    let mut csv_buffer = String::with_capacity(300_000);
    csv_buffer.push_str("reference;designation;fabricant;unite;prix;longueur;largeur;epaisseur;gtin\n");

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
            // Anomalie volontaire (GTIN corrompu) pour tester le routage quarantaine
            csv_buffer.push_str(&format!(
                "ERR_{i};Prise 2P+T Legrand avec GTIN erroné;Legrand France;PCE;7.50;80;80;40;3017620422009\n"
            ));
        }
    }

    let csv_adapter = registry.get(SourceFormat::Csv).expect("CsvAdapter introuvable");

    let start_time = Instant::now();

    // 1. Parsing streaming
    let records = csv_adapter
        .parse_content(&csv_buffer)
        .expect("Échec du streaming CSV à grande échelle");
    assert_eq!(records.len(), 1500);

    let mut verified_count = 0;
    let mut rejected_count = 0;

    let stream_proof = lyxal_pipeline_ingestion::proof::CommercialProof::new(
        lyxal_pipeline_ingestion::proof::CommercialProofType::CertifiedManufacturerEdi,
        "EDI-STREAM-1500",
        "EDI_HUB_BTP",
        "system:stream_worker",
        "2026-10-25T10:00:00Z",
    );

    // 2. Normalisation et routage quarantaine
    for rec in &records {
        let normalized = norm_engine.normalize_with_proof(rec, None, SourceFormat::Csv, Some(stream_proof.clone()));

        match normalized.qualification {
            ItemQualification::Verified => verified_count += 1,
            ItemQualification::Rejected => {
                rejected_count += 1;
                quarantine.log_anomaly(
                    "batch_large_scale_01",
                    rec.line_number,
                    &rec.raw_hash,
                    Some(&rec.raw_reference),
                    rec.raw_manufacturer.as_deref(),
                    AnomalySeverity::Error,
                    AnomalyCategory::InvalidGtin,
                    "INGESTION_GTIN_CHECKSUM_INVALID",
                    &normalized.qualification_reason,
                    Some("gtin"),
                    rec.raw_gtin.as_deref(),
                    rec.raw_payload.clone(),
                    ItemQualification::Rejected,
                );
            }
            ItemQualification::ToConfirm => {}
        }
    }

    let duration = start_time.elapsed();

    // Vérification des volumétries
    assert_eq!(rejected_count, 375); // 1500 / 4 = 375 anomalies
    assert_eq!(verified_count, 1125); // 1500 - 375 = 1125 vérifiés
    assert_eq!(quarantine.len(), 375);

    // Débit de streaming et performance industrielle : 1 500 articles traités en streaming
    assert!(
        duration.as_millis() < 3000,
        "Le pipeline de streaming doit traiter 1500 lignes en moins de 3s en mode debug (actuel: {}ms)",
        duration.as_millis()
    );

    let throughput = (1500.0 / duration.as_secs_f64()) as usize;
    println!("Débit mesuré sur 1 500 articles : {} articles/seconde (durée: {}ms)", throughput, duration.as_millis());
    assert!(throughput >= 500, "Débit minimum attendu en mode test : >= 500 articles/seconde");
}
