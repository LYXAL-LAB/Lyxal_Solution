//! Réglages du coffre-fort (`fn::secrets_settings_get`, `fn::secrets_settings_set`).

use lyxal_surreal::SurrealValue;

use super::types::{SecretsDatetime, SecretsRecordId};

/// Paramètres de `fn::secrets_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// Réglages enregistrés pour une portée (un champ absent prend la valeur de repli).
#[derive(Debug, Clone, SurrealValue)]
pub struct StoredSettings {
    /// Ligne de réglages.
    pub id: SecretsRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<SecretsRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Versions conservées par secret.
    pub max_versions: Option<i64>,
    /// Délai avant la purge d'un secret supprimé, en jours.
    pub deleted_retention_days: Option<i64>,
    /// Protection contre la purge anticipée (irréversible).
    pub purge_protection: Option<bool>,
    /// Taille maximale d'une valeur, en octets.
    pub max_value_bytes: Option<i64>,
    /// Visibilité par défaut d'un nouveau secret (`restricted`, `revealable`).
    pub default_visibility: Option<String>,
    /// Alerte avant échéance, en jours.
    pub expiry_warning_days: Option<i64>,
    /// Dernière modification.
    pub updated_at: SecretsDatetime,
}

/// Réglages effectifs d'une portée (organisation, sinon installation, sinon valeurs par défaut).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct EffectiveSettings {
    /// Versions conservées par secret.
    pub max_versions: i64,
    /// Délai avant la purge d'un secret supprimé, en jours.
    pub deleted_retention_days: i64,
    /// Protection contre la purge anticipée.
    pub purge_protection: bool,
    /// Taille maximale d'une valeur, en octets.
    pub max_value_bytes: i64,
    /// Visibilité par défaut d'un nouveau secret.
    pub default_visibility: String,
    /// Alerte avant échéance, en jours.
    pub expiry_warning_days: i64,
}

/// Résultat de `fn::secrets_settings_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SettingsView {
    /// Réglages propres à la portée, s'ils existent.
    pub own: Option<StoredSettings>,
    /// Réglages effectifs.
    pub effective: EffectiveSettings,
}

/// Paramètres de `fn::secrets_settings_set` : un champ fourni est remplacé, un champ nommé dans
/// `clear` est effacé, les autres sont conservés.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsSetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Versions conservées par secret (1 à 100).
    pub max_versions: Option<i64>,
    /// Délai avant la purge d'un secret supprimé, en jours (7 à 90).
    pub deleted_retention_days: Option<i64>,
    /// Protection contre la purge anticipée (irréversible une fois activée).
    pub purge_protection: Option<bool>,
    /// Taille maximale d'une valeur, en octets (1 Mio au plus).
    pub max_value_bytes: Option<i64>,
    /// Visibilité par défaut d'un nouveau secret.
    pub default_visibility: Option<String>,
    /// Alerte avant échéance, en jours.
    pub expiry_warning_days: Option<i64>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}
