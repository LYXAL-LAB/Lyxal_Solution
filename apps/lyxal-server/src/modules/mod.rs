mod contract;
mod system;

pub use contract::{
    LyxalModule, ModuleContext, ModuleDescriptor, ModuleId, ModuleMigration, ModuleState,
    SharedModule,
};
pub use system::SystemModule;

use crate::config::AppConfig;
use std::sync::Arc;

#[cfg(feature = "module-ingestion")]
mod ingestion;

#[cfg(feature = "module-ingestion")]
pub use ingestion::IngestionServerModule;

pub fn compiled_modules(_config: &AppConfig) -> Vec<Arc<dyn LyxalModule>> {
    let mut modules: Vec<Arc<dyn LyxalModule>> = vec![Arc::new(SystemModule::new())];

    #[cfg(feature = "module-ingestion")]
    modules.push(Arc::new(IngestionServerModule::new()));

    modules
}
