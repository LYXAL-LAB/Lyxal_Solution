//! Module `lyxal_auth` : implémentation `LyxalModule` et sonde de santé, enregistrées auprès du
//! runtime. Ses ressources SurrealQL sont embarquées par `build.rs` et installées avec les autres
//! modules ; les routes HTTP `/auth/*` arrivent au lot 3.

use crate::error::ServerError;
use lyxal_auth::{AuthHealthCheck, AuthModule, AuthStore};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_auth::MODULE_ID;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(AuthModule::new())
}

/// Sonde de santé sur la session système de l'hôte.
pub fn register_services(runtime: &LyxalRuntime, client: &Surreal<Any>) -> Result<(), ServerError> {
    runtime
        .health_registry()
        .register_check(Arc::new(AuthHealthCheck::new(AuthStore::new(
            client.clone(),
        ))))?;
    Ok(())
}
