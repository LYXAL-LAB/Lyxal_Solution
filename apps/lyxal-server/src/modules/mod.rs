mod contract;
mod system;

pub use contract::{
    LyxalModule, ModuleContext, ModuleDescriptor, ModuleId, ModuleMigration, ModuleState,
};
pub use system::SystemModule;

use crate::config::AppConfig;
use std::sync::Arc;

pub fn compiled_modules(_config: &AppConfig) -> Vec<Arc<dyn LyxalModule>> {
    let modules: Vec<Arc<dyn LyxalModule>> = vec![Arc::new(SystemModule::new())];

    // Les modules métier sont ajoutés ici après raccordement à leurs crates :
    //
    // #[cfg(feature = "module-timezone")]
    // modules.push(Arc::new(lyxal_timezone::TimezoneModule::new()));
    //
    // Le contrat doit être partagé par `lyxal-runtime` à terme.
    modules
}
