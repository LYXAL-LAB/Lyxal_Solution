use std::time::Duration;

/// Configuration de la boucle continue de réconciliation (Lyxal Runtime V1.7).
#[derive(Debug, Clone)]
pub struct ReconciliationLoopConfig {
    /// Intervalle nominal entre deux cycles d'évaluation consécutifs.
    pub interval: Duration,
    /// Délai initial avant l'exécution du premier cycle lors du démarrage.
    pub initial_delay: Duration,
    /// Délai de base pour le calcul du backoff exponentiel en cas d'erreur de contrôle.
    pub base_backoff: Duration,
    /// Plafond maximal du délai de backoff.
    pub max_backoff: Duration,
    /// Facteur multiplicateur du backoff exponentiel.
    pub backoff_factor: f64,
}

impl Default for ReconciliationLoopConfig {
    fn default() -> Self {
        Self {
            interval: Duration::from_secs(30),
            initial_delay: Duration::from_secs(0),
            base_backoff: Duration::from_secs(5),
            max_backoff: Duration::from_secs(300), // 5 minutes
            backoff_factor: 2.0,
        }
    }
}
