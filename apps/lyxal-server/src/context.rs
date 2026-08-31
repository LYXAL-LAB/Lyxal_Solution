use crate::{
    config::AppConfig, database::Database, health::HealthRegistry, metrics::Metrics,
    runtime::RuntimeHandle,
};
use std::sync::Arc;

#[derive(Clone)]
pub struct AppContext {
    pub config: Arc<AppConfig>,
    pub database: Database,
    pub health: HealthRegistry,
    pub metrics: Metrics,
    pub runtime: RuntimeHandle,
}

impl AppContext {
    pub fn new(
        config: Arc<AppConfig>,
        database: Database,
        health: HealthRegistry,
        metrics: Metrics,
        runtime: RuntimeHandle,
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
