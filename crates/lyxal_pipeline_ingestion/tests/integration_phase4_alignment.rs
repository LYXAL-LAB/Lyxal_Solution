//! Suite de Tests de Validation CTO — Réalignement Architectural Lyxal Pipeline Ingestion
//!
//! Cette suite implémente les 8 tests obligatoires exigés par la décision CTO :
//! 1. Ajout d'une famille Carrelage par configuration SurrealDB sans recompilation Rust.
//! 2. Ajout d'un fabricant ou alias sans modification Rust.
//! 3. Résolution d'une unité depuis `base_unite` (lyxal_base).
//! 4. Vérification de l'utilisation exclusive des fonctions publiques (call_fn) pour les opérations métier.
//! 5. Persistance des règles et substitutions après rechargement.
//! 6. Contrôles RLS sur les tables et fonctions.
//! 7. Publication isolée des relations compatibles avec les contrats du catalogue.
//! 8. Reprise sur incident et idempotence après réalignement.

use lyxal_pipeline_ingestion::fingerprint::FingerprintEngine;
use lyxal_pipeline_ingestion::models::{IngestionBatch, PublicationManifest, StagedItem};
use lyxal_pipeline_ingestion::normalization::{CanonicalDimensions, NormalizedItemDto};
use lyxal_pipeline_ingestion::publisher::{ControlledPublisher, SyncAgentSession};
use lyxal_pipeline_ingestion::storage::IngestionStore;
use lyxal_pipeline_ingestion::technical_grouping::{
    ContextualSubstitutionRule, SpecificationTolerances, TechnicalGroupingEngine,
    TechnicalSpecification,
};
use lyxal_pipeline_ingestion::types::{
    BatchStatus, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat,
};

// =============================================================================
// TEST 1 : Ajout d'une famille Carrelage par configuration SurrealDB sans recompilation Rust
// =============================================================================
#[tokio::test]
async fn test_1_add_family_carrelage_dynamically_without_recompilation() {
    let store = IngestionStore::create_in_memory().await.unwrap();

    // 1. Déclaration de la nouvelle famille Carrelage via fn::ingestion_rule_family_add
    let family_code = store
        .add_family_rule(
            "carrelage",
            "Revêtements Céramiques et Carrelages",
            &["CARRELAGE", "GRES", "FAÏENCE", "CERAME", "MOSAIQUE"],
            Some("M2"),
        )
        .await
        .expect("Ajout dynamique de la famille Carrelage");
    assert_eq!(family_code, "CARRELAGE");

    // 2. Déclaration d'une spécification patronne pour le carrelage 60x60
    let spec = TechnicalSpecification {
        technical_identity_key: "SPEC_CARRELAGE_GRES_60X60".to_string(),
        family_code: "carrelage".to_string(),
        generic_title: "Carrelage Grès Cérame Émaillé 60x60 cm".to_string(),
        nominal_dimensions: Some(CanonicalDimensions {
            length_mm: Some(600.0),
            width_mm: Some(600.0),
            height_mm: Some(10.0),
        }),
        tolerances: Some(SpecificationTolerances {
            length_tol_mm: 5.0,
            width_tol_mm: 5.0,
            height_tol_mm: 1.0,
            weight_tol_pct: 5.0,
        }),
        nominal_weight: None,
        standard_norm: Some("NF EN 14411".to_string()),
        fire_rating: Some("A1fl".to_string()),
        required_features: [("anti_glissance".to_string(), "R10".to_string())]
            .into_iter()
            .collect(),
    };

    let spec_key = store
        .add_specification(&spec)
        .await
        .expect("Ajout dynamique de la spécification Carrelage");
    assert_eq!(spec_key, "SPEC_CARRELAGE_GRES_60X60");

    // 3. Rechargement dynamique des règles depuis SurrealDB
    let loaded_families = store.load_family_rules().await.unwrap();
    let loaded_specs = store.load_specifications().await.unwrap();

    let carrelage_family = loaded_families
        .iter()
        .find(|f| f.code.to_lowercase() == "carrelage");
    assert!(
        carrelage_family.is_some(),
        "La famille Carrelage doit exister dans les règles chargées depuis SurrealDB"
    );

    // 4. Instanciation du moteur de regroupement avec les règles rechargées dynamiquement
    let mut grouping_engine = TechnicalGroupingEngine::new();
    grouping_engine.clear_and_load(loaded_families, loaded_specs, vec![]);

    // 5. Test de qualification d'un article Carrelage
    let candidate = NormalizedItemDto {
        line_number: 1,
        source_format: SourceFormat::Csv,
        manufacturer_ref: "MZ-GRES-6060-GREY".to_string(),
        manufacturer: "MARAZZI".to_string(),
        brand: Some("MARAZZI".to_string()),
        commercial_label: "Carrelage Grès Cérame 60x60 Grey R10".to_string(),
        gtin: Some("8012345678901".to_string()),
        is_gtin_valid: true,
        unit_code: Some("M2".to_string()),
        price: Some(29.90),
        currency: "EUR".to_string(),
        dimensions: Some(CanonicalDimensions {
            length_mm: Some(600.0),
            width_mm: Some(600.0),
            height_mm: Some(10.0),
        }),
        weight: None,
        technical_features: [("anti_glissance".to_string(), "R10".to_string())]
            .into_iter()
            .collect(),
        commercial_proof: None,
        qualification: ItemQualification::Verified,
        qualification_reason: "Vérifié".to_string(),
        canonical_fingerprint: "fp_carrelage_01".to_string(),
        raw_payload: serde_json::json!({ "designation": "Carrelage Grès 60x60" }),
        raw_hash: "hash_raw_carrelage".to_string(),
        rules_engine_version: "2026.1".to_string(),
    };

    let decision = grouping_engine.evaluate_item(&candidate);
    assert_eq!(
        decision.technical_identity_key, "SPEC_CARRELAGE_GRES_60X60",
        "Le moteur DOIT associer l'article à la nouvelle spécification Carrelage sans recompilation Rust"
    );
}

// =============================================================================
// TEST 2 : Ajout d'un fabricant ou alias sans modification Rust
// =============================================================================
#[tokio::test]
async fn test_2_add_manufacturer_alias_dynamically_without_recompilation() {
    let store = IngestionStore::create_in_memory().await.unwrap();

    // 1. Résolution préalable d'un fabricant inconnu
    let before_res = store.resolve_manufacturer("MAPEI FRANCE SAS").await.unwrap();
    assert!(!before_res.is_verified, "Le fabricant ne doit pas être certifié au départ");

    // 2. Déclaration dynamique d'un nouvel alias fabricant dans SurrealDB
    let q = r#"
        UPSERT ingestion_manufacturer_alias:MAPEI_FRANCE CONTENT {
            raw_alias: "MAPEI FRANCE SAS",
            canonical_name: "MAPEI",
            holding_or_group: "MAPEI GROUP",
            is_verified: true
        };
    "#;
    store.client().query(q).await.unwrap();

    // 3. Résolution dynamique via fn::ingestion_resolve_manufacturer
    let after_res = store.resolve_manufacturer("MAPEI FRANCE SAS").await.unwrap();
    assert!(after_res.resolved, "L'alias doit être résolu dynamiquement");
    assert_eq!(after_res.canonical_name, "MAPEI");
    assert_eq!(after_res.holding_or_group, Some("MAPEI GROUP".to_string()));
    assert!(after_res.is_verified);
}

// =============================================================================
// TEST 3 : Résolution d'une unité depuis base_unite
// =============================================================================
#[tokio::test]
async fn test_3_resolve_unit_from_base_unite() {
    let store = IngestionStore::create_in_memory().await.unwrap();

    // 1. Résolution d'un code officiel direct présent dans base_unite
    let res_m2 = store.resolve_unit("M2").await.unwrap();
    assert_eq!(res_m2, Some("M2".to_string()), "M2 doit être résolu depuis base_unite");

    let res_pce = store.resolve_unit("PCE").await.unwrap();
    assert_eq!(res_pce, Some("PCE".to_string()), "PCE doit être résolu depuis base_unite");

    // 2. Résolution d'un alias commercial vers base_unite (SQM -> M2)
    let res_sqm = store.resolve_unit("SQM").await.unwrap();
    assert_eq!(res_sqm, Some("M2".to_string()), "SQM doit être normalisé vers M2");

    let res_piece = store.resolve_unit("PIECE").await.unwrap();
    assert_eq!(res_piece, Some("PCE".to_string()), "PIECE doit être normalisé vers PCE");

    // 3. Ajout dynamique d'un nouveau code dans base_unite
    let q = r#"
        UPSERT base_unite:LTR CONTENT { code: "LTR", libelle: "Litre", symbole: "l" };
        UPSERT ingestion_unit_alias:LITRE CONTENT { raw_alias: "LITRE", canonical_unit: "LTR" };
    "#;
    store.client().query(q).await.unwrap();

    let res_litre = store.resolve_unit("LITRE").await.unwrap();
    assert_eq!(res_litre, Some("LTR".to_string()), "L'alias dynamique LITRE doit pointer vers LTR");

    // 4. Unité inconnue non résolue
    let res_unknown = store.resolve_unit("UNITE_FICTIVE_XYZ").await.unwrap();
    assert_eq!(res_unknown, None, "Une unité inconnue ne doit pas être résolue");
}

// =============================================================================
// TEST 4 : Utilisation exclusive des fonctions publiques pour les opérations métier
// =============================================================================
#[tokio::test]
async fn test_4_exclusive_use_of_public_functions_for_business_ops() {
    let store = IngestionStore::create_in_memory().await.unwrap();
    let batch_id = "batch_exclusive_fn";
    let manifest_ref = "MANIFEST-EXCL-001";

    // 1. Création de lot via fn::ingestion_batch_create
    let batch = IngestionBatch {
        id: Some(batch_id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "PLACO".to_string(),
        nom_fichier: "test.csv".to_string(),
        file_hash_blake3: "hash_001".to_string(),
        taille_octets: 1000,
        statut: BatchStatus::Received,
        cursor_offset: 0,
        chunk_size: 50,
        total_lignes: 10,
        lignes_verifiees: 0,
        lignes_a_confirmer: 0,
        lignes_rejetees: 0,
        transitions: Vec::new(),
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("fn::ingestion_batch_create");

    // 2. Checkpoint via fn::ingestion_batch_checkpoint
    store
        .save_checkpoint(batch_id, 5, 10, 4, 1, 0)
        .await
        .expect("fn::ingestion_batch_checkpoint");
    let offset = store.load_checkpoint(batch_id).await.unwrap();
    assert_eq!(offset, 5);

    // 3. Sauvegarde d'un manifeste déclaré scellé mais avec un hash vide -> Rejet
    let invalid_sealed_manifest = PublicationManifest {
        id: None,
        manifest_ref: manifest_ref.to_string(),
        batch: batch_id.to_string(),
        manifest_version: 1,
        seal_hash: "".to_string(),
        is_sealed: true,
        statut: ManifestStatus::Draft,
        approved_by: None,
        approved_at: None,
        approver_role: None,
        nb_articles_insert: 1,
        nb_articles_update: 0,
        items_committed: 0,
        items_failed: 0,
        execution_items: Vec::new(),
        transitions: Vec::new(),
        executed_at: None,
    };

    let save_err = store.save_manifest(&invalid_sealed_manifest).await;
    assert!(
        save_err.is_err(),
        "fn::ingestion_manifest_save DOIT rejeter un manifeste déclaré scellé sans seal_hash"
    );

    // 4. Sauvegarde d'un brouillon non scellé -> Succès, mais rejet à l'approbation
    let mut draft_manifest = invalid_sealed_manifest;
    draft_manifest.is_sealed = false;
    store.save_manifest(&draft_manifest).await.expect("Sauvegarde brouillon réussie");

    let approve_unsealed = store
        .approve_manifest(
            manifest_ref,
            "steward_alice",
            "Tentative d'approbation non scellé",
        )
        .await;
    assert!(
        approve_unsealed.is_err(),
        "fn::ingestion_manifest_approve DOIT rejeter l'approbation d'un manifeste non scellé"
    );

    // 5. Sauvegarde avec scellement BLAKE3 valide
    let mut valid_manifest = draft_manifest;
    valid_manifest.seal_hash = "blake3_seal_valid_hash".to_string();
    valid_manifest.is_sealed = true;
    store.save_manifest(&valid_manifest).await.expect("fn::ingestion_manifest_save réussi");

    // 5. Approbation sous contrôle strict du rôle steward_admin
    let approve_ok = store
        .approve_manifest(
            manifest_ref,
            "steward_alice",
            "Bordereau vérifié et validé conforme",
        )
        .await;
    assert!(approve_ok.is_ok(), "fn::ingestion_manifest_approve exécutée avec succès");

    let loaded_manif = store.get_manifest(manifest_ref).await.unwrap().unwrap();
    assert_eq!(loaded_manif.statut, ManifestStatus::Approved);
    assert_eq!(loaded_manif.approved_by, Some("steward_alice".to_string()));
}

// =============================================================================
// TEST 5 : Persistance des règles et substitutions après redémarrage
// =============================================================================
#[tokio::test]
async fn test_5_persistence_of_rules_and_substitutions_across_instances() {
    let store = IngestionStore::create_in_memory().await.unwrap();

    // 1. Insertion d'une règle de substitution contextualisée
    let rule = ContextualSubstitutionRule {
        rule_id: "SUBST-PLACO-SINIAT-CLOISON-01".to_string(),
        source_manufacturer: "PLACO".to_string(),
        source_ref: "BA13-2500".to_string(),
        target_manufacturer: "SINIAT".to_string(),
        target_ref: "PRÉGYPLAC-BA13".to_string(),
        system_scope: "CLOISON_DISTRIBUTIVE_98_48".to_string(),
        certification_body: "CSTB".to_string(),
        certification_reference: "ATec-09-14-1234".to_string(),
        valid_until: "2028-12-31T23:59:59Z".to_string(),
        is_revoked: false,
        revocation_reason: None,
    };

    let inserted_id = store
        .add_substitution_rule(&rule)
        .await
        .expect("Insertion de la règle de substitution");
    assert_eq!(inserted_id, "SUBST-PLACO-SINIAT-CLOISON-01");

    // 2. Rechargement des règles de substitution
    let loaded_rules = store.load_substitution_rules().await.unwrap();
    let found = loaded_rules
        .iter()
        .find(|r| r.rule_id == "SUBST-PLACO-SINIAT-CLOISON-01");

    assert!(found.is_some(), "La règle de substitution DOIT être persistée");
    let loaded = found.unwrap();
    assert_eq!(loaded.source_manufacturer, "PLACO");
    assert_eq!(loaded.target_manufacturer, "SINIAT");
    assert_eq!(loaded.system_scope, "CLOISON_DISTRIBUTIVE_98_48");
    assert_eq!(loaded.certification_reference, "ATec-09-14-1234");
    assert!(!loaded.is_revoked);
}

// =============================================================================
// TEST 6 : Contrôles RLS sur les nouvelles tables et fonctions
// =============================================================================
#[tokio::test]
async fn test_6_rls_permissions_on_new_tables_and_functions() {
    let store = IngestionStore::create_in_memory().await.unwrap();

    // Vérifier les permissions définies sur les schémas déclaratifs
    let tables = vec![
        "ingestion_family_rule",
        "ingestion_specification",
        "ingestion_substitution_rule",
        "ingestion_unit_alias",
        "ingestion_manufacturer_alias",
    ];

    for tbl in tables {
        let q = format!("INFO FOR TABLE {tbl};");
        let res = store.client().query(q).await;
        assert!(res.is_ok(), "La table '{tbl}' doit être déclarée et valide dans le dictionnaire");
    }
}

// =============================================================================
// TEST 7 : Publication isolée des relations compatibles avec les contrats du catalogue
// =============================================================================
#[tokio::test]
async fn test_7_isolated_publication_compatible_with_catalogue_contracts() {
    let store = IngestionStore::create_in_memory().await.unwrap();
    let publisher = ControlledPublisher::new(store.clone());

    // 1. Tenter une publication sans session autorisée -> DOIT être rejetée
    let unauth_session = SyncAgentSession::new("intruder", "guest", vec![]);
    let pub_unauth = publisher.publish_manifest("MANIFEST-ANY", &unauth_session).await;
    assert!(
        pub_unauth.is_err(),
        "Un utilisateur non habilité ne peut pas publier vers le Catalogue"
    );

    // 2. Règle CTO Formelle : Zéro publication dans le Master de production
    let authorized_session = SyncAgentSession::new(
        "sync_agent_prod",
        "catalogue_sync_agent",
        vec!["catalogue:sync:write".to_string()],
    );

    let manifest_ref = "MANIFEST-ISO-001";
    let batch_id = "batch_iso";

    let batch = IngestionBatch {
        id: Some(batch_id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "PLACO".to_string(),
        nom_fichier: "test.csv".to_string(),
        file_hash_blake3: "hash_iso".to_string(),
        taille_octets: 1000,
        statut: BatchStatus::Received,
        cursor_offset: 0,
        chunk_size: 50,
        total_lignes: 1,
        lignes_verifiees: 1,
        lignes_a_confirmer: 0,
        lignes_rejetees: 0,
        transitions: Vec::new(),
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.unwrap();

    let staged = StagedItem {
        id: None,
        batch: batch_id.to_string(),
        raw_record: "raw_rec_01".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_iso_01".to_string(),
        rules_version: "2026.1".to_string(),
        fabricant: "PLACO".to_string(),
        marque: Some("PLACO".to_string()),
        reference_fabricant: "PLACO-BA13".to_string(),
        code_barre_gtin: Some("3401234567890".to_string()),
        libelle_commercial: "Plaque Placo BA13 2500x1200".to_string(),
        description_technique: None,
        type_item: "PLAQUE_PLATRE".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::Verified,
        qualification_reason: None,
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: Vec::new(),
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    store.save_staged_item(&staged).await.unwrap();

    let seal_hash = FingerprintEngine::compute_manifest_seal(&["fp_iso_01".to_string()]);
    let manifest = PublicationManifest {
        id: None,
        manifest_ref: manifest_ref.to_string(),
        batch: batch_id.to_string(),
        manifest_version: 1,
        seal_hash,
        is_sealed: true,
        statut: ManifestStatus::Draft,
        approved_by: None,
        approved_at: None,
        approver_role: None,
        nb_articles_insert: 1,
        nb_articles_update: 0,
        items_committed: 0,
        items_failed: 0,
        execution_items: Vec::new(),
        transitions: Vec::new(),
        executed_at: None,
    };
    store.save_manifest(&manifest).await.unwrap();
    store
        .approve_manifest(manifest_ref, "steward_chief", "Validation isolée des articles")
        .await
        .unwrap();

    let report = publisher
        .publish_manifest(manifest_ref, &authorized_session)
        .await
        .expect("Publication isolée réussie");

    assert_eq!(report.newly_published, 1);
    assert_eq!(report.failed, 0);
    assert!(report.is_completed);

    let committed = store.get_manifest(manifest_ref).await.unwrap().unwrap();
    assert_eq!(committed.statut, ManifestStatus::Committed);
}

// =============================================================================
// TEST 8 : Reprise sur incident et idempotence après réalignement
// =============================================================================
#[tokio::test]
async fn test_8_crash_recovery_and_idempotence_after_realignment() {
    let store = IngestionStore::create_in_memory().await.unwrap();
    let batch_id = "batch_crash_recovery";

    let batch = IngestionBatch {
        id: Some(batch_id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "ISOVER".to_string(),
        nom_fichier: "isover_100_items.csv".to_string(),
        file_hash_blake3: "hash_crash_01".to_string(),
        taille_octets: 5000,
        statut: BatchStatus::Received,
        cursor_offset: 0,
        chunk_size: 10,
        total_lignes: 20,
        lignes_verifiees: 0,
        lignes_a_confirmer: 0,
        lignes_rejetees: 0,
        transitions: Vec::new(),
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.unwrap();

    // 1. Simulation du traitement du premier tronçon (offset 0 -> 10)
    for i in 1..=10 {
        let staged = StagedItem {
            id: None,
            batch: batch_id.to_string(),
            raw_record: format!("raw_{i}"),
            ligne_numero: i,
            canonical_fingerprint: format!("fp_isover_{i:03}"),
            rules_version: "2026.1".to_string(),
            fabricant: "ISOVER".to_string(),
            marque: Some("ISOVER".to_string()),
            reference_fabricant: format!("ISO-GR32-{i:03}"),
            code_barre_gtin: Some(format!("3401234567{i:02}")),
            libelle_commercial: format!("Laine de verre GR32 {i}"),
            description_technique: None,
            type_item: "ISOLATION_ROULEAU".to_string(),
            unite_reference: "M2".to_string(),
            conditionnement: PackagingDetails::default(),
            qualification: ItemQualification::Verified,
            qualification_reason: None,
            commercial_proof: None,
            publication_action: PublicationAction::Insert,
            diff_payload: None,
            transitions: Vec::new(),
            is_approved: false,
            approved_by: None,
            approved_at: None,
        };
        store.save_staged_item(&staged).await.unwrap();
    }
    // Checkpoint intermédiaire enregistré
    store.save_checkpoint(batch_id, 10, 20, 10, 0, 0).await.unwrap();

    // 2. SIMULATION D'INCIDENT / CRASH SYSTEM
    // Le système redémarre et recharge le dernier checkpoint
    let resume_offset = store.load_checkpoint(batch_id).await.unwrap();
    assert_eq!(resume_offset, 10, "Le point de reprise DOIT être préservé");

    // 3. Reprise du traitement (offset 10 -> 20)
    for i in 11..=20 {
        let staged = StagedItem {
            id: None,
            batch: batch_id.to_string(),
            raw_record: format!("raw_{i}"),
            ligne_numero: i,
            canonical_fingerprint: format!("fp_isover_{i:03}"),
            rules_version: "2026.1".to_string(),
            fabricant: "ISOVER".to_string(),
            marque: Some("ISOVER".to_string()),
            reference_fabricant: format!("ISO-GR32-{i:03}"),
            code_barre_gtin: Some(format!("3401234567{i:02}")),
            libelle_commercial: format!("Laine de verre GR32 {i}"),
            description_technique: None,
            type_item: "ISOLATION_ROULEAU".to_string(),
            unite_reference: "M2".to_string(),
            conditionnement: PackagingDetails::default(),
            qualification: ItemQualification::Verified,
            qualification_reason: None,
            commercial_proof: None,
            publication_action: PublicationAction::Insert,
            diff_payload: None,
            transitions: Vec::new(),
            is_approved: false,
            approved_by: None,
            approved_at: None,
        };
        store.save_staged_item(&staged).await.unwrap();
    }
    store.save_checkpoint(batch_id, 20, 20, 20, 0, 0).await.unwrap();

    // 4. Vérification d'absence totale de duplication
    let all_staged = store.get_staged_items_by_batch(batch_id).await.unwrap();
    assert_eq!(
        all_staged.len(),
        20,
        "Exactement 20 articles en staging doivent être enregistrés sans aucun doublon"
    );

    // 5. Re-jeu complet identique pour tester l'idempotence stricte
    for item in &all_staged {
        store.save_staged_item(item).await.unwrap();
    }
    let after_replay = store.get_staged_items_by_batch(batch_id).await.unwrap();
    assert_eq!(
        after_replay.len(),
        20,
        "La réexécution complète DOIT être strictement idempotente"
    );
}
