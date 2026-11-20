use crate::config::AppConfig;
use crate::modules::auth::AuthHost;
use crate::modules::notification::NotificationHost;
use crate::modules::scheduler::SchedulerHost;
use crate::modules::secrets::SecretsHost;
use lyxal_host::{database::Database, health::HealthRegistry, metrics::Metrics};
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
    /// Planificateur (routes `/scheduler/*`), absent si le module n'est pas hébergé.
    pub scheduler: Option<SchedulerHost>,
    /// Notifications (routes `/notification/*`), absent si le module n'est pas hébergé.
    pub notification: Option<NotificationHost>,
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
            scheduler: None,
            notification: None,
        }
    }

    /// Contexte avec le coffre-fort des secrets (routes `/secrets/*`).
    pub fn with_secrets(mut self, secrets: SecretsHost) -> Self {
        self.secrets = Some(secrets);
        self
    }

    /// Contexte avec le planificateur (routes `/scheduler/*`).
    pub fn with_scheduler(mut self, scheduler: SchedulerHost) -> Self {
        self.scheduler = Some(scheduler);
        self
    }

    /// Contexte avec les notifications (routes `/notification/*`).
    pub fn with_notification(mut self, notification: NotificationHost) -> Self {
        self.notification = Some(notification);
        self
    }
}
