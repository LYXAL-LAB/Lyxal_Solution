// SPDX-License-Identifier: AGPL-3.0-only

//! Domaines de courrier (`fn::mail_domain_*`).

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Domaine de courrier.
#[derive(Debug, Clone, SurrealValue)]
pub struct Domain {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Domaine vérifié de `lyxal_auth`.
    pub auth_domain: MailRecordId,
    /// Nom (forme ASCII, minuscules).
    pub name: String,
    /// État : `active` ou `disabled`.
    pub state: String,
    /// Séparateur de sous-adresse (`+`), absent : aucun.
    pub subaddress_separator: Option<String>,
    /// Adresses et alias du domaine (compteur tenu).
    pub address_count: i64,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_domain_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainCreateParams {
    /// Domaine vérifié de l'organisation (`auth_organization_domain:<clé>`).
    pub auth_domain: String,
    /// Séparateur de sous-adresse : `+` (par défaut) ou `none`.
    pub subaddress_separator: Option<String>,
}

/// Paramètres de `fn::mail_domain_get` et `fn::mail_domain_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainRefParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: String,
}

/// Paramètres de `fn::mail_domain_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct DomainListParams {
    /// Organisation (absente : celle de la session).
    pub tenant: Option<String>,
    /// Curseur : nom du dernier domaine de la page précédente.
    pub after: Option<String>,
    /// Domaines au plus (50 par défaut, 200 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_domain_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainList {
    /// Domaines, triés par nom.
    pub items: Vec<Domain>,
    /// Curseur de la page suivante, absent à la fin.
    pub next: Option<String>,
}

/// Paramètres de `fn::mail_domain_update` : un champ absent est conservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainUpdateParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: String,
    /// État : `active` ou `disabled`.
    pub state: Option<String>,
    /// Séparateur de sous-adresse : `+` ou `none`.
    pub subaddress_separator: Option<String>,
}

/// Résultat d'une suppression.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct Deleted {
    /// Fiche supprimée.
    pub deleted: bool,
}
