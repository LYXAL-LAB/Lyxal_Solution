//! Module `lyxal_secrets` pour `lyxal_runtime`.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_secrets";

/// Module `lyxal_secrets` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; worker et sonde sont enregistrés par l'hôte.
pub struct SecretsModule {
    descriptor: ModuleDescriptor,
}

impl Default for SecretsModule {
    fn default() -> Self {
        Self::new()
    }
}

impl SecretsModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Secrets")
            .description(
                "Coffre-fort des secrets applicatifs de Lyxal OS : fiches, versions scellées, étiquettes, droits par opération, ticket de lecture et journal chaîné",
            )
            .capability("database")
            .capability("events")
            .capability("secrets")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for SecretsModule {
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
