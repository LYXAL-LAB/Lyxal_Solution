use std::time::Duration;
use uuid::Uuid;

/// Configuration unifiée d'exécution du LYXAL Event Engine (`EventWorker`).
#[derive(Debug, Clone)]
pub struct EventWorkerConfig {
    /// Identifiant unique du worker / nœud (pour le bail distribué).
    pub worker_id: String,
    /// Identifiant optionnel d'instance de cluster.
    pub instance_id: Option<String>,
    /// Intervalle de scrutation (polling) lorsque aucun événement n'est en attente.
    pub poll_interval: Duration,
    /// Durée de validité (TTL) du bail distribué de streaming.
    pub lease_ttl: Duration,
    /// Intervalle de renouvellement du bail distribué par le leader actif.
    pub lease_renew_interval: Duration,
    /// Nombre maximal d'événements outbox récupérés par lot.
    pub batch_size: usize,
    /// Capacité maximale de messages en vol (fenêtre d'acquittement contiguë).
    pub max_unacked: usize,
    /// Délai maximal alloué à l'exécution d'un handler avant interruption.
    pub dispatch_timeout: Duration,
    /// Délai maximal d'attente d'acquittement (ACK watchdog).
    pub ack_timeout: Duration,
    /// Nombre maximal de tentatives de relivraison avant transfert en Dead Letter Queue.
    pub max_redelivery_count: u32,
    /// Topic optionnel de destination pour la Dead Letter Queue.
    pub dead_letter_topic: Option<String>,
    /// Délai de base pour le backoff exponentiel des retries.
    pub retry_base_delay: Duration,
    /// Plafond maximal du délai de retry.
    pub retry_max_delay: Duration,
    /// Active le Full Jitter sur les retries pour éviter les réveils synchrones.
    pub jitter: bool,
    /// Intervalle d'exécution de la tâche de reprise des fan-outs interrompus.
    pub fanout_recovery_interval: Duration,
}

impl Default for EventWorkerConfig {
    fn default() -> Self {
        Self {
            worker_id: format!("event_worker_{}", Uuid::now_v7().simple()),
            instance_id: None,
            poll_interval: Duration::from_millis(100),
            lease_ttl: Duration::from_secs(5),
            lease_renew_interval: Duration::from_secs(2),
            batch_size: 50,
            max_unacked: 100,
            dispatch_timeout: Duration::from_secs(5),
            ack_timeout: Duration::from_secs(2),
            max_redelivery_count: 3,
            dead_letter_topic: None,
            retry_base_delay: Duration::from_secs(1),
            retry_max_delay: Duration::from_secs(300),
            jitter: true,
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

    /// Personnalise la durée TTL du bail distribué.
    #[must_use]
    pub fn with_lease_ttl(mut self, ttl: Duration) -> Self {
        self.lease_ttl = ttl;
        self
    }

    /// Personnalise l'intervalle de renouvellement du bail.
    #[must_use]
    pub fn with_lease_renew_interval(mut self, interval: Duration) -> Self {
        self.lease_renew_interval = interval;
        self
    }

    /// Personnalise la capacité maximale de messages en vol (fenêtre contiguë).
    #[must_use]
    pub fn with_max_unacked(mut self, max: usize) -> Self {
        self.max_unacked = max;
        self
    }

    /// Personnalise le délai d'ACK timeout du watchdog.
    #[must_use]
    pub fn with_ack_timeout(mut self, timeout: Duration) -> Self {
        self.ack_timeout = timeout;
        self
    }

    /// Personnalise le nombre maximal de retries avant DLQ.
    #[must_use]
    pub fn with_max_redelivery_count(mut self, count: u32) -> Self {
        self.max_redelivery_count = count;
        self
    }

    /// Personnalise le topic DLQ optionnel.
    #[must_use]
    pub fn with_dead_letter_topic(mut self, topic: impl Into<String>) -> Self {
        self.dead_letter_topic = Some(topic.into());
        self
    }

    /// Personnalise le délai de base pour le retry.
    #[must_use]
    pub fn with_retry_base_delay(mut self, delay: Duration) -> Self {
        self.retry_base_delay = delay;
        self
    }

    /// Personnalise le plafond maximal du délai de retry.
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
