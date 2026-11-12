//! Réglages du stockage (`fn::storage_settings_get`, `fn::storage_settings_set`).

use lyxal_surreal::SurrealValue;

use super::types::{StorageDatetime, StorageRecordId};

/// Paramètres de `fn::storage_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// Réglages enregistrés pour une portée (un champ absent prend la valeur de repli).
#[derive(Debug, Clone, SurrealValue)]
pub struct StoredSettings {
    /// Ligne de réglages.
    pub id: StorageRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: Option<i64>,
    /// Volume maximal de la portée, en octets.
    pub quota_bytes: Option<i64>,
    /// Délai d'une écriture en attente, en secondes.
    pub pending_ttl_seconds: Option<i64>,
    /// Conservation d'un fichier supprimé, en jours.
    pub deleted_retention_days: Option<i64>,
    /// Dernière modification.
    pub updated_at: StorageDatetime,
}

/// Réglages effectifs d'une portée (organisation, sinon installation, sinon valeurs par défaut).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct EffectiveSettings {
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: i64,
    /// Volume maximal de la portée, en octets (absent : sans quota).
    pub quota_bytes: Option<i64>,
    /// Délai d'une écriture en attente, en secondes.
    pub pending_ttl_seconds: i64,
    /// Conservation d'un fichier supprimé, en jours.
    pub deleted_retention_days: i64,
}

/// Résultat de `fn::storage_settings_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SettingsView {
    /// Réglages propres à la portée, s'ils existent.
    pub own: Option<StoredSettings>,
    /// Réglages effectifs.
    pub effective: EffectiveSettings,
}

/// Paramètres de `fn::storage_settings_set` : un champ fourni est remplacé, un champ nommé dans
/// `clear` est effacé, les autres sont conservés.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsSetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: Option<i64>,
    /// Volume maximal de la portée, en octets.
    pub quota_bytes: Option<i64>,
    /// Délai d'une écriture en attente, en secondes.
    pub pending_ttl_seconds: Option<i64>,
    /// Conservation d'un fichier supprimé, en jours.
    pub deleted_retention_days: Option<i64>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}
