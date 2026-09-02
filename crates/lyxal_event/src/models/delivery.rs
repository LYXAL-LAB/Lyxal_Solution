use super::envelope::EventContext;
use serde::{Deserialize, Serialize};
use surrealdb::sql::{Datetime, Thing as RecordId};

/// Statut du cycle de vie d'une livraison d'événement.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DeliveryStatus {
    /// En attente d'acquisition par un worker.
    Pending,
    /// En cours de traitement par un worker détenant le bail.
    Processing,
    /// Livré et acquitté avec succès.
    Delivered,
    /// En échec temporaire, en attente de retry après backoff.
    Failed,
    /// Rejeté en Dead-Letter après épuisement des tentatives.
    DeadLetter,
}

/// Enregistrement de distribution unitaire pour un événement et un abonnement.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventDelivery {
    /// Identifiant de l'enregistrement dans la table event_delivery.
    pub id: RecordId,
    /// Référence à l'événement parent dans l'outbox.
    pub outbox_event: RecordId,
    /// Référence à l'abonnement destinataire.
    pub subscription: RecordId,
    /// Module destinataire.
    pub target_module: String,
    /// Contexte d'isolation de l'instance.
    pub context: EventContext,
    /// Statut actuel de la livraison.
    pub status: DeliveryStatus,
    /// Nombre de tentatives déjà consommées.
    pub attempts: u32,
    /// Nombre maximal d'essais.
    pub max_attempts: u32,
    /// Prochaine tentative éligible.
    pub next_retry_at: Datetime,
    /// Horodatage d'expiration du bail actif.
    pub locked_until: Option<Datetime>,
    /// Identifiant du worker détenant le bail.
    pub lease_owner: Option<String>,
    /// Dernier message d'erreur capturé.
    pub last_error: Option<String>,
    /// Horodatage de livraison réussie.
    pub delivered_at: Option<Datetime>,
    /// Horodatage de création de la livraison.
    pub created_at: Datetime,
}
