// SPDX-License-Identifier: AGPL-3.0-only

//! Contenus des messages (chemin de dépôt) et maintenance (`fn::mail_content_*`,
//! `fn::mail_tombstone_purge`, `fn::mail_account_purge_step`).

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Paramètres de `fn::mail_content_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ContentBeginParams {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// Taille du message en clair, en octets.
    pub size: i64,
    /// Protection (`platform` seul au lot 4).
    pub protection: Option<String>,
}

/// Résultat de `fn::mail_content_begin` : contenu réservé et fichier à écrire.
#[derive(Debug, Clone, SurrealValue)]
pub struct ContentReservation {
    /// Contenu `pending`.
    pub content: MailRecordId,
    /// Clé du fichier dans le bucket (`<compte>/<UUID v7>.eml`, sans donnée personnelle).
    pub key: String,
    /// Nom du bucket chiffré de l'organisation (`lyxal-mail`).
    pub bucket_name: String,
    /// Taille maximale d'un message, en octets.
    pub max_size: i64,
    /// Organisation du compte.
    pub tenant: MailRecordId,
    /// Fin du délai d'abandon.
    pub expires_at: MailDatetime,
}

/// Contenu d'un message.
#[derive(Debug, Clone, SurrealValue)]
pub struct Content {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Compte.
    pub account: MailRecordId,
    /// Clé du fichier dans le bucket.
    pub key: String,
    /// Fichier de `lyxal_storage`.
    pub object: Option<MailRecordId>,
    /// État : `pending`, `stored` ou `released`.
    pub state: String,
    /// Taille en clair, en octets.
    pub size: i64,
    /// Protection.
    pub protection: String,
    /// Empreinte de la clé de l'utilisateur (niveaux B et C).
    pub key_fingerprint: Option<String>,
    /// Messages qui lisent ce contenu.
    pub refs: i64,
    /// Fin du délai d'abandon.
    pub expires_at: Option<MailDatetime>,
}

/// Paramètres de `fn::mail_content_attach`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ContentAttachParams {
    /// Contenu `pending` (`mail_content:<clé>`).
    pub content: String,
    /// Fichier écrit (`storage_object:<clé>`).
    pub object: String,
}

/// Résultat de `fn::mail_content_open` : fichier à lire.
#[derive(Debug, Clone, SurrealValue)]
pub struct ContentLocation {
    /// Fichier de `lyxal_storage`.
    pub object: MailRecordId,
    /// Taille en clair, en octets.
    pub size: i64,
    /// Protection.
    pub protection: String,
    /// Empreinte de la clé de l'utilisateur (niveaux B et C).
    pub key_fingerprint: Option<String>,
}

/// Paramètres des opérations de maintenance.
#[derive(Debug, Clone, Copy, Default, SurrealValue)]
pub struct MaintenanceParams {
    /// Éléments traités au plus par appel (valeur de la fonction par défaut).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_content_expire`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct ContentExpired {
    /// Contenus abandonnés retirés avec leur fichier.
    pub expired: i64,
    /// Contenus libérés (plus aucun lecteur) retirés avec leur fichier.
    pub released: i64,
}

/// Résultat de `fn::mail_tombstone_purge`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct TombstonesPurged {
    /// Pierres tombales retirées.
    pub purged: i64,
}

/// Résultat de `fn::mail_account_purge_step`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct AccountPurgeStep {
    /// Comptes purgés.
    pub accounts: i64,
    /// Messages retirés.
    pub messages: i64,
    /// Plus aucun compte à purger.
    pub done: bool,
}
