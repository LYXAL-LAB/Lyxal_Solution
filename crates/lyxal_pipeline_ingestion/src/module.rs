use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::types::ModuleId;

/// Module officiel d'ingestion industrielle pour Lyxal OS.
pub struct PipelineIngestionModule {
    descriptor: ModuleDescriptor,
}

impl Default for PipelineIngestionModule {
    fn default() -> Self {
        Self::new()
    }
}

impl PipelineIngestionModule {
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new("lyxal_pipeline_ingestion"), "0.1.0")
            .name("Lyxal Pipeline Ingestion")
            .description("Moteur industriel d'ingestion, normalisation et qualification fabricants pour le Master Catalogue")
            .capability("database")
            .capability("workers")
            .capability("events")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_base"))
            .dependency(ModuleId::new("lyxal_crypto"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .build();

        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for PipelineIngestionModule {
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
