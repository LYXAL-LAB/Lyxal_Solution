use std::time::Duration;
use uuid::Uuid;

/// Configuration du worker d'exécution des événements.
#[derive(Debug, Clone)]
pub struct EventWorkerConfig {
    /// Identifiant unique de ce worker dans le cluster.
    pub worker_id: String,
    /// Identifiant optionnel d'instance pour restreindre l'exécution à une instance spécifique.
    pub instance_id: Option<String>,
    /// Intervalle de polling lors des cycles vides.
    pub poll_interval: Duration,
    /// Nombre maximal de livraisons réclamées par lot.
    pub batch_size: usize,
    /// Nombre maximal d'essais avant mise en dead-letter.
    pub max_attempts: u32,
    /// Délai maximal d'exécution accordé à un handler unitaire.
    pub dispatch_timeout: Duration,
    /// Délai de base pour le backoff exponentiel.
    pub retry_base_delay: Duration,
    /// Plafond maximal du délai de retry.
    pub retry_max_delay: Duration,
    /// Active le Full Jitter sur les retries pour éviter les réveils synchrones.
    pub jitter: bool,
    /// Délai de temporisation minimal entre deux cycles de polling consécutifs non vides.
    pub min_cycle_delay: Duration,
    /// Intervalle d'exécution de la tâche de reprise des fan-outs interrompus.
    pub fanout_recovery_interval: Duration,
}

impl Default for EventWorkerConfig {
    fn default() -> Self {
        Self {
            worker_id: format!("worker_{}", Uuid::now_v7()),
            instance_id: None,
            poll_interval: Duration::from_millis(50),
            batch_size: 20,
            max_attempts: 5,
            dispatch_timeout: Duration::from_secs(30),
            retry_base_delay: Duration::from_secs(1),
            retry_max_delay: Duration::from_secs(300),
            jitter: true,
            min_cycle_delay: Duration::from_millis(5),
            fanout_recovery_interval: Duration::from_secs(5),
        }
    }
}

impl EventWorkerConfig {
    /// Définit un worker_id explicite.
    #[must_use]
    pub fn with_worker_id(mut self, id: impl Into<String>) -> Self {
        self.worker_id = id.into();
        self
    }

    /// Filtre sur une instance spécifique.
    #[must_use]
    pub fn with_instance_id(mut self, instance_id: impl Into<String>) -> Self {
        self.instance_id = Some(instance_id.into());
        self
    }

    /// Personnalise le batch_size.
    #[must_use]
    pub fn with_batch_size(mut self, size: usize) -> Self {
        self.batch_size = size;
        self
    }

    /// Personnalise le dispatch_timeout.
    #[must_use]
    pub fn with_dispatch_timeout(mut self, timeout: Duration) -> Self {
        self.dispatch_timeout = timeout;
        self
    }

    /// Personnalise l'intervalle de polling.
    #[must_use]
    pub fn with_poll_interval(mut self, interval: Duration) -> Self {
        self.poll_interval = interval;
        self
    }

    /// Personnalise le nombre maximal d'essais.
    #[must_use]
    pub fn with_max_attempts(mut self, max_attempts: u32) -> Self {
        self.max_attempts = max_attempts;
        self
    }

    /// Personnalise le délai de base de retry.
    #[must_use]
    pub fn with_retry_base_delay(mut self, delay: Duration) -> Self {
        self.retry_base_delay = delay;
        self
    }

    /// Personnalise le plafond maximal de retry.
    #[must_use]
    pub fn with_retry_max_delay(mut self, delay: Duration) -> Self {
        self.retry_max_delay = delay;
        self
    }

    /// Active ou désactive le jitter.
    #[must_use]
    pub fn with_jitter(mut self, jitter: bool) -> Self {
        self.jitter = jitter;
        self
    }
}
