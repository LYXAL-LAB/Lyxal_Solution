use serde::{Deserialize, Serialize};

/// Métriques et statistiques opérationnelles du `RuntimeEventBus`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub struct RuntimeEventBusStats {
    /// Nombre total d'événements publiés avec succès sur le bus.
    pub published: u64,
    /// Nombre total d'événements écrasés dans le buffer circulaire de diffusion (broadcast capacity).
    pub broadcast_dropped: u64,
    /// Nombre total d'occurrences où un consommateur abonné a pris du retard (Lagged).
    pub lagged_subscribers: u64,
    /// Nombre total d'échecs de persistance I/O dans le journal système.
    pub journal_failures: u64,
    /// Nombre total d'événements abandonnés avant journalisation par saturation de la file bornée.
    pub journal_dropped: u64,
}
