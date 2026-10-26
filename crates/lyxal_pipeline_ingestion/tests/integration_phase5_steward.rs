//! Suite de tests d'intégration Phase 5 : Data Steward & Observabilité Industrielle
//!
//! Exécute les validations strictes requises par la décision CTO :
//! 1. Métriques consolidées du tableau de bord (KPIs temps réel).
//! 2. Listing paginé et filtré des articles en staging.
//! 3. Sécurité de session pour la requalification (rejet si rôle non autorisé).
//! 4. Règle absolue CTO : Preuve commerciale authentifiée exigée pour VERIFIED.
//! 5. Résolution de quarantaine : transition obligatoire vers TO_CONFIRM (JAMAIS VERIFIED direct).
//! 6. Listing et consultation détaillée des manifestes avec intégrité de scellement.
//! 7. Sonde de santé industrielle `IngestionHealthCheck` conforme à `lyxal_runtime`.

use lyxal_pipeline_ingestion::health::IngestionHealthCheck;
use lyxal_pipeline_ingestion::models::{IngestionBatch, PublicationManifest, QuarantineRecord, StagedItem};
use lyxal_pipeline_ingestion::proof::{CommercialProof, CommercialProofType};
use lyxal_pipeline_ingestion::storage::store::{
    IngestionStore, ManifestListFilter, QuarantineListFilter, QuarantineResolveParams,
    SessionAuthContext, StagedListFilter, StagedRequalifyParams,
};
use lyxal_pipeline_ingestion::types::{
    BatchStatus, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat, StateTransitionRecord,
};
use lyxal_runtime::{ModuleContext, ModuleHealthCheck};

/// Helper créant un store in-memory préconfiguré
async fn setup_test_store() -> IngestionStore {
    IngestionStore::create_in_memory()
        .await
        .expect("Initialisation du store in-memory")
}

#[tokio::test]
async fn test_1_dashboard_metrics_aggregation() {
    let store = setup_test_store().await;

    // 1. Création d'un lot
    let batch = IngestionBatch {
        id: Some("batch_dash_01".to_string()),
        source_type: SourceFormat::FabDis,
        source_format_version: "3.0".to_string(),
        fournisseur_id: "FOURN_PLACO".to_string(),
        nom_fichier: "placo_catalogue.csv".to_string(),
        file_hash_blake3: "hash_dash_01".to_string(),
        taille_octets: 1024,
        statut: BatchStatus::Staged,
        cursor_offset: 2,
        chunk_size: 500,
        total_lignes: 2,
        lignes_verifiees: 1,
        lignes_a_confirmer: 1,
        lignes_rejetees: 0,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    // 2. Création de deux articles en staging (1 VERIFIED, 1 TO_CONFIRM)
    let staged1 = StagedItem {
        id: None,
        batch: "batch_dash_01".to_string(),
        raw_record: "raw_1".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_dash_01".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "PLACO".to_string(),
        marque: Some("PLACO".to_string()),
        reference_fabricant: "BA13-STD".to_string(),
        code_barre_gtin: Some("3401234567890".to_string()),
        libelle_commercial: "Plaque Placo BA13 Standard".to_string(),
        description_technique: None,
        type_item: "PLAQUE_PLATRE".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::Verified,
        qualification_reason: Some("Preuve fabricant certifiée".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    store.save_staged_item(&staged1).await.expect("Save staged 1");

    let staged2 = StagedItem {
        id: None,
        batch: "batch_dash_01".to_string(),
        raw_record: "raw_2".to_string(),
        ligne_numero: 2,
        canonical_fingerprint: "fp_dash_02".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "PLACO".to_string(),
        marque: Some("PLACO".to_string()),
        reference_fabricant: "BA13-HYDRO".to_string(),
        code_barre_gtin: Some("3401234567891".to_string()),
        libelle_commercial: "Plaque Placo BA13 Hydrofuge".to_string(),
        description_technique: None,
        type_item: "PLAQUE_PLATRE".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::ToConfirm,
        qualification_reason: Some("Attente arbitrage commercial".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    store.save_staged_item(&staged2).await.expect("Save staged 2");

    // 3. Appel de la fonction publique SurrealQL fn::ingestion_dashboard_metrics via store.call_fn
    let metrics = store.get_dashboard_metrics(None).await.expect("get_dashboard_metrics");

    assert_eq!(metrics.batches.total, 1);
    assert_eq!(metrics.batches.staged, 1);
    assert_eq!(metrics.items.total, 2);
    assert_eq!(metrics.items.verified, 1);
    assert_eq!(metrics.items.to_confirm, 1);
    assert_eq!(metrics.items.rejected, 0);
}

#[tokio::test]
async fn test_2_staged_listing_and_filtering() {
    let store = setup_test_store().await;

    let batch = IngestionBatch {
        id: Some("batch_list_01".to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURN_ISOVER".to_string(),
        nom_fichier: "isover.csv".to_string(),
        file_hash_blake3: "hash_list_01".to_string(),
        taille_octets: 512,
        statut: BatchStatus::Staged,
        cursor_offset: 2,
        chunk_size: 500,
        total_lignes: 2,
        lignes_verifiees: 1,
        lignes_a_confirmer: 1,
        lignes_rejetees: 0,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    let staged1 = StagedItem {
        id: None,
        batch: "batch_list_01".to_string(),
        raw_record: "raw_1".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_list_01".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "ISOVER".to_string(),
        marque: Some("ISOVER".to_string()),
        reference_fabricant: "GR32-100".to_string(),
        code_barre_gtin: Some("3401234567892".to_string()),
        libelle_commercial: "Laine de verre GR32 100mm".to_string(),
        description_technique: None,
        type_item: "ISOLATION".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::Verified,
        qualification_reason: Some("Vérifié".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    store.save_staged_item(&staged1).await.expect("Save staged 1");

    let staged2 = StagedItem {
        id: None,
        batch: "batch_list_01".to_string(),
        raw_record: "raw_2".to_string(),
        ligne_numero: 2,
        canonical_fingerprint: "fp_list_02".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "ISOVER".to_string(),
        marque: Some("ISOVER".to_string()),
        reference_fabricant: "IBR-200".to_string(),
        code_barre_gtin: Some("3401234567893".to_string()),
        libelle_commercial: "Rouleau IBR 200mm".to_string(),
        description_technique: None,
        type_item: "ISOLATION".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::ToConfirm,
        qualification_reason: Some("Attente fiche technique".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    store.save_staged_item(&staged2).await.expect("Save staged 2");

    // 1. Consultation sans filtre (total = 2)
    let res_all = store.list_staged_items(StagedListFilter::default()).await.expect("list all");
    assert_eq!(res_all.total, 2);
    assert_eq!(res_all.items.len(), 2);

    // 2. Filtre par qualification TO_CONFIRM (total = 1)
    let res_to_confirm = store.list_staged_items(StagedListFilter {
        qualification: Some("TO_CONFIRM".to_string()),
        ..Default::default()
    }).await.expect("filter TO_CONFIRM");
    assert_eq!(res_to_confirm.total, 1);
    assert_eq!(res_to_confirm.items.len(), 1);
}

#[tokio::test]
async fn test_3_steward_requalification_session_security() {
    let store = setup_test_store().await;

    let batch = IngestionBatch {
        id: Some("batch_sec_01".to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURN_PLACO".to_string(),
        nom_fichier: "placo.csv".to_string(),
        file_hash_blake3: "hash_sec_01".to_string(),
        taille_octets: 512,
        statut: BatchStatus::Staged,
        cursor_offset: 1,
        chunk_size: 500,
        total_lignes: 1,
        lignes_verifiees: 0,
        lignes_a_confirmer: 1,
        lignes_rejetees: 0,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    let staged = StagedItem {
        id: None,
        batch: "batch_sec_01".to_string(),
        raw_record: "raw_1".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_sec_01".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "PLACO".to_string(),
        marque: Some("PLACO".to_string()),
        reference_fabricant: "SEC-REF-01".to_string(),
        code_barre_gtin: Some("3401234567894".to_string()),
        libelle_commercial: "Article Test Sécurité".to_string(),
        description_technique: None,
        type_item: "PRODUIT".to_string(),
        unite_reference: "PCE".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::ToConfirm,
        qualification_reason: Some("Attente décision".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    let item_id = store.save_staged_item(&staged).await.expect("Save staged");

    // TENTATIVE 1 : Utilisateur non authentifié ou simple opérateur (rôle guest / operator)
    // DOIT ÊTRE REJETÉ PAR LE CONTRÔLE SURREALQL
    let unauth_params = StagedRequalifyParams {
        item_id: item_id.clone(),
        new_qualification: "REJECTED".to_string(),
        justification: "Rejet motif arbitraire opérateur non habilité".to_string(),
        proof: None,
        language: Some("fr".to_string()),
        _session_auth: Some(SessionAuthContext {
            user_id: "user_operator_42".to_string(),
            role: "catalog_operator".to_string(), // NON steward_admin
        }),
    };
    let unauth_res = store.requalify_staged_item(unauth_params).await;
    assert!(unauth_res.is_err(), "Un opérateur non steward_admin DOIT être formellement rejeté");

    // TENTATIVE 2 : Justification trop courte (< 10 caractères) avec steward_admin
    // DOIT ÊTRE REJETÉ PAR SURREALQL
    let short_justif_params = StagedRequalifyParams {
        item_id: item_id.clone(),
        new_qualification: "REJECTED".to_string(),
        justification: "Court".to_string(), // 5 car. < 10 car.
        proof: None,
        language: Some("fr".to_string()),
        _session_auth: Some(SessionAuthContext {
            user_id: "steward_bob".to_string(),
            role: "steward_admin".to_string(),
        }),
    };
    let short_res = store.requalify_staged_item(short_justif_params).await;
    assert!(short_res.is_err(), "Une justification < 10 caractères DOIT être rejetée");
}

#[tokio::test]
async fn test_4_requalification_verified_requires_strict_commercial_proof() {
    let store = setup_test_store().await;

    let batch = IngestionBatch {
        id: Some("batch_proof_01".to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURN_KNAUF".to_string(),
        nom_fichier: "knauf.csv".to_string(),
        file_hash_blake3: "hash_proof_01".to_string(),
        taille_octets: 512,
        statut: BatchStatus::Staged,
        cursor_offset: 1,
        chunk_size: 500,
        total_lignes: 1,
        lignes_verifiees: 0,
        lignes_a_confirmer: 1,
        lignes_rejetees: 0,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    let staged = StagedItem {
        id: None,
        batch: "batch_proof_01".to_string(),
        raw_record: "raw_1".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_proof_01".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "KNAUF".to_string(),
        marque: Some("KNAUF".to_string()),
        reference_fabricant: "KNAUF-KF-13".to_string(),
        code_barre_gtin: Some("3401234567895".to_string()),
        libelle_commercial: "Plaque Knauf Feu KF 13mm".to_string(),
        description_technique: None,
        type_item: "PLAQUE_PLATRE".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::ToConfirm,
        qualification_reason: Some("Attente certificat tarifaire officiel".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    let item_id = store.save_staged_item(&staged).await.expect("Save staged");

    // TENTATIVE 1 : Promotion vers VERIFIED SANS CommercialProof
    // RÈGLE D'OR CTO : STRICTEMENT INTERDIT
    let no_proof_params = StagedRequalifyParams {
        item_id: item_id.clone(),
        new_qualification: "VERIFIED".to_string(),
        justification: "Validation arbitraire sans attestation documentaire".to_string(),
        proof: None,
        language: Some("fr".to_string()),
        _session_auth: Some(SessionAuthContext {
            user_id: "steward_alice".to_string(),
            role: "steward_admin".to_string(),
        }),
    };
    let no_proof_res = store.requalify_staged_item(no_proof_params).await;
    assert!(no_proof_res.is_err(), "Le passage en VERIFIED sans CommercialProof DOIT échouer");

    // TENTATIVE 2 : Promotion vers VERIFIED AVEC CommercialProof authentique
    let valid_proof = CommercialProof::new(
        CommercialProofType::OfficialTariffCertificate,
        "TARIF-KNAUF-2026-CERT-0099",
        "KNAUF SAS Direction Commerciale France",
        "steward_alice",
        "2026-10-25T11:00:00Z",
    );

    let with_proof_params = StagedRequalifyParams {
        item_id: item_id.clone(),
        new_qualification: "VERIFIED".to_string(),
        justification: "Preuve tarifaire officielle 2026 validée et vérifiée au greffe".to_string(),
        proof: Some(valid_proof),
        language: Some("fr".to_string()),
        _session_auth: Some(SessionAuthContext {
            user_id: "steward_alice".to_string(),
            role: "steward_admin".to_string(),
        }),
    };
    let with_proof_res = store.requalify_staged_item(with_proof_params).await;
    assert!(with_proof_res.is_ok(), "Le passage en VERIFIED avec preuve DOIT réussir : {:?}", with_proof_res);

    // Vérification de la transition d'état et de l'approbation
    let filter = StagedListFilter {
        qualification: Some("VERIFIED".to_string()),
        ..Default::default()
    };
    let list_res = store.list_staged_items(filter).await.expect("List verified");
    assert_eq!(list_res.total, 1);
    assert_eq!(list_res.items[0]["is_approved"], true);
    assert_eq!(list_res.items[0]["approved_by"], "steward_alice");
}

#[tokio::test]
async fn test_5_quarantine_listing_and_resolution_forces_to_confirm() {
    let store = setup_test_store().await;

    let batch = IngestionBatch {
        id: Some("batch_quar_01".to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURN_SINIAT".to_string(),
        nom_fichier: "siniat_anomalies.csv".to_string(),
        file_hash_blake3: "hash_quar_01".to_string(),
        taille_octets: 256,
        statut: BatchStatus::Staged,
        cursor_offset: 1,
        chunk_size: 500,
        total_lignes: 1,
        lignes_verifiees: 0,
        lignes_a_confirmer: 0,
        lignes_rejetees: 1,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    // Article en staging rejeté initialement
    let staged = StagedItem {
        id: None,
        batch: "batch_quar_01".to_string(),
        raw_record: "raw_q_1".to_string(),
        ligne_numero: 1,
        canonical_fingerprint: "fp_siniat_01".to_string(),
        rules_version: "1.0.0".to_string(),
        fabricant: "SINIAT".to_string(),
        marque: Some("SINIAT".to_string()),
        reference_fabricant: "SINIAT-PREGY-13".to_string(),
        code_barre_gtin: Some("0000000000000".to_string()), // GTIN invalide
        libelle_commercial: "Plaque Prégydro BA13".to_string(),
        description_technique: None,
        type_item: "PLAQUE_PLATRE".to_string(),
        unite_reference: "M2".to_string(),
        conditionnement: PackagingDetails::default(),
        qualification: ItemQualification::Rejected,
        qualification_reason: Some("Checksum GTIN invalide".to_string()),
        commercial_proof: None,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: vec![],
        is_approved: false,
        approved_by: None,
        approved_at: None,
    };
    let staged_id = store.save_staged_item(&staged).await.expect("Save staged");

    // Enregistrement d'une anomalie en quarantaine
    let quar_rec = QuarantineRecord {
        id: None,
        batch: "batch_quar_01".to_string(),
        raw_record: "raw_q_1".to_string(),
        code_erreur: "INGESTION_GTIN_INVALID".to_string(),
        severite: "CRITICAL".to_string(),
        champ_concerne: "code_barre_gtin".to_string(),
        valeur_fautive: Some(serde_json::json!("0000000000000")),
        cause_detaillee: "La clé de contrôle du code EAN/GTIN est invalide".to_string(),
        created_at: None,
        is_resolved: false,
        resolved_by: None,
        resolved_at: None,
        resolution_comment: None,
    };
    let q_id = store.log_quarantine(&quar_rec).await.expect("Log quarantine");

    // 1. Consultation des anomalies non résolues
    let list_q = store.list_quarantine_records(QuarantineListFilter {
        is_resolved: Some(false),
        ..Default::default()
    }).await.expect("List quarantine");
    assert_eq!(list_q.total, 1);

    // 2. Résolution par le Data Steward avec correction du GTIN
    // RÈGLE FORMELLE CTO : Cette correction DOIT repasser l'article en TO_CONFIRM et JAMAIS en VERIFIED !
    let resolve_params = QuarantineResolveParams {
        quarantine_id: q_id.clone(),
        comment: "GTIN fabricant corrigé suite consultation fiche produit officielle".to_string(),
        staged_item_id: Some(staged_id.clone()),
        corrections: Some(serde_json::json!({
            "corrected_gtin": "3401234567896"
        })),
        language: Some("fr".to_string()),
        _session_auth: Some(SessionAuthContext {
            user_id: "steward_bob".to_string(),
            role: "steward_admin".to_string(),
        }),
    };
    let res = store.resolve_quarantine_record(resolve_params).await.expect("Resolve quarantine");
    assert!(res, "La résolution d'anomalie doit réussir");

    // 3. Vérification que l'anomalie est marquée résolue
    let list_resolved = store.list_quarantine_records(QuarantineListFilter {
        is_resolved: Some(true),
        ..Default::default()
    }).await.expect("List resolved");
    assert_eq!(list_resolved.total, 1);
    assert_eq!(list_resolved.records[0]["resolved_by"], "steward_bob");

    // 4. VÉRIFICATION DE LA RÈGLE D'OR CTO : L'article est repassé en TO_CONFIRM (PAS VERIFIED !)
    let staged_list = store.list_staged_items(StagedListFilter {
        qualification: Some("TO_CONFIRM".to_string()),
        ..Default::default()
    }).await.expect("List TO_CONFIRM");
    assert_eq!(staged_list.total, 1);
    assert_eq!(staged_list.items[0]["qualification"], "TO_CONFIRM");
    assert_eq!(staged_list.items[0]["code_barre_gtin"], "3401234567896");
}

#[tokio::test]
async fn test_6_manifest_listing_and_detail_integrity() {
    let store = setup_test_store().await;

    let batch = IngestionBatch {
        id: Some("batch_manif_01".to_string()),
        source_type: SourceFormat::Csv,
        source_format_version: "1.0".to_string(),
        fournisseur_id: "FOURN_LEGRAND".to_string(),
        nom_fichier: "legrand.csv".to_string(),
        file_hash_blake3: "hash_manif_01".to_string(),
        taille_octets: 1024,
        statut: BatchStatus::Staged,
        cursor_offset: 1,
        chunk_size: 500,
        total_lignes: 1,
        lignes_verifiees: 1,
        lignes_a_confirmer: 0,
        lignes_rejetees: 0,
        transitions: vec![],
        provenance_details: serde_json::json!({}),
        created_at: None,
        completed_at: None,
    };
    store.create_batch(&batch).await.expect("Création lot");

    // Création d'un manifeste scellé
    let manifest = PublicationManifest {
        id: None,
        batch: "batch_manif_01".to_string(),
        manifest_ref: "PUB-2026-LEGRAND-001".to_string(),
        manifest_version: 1,
        seal_hash: "blake3_seal_hash_abcdef0123456789abcdef0123456789".to_string(),
        is_sealed: true,
        statut: ManifestStatus::Sealed,
        approved_by: None,
        approved_at: None,
        approver_role: None,
        nb_articles_insert: 10,
        nb_articles_update: 0,
        items_committed: 0,
        items_failed: 0,
        execution_items: vec![serde_json::json!({"ref": "LEG-001", "action": "INSERT"})],
        transitions: vec![StateTransitionRecord {
            from_statut: "DRAFT".to_string(),
            to_statut: "SEALED".to_string(),
            transition_at: "2026-10-25T12:00:00Z".to_string(),
            transition_by: "system".to_string(),
            reason: "Scellement BLAKE3".to_string(),
        }],
        executed_at: None,
    };
    store.save_manifest(&manifest).await.expect("Save manifest");

    // 1. Listing paginé des manifestes
    let res_list = store.list_manifests(ManifestListFilter::default()).await.expect("List manifests");
    assert_eq!(res_list.total, 1);
    assert_eq!(res_list.manifests[0]["manifest_ref"], "PUB-2026-LEGRAND-001");

    // 2. Consultation détaillée avec contrôle de scellement
    let detail = store.get_manifest_detail("PUB-2026-LEGRAND-001").await.expect("Get manifest detail");
    assert_eq!(detail.is_sealed, true);
    assert_eq!(detail.seal_hash, "blake3_seal_hash_abcdef0123456789abcdef0123456789");
    assert_eq!(detail.execution_count, 1);
    assert_eq!(detail.transition_count, 1);
}

#[tokio::test]
async fn test_7_ingestion_health_check_probe() {
    let store = setup_test_store().await;

    // Sonde de santé connectée au store
    let probe = IngestionHealthCheck::with_store(store);
    let ctx = ModuleContext::new("lyxal_pipeline_ingestion");

    let result = probe.check(&ctx).await.expect("Health check probe execution");
    assert_eq!(result.status, lyxal_runtime::health::HealthStatus::Healthy);
    assert_eq!(result.module_id.as_str(), "lyxal_pipeline_ingestion");
    assert!(result.message.unwrap().contains("healthy"));
}
