//! Publication réelle d'un manifeste approuvé vers le catalogue installé, sous le jeton de
//! service `catalogue_sync_agent` (accès JWT défini comme le fait l'hôte).

use std::sync::Arc;

use lyxal_event::{CorrelationId, EventContext, EventId, Handler, HandlerContext};
use lyxal_pipeline_ingestion::error::IngestionError;
use lyxal_pipeline_ingestion::events::ManifestApprovedEvent;
use lyxal_pipeline_ingestion::fingerprint::FingerprintEngine;
use lyxal_pipeline_ingestion::models::StagedItem;
use lyxal_pipeline_ingestion::proof::{CommercialProof, CommercialProofType};
use lyxal_pipeline_ingestion::publisher::{
    catalogue_master_id, CatalogueTokenIssuer, ControlledPublisher, ManifestApprovedHandler,
    PublicationConsumer,
};
use lyxal_pipeline_ingestion::storage::{IngestionStore, ManifestDraft, NewBatch};
use lyxal_pipeline_ingestion::types::{
    Dimensions, ItemQualification, ManifestStatus, PackagingDetails, PublicationAction,
    SourceFormat,
};
use lyxal_runtime::worker::CancellationToken;
use lyxal_runtime::EventConsumerModule;
use lyxal_surreal::{RecordId, SurrealValue};

fn proof(reference: &str, authority: &str) -> CommercialProof {
    CommercialProof::new(
        CommercialProofType::CertifiedManufacturerEdi,
        reference,
        authority,
        "system:edi_receiver",
        "2026-10-25T10:00:00Z",
    )
}

fn item(
    batch: &str,
    line: usize,
    reference: &str,
    qualification: ItemQualification,
    proof: Option<CommercialProof>,
) -> StagedItem {
    StagedItem {
        id: None,
        batch: batch.to_string(),
        raw_record: format!("{batch}_{line}"),
        ligne_numero: line,
        canonical_fingerprint: lyxal_crypto::blake3_hex(format!("{batch}:{reference}").as_bytes()),
        rules_version: "2026.1".to_string(),
        fabricant: "PLACO".to_string(),
        marque: Some("PLACO".to_string()),
        reference_fabricant: reference.to_string(),
        code_barre_gtin: (line == 1).then(|| "3017620422003".to_string()),
        libelle_commercial: format!("Plaque de plâtre {reference}"),
        description_technique: None,
        type_item: "PRODUIT".to_string(),
        unite_reference: Some("M2".to_string()),
        conditionnement: PackagingDetails {
            unite_vente: Some("PCE".to_string()),
            quantite_par_colis: 1.0,
            poids_brut_kg: Some(25.5),
            dimensions: Some(Dimensions {
                longueur_mm: 2500.0,
                largeur_mm: 1200.0,
                epaisseur_mm: 12.5,
            }),
        },
        qualification,
        qualification_reason: Some("Qualification de test".to_string()),
        commercial_proof: proof,
        publication_action: PublicationAction::Insert,
        diff_payload: None,
        transitions: Vec::new(),
        is_approved: false,
        approved_by: None,
        approved_at: None,
    }
}

/// Lot, articles et manifeste scellé (sceau des empreintes du lot), approuvé en session système.
async fn approved_manifest(
    store: &IngestionStore,
    batch: &str,
    manifest_ref: &str,
    items: &[StagedItem],
) {
    store
        .create_batch(&NewBatch {
            id: Some(batch.to_string()),
            source_type: SourceFormat::Csv,
            source_format_version: "1.0".to_string(),
            fournisseur_id: "FOURN_PLACO".to_string(),
            nom_fichier: format!("{batch}.csv"),
            file_hash_blake3: lyxal_crypto::blake3_hex(batch.as_bytes()),
            taille_octets: 512,
            chunk_size: 50,
            provenance_details: serde_json::json!({}),
        })
        .await
        .expect("lot");
    for outcome in store
        .save_staged_items_chunk(items)
        .await
        .expect("articles")
    {
        outcome.expect("article enregistré");
    }
    let fingerprints: Vec<String> = items
        .iter()
        .map(|i| i.canonical_fingerprint.clone())
        .collect();
    store
        .save_manifest(&ManifestDraft {
            manifest_ref: manifest_ref.to_string(),
            batch_id: batch.to_string(),
            manifest_version: 1,
            seal_hash: FingerprintEngine::compute_manifest_seal(&fingerprints),
            statut: ManifestStatus::Sealed,
            nb_articles_insert: items.len() as i64,
            nb_articles_update: 0,
        })
        .await
        .expect("manifeste scellé");
    store
        .approve_manifest(manifest_ref, "Manifeste contrôlé avant publication")
        .await
        .expect("approbation");
}

#[derive(Debug, SurrealValue)]
struct CatalogueRow {
    code: String,
    master_id: Option<String>,
    is_custom: bool,
    nature_reference: String,
    fabricant: Option<String>,
    reference_fabricant: Option<String>,
    code_barre: Option<String>,
    unite_reference: RecordId,
    #[surreal(rename = "type")]
    type_item: RecordId,
    unite_conditionnement: Option<RecordId>,
}

async fn catalogue_rows(store: &IngestionStore) -> Vec<CatalogueRow> {
    store
        .client()
        .query(
            "SELECT code, master_id, is_custom, nature_reference, fabricant, reference_fabricant, \
             code_barre, unite_reference, type, unite_conditionnement \
             FROM catalogue_item ORDER BY code",
        )
        .await
        .expect("lecture catalogue")
        .take(0)
        .expect("articles du catalogue")
}

#[tokio::test]
async fn approved_manifest_is_published_to_the_catalogue() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let items = vec![
        item(
            "lot_pub",
            1,
            "BA13",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
        ),
        item(
            "lot_pub",
            2,
            "BA18",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-002", "EDI_HUB_SAINT_GOBAIN")),
        ),
        item("lot_pub", 3, "BA25", ItemQualification::ToConfirm, None),
        item("lot_pub", 4, "BA06", ItemQualification::Rejected, None),
    ];
    approved_manifest(&store, "lot_pub", "MAN-PUB", &items).await;

    let publisher = ControlledPublisher::new(store.client().clone(), issuer);
    let report = publisher
        .publish_manifest("MAN-PUB")
        .await
        .expect("publication");
    assert_eq!(report.final_status, ManifestStatus::Committed);
    assert_eq!(
        (
            report.eligible_verified,
            report.newly_published,
            report.skipped_to_confirm,
            report.skipped_rejected,
            report.failed
        ),
        (2, 2, 1, 1, 0)
    );

    // Articles maîtres conformes au contrat du catalogue, identifiants stables
    let rows = catalogue_rows(&store).await;
    assert_eq!(rows.len(), 2);
    let ba13 = rows
        .iter()
        .find(|r| r.reference_fabricant.as_deref() == Some("BA13"))
        .expect("BA13 publié");
    assert_eq!(ba13.code, catalogue_master_id("PLACO", "BA13"));
    assert_eq!(ba13.master_id.as_deref(), Some(ba13.code.as_str()));
    assert!(!ba13.is_custom);
    assert_eq!(ba13.nature_reference, "COMMERCIALE");
    assert_eq!(ba13.fabricant.as_deref(), Some("PLACO"));
    assert_eq!(ba13.code_barre.as_deref(), Some("3017620422003"));
    assert_eq!(ba13.unite_reference, RecordId::new("base_unite", "M2"));
    assert_eq!(ba13.type_item, RecordId::new("catalogue_type", "PRODUIT"));
    assert_eq!(
        ba13.unite_conditionnement,
        Some(RecordId::new("base_unite", "PCE"))
    );

    // Unités utilisées par les articles publiés : la base refuse leur suppression directe
    // (REFERENCE ON DELETE REJECT sur unite_reference et unite_conditionnement)
    for unit in ["M2", "PCE"] {
        let deleted = store
            .client()
            .query(format!("DELETE base_unite:{unit};"))
            .await
            .expect("requête")
            .check();
        assert!(
            deleted.is_err(),
            "base_unite:{unit} ne doit pas être supprimable"
        );
    }

    // Manifeste exécuté au nom de l'agent de synchronisation
    let manifest = store
        .get_manifest("MAN-PUB")
        .await
        .expect("lecture")
        .expect("manifeste");
    assert_eq!(manifest.statut, ManifestStatus::Committed);
    assert_eq!(manifest.items_committed, 2);
    assert_eq!(manifest.execution_items.len(), 2);
    let last = manifest.transitions.last().expect("transition");
    assert_eq!(last.to_state, "COMMITTED");
    assert_eq!(last.triggered_by.as_deref(), Some("service:catalogue_sync"));

    // Un manifeste exécuté n'est pas republié
    let again = publisher.publish_manifest("MAN-PUB").await.expect("rejeu");
    assert_eq!(again.final_status, ManifestStatus::Committed);
    assert_eq!(again.newly_published, 0);
    assert_eq!(catalogue_rows(&store).await.len(), 2);
}

#[tokio::test]
async fn ineligible_proof_fails_the_manifest_without_catalogue_write() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let items = vec![item(
        "lot_pilote",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("PILOT-2026-01", "EDI_HUB_SAINT_GOBAIN")),
    )];
    approved_manifest(&store, "lot_pilote", "MAN-PILOTE", &items).await;

    let report = ControlledPublisher::new(store.client().clone(), issuer)
        .publish_manifest("MAN-PILOTE")
        .await
        .expect("publication");
    assert_eq!(report.final_status, ManifestStatus::Failed);
    assert_eq!((report.newly_published, report.failed), (0, 1));
    assert!(catalogue_rows(&store).await.is_empty());

    let manifest = store
        .get_manifest("MAN-PILOTE")
        .await
        .expect("lecture")
        .expect("manifeste");
    assert_eq!(manifest.statut, ManifestStatus::Failed);
    let entry = &manifest.execution_items[0];
    assert_eq!(entry["success"], false);
    assert!(entry["error"]
        .as_str()
        .unwrap_or_default()
        .starts_with("INGESTION_PROOF_INVALID"));
}

#[tokio::test]
async fn catalogue_refusal_is_journaled_and_others_are_published() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let mut unknown_unit = item(
        "lot_mixte",
        2,
        "BA18",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-002", "EDI_HUB_SAINT_GOBAIN")),
    );
    unknown_unit.unite_reference = Some("BOITE".to_string());
    let items = vec![
        item(
            "lot_mixte",
            1,
            "BA13",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
        ),
        unknown_unit,
    ];
    approved_manifest(&store, "lot_mixte", "MAN-MIXTE", &items).await;

    let report = ControlledPublisher::new(store.client().clone(), issuer)
        .publish_manifest("MAN-MIXTE")
        .await
        .expect("publication");
    assert_eq!(report.final_status, ManifestStatus::Failed);
    assert_eq!((report.newly_published, report.failed), (1, 1));
    assert_eq!(catalogue_rows(&store).await.len(), 1);

    let manifest = store
        .get_manifest("MAN-MIXTE")
        .await
        .expect("lecture")
        .expect("manifeste");
    let refused = manifest
        .execution_items
        .iter()
        .find(|e| e["success"] == false)
        .expect("article refusé journalisé");
    assert_eq!(refused["item_ref"], catalogue_master_id("PLACO", "BA18"));
    assert!(refused["error"]
        .as_str()
        .unwrap_or_default()
        .starts_with("CATALOGUE_ITEM_UNITE_INVALID"));
}

#[tokio::test]
async fn resumed_publication_skips_journaled_and_already_created_items() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let items = vec![
        item(
            "lot_reprise",
            1,
            "BA13",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
        ),
        item(
            "lot_reprise",
            2,
            "BA18",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-002", "EDI_HUB_SAINT_GOBAIN")),
        ),
    ];
    approved_manifest(&store, "lot_reprise", "MAN-REPRISE", &items).await;

    // Exécution interrompue : BA13 journalisé, BA18 créé au catalogue mais pas journalisé
    store
        .update_manifest_execution_item(
            "MAN-REPRISE",
            &catalogue_master_id("PLACO", "BA13"),
            PublicationAction::Insert,
            true,
            None,
        )
        .await
        .expect("journal");
    let token = issuer.issue().expect("jeton");
    let sync_session = store.client().clone();
    sync_session
        .authenticate(token.expose_secret().to_string())
        .await
        .expect("session de l'agent de synchronisation");
    let code = catalogue_master_id("PLACO", "BA18");
    let created: Vec<serde_json::Value> = sync_session
        .query("RETURN fn::catalogue_item_create({ code: $code, master_id: $code, type: 'PRODUIT', libelle: 'Plaque de plâtre BA18', unite_reference: 'M2', nature_reference: 'COMMERCIALE', fabricant: 'PLACO', reference_fabricant: 'BA18' }).ok")
        .bind(("code", code))
        .await
        .expect("création directe")
        .take(0)
        .expect("résultat");
    assert_eq!(created, vec![serde_json::json!(true)]);
    let publisher = ControlledPublisher::new(store.client().clone(), issuer);

    let report = publisher
        .publish_manifest("MAN-REPRISE")
        .await
        .expect("reprise");
    assert_eq!(report.final_status, ManifestStatus::Committed);
    // BA13 journalisé est sauté ; BA18 déjà créé (même code, même master_id) est reconnu
    assert_eq!(
        (
            report.already_published,
            report.newly_published,
            report.failed
        ),
        (1, 1, 0)
    );
    let rows = catalogue_rows(&store).await;
    assert_eq!(
        rows.len(),
        1,
        "ni BA13 (journalisé) ni BA18 (déjà créé) ne sont recréés"
    );
    assert_eq!(rows[0].reference_fabricant.as_deref(), Some("BA18"));
}

#[tokio::test]
async fn tampered_batch_and_unapproved_manifest_are_refused() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let publisher = ControlledPublisher::new(store.client().clone(), issuer);
    let items = vec![item(
        "lot_altere",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
    )];
    approved_manifest(&store, "lot_altere", "MAN-ALTERE", &items).await;

    // Article ajouté au lot après l'approbation : le sceau ne correspond plus
    for outcome in store
        .save_staged_items_chunk(&[item(
            "lot_altere",
            2,
            "BA18",
            ItemQualification::Verified,
            Some(proof("EDI-2026-PLACO-002", "EDI_HUB_SAINT_GOBAIN")),
        )])
        .await
        .expect("ajout")
    {
        outcome.expect("article ajouté");
    }
    let tampered = publisher.publish_manifest("MAN-ALTERE").await;
    assert!(
        matches!(tampered, Err(IngestionError::FingerprintTampered(_))),
        "{tampered:?}"
    );
    assert!(catalogue_rows(&store).await.is_empty());

    // Manifeste seulement scellé
    let unknown = publisher.publish_manifest("MAN-INCONNU").await;
    assert!(
        matches!(unknown, Err(IngestionError::Storage(_))),
        "{unknown:?}"
    );
}

#[tokio::test]
async fn token_signed_with_another_key_is_refused() {
    let store = crate::support::installed_store().await;
    let _defined = crate::support::sync_issuer(&store).await;
    // Second accès défini ensuite : l'émetteur du premier ne signe plus avec la clé de la base
    let stale_issuer = {
        let other = crate::support::installed_store().await;
        crate::support::sync_issuer(&other).await
    };
    let items = vec![item(
        "lot_cle",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
    )];
    approved_manifest(&store, "lot_cle", "MAN-CLE", &items).await;

    let refused = ControlledPublisher::new(store.client().clone(), stale_issuer)
        .publish_manifest("MAN-CLE")
        .await;
    assert!(
        matches!(refused, Err(IngestionError::Surreal(_))),
        "{refused:?}"
    );
    assert!(catalogue_rows(&store).await.is_empty());
    // La session système de l'hôte n'est pas affectée
    assert_eq!(
        store
            .get_manifest("MAN-CLE")
            .await
            .expect("lecture")
            .expect("manifeste")
            .statut,
        ManifestStatus::Approved
    );
}

#[tokio::test]
async fn approval_event_handler_publishes_the_manifest() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let items = vec![item(
        "lot_evt",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
    )];
    approved_manifest(&store, "lot_evt", "MAN-EVT", &items).await;

    // Le consommateur enregistre son handler pour ingestion.manifest.approved
    let publisher = Arc::new(ControlledPublisher::new(store.client().clone(), issuer));
    let mut registry = lyxal_event::HandlerRegistry::new();
    PublicationConsumer::new(publisher.clone())
        .register_event_handlers(&mut registry)
        .expect("enregistrement");
    assert!(registry.contains("ingestion.manifest.approved"));

    // L'événement émis par la base à l'approbation porte la référence du manifeste
    let payload: Vec<serde_json::Value> = store
        .client()
        .query("SELECT VALUE payload FROM event_outbox WHERE event_type = 'ingestion.manifest.approved'")
        .await
        .expect("outbox")
        .take(0)
        .expect("événements");
    assert_eq!(payload.len(), 1);
    let event: ManifestApprovedEvent =
        serde_json::from_value(payload[0].clone()).expect("événement typé");
    assert_eq!(event.manifest_ref, "MAN-EVT");

    let ctx = HandlerContext::new(
        EventId::new(),
        RecordId::new("event_delivery", "test"),
        CorrelationId::new(),
        None,
        EventContext::new("instance_test", "ingestion", "manifest"),
        1,
        CancellationToken::new(),
    );
    ManifestApprovedHandler::new(publisher.clone())
        .handle(event.clone(), &ctx)
        .await
        .expect("publication par le handler");
    assert_eq!(catalogue_rows(&store).await.len(), 1);

    // Livraison en double (at-least-once) : sans effet
    ManifestApprovedHandler::new(publisher)
        .handle(event, &ctx)
        .await
        .expect("rejeu");
    assert_eq!(catalogue_rows(&store).await.len(), 1);
}

#[tokio::test]
async fn later_batch_revision_updates_the_published_item() {
    let store = crate::support::installed_store().await;
    let issuer = crate::support::sync_issuer(&store).await;
    let publisher = ControlledPublisher::new(store.client().clone(), issuer);
    let first = vec![item(
        "lot_v1",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-001", "EDI_HUB_SAINT_GOBAIN")),
    )];
    approved_manifest(&store, "lot_v1", "MAN-V1", &first).await;
    publisher
        .publish_manifest("MAN-V1")
        .await
        .expect("première publication");

    // Lot ultérieur : même fabricant et même référence, libellé et code-barres révisés
    let mut revised = item(
        "lot_v2",
        1,
        "BA13",
        ItemQualification::Verified,
        Some(proof("EDI-2026-PLACO-009", "EDI_HUB_SAINT_GOBAIN")),
    );
    revised.libelle_commercial = "Plaque de plâtre BA13 hydrofuge".to_string();
    revised.code_barre_gtin = Some("4006381333931".to_string());
    approved_manifest(&store, "lot_v2", "MAN-V2", &[revised]).await;
    let report = publisher
        .publish_manifest("MAN-V2")
        .await
        .expect("révision");
    assert_eq!(report.final_status, ManifestStatus::Committed);
    assert_eq!(report.newly_published, 1);

    let rows: Vec<(String, Option<String>)> = store
        .client()
        .query("SELECT VALUE [libelle, code_barre] FROM catalogue_item")
        .await
        .expect("lecture")
        .take::<Vec<Vec<serde_json::Value>>>(0)
        .expect("articles")
        .into_iter()
        .map(|r| {
            (
                r[0].as_str().unwrap_or_default().to_string(),
                r[1].as_str().map(str::to_string),
            )
        })
        .collect();
    assert_eq!(
        rows,
        vec![(
            "Plaque de plâtre BA13 hydrofuge".to_string(),
            Some("4006381333931".to_string())
        )],
        "un seul article maître, porteur de la révision"
    );
}
