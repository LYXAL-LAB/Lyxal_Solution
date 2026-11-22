// SPDX-License-Identifier: AGPL-3.0-only

//! Comptes, quotas, adresses et alias (`fn::mail_account_*`, `fn::mail_quota_get`,
//! `fn::mail_address_*`).

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Compte de courrier d'un membre.
#[derive(Debug, Clone, SurrealValue)]
pub struct Account {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Identité titulaire.
    pub identity: Option<MailRecordId>,
    /// État : `active`, `disabled` ou `deleting`.
    pub state: String,
    /// Adresse principale.
    pub primary_address: Option<MailRecordId>,
    /// Quota propre du compte, en octets.
    pub quota_bytes: Option<i64>,
    /// Premier refus pour quota depuis le dernier passage sous le quota.
    pub quota_exceeded_at: Option<MailDatetime>,
    /// Messages du compte.
    pub message_count: i64,
    /// Volume des messages, en octets.
    pub used_bytes: i64,
    /// Numéro de modification du compte.
    pub modseq: i64,
    /// Prochaine `UIDVALIDITY`.
    pub uid_validity_next: i64,
    /// Plancher des changements (effacements purgés jusqu'à ce numéro).
    pub changes_floor: i64,
    /// Dossiers du compte.
    pub mailbox_count: i64,
    /// Adresses du compte.
    pub address_count: i64,
    /// Quota effectif (rendu par `fn::mail_account_get` ; absent : sans quota).
    pub effective_quota_bytes: Option<i64>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Adresse d'un compte ou alias.
#[derive(Debug, Clone, SurrealValue)]
pub struct Address {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Domaine de courrier.
    pub domain: MailRecordId,
    /// Partie locale (minuscules).
    pub local_part: String,
    /// Adresse complète.
    pub address: String,
    /// `account` ou `alias`.
    pub kind: String,
    /// Compte d'une adresse `account`.
    pub account: Option<MailRecordId>,
    /// Comptes visés par un alias.
    pub targets: Vec<MailRecordId>,
    /// État : `active` ou `disabled`.
    pub state: String,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_account_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountCreateParams {
    /// Identité membre de l'organisation (`auth_identity:<clé>`).
    pub identity: String,
    /// Domaine de l'adresse principale (`mail_domain:<clé>`).
    pub domain: String,
    /// Partie locale de l'adresse principale (ASCII).
    pub local_part: String,
    /// Quota propre du compte, en octets.
    pub quota_bytes: Option<i64>,
}

/// Résultat de `fn::mail_account_create` : compte et adresse principale (six dossiers créés
/// ensemble).
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountCreated {
    /// Compte.
    pub account: Account,
    /// Adresse principale.
    pub address: Address,
}

/// Paramètres de `fn::mail_account_get` et `fn::mail_quota_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AccountGetParams {
    /// Compte (absent : celui de la session).
    pub account: Option<String>,
}

/// Paramètres de `fn::mail_account_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountRefParams {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
}

/// Paramètres de `fn::mail_account_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AccountListParams {
    /// Organisation (absente : celle de la session).
    pub tenant: Option<String>,
    /// État des comptes listés.
    pub state: Option<String>,
    /// Curseur : identifiant du dernier compte de la page précédente.
    pub after: Option<String>,
    /// Comptes au plus (50 par défaut, 200 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_account_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountList {
    /// Comptes, triés par identifiant.
    pub items: Vec<Account>,
    /// Curseur de la page suivante, absent à la fin.
    pub next: Option<String>,
}

/// Paramètres de `fn::mail_account_update` : un champ absent est conservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountUpdateParams {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// État : `active` ou `disabled`.
    pub state: Option<String>,
    /// Quota propre du compte, en octets.
    pub quota_bytes: Option<i64>,
    /// Champs à effacer (`quota_bytes`).
    pub clear: Vec<String>,
}

/// Ressource de quota (RFC 9208).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct QuotaResource {
    /// `STORAGE` ou `MESSAGE`.
    pub name: String,
    /// Usage.
    pub usage: i64,
    /// Limite (absente : sans limite).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_quota_get`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct Quota {
    /// Volume des messages, en octets.
    pub used_bytes: i64,
    /// Messages du compte.
    pub message_count: i64,
    /// Quota effectif, en octets (absent : sans quota).
    pub quota_bytes: Option<i64>,
    /// Ressources `STORAGE` et `MESSAGE`.
    pub resources: Vec<QuotaResource>,
}

/// Paramètres de `fn::mail_address_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressCreateParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: String,
    /// Partie locale (ASCII).
    pub local_part: String,
    /// `account` (avec `account`) ou `alias` (avec `targets`).
    pub kind: String,
    /// Compte d'une adresse `account`.
    pub account: Option<String>,
    /// Comptes visés par un alias (1 à 50).
    pub targets: Option<Vec<String>>,
}

/// Paramètres de `fn::mail_address_update` : un champ absent est conservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressUpdateParams {
    /// Adresse (`mail_address:<clé>`).
    pub address: String,
    /// État : `active` ou `disabled`.
    pub state: Option<String>,
    /// Comptes visés (alias seulement).
    pub targets: Option<Vec<String>>,
}

/// Paramètres de `fn::mail_address_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressRefParams {
    /// Adresse (`mail_address:<clé>`).
    pub address: String,
}

/// Paramètres de `fn::mail_address_list` : adresses d'un domaine ou d'un compte.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AddressListParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: Option<String>,
    /// Compte (`mail_account:<clé>`).
    pub account: Option<String>,
    /// Curseur : dernière adresse de la page précédente.
    pub after: Option<String>,
    /// Adresses au plus (50 par défaut, 200 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_address_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressList {
    /// Adresses, triées.
    pub items: Vec<Address>,
    /// Curseur de la page suivante, absent à la fin.
    pub next: Option<String>,
}

/// Paramètres de `fn::mail_address_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressResolveParams {
    /// Adresse du destinataire.
    pub address: String,
}

/// Résultat de `fn::mail_address_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ResolvedRecipient {
    /// Comptes actifs qui reçoivent le message.
    pub accounts: Vec<MailRecordId>,
    /// Adresse inscrite qui a servi.
    pub address: String,
}
