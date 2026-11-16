//! Diffusions traitées par le worker (`fn::notification_broadcast_*`).

use lyxal_surreal::SurrealValue;

use super::types::NotificationRecordId;

/// Paramètres de `fn::notification_broadcast_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BroadcastClaimParams {
    /// Identifiant du worker.
    pub worker_id: String,
    /// Durée de la réservation en secondes (10 à 3600), renouvelée à chaque paquet.
    pub lease_seconds: i64,
}

/// Diffusion réservée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct BroadcastClaim {
    /// Diffusion.
    pub broadcast_id: NotificationRecordId,
    /// Jeton de réservation.
    pub claim_token: String,
}

/// Paramètres de `fn::notification_broadcast_step`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BroadcastStepParams {
    /// Diffusion (`notification_broadcast:<clé>`).
    pub broadcast_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Destinataires par paquet (500 au plus).
    pub size: i64,
    /// Durée de la réservation renouvelée, en secondes.
    pub lease_seconds: i64,
}

/// Résultat de `fn::notification_broadcast_step`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct BroadcastStep {
    /// Destinataires examinés.
    pub processed: i64,
    /// Déclenchements créés.
    pub created: i64,
    /// Destinataires écartés.
    pub skipped: i64,
    /// Tous les destinataires ont été traités.
    pub done: bool,
}

/// Paramètres de `fn::notification_broadcast_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BroadcastCompleteParams {
    /// Diffusion.
    pub broadcast_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
}

/// Résultat de `fn::notification_broadcast_complete`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct BroadcastCompleted {
    /// État (`completed`).
    pub status: String,
    /// Destinataires examinés.
    pub processed: i64,
    /// Déclenchements créés.
    pub created: i64,
    /// Destinataires écartés.
    pub skipped: i64,
}
