use lyxal_event::EventWorkerConfig;
use std::time::Duration;

/// Configuration du moteur d'événements intégré dans Lyxal Runtime.
#[derive(Debug, Clone)]
pub struct EventEngineConfig {
    /// Indique si le moteur d'événements asynchrone est activé pour l'instance.
    pub enabled: bool,
    /// Configuration spécifique du worker d'exécution des événements.
    pub worker_config: EventWorkerConfig,
    /// Intervalle de réveil du ramasse-miettes (Garbage Collector).
    pub gc_interval: Duration,
    /// Période de rétention des événements délivrés et outboxes fanned-out (en jours).
    pub retention_days: u32,
    /// Déclenche automatiquement la reprise des fan-outs interrompus lors du démarrage.
    pub auto_recover_fanouts: bool,
    /// Nombre maximal d'événements outbox repris par cycle de démarrage.
    pub recover_fanout_batch_size: usize,
    /// Initialise automatiquement les schémas et fonctions SurrealQL de lyxal_event.
    pub auto_init_schema: bool,
}

impl Default for EventEngineConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            worker_config: EventWorkerConfig::default(),
            gc_interval: Duration::from_secs(300),
            retention_days: 7,
            auto_recover_fanouts: true,
            recover_fanout_batch_size: 50,
            auto_init_schema: true,
        }
    }
}

impl EventEngineConfig {
    /// Active ou désactive le moteur d'événements.
    #[must_use]
    pub fn with_enabled(mut self, enabled: bool) -> Self {
        self.enabled = enabled;
        self
    }

    /// Personnalise la configuration du worker d'événements.
    #[must_use]
    pub fn with_worker_config(mut self, config: EventWorkerConfig) -> Self {
        self.worker_config = config;
        self
    }

    /// Définit l'intervalle d'exécution du Garbage Collector.
    #[must_use]
    pub fn with_gc_interval(mut self, interval: Duration) -> Self {
        self.gc_interval = interval;
        self
    }

    /// Définit la durée de rétention en jours.
    #[must_use]
    pub fn with_retention_days(mut self, days: u32) -> Self {
        self.retention_days = days;
        self
    }

    /// Active ou désactive la reprise automatique des fan-outs au boot.
    #[must_use]
    pub fn with_auto_recover_fanouts(mut self, auto_recover: bool) -> Self {
        self.auto_recover_fanouts = auto_recover;
        self
    }

    /// Active ou désactive l'initialisation automatique des schémas.
    #[must_use]
    pub fn with_auto_init_schema(mut self, auto_init: bool) -> Self {
        self.auto_init_schema = auto_init;
        self
    }
}
