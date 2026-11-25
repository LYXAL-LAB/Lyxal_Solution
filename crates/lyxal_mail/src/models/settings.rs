// SPDX-License-Identifier: AGPL-3.0-only

//! Réglages (`fn::mail_settings_*`).

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Paramètres de `fn::mail_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// Réglages enregistrés d'une portée (un champ absent : valeur de la portée englobante).
#[derive(Debug, Clone, SurrealValue)]
pub struct StoredSettings {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<MailRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Taille maximale d'un message, en octets.
    pub max_message_bytes: Option<i64>,
    /// Quota par défaut d'un compte, en octets.
    pub default_quota_bytes: Option<i64>,
    /// Conservation des effacements, en jours.
    pub tombstone_retention_days: Option<i64>,
    /// Dossiers par compte.
    pub max_mailboxes_per_account: Option<i64>,
    /// Adresses par compte.
    pub max_addresses_per_account: Option<i64>,
    /// Mots-clés par message.
    pub max_keywords_per_message: Option<i64>,
    /// Installation seulement : adresse inscrite qui reçoit le destinataire `postmaster` écrit
    /// sans domaine.
    pub postmaster: Option<String>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Réglages effectifs d'une portée (organisation, sinon installation, sinon valeurs par défaut).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct EffectiveSettings {
    /// Taille maximale d'un message, en octets.
    pub max_message_bytes: i64,
    /// Quota par défaut d'un compte, en octets (absent : sans quota).
    pub default_quota_bytes: Option<i64>,
    /// Conservation des effacements, en jours.
    pub tombstone_retention_days: i64,
    /// Dossiers par compte.
    pub max_mailboxes_per_account: i64,
    /// Adresses par compte.
    pub max_addresses_per_account: i64,
    /// Mots-clés par message.
    pub max_keywords_per_message: i64,
}

/// Résultat de `fn::mail_settings_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SettingsView {
    /// Réglages enregistrés de la portée.
    pub own: Option<StoredSettings>,
    /// Réglages effectifs.
    pub effective: EffectiveSettings,
}

/// Paramètres de `fn::mail_settings_set` : un champ fourni est remplacé, un champ nommé dans
/// `clear` est effacé, les autres sont conservés.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsSetParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Taille maximale d'un message, en octets (1 Kio à 5 Gio).
    pub max_message_bytes: Option<i64>,
    /// Quota par défaut d'un compte, en octets.
    pub default_quota_bytes: Option<i64>,
    /// Conservation des effacements, en jours (7 à 365).
    pub tombstone_retention_days: Option<i64>,
    /// Dossiers par compte (6 à 10 000).
    pub max_mailboxes_per_account: Option<i64>,
    /// Adresses par compte (1 à 1 000).
    pub max_addresses_per_account: Option<i64>,
    /// Mots-clés par message (1 à 1 000).
    pub max_keywords_per_message: Option<i64>,
    /// Installation seulement : adresse inscrite qui reçoit le destinataire `postmaster` écrit
    /// sans domaine (RFC 5321 §4.5.1).
    pub postmaster: Option<String>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}
