use crate::modules::auth::AuthHost;
use crate::{config::AppConfig, database::Database, health::HealthRegistry, metrics::Metrics};
use lyxal_runtime::LyxalRuntime;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppContext {
    pub config: Arc<AppConfig>,
    pub database: Database,
    pub health: HealthRegistry,
    pub metrics: Metrics,
    pub runtime: Arc<LyxalRuntime>,
    /// Service de connexion (routes `/auth/*`).
    pub auth: Option<Arc<AuthHost>>,
}

impl AppContext {
    pub fn new(
        config: Arc<AppConfig>,
        database: Database,
        health: HealthRegistry,
        metrics: Metrics,
        runtime: Arc<LyxalRuntime>,
        auth: Option<Arc<AuthHost>>,
    ) -> Self {
        Self {
            config,
            database,
            health,
            metrics,
            runtime,
            auth,
        }
    }
}
