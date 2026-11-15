//! Journal des actions (`fn::scheduler_audit_list`).

use lyxal_surreal::SurrealValue;

use super::types::{SchedulerDatetime, SchedulerRecordId, SchedulerValue};

/// Paramètres de `fn::scheduler_audit_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AuditListParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Planification.
    pub schedule: Option<SchedulerRecordId>,
    /// Action (`schedule.create`, `run.cancel`…).
    pub action: Option<String>,
    /// Date minimale.
    pub since: Option<SchedulerDatetime>,
    /// Taille de la page (500 au plus).
    pub limit: Option<i64>,
    /// Position du premier élément.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Entrée du journal (`scheduler_audit`) ; jamais d'arguments.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AuditEntry {
    /// Identifiant.
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Action.
    pub action: String,
    /// Identité ou application de l'auteur (absente : session système).
    pub actor: Option<String>,
    /// Type de session.
    pub session_kind: Option<String>,
    /// Adresse de la session.
    pub ip: Option<String>,
    /// Planification concernée.
    pub schedule: Option<String>,
    /// Exécution concernée.
    pub run: Option<String>,
    /// Détails.
    pub details: SchedulerValue,
    /// Écriture.
    pub created_at: SchedulerDatetime,
}
