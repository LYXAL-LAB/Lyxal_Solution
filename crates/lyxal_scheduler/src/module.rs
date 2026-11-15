//! Module `lyxal_scheduler` pour `lyxal_runtime`.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_scheduler";

/// Module `lyxal_scheduler` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; ses workers (planificateur, exécuteurs) et sa sonde sont enregistrés par l'hôte
/// et démarrés et arrêtés par le runtime avec lui.
pub struct SchedulerModule {
    descriptor: ModuleDescriptor,
}

impl Default for SchedulerModule {
    fn default() -> Self {
        Self::new()
    }
}

impl SchedulerModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Scheduler")
            .description(
                "Planification et exécution des tâches différées et périodiques de Lyxal OS : tâches déclarées par les modules, files, calendriers, planifications, exécutions sous bail, nouvelles tentatives, chevauchement, rattrapage, droits par organisation, journal et événements",
            )
            .capability("database")
            .capability("events")
            .capability("scheduler")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for SchedulerModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}
