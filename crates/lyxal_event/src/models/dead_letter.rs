use super::envelope::EventContext;
use serde::{Deserialize, Serialize};
use surrealdb::sql::{Datetime, Thing as RecordId};

/// Enregistrement de mise en quarantaine (Dead Letter Queue).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventDeadLetter {
    /// Identifiant de l'enregistrement dans la table event_dead_letter.
    pub id: RecordId,
    /// Référence à la livraison en échec.
    pub delivery: RecordId,
    /// Référence à l'événement parent dans l'outbox.
    pub outbox_event: RecordId,
    /// Module cible concerné.
    pub target_module: String,
    /// Contexte d'isolation de l'instance.
    pub context: EventContext,
    /// Nombre total de tentatives effectuées.
    pub attempts: u32,
    /// Dernier message d'erreur.
    pub last_error: String,
    /// Copie du payload pour inspection et rejeu.
    pub payload: serde_json::Value,
    /// Métadonnées de l'événement.
    pub metadata: serde_json::Value,
    /// Indique si la dead letter a été rejouée.
    pub replayed: bool,
    /// Horodatage UTC du rejeu.
    pub replayed_at: Option<Datetime>,
    /// Horodatage UTC d'épuisement des tentatives.
    pub exhausted_at: Datetime,
}
