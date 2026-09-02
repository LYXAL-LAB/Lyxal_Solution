use crate::context::ModuleContext;
use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::types::ModuleId;
use async_trait::async_trait;

/// Contrat officiel et universel implémenté par chaque module de l'écosystème Lyxal OS.
///
/// Le moteur Lyxal Runtime ne dépend d'aucun module concret (`TimezoneModule`, `SchedulerModule`, etc.)
/// et orchestre l'ensemble des modules exclusivement à travers ce trait générique.
#[async_trait]
pub trait LyxalModule: Send + Sync + 'static {
    /// Retourne le descripteur immuable du module (nom, version, dépendances, capacités).
    fn descriptor(&self) -> &ModuleDescriptor;

    /// Raccourci retournant l'identifiant canonique du module.
    fn id(&self) -> &ModuleId {
        &self.descriptor().id
    }

    /// Phase d'installation : prépare les ressources et initialise le module.
    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    /// Phase de démarrage : lance les services d'arrière-plan, workers et serveurs du module.
    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    /// Phase d'arrêt : arrête proprement tous les services, timers et connexions du module.
    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}
