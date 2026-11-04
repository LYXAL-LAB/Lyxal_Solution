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
}

impl AppContext {
    pub fn new(
        config: Arc<AppConfig>,
        database: Database,
        health: HealthRegistry,
        metrics: Metrics,
        runtime: Arc<LyxalRuntime>,
    ) -> Self {
        Self {
            config,
            database,
            health,
            metrics,
            runtime,
        }
    }
}
