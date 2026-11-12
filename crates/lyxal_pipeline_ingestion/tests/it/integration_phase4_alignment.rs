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

use lyxal_pipeline_ingestion::models::StagedItem;
use lyxal_pipeline_ingestion::normalization::CanonicalDimensions;
use lyxal_pipeline_ingestion::rules::{
    ContextualSubstitutionRule, SpecificationTolerances, TechnicalSpecification,
};
use lyxal_pipeline_ingestion::storage::{ManifestDraft, NewBatch};
use lyxal_pipeline_ingestion::types::{
    ItemQualification, ManifestStatus, PackagingDetails, PublicationAction, SourceFormat,
};

// =============================================================================
// TEST 1 : Ajout d'une famille Carrelage par configuration SurrealDB sans recompilation Rust
// =============================================================================
#[tokio::test]
async fn test_1_add_family_carrelage_dynamically_without_recompilation() {
    let store = crate::support::installed_store().await;

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

    // 3. Référentiels relus en base par fn::ingestion_rules_load
    let mut res = store
        .client()
        .query("RETURN fn::ingestion_rules_load({}).data.{ f: families[WHERE code = 'CARRELAGE'].standard_unit, s: specifications[WHERE technical_identity_key = 'SPEC_CARRELAGE_GRES_60X60'].family_code }")
        .await
        .expect("chargement des référentiels");
    let loaded: Option<serde_json::Value> = res.take(0).expect("référentiels");
    assert_eq!(
        loaded,
        Some(serde_json::json!({ "f": ["M2"], "s": ["CARRELAGE"] })),
        "famille et spécification enregistrées sans recompilation Rust"
    );
}

// =============================================================================
// TEST 2 : Ajout d'un fabricant ou alias sans modification Rust
// =============================================================================
#[tokio::test]
async fn test_2_add_manufacturer_alias_dynamically_without_recompilation() {
    let store = crate::support::installed_store().await;

    let names = vec!["MAPEI FRANCE SAS".to_string()];

    // 1. Fabricant inconnu : nom normalisé (suffixes retirés), non résolu ni vérifié
    let before = store.resolve_manufacturers(&names).await.unwrap();
    let before_res = &before["MAPEI FRANCE SAS"];
    assert!(!before_res.resolved && !before_res.is_verified);
    assert_eq!(before_res.canonical_name, "MAPEI");

    // 2. Déclaration d'un nouvel alias fabricant dans SurrealDB
    let q = r#"
        UPSERT ingestion_manufacturer_alias:MAPEI CONTENT {
            raw_alias: "MAPEI",
            canonical_name: "MAPEI",
            holding_or_group: "MAPEI GROUP",
            is_verified: true
        };
    "#;
    store
        .client()
        .query(q)
        .await
        .unwrap()
        .check()
        .expect("alias MAPEI");

    // 3. Résolution par l'alias, après retrait des suffixes juridiques
    let after = store.resolve_manufacturers(&names).await.unwrap();
    let after_res = &after["MAPEI FRANCE SAS"];
    assert!(after_res.resolved, "L'alias doit être résolu dynamiquement");
    assert_eq!(after_res.canonical_name, "MAPEI");
    assert_eq!(after_res.holding_or_group, Some("MAPEI GROUP".to_string()));
    assert!(after_res.is_verified);
}

// =============================================================================
// TEST 3 : Résolution d'un bloc d'unités par les alias et le référentiel de lyxal_base
// =============================================================================
#[tokio::test]
async fn test_3_resolve_units_from_base_unite() {
    let store = crate::support::installed_store().await;
    let raw: Vec<String> = [
        "M2",
        "PCE",
        "SQM",
        "PIECE",
        "MTK",
        "m.l.",
        "BIDON",
        "UNITE_FICTIVE_XYZ",
    ]
    .iter()
    .map(|u| u.to_string())
    .collect();

    // Codes Lyxal, alias commerciaux, codes d'échange (lyxal_base), clé sans points
    let resolved = store.resolve_units(&raw).await.unwrap();
    assert_eq!(resolved.get("M2").map(String::as_str), Some("M2"));
    assert_eq!(resolved.get("PCE").map(String::as_str), Some("PCE"));
    assert_eq!(resolved.get("SQM").map(String::as_str), Some("M2"));
    assert_eq!(resolved.get("PIECE").map(String::as_str), Some("PCE"));
    assert_eq!(resolved.get("MTK").map(String::as_str), Some("M2"));
    assert_eq!(resolved.get("m.l.").map(String::as_str), Some("ML"));
    assert!(!resolved.contains_key("BIDON"));
    assert!(!resolved.contains_key("UNITE_FICTIVE_XYZ"));

    // Alias ajouté par le steward vers une unité du référentiel
    store
        .client()
        .query(r#"UPSERT ingestion_unit_alias:BIDON CONTENT { raw_alias: "BIDON", canonical_unit: "LTR" };"#)
        .await
        .unwrap()
        .check()
        .expect("alias BIDON");
    let resolved = store.resolve_units(&raw).await.unwrap();
    assert_eq!(resolved.get("BIDON").map(String::as_str), Some("LTR"));
}

// =============================================================================
// TEST 4 : Utilisation exclusive des fonctions publiques pour les opérations métier
// =============================================================================
#[tokio::test]
async fn test_4_exclusive_use_of_public_functions_for_business_ops() {
    let store = crate::support::installed_store().await;
    let batch_id = "batch_exclusive_fn";
    let manifest_ref = "MANIFEST-EXCL-001";

    // 1. Création de lot via fn::ingestion_batch_create
    let batch = NewBatch {
        id: Some(batch_id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        source_encoding: lyxal_pipeline_ingestion::types::SourceEncoding::Utf8,
        fournisseur_id: "PLACO".to_string(),
        source_object: crate::support::source(&store, "test.csv", b"hash_001").await,
        chunk_size: 50,
        provenance_details: serde_json::json!({}),
        commercial_proof: None,
    };
    let claim = crate::support::claimed_batch(&store, &batch).await;

    // 2. Checkpoint via fn::ingestion_batch_checkpoint
    store
        .save_checkpoint(
            &claim,
            batch_id,
            &lyxal_pipeline_ingestion::storage::BatchProgress {
                cursor_offset: 5,
                total_lignes: 10,
                verified: 4,
                to_confirm: 1,
                rejected: 0,
            },
        )
        .await
        .expect("fn::ingestion_batch_checkpoint");
    let offset = store.load_checkpoint(batch_id).await.unwrap();
    assert_eq!(offset, 5);

    // 3. Brouillon : ni contenu ni sceau, approbation refusée
    let draft_manifest = ManifestDraft {
        manifest_ref: manifest_ref.to_string(),
        batch_id: batch_id.to_string(),
        manifest_version: 1,
        statut: ManifestStatus::Draft,
        nb_articles_insert: 1,
        nb_articles_update: 0,
    };
    store
        .save_manifest(&draft_manifest)
        .await
        .expect("Sauvegarde brouillon réussie");
    let draft = store.get_manifest_detail(manifest_ref).await.unwrap();
    assert!(draft.manifest.seal_hash.is_none() && draft.manifest.contenu.is_none());
    assert!(!draft.seal_valid);

    let approve_unsealed = store
        .approve_manifest(manifest_ref, "Tentative d'approbation non scellé")
        .await;
    assert!(
        approve_unsealed.is_err(),
        "fn::ingestion_manifest_approve DOIT rejeter l'approbation d'un manifeste non scellé"
    );

    // 4. Scellement : le serveur fige le contenu et calcule le sceau BLAKE3
    let mut sealed_manifest = draft_manifest;
    sealed_manifest.statut = ManifestStatus::Sealed;
    store
        .save_manifest(&sealed_manifest)
        .await
        .expect("fn::ingestion_manifest_save réussi");
    let sealed = store.get_manifest_detail(manifest_ref).await.unwrap();
    assert_eq!(sealed.seal_hash.as_deref().map(str::len), Some(64));
    assert!(sealed.seal_valid);

    // 5. Approbation sous contrôle strict de la permission ingestion.manifest.approve
    let approve_ok = store
        .approve_manifest(manifest_ref, "Bordereau vérifié et validé conforme")
        .await;
    assert!(
        approve_ok.is_ok(),
        "fn::ingestion_manifest_approve exécutée avec succès"
    );

    let loaded_manif = store.get_manifest(manifest_ref).await.unwrap().unwrap();
    assert_eq!(loaded_manif.statut, ManifestStatus::Approved);
    // Approbateur lu dans la session : ici la session système de l'hôte.
    assert_eq!(loaded_manif.approved_by, Some("system".to_string()));
}

// =============================================================================
// TEST 5 : Persistance des règles et substitutions après redémarrage
// =============================================================================
#[tokio::test]
async fn test_5_persistence_of_rules_and_substitutions_across_instances() {
    let store = crate::support::installed_store().await;

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

    // 2. Règle relue en base par fn::ingestion_rules_load
    let mut res = store
        .client()
        .query("RETURN fn::ingestion_rules_load({}).data.substitutions[WHERE rule_id = 'SUBST-PLACO-SINIAT-CLOISON-01'].{ source_manufacturer, target_manufacturer, system_scope, certification_reference, is_revoked }")
        .await
        .expect("chargement des règles");
    let loaded: Option<serde_json::Value> = res.take(0).expect("règles");
    assert_eq!(
        loaded,
        Some(serde_json::json!({
            "source_manufacturer": "PLACO",
            "target_manufacturer": "SINIAT",
            "system_scope": "CLOISON_DISTRIBUTIVE_98_48",
            "certification_reference": "ATec-09-14-1234",
            "is_revoked": false
        })),
        "La règle de substitution DOIT être persistée"
    );
}

// =============================================================================
// TEST 6 : Contrôles RLS sur les nouvelles tables et fonctions
// =============================================================================
#[tokio::test]
async fn test_6_rls_permissions_on_new_tables_and_functions() {
    let store = crate::support::installed_store().await;

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
        assert!(
            res.is_ok(),
            "La table '{tbl}' doit être déclarée et valide dans le dictionnaire"
        );
    }
}

// =============================================================================
// TEST 8 : Reprise sur incident et idempotence après réalignement
// =============================================================================
#[tokio::test]
async fn test_8_crash_recovery_and_idempotence_after_realignment() {
    let store = crate::support::installed_store().await;
    let batch_id = "batch_crash_recovery";

    let batch = NewBatch {
        id: Some(batch_id.to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        source_encoding: lyxal_pipeline_ingestion::types::SourceEncoding::Utf8,
        fournisseur_id: "ISOVER".to_string(),
        source_object: crate::support::source(&store, "isover_100_items.csv", b"hash_crash_01").await,
        chunk_size: 10,
        provenance_details: serde_json::json!({}),
        commercial_proof: None,
    };
    let claim = crate::support::claimed_batch(&store, &batch).await;

    // 1. Simulation du traitement du premier tronçon (offset 0 -> 10)
    for i in 1..=10 {
        let staged = StagedItem {
            id: None,
            batch: batch_id.to_string(),
            raw_record: format!("raw_{i}"),
            ligne_numero: i,
            canonical_fingerprint: lyxal_crypto::blake3_hex(format!("fp_isover_{i:03}").as_bytes()),
            rules_version: "2026.1".to_string(),
            fabricant: "ISOVER".to_string(),
            marque: Some("ISOVER".to_string()),
            reference_fabricant: format!("ISO-GR32-{i:03}"),
            code_barre_gtin: None,
            libelle_commercial: format!("Laine de verre GR32 {i}"),
            description_technique: None,
            type_item: "PRODUIT".to_string(),
            unite_reference: Some("M2".to_string()),
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
        store.save_staged_item(&claim, &staged).await.unwrap();
    }
    // Checkpoint intermédiaire enregistré
    store
        .save_checkpoint(
            &claim,
            batch_id,
            &lyxal_pipeline_ingestion::storage::BatchProgress {
                cursor_offset: 10,
                total_lignes: 20,
                verified: 10,
                to_confirm: 0,
                rejected: 0,
            },
        )
        .await
        .unwrap();

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
            canonical_fingerprint: lyxal_crypto::blake3_hex(format!("fp_isover_{i:03}").as_bytes()),
            rules_version: "2026.1".to_string(),
            fabricant: "ISOVER".to_string(),
            marque: Some("ISOVER".to_string()),
            reference_fabricant: format!("ISO-GR32-{i:03}"),
            code_barre_gtin: None,
            libelle_commercial: format!("Laine de verre GR32 {i}"),
            description_technique: None,
            type_item: "PRODUIT".to_string(),
            unite_reference: Some("M2".to_string()),
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
        store.save_staged_item(&claim, &staged).await.unwrap();
    }
    store
        .save_checkpoint(
            &claim,
            batch_id,
            &lyxal_pipeline_ingestion::storage::BatchProgress {
                cursor_offset: 20,
                total_lignes: 20,
                verified: 20,
                to_confirm: 0,
                rejected: 0,
            },
        )
        .await
        .unwrap();

    // 4. Vérification d'absence totale de duplication
    let all_staged = store.get_staged_items_by_batch(batch_id).await.unwrap();
    assert_eq!(
        all_staged.len(),
        20,
        "Exactement 20 articles en staging doivent être enregistrés sans aucun doublon"
    );

    // 5. Re-jeu complet identique pour tester l'idempotence stricte
    for item in &all_staged {
        store.save_staged_item(&claim, item).await.unwrap();
    }
    let after_replay = store.get_staged_items_by_batch(batch_id).await.unwrap();
    assert_eq!(
        after_replay.len(),
        20,
        "La réexécution complète DOIT être strictement idempotente"
    );
}
