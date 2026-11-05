//! Appels des fonctions publiques du catalogue sous la session de l'agent de synchronisation.
//!
//! Contrat de `lyxal_catalogue` (README §2–3) : article commercial maître (`nature_reference =
//! COMMERCIALE`, `master_id` renseigné), type `catalogue_type:<TYPE>`, unité de référence
//! `base_unite:<CODE>`. Les identifiants sont stables : `code = master_id = ING-<empreinte>`,
//! empreinte BLAKE3 du fabricant et de la référence fabricant.

use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, RecordId, SurrealValue};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::StagedItem;
use crate::types::PublicationAction;

/// Identifiant stable (code et `master_id`) d'un article publié par le pipeline.
pub fn catalogue_master_id(fabricant: &str, reference_fabricant: &str) -> String {
    let digest = lyxal_crypto::blake3_hex(
        format!(
            "{}\u{1f}{}",
            fabricant.trim().to_uppercase(),
            reference_fabricant.trim()
        )
        .as_bytes(),
    );
    format!("ING-{}", digest[..32].to_uppercase())
}

#[derive(Clone, SurrealValue)]
struct CatalogueDimensions {
    longueur: f64,
    largeur: f64,
    epaisseur: f64,
}

#[derive(Clone, SurrealValue)]
struct CatalogueConditionnement {
    type_unite: RecordId,
    quantite: f64,
    poids_kg: Option<f64>,
    dimensions: Option<CatalogueDimensions>,
}

#[derive(Clone, SurrealValue)]
struct CatalogueItemCreateParams {
    code: String,
    #[surreal(rename = "type")]
    type_item: String,
    libelle: String,
    unite_reference: String,
    description: Option<String>,
    nature_reference: String,
    fabricant: String,
    marque: Option<String>,
    reference_fabricant: String,
    code_barre: Option<String>,
    conditionnement: CatalogueConditionnement,
    master_id: String,
}

#[derive(SurrealValue)]
struct CatalogueItemUpdateParams {
    id: RecordId,
    libelle: String,
    unite_reference: String,
    description: Option<String>,
    fabricant: String,
    marque: Option<String>,
    reference_fabricant: String,
    code_barre: Option<String>,
    conditionnement: CatalogueConditionnement,
}

#[derive(SurrealValue)]
struct CatalogueItemGetParams {
    code: String,
}

/// Article du catalogue (identifiant et `master_id`), renvoyé par la création et la mise à jour.
#[derive(SurrealValue)]
struct CatalogueItemRef {
    id: RecordId,
    master_id: Option<String>,
}

/// Réponse de `fn::catalogue_item_get` : l'article et ses données associées.
#[derive(SurrealValue)]
struct CatalogueItemDetail {
    item: CatalogueItemRef,
}

/// Client des fonctions d'articles du catalogue, sur une session authentifiée par le jeton de
/// service `catalogue_sync_agent`.
pub(crate) struct CatalogueSyncClient {
    db: Surreal<Any>,
}

#[async_trait::async_trait]
impl LyxalSurrealCall for CatalogueSyncClient {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

impl CatalogueSyncClient {
    pub(crate) fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Crée (`Insert`) ou met à jour (`Update`) l'article maître correspondant à `item`.
    /// Une création déjà faite (même code, même `master_id`) est reconnue comme publiée.
    pub(crate) async fn publish(
        &self,
        item: &StagedItem,
        action: PublicationAction,
    ) -> Result<(), LyxalSurrealError> {
        let params = create_params(item);
        match action {
            PublicationAction::Insert => {
                let created: Result<CatalogueItemRef, LyxalSurrealError> =
                    self.call_fn("catalogue_item_create", params.clone()).await;
                match created {
                    Ok(_) => Ok(()),
                    Err(LyxalSurrealError::Call(call))
                        if call.is_business_code("CATALOGUE_ITEM_ALREADY_EXISTS") =>
                    {
                        // Reprise après incident : l'article a déjà été créé par ce pipeline.
                        let existing = self.get_by_code(&params.code).await?;
                        if existing.master_id.as_deref() == Some(params.master_id.as_str()) {
                            Ok(())
                        } else {
                            Err(LyxalSurrealError::Call(call))
                        }
                    }
                    Err(e) => Err(e),
                }
            }
            PublicationAction::Update => {
                let existing = self.get_by_code(&params.code).await?;
                let update = CatalogueItemUpdateParams {
                    id: existing.id,
                    libelle: params.libelle,
                    unite_reference: params.unite_reference,
                    description: params.description,
                    fabricant: params.fabricant,
                    marque: params.marque,
                    reference_fabricant: params.reference_fabricant,
                    code_barre: params.code_barre,
                    conditionnement: params.conditionnement,
                };
                let _: CatalogueItemRef = self.call_fn("catalogue_item_update", update).await?;
                Ok(())
            }
            PublicationAction::Unchanged | PublicationAction::Deprecate => Ok(()),
        }
    }

    async fn get_by_code(&self, code: &str) -> Result<CatalogueItemRef, LyxalSurrealError> {
        let detail: CatalogueItemDetail = self
            .call_fn(
                "catalogue_item_get",
                CatalogueItemGetParams {
                    code: code.to_string(),
                },
            )
            .await?;
        Ok(detail.item)
    }
}

fn create_params(item: &StagedItem) -> CatalogueItemCreateParams {
    let master_id = catalogue_master_id(&item.fabricant, &item.reference_fabricant);
    let packaging = &item.conditionnement;
    CatalogueItemCreateParams {
        code: master_id.clone(),
        type_item: item.type_item.clone(),
        libelle: item.libelle_commercial.clone(),
        unite_reference: item.unite_reference.clone(),
        description: item.description_technique.clone(),
        nature_reference: "COMMERCIALE".to_string(),
        fabricant: item.fabricant.clone(),
        marque: item.marque.clone(),
        reference_fabricant: item.reference_fabricant.clone(),
        code_barre: item.code_barre_gtin.clone(),
        conditionnement: CatalogueConditionnement {
            type_unite: RecordId::new("base_unite", packaging.unite_vente.trim().to_uppercase()),
            quantite: packaging.quantite_par_colis,
            poids_kg: packaging.poids_brut_kg,
            dimensions: packaging.dimensions.as_ref().map(|d| CatalogueDimensions {
                longueur: d.longueur_mm,
                largeur: d.largeur_mm,
                epaisseur: d.epaisseur_mm,
            }),
        },
        master_id,
    }
}
