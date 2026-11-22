// SPDX-License-Identifier: AGPL-3.0-only

//! Dossiers (`fn::mail_mailbox_*`).

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Dossier d'un compte et ses compteurs.
#[derive(Debug, Clone, SurrealValue)]
pub struct Mailbox {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Compte.
    pub account: MailRecordId,
    /// Dossier parent.
    pub parent: Option<MailRecordId>,
    /// Nom (segment).
    pub name: String,
    /// Chemin complet (`/`).
    pub path: String,
    /// Rôle `SPECIAL-USE` (`inbox`, `drafts`, `sent`, `junk`, `trash`, `archive`).
    pub role: Option<String>,
    /// Abonné.
    pub subscribed: bool,
    /// Ordre d'affichage.
    pub sort_order: i64,
    /// `UIDVALIDITY`.
    pub uid_validity: i64,
    /// Prochain UID.
    pub uid_next: i64,
    /// Numéro de modification du dernier changement du dossier lui-même.
    pub modseq: i64,
    /// `HIGHESTMODSEQ`.
    pub highest_modseq: i64,
    /// Messages.
    pub total: i64,
    /// Messages non lus.
    pub unseen: i64,
    /// Volume, en octets.
    pub size: i64,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_mailbox_create`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MailboxCreateParams {
    /// Compte (absent : celui de la session).
    pub account: Option<String>,
    /// Nom.
    pub name: String,
    /// Dossier parent.
    pub parent: Option<String>,
    /// Rôle (`drafts`, `sent`, `junk`, `trash`, `archive`).
    pub role: Option<String>,
    /// Abonné (vrai par défaut).
    pub subscribed: Option<bool>,
}

/// Paramètres de `fn::mail_mailbox_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MailboxRefParams {
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
}

/// Paramètres de `fn::mail_mailbox_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MailboxListParams {
    /// Compte (absent : celui de la session).
    pub account: Option<String>,
}

/// Paramètres de `fn::mail_mailbox_update` : un champ absent est conservé.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MailboxUpdateParams {
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Nouveau nom.
    pub name: Option<String>,
    /// Nouveau parent.
    pub parent: Option<String>,
    /// Rôle.
    pub role: Option<String>,
    /// Abonné.
    pub subscribed: Option<bool>,
    /// Ordre d'affichage.
    pub sort_order: Option<i64>,
    /// Champs à effacer (`parent`, `role`).
    pub clear: Vec<String>,
}

/// Paramètres de `fn::mail_mailbox_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MailboxDeleteParams {
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Effacer aussi ses messages (5 000 au plus).
    pub remove_messages: bool,
}

/// Résultat de `fn::mail_mailbox_delete`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct MailboxDeleted {
    /// Dossier supprimé.
    pub deleted: bool,
    /// Messages effacés avec lui.
    pub expunged: i64,
}
