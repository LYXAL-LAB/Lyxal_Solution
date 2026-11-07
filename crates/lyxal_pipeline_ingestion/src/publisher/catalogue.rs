//! Appels des fonctions publiques du catalogue sous la session de l'agent de synchronisation.
//!
//! Contrat de `lyxal_catalogue` (README §2–3) : article commercial maître (`nature_reference =
//! COMMERCIALE`, `master_id` renseigné), type `catalogue_type:<TYPE>`, unité de référence
//! `base_unite:<CODE>` (unité de référence et unité de conditionnement). La charge utile publiée
//! est celle du contenu figé du manifeste (`fn::ingestion_manifest_content`), envoyée telle
//! quelle ; son identifiant stable `code = master_id = ING-<empreinte>` y est déjà calculé.

use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, RecordId, SurrealValue, ToSql};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{CatalogueConditionnement, CataloguePayload};
use crate::types::PublicationAction;

#[derive(SurrealValue)]
struct CatalogueItemUpdateParams {
    /// `catalogue_item:<clé>` en texte (règle `record` de lyxal_core).
    id: String,
    libelle: String,
    unite_reference: Option<String>,
    description: Option<String>,
    fabricant: String,
    marque: Option<String>,
    reference_fabricant: String,
    code_barre: Option<String>,
    conditionnement: CatalogueConditionnement,
    unite_conditionnement: Option<String>,
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

    /// Crée (`Insert`) ou met à jour (`Update`) l'article maître décrit par `payload` (contenu
    /// figé du manifeste, unité de référence résolue). Un article déjà présent au catalogue (même
    /// code, même `master_id` : reprise après incident ou nouvelle révision importée par un lot
    /// ultérieur) est mis à jour avec ce contenu, jamais compté comme publié sans écriture.
    pub(crate) async fn publish(
        &self,
        payload: &CataloguePayload,
        action: PublicationAction,
    ) -> Result<(), LyxalSurrealError> {
        match action {
            PublicationAction::Insert => {
                let created: Result<CatalogueItemRef, LyxalSurrealError> =
                    self.call_fn("catalogue_item_create", payload.clone()).await;
                match created {
                    Ok(_) => Ok(()),
                    Err(LyxalSurrealError::Call(call))
                        if call.is_business_code("CATALOGUE_ITEM_ALREADY_EXISTS") =>
                    {
                        let existing = self.get_by_code(&payload.code).await?;
                        if existing.master_id.as_deref() == Some(payload.master_id.as_str()) {
                            self.update(existing.id, payload).await
                        } else {
                            Err(LyxalSurrealError::Call(call))
                        }
                    }
                    Err(e) => Err(e),
                }
            }
            PublicationAction::Update => {
                let existing = self.get_by_code(&payload.code).await?;
                self.update(existing.id, payload).await
            }
            PublicationAction::Unchanged | PublicationAction::Deprecate => Ok(()),
        }
    }

    async fn update(
        &self,
        id: RecordId,
        payload: &CataloguePayload,
    ) -> Result<(), LyxalSurrealError> {
        let update = CatalogueItemUpdateParams {
            id: id.to_sql(),
            libelle: payload.libelle.clone(),
            unite_reference: payload.unite_reference.clone(),
            description: payload.description.clone(),
            fabricant: payload.fabricant.clone(),
            marque: payload.marque.clone(),
            reference_fabricant: payload.reference_fabricant.clone(),
            code_barre: payload.code_barre.clone(),
            conditionnement: payload.conditionnement.clone(),
            unite_conditionnement: payload.unite_conditionnement.clone(),
        };
        let _: CatalogueItemRef = self.call_fn("catalogue_item_update", update).await?;
        Ok(())
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
