use crate::modules::auth::AuthHost;
use crate::modules::secrets::SecretsHost;
use crate::{config::AppConfig, database::Database, health::HealthRegistry, metrics::Metrics};
use lyxal_runtime::LyxalRuntime;
use lyxal_storage::{Backends, ContentScanner};
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
    /// Supports et antivirus des fichiers (routes `/storage/*`).
    pub storage: StorageHost,
    /// Coffre-fort des secrets (routes `/secrets/*`), absent si le module n'est pas hébergé.
    pub secrets: Option<SecretsHost>,
}

/// Ce que les routes des fichiers reçoivent de l'hôte : les supports configurés et, s'il y en a
/// un, l'antivirus qui analyse tout fichier envoyé.
#[derive(Clone, Default)]
pub struct StorageHost {
    pub backends: Arc<Backends>,
    pub scanner: Option<Arc<dyn ContentScanner>>,
}

impl AppContext {
    pub fn new(
        config: Arc<AppConfig>,
        database: Database,
        health: HealthRegistry,
        metrics: Metrics,
        runtime: Arc<LyxalRuntime>,
        auth: Option<Arc<AuthHost>>,
        storage: StorageHost,
    ) -> Self {
        Self {
            config,
            database,
            health,
            metrics,
            runtime,
            auth,
            storage,
            secrets: None,
        }
    }

    /// Contexte avec le coffre-fort des secrets (routes `/secrets/*`).
    pub fn with_secrets(mut self, secrets: SecretsHost) -> Self {
        self.secrets = Some(secrets);
        self
    }
}
