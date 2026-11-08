//! Domaines e-mail vérifiés d'une organisation.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId};

/// Paramètres de `fn::auth_organization_domain_add` (construits par `DomainVerifier`).
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainAddParams {
    /// Organisation (texte).
    pub organization: String,
    /// Domaine.
    pub domain: String,
    /// Empreinte BLAKE3 (hex) du jeton de défi.
    pub challenge_hash: String,
}

/// Domaine déclaré, renvoyé par `fn::auth_organization_domain_add`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct OrganizationDomainCreated {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Domaine normalisé.
    pub domain: String,
    /// Nom de l'enregistrement TXT à publier.
    pub txt_record: String,
}

/// Paramètres de `fn::auth_organization_domain_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainVerifyParams {
    /// Domaine (texte `auth_organization_domain:<clé>`).
    pub domain: String,
    /// Empreintes BLAKE3 (hex) des enregistrements TXT lus.
    pub observed_hashes: Vec<String>,
}

/// Paramètres de `fn::auth_organization_domain_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DomainGetParams {
    /// Domaine (texte `auth_organization_domain:<clé>`).
    pub domain: String,
}

/// Domaine d'une organisation (sans empreinte de défi).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct OrganizationDomain {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Organisation.
    pub organization: AuthRecordId,
    /// Domaine.
    pub domain: String,
    /// `pending` ou `verified`.
    pub state: String,
    /// Date de vérification.
    pub verified_at: Option<AuthDatetime>,
    /// Rattachement automatique.
    pub auto_join: bool,
}
