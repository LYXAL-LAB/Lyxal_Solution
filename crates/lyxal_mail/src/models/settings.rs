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
    /// Destinataires d'un message déposé, au plus (1 à 1 000).
    pub send_recipients_per_message: Option<i64>,
    /// Messages déposés par un compte et par jour UTC (1 à 1 000 000).
    pub send_messages_per_day: Option<i64>,
    /// Destinataires des messages d'un compte par jour UTC (1 à 10 000 000).
    pub send_recipients_per_day: Option<i64>,
    /// Messages des modules d'une organisation par heure UTC (1 à 10 000 000).
    pub module_messages_per_hour: Option<i64>,
    /// Transferts d'alias vers l'extérieur d'une organisation par jour UTC (0 à 10 000 000).
    pub forward_messages_per_day: Option<i64>,
    /// Installation seulement : délais entre deux essais, en minutes (le dernier se répète).
    pub retry_intervals: Option<Vec<i64>>,
    /// Installation seulement : décalage aléatoire des délais, en pour cent (0 à 50).
    pub retry_jitter_percent: Option<i64>,
    /// Installation seulement : âge en file qui donne l'avis de retard, en heures (1 à 72).
    pub delay_notice_hours: Option<i64>,
    /// Installation seulement : durée de vie d'un envoi en file, en heures (1 à 720).
    pub expire_hours: Option<i64>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Réglages effectifs d'une portée (organisation, sinon installation, sinon valeurs par défaut).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
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
    /// Destinataires d'un message déposé (plafonné par l'installation).
    pub send_recipients_per_message: i64,
    /// Messages déposés par un compte et par jour UTC.
    pub send_messages_per_day: i64,
    /// Destinataires des messages d'un compte par jour UTC.
    pub send_recipients_per_day: i64,
    /// Messages des modules de l'organisation par heure UTC.
    pub module_messages_per_hour: i64,
    /// Transferts d'alias vers l'extérieur de l'organisation par jour UTC.
    pub forward_messages_per_day: i64,
    /// Délais entre deux essais, en minutes (installation).
    pub retry_intervals: Vec<i64>,
    /// Décalage aléatoire des délais, en pour cent (installation).
    pub retry_jitter_percent: i64,
    /// Âge en file qui donne l'avis de retard, en heures (installation).
    pub delay_notice_hours: i64,
    /// Durée de vie d'un envoi en file, en heures (installation).
    pub expire_hours: i64,
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
    /// Destinataires d'un message déposé, au plus (1 à 1 000).
    pub send_recipients_per_message: Option<i64>,
    /// Messages déposés par un compte et par jour UTC (1 à 1 000 000).
    pub send_messages_per_day: Option<i64>,
    /// Destinataires des messages d'un compte par jour UTC (1 à 10 000 000).
    pub send_recipients_per_day: Option<i64>,
    /// Messages des modules d'une organisation par heure UTC (1 à 10 000 000).
    pub module_messages_per_hour: Option<i64>,
    /// Transferts d'alias vers l'extérieur d'une organisation par jour UTC (0 à 10 000 000).
    pub forward_messages_per_day: Option<i64>,
    /// Installation seulement : délais entre deux essais, en minutes (le dernier se répète).
    pub retry_intervals: Option<Vec<i64>>,
    /// Installation seulement : décalage aléatoire des délais, en pour cent (0 à 50).
    pub retry_jitter_percent: Option<i64>,
    /// Installation seulement : âge en file qui donne l'avis de retard, en heures (1 à 72).
    pub delay_notice_hours: Option<i64>,
    /// Installation seulement : durée de vie d'un envoi en file, en heures (1 à 720).
    pub expire_hours: Option<i64>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}
