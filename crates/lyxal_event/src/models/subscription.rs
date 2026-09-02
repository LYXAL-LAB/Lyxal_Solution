use serde::{Deserialize, Serialize};
use surrealdb::sql::{Datetime, Thing as RecordId};

/// Modèle de domaine d'un abonnement à un type ou pattern d'événements.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventSubscription {
    /// Identifiant de l'enregistrement SurrealDB.
    pub id: Option<RecordId>,
    /// Nom unique de l'abonnement.
    pub name: String,
    /// Module destinataire (ex: "lyxal_notification").
    pub target_module: String,
    /// Motif écouté (ex: "booking.created", "booking.*", "*").
    pub event_pattern: String,
    /// Nom du handler correspondant.
    pub handler_name: String,
    /// Indique si l'abonnement est actif.
    pub is_active: bool,
    /// Nombre maximal de tentatives allouées par défaut.
    pub max_attempts: u32,
    /// Horodatage UTC de création.
    pub created_at: Option<Datetime>,
}

impl EventSubscription {
    /// Crée une nouvelle définition d'abonnement.
    #[must_use]
    pub fn new(
        name: impl Into<String>,
        target_module: impl Into<String>,
        event_pattern: impl Into<String>,
        handler_name: impl Into<String>,
    ) -> Self {
        Self {
            id: None,
            name: name.into(),
            target_module: target_module.into(),
            event_pattern: event_pattern.into(),
            handler_name: handler_name.into(),
            is_active: true,
            max_attempts: 5,
            created_at: None,
        }
    }

    /// Personnalise le nombre maximal d'essais.
    #[must_use]
    pub fn with_max_attempts(mut self, max_attempts: u32) -> Self {
        self.max_attempts = max_attempts;
        self
    }
}
