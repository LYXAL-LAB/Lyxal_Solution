//! Module `lyxal_i18n` : implémentation `LyxalModule` et sonde de santé (réglages, langue par
//! défaut rendue, base des fuseaux horaires).

use crate::error::ServerError;
use lyxal_i18n::{I18nHealthCheck, I18nModule, I18nStore};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_i18n::MODULE_ID;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(I18nModule::new())
}

/// Enregistre la sonde de santé du module.
pub fn register_services(runtime: &LyxalRuntime, client: &Surreal<Any>) -> Result<(), ServerError> {
    runtime
        .health_registry()
        .register_check(Arc::new(I18nHealthCheck::new(I18nStore::new(
            client.clone(),
        ))))?;
    Ok(())
}
