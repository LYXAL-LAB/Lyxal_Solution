//! Aperçu d'une étape de canal (décision C7) : objet, HTML et texte rendus avec des données
//! d'exemple par le moteur de rendu du worker, sans aucune écriture ni secret. Les données du
//! rendu (gabarit, langue, textes, mise en page) sont lues par `fn::notification_step_preview`
//! au nom de l'appelant (permission `notification.read`).

use crate::error::NotificationResult;
use crate::models::StepPreviewParams;
use crate::render::{RenderedEmail, Renderer};
use crate::store::NotificationStore;

/// Aperçu des étapes d'un parcours.
pub struct NotificationPreview {
    store: NotificationStore,
    renderer: Renderer,
}

impl NotificationPreview {
    /// Aperçu sur la session de l'appelant.
    pub fn new(store: NotificationStore) -> Self {
        Self {
            store,
            renderer: Renderer::preview(),
        }
    }

    /// Rend l'étape `step_key` du parcours `workflow` avec les données d'exemple `payload`, dans
    /// la langue `locale` (sinon celle de l'organisation, sinon celle de l'installation). Une
    /// variable absente des données d'exemple s'affiche vide ; une clé de traduction inconnue,
    /// un argument manquant ou un filtre mal employé font échouer le rendu
    /// (`NOTIFICATION_RENDER_FAILED`).
    pub async fn render(&self, params: StepPreviewParams) -> NotificationResult<RenderedEmail> {
        let data = self.store.step_preview(params).await?;
        self.renderer.render(&data, None, None)
    }
}
