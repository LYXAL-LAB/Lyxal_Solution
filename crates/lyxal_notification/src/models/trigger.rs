//! Déclenchement d'un parcours (`fn::notification_trigger`).

use lyxal_surreal::SurrealValue;

use super::types::{NotificationDatetime, NotificationRecordId};

/// Destinataire d'un parcours.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Recipient {
    /// Adresse e-mail (normalisée par la base).
    pub email: String,
    /// Langue préférée (BCP 47).
    pub locale: Option<String>,
    /// Nom affiché.
    pub name: Option<String>,
}

/// Paramètres de `fn::notification_trigger`. Les identifiants transmis sont des textes
/// `table:clé` (règle `record` de `lyxal_core`).
#[derive(Clone, SurrealValue)]
pub struct TriggerParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du parcours (ou `trigger_event`).
    pub workflow_key: Option<String>,
    /// Type d'événement déclencheur (ou `workflow_key`).
    pub trigger_event: Option<String>,
    /// Clé d'idempotence (identifiant d'événement ou clé fournie).
    pub idempotency_key: String,
    /// Événement d'origine.
    pub event_id: Option<String>,
    /// Destinataire.
    pub recipient: Recipient,
    /// Variables non sensibles (objet JSON).
    pub payload: serde_json::Value,
    /// Variables sensibles scellées sous le contexte du module (`enc:v2`).
    pub secret: Option<String>,
    /// Fin de validité du secret.
    pub expires_at: Option<NotificationDatetime>,
}

impl std::fmt::Debug for TriggerParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TriggerParams")
            .field("tenant", &self.tenant)
            .field("workflow_key", &self.workflow_key)
            .field("trigger_event", &self.trigger_event)
            .field("idempotency_key", &self.idempotency_key)
            .field("event_id", &self.event_id)
            .field("recipient", &self.recipient)
            .field("secret", &self.secret.as_ref().map(|_| "[REDACTED]"))
            .field("expires_at", &self.expires_at)
            .finish_non_exhaustive()
    }
}

/// Issue d'un déclenchement.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum TriggerStatus {
    /// Déclenchement créé, étapes en file.
    Created,
    /// Clé déjà utilisée : déclenchement existant renvoyé.
    Duplicate,
    /// Adresse supprimée : déclenchement abandonné.
    Skipped,
}

/// Résultat de `fn::notification_trigger`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TriggerResult {
    /// Déclenchement.
    pub run_id: NotificationRecordId,
    /// Issue.
    pub status: TriggerStatus,
    /// Motif d'abandon (`suppressed:<motif>`).
    pub skip_reason: Option<String>,
    /// Étapes créées (ou existantes pour un rejeu).
    pub job_ids: Vec<NotificationRecordId>,
}
