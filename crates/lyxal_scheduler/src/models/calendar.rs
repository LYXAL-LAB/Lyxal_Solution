//! Calendriers d'exceptions (`fn::scheduler_calendar_*`).

use lyxal_surreal::SurrealValue;

use super::shared::CalendarRule;
use super::types::{SchedulerDatetime, SchedulerRecordId};

/// Paramètres de `fn::scheduler_calendar_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CalendarCreateParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Nom (slug), unique dans sa portée.
    pub name: String,
    /// Usage du calendrier.
    pub description: Option<String>,
    /// Règles (1 à 100).
    pub rules: Vec<CalendarRule>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_calendar_update` : un champ absent est conservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct CalendarUpdateParams {
    /// Calendrier.
    pub calendar: SchedulerRecordId,
    /// Usage du calendrier.
    pub description: Option<String>,
    /// Nouvelles règles.
    pub rules: Option<Vec<CalendarRule>>,
    /// Champs à effacer (`description`).
    pub clear: Option<Vec<String>>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_calendar_get` et `fn::scheduler_calendar_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CalendarRefParams {
    /// Calendrier.
    pub calendar: SchedulerRecordId,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_calendar_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct CalendarListParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Taille de la page (500 au plus).
    pub limit: Option<i64>,
    /// Position du premier élément.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Calendrier d'exceptions (`scheduler_calendar`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Calendar {
    /// Identifiant.
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Nom (slug).
    pub name: String,
    /// Usage.
    pub description: Option<String>,
    /// Règles.
    pub rules: Vec<CalendarRule>,
    /// Identité qui a créé le calendrier.
    pub created_by: Option<SchedulerRecordId>,
    /// Création.
    pub created_at: SchedulerDatetime,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
    /// Planifications lisibles qui l'utilisent, 100 au plus (`fn::scheduler_calendar_get`
    /// seulement).
    pub schedules: Option<Vec<SchedulerRecordId>>,
}
