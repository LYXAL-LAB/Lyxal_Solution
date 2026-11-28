//! Réglages (`fn::infra_settings_get`, `fn::infra_settings_update`).

use lyxal_surreal::SurrealValue;

/// Paramètres de `fn::infra_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Langue des messages d'erreur (`fr` par défaut).
    pub language: Option<String>,
}

/// Paramètres de `fn::infra_settings_update` : un champ absent est conservé.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsUpdateParams {
    /// Intervalle entre deux passes d'une zone, en minutes (1 à 1 440).
    pub reconcile_minutes: Option<i64>,
    /// Durée de vie par défaut, en secondes (60 à 86 400, au moins `min_ttl`).
    pub default_ttl: Option<i64>,
    /// Durée de vie minimale acceptée, en secondes.
    pub min_ttl: Option<i64>,
    /// Suppressions au-delà desquelles un plan est bloqué.
    pub max_deletions: Option<i64>,
    /// Part des enregistrements de Lyxal, en pour cent, au-delà de laquelle un plan est bloqué.
    pub max_deletion_percent: Option<i64>,
    /// Délai de vérification de la publication, en heures.
    pub verify_timeout_hours: Option<i64>,
    /// Débit des appels à l'hébergeur, par compte et par seconde.
    pub requests_per_second: Option<i64>,
    /// Conservation du journal, en jours.
    pub change_retention_days: Option<i64>,
    /// Conservation d'un enregistrement retiré, en jours.
    pub released_retention_days: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Réglages effectifs (résultat de `fn::infra_settings_get` et `fn::infra_settings_update`).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct SettingsResult {
    /// Intervalle entre deux passes d'une zone, en minutes.
    pub reconcile_minutes: i64,
    /// Durée de vie par défaut, en secondes.
    pub default_ttl: i64,
    /// Durée de vie minimale acceptée, en secondes.
    pub min_ttl: i64,
    /// Suppressions au-delà desquelles un plan est bloqué.
    pub max_deletions: i64,
    /// Part des enregistrements de Lyxal au-delà de laquelle un plan est bloqué, en pour cent.
    pub max_deletion_percent: i64,
    /// Délai de vérification de la publication, en heures.
    pub verify_timeout_hours: i64,
    /// Débit des appels à l'hébergeur, par compte et par seconde.
    pub requests_per_second: i64,
    /// Conservation du journal, en jours.
    pub change_retention_days: i64,
    /// Conservation d'un enregistrement retiré, en jours.
    pub released_retention_days: i64,
}
