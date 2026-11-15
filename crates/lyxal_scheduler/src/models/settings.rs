//! Réglages du planificateur (`fn::scheduler_settings_*`).

use lyxal_surreal::SurrealValue;

use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId};

/// Paramètres de `fn::scheduler_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_settings_set` : un champ fourni est remplacé, un champ nommé
/// dans `clear` est effacé, les autres sont conservés.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsSetParams {
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Fenêtre de rattrapage (1 min à 30 jours).
    pub catchup_window: Option<SchedulerDuration>,
    /// Conservation des exécutions terminées (1 à 3650 jours).
    pub run_retention: Option<SchedulerDuration>,
    /// Exécutions terminées toujours gardées par planification (0 à 1000).
    pub keep_last_runs: Option<i64>,
    /// Exécutions simultanées d'une organisation dans une file (1 à 10000).
    pub tenant_concurrency: Option<i64>,
    /// Planifications par organisation.
    pub max_schedules: Option<i64>,
    /// Exécutions en attente par organisation.
    pub max_pending_runs: Option<i64>,
    /// Taille maximale des arguments, en octets (256 à 1 Mio).
    pub max_args_bytes: Option<i64>,
    /// Champs à effacer (noms des champs ci-dessus).
    pub clear: Option<Vec<String>>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Réglages enregistrés d'une portée (`scheduler_settings`) ; un champ absent prend la valeur de
/// l'installation, puis la valeur par défaut.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct StoredSettings {
    /// Identifiant (`scheduler_settings:<portée>`).
    pub id: SchedulerRecordId,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Fenêtre de rattrapage.
    pub catchup_window: Option<SchedulerDuration>,
    /// Conservation des exécutions terminées.
    pub run_retention: Option<SchedulerDuration>,
    /// Exécutions terminées toujours gardées par planification.
    pub keep_last_runs: Option<i64>,
    /// Exécutions simultanées d'une organisation dans une file.
    pub tenant_concurrency: Option<i64>,
    /// Planifications par organisation.
    pub max_schedules: Option<i64>,
    /// Exécutions en attente par organisation.
    pub max_pending_runs: Option<i64>,
    /// Taille maximale des arguments, en octets.
    pub max_args_bytes: Option<i64>,
    /// Dernière modification.
    pub updated_at: SchedulerDatetime,
}

/// Réglages effectifs d'une portée (organisation, sinon installation, sinon défaut).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Settings {
    /// Fenêtre de rattrapage.
    pub catchup_window: SchedulerDuration,
    /// Conservation des exécutions terminées.
    pub run_retention: SchedulerDuration,
    /// Exécutions terminées toujours gardées par planification.
    pub keep_last_runs: i64,
    /// Exécutions simultanées d'une organisation dans une file.
    pub tenant_concurrency: i64,
    /// Planifications par organisation.
    pub max_schedules: i64,
    /// Exécutions en attente par organisation.
    pub max_pending_runs: i64,
    /// Taille maximale des arguments, en octets.
    pub max_args_bytes: i64,
}

/// Résultat de `fn::scheduler_settings_get` et `fn::scheduler_settings_set`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SettingsResult {
    /// Réglages enregistrés de la portée (absents : aucun).
    pub own: Option<StoredSettings>,
    /// Réglages effectifs.
    pub effective: Settings,
}
