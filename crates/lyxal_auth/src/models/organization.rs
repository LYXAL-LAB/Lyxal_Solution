//! Organisations et adhésions.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId, AuthValue};

/// État d'une organisation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum OrganizationState {
    /// Active.
    Active,
    /// Suspendue.
    Suspended,
    /// Supprimée (purge différée).
    Deleted,
}

/// Organisation cliente.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Organization {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Identifiant lisible unique.
    pub slug: String,
    /// Nom affiché.
    pub name: String,
    /// Description.
    pub description: Option<String>,
    /// État.
    pub state: OrganizationState,
    /// Image de marque.
    pub branding: AuthValue,
    /// Données libres.
    pub custom_data: AuthValue,
    /// Double facteur exigé.
    pub mfa_required: bool,
    /// Création.
    pub created_at: AuthDatetime,
    /// Dernière modification.
    pub updated_at: AuthDatetime,
}

/// Paramètres de `fn::auth_organization_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct OrganizationCreateParams {
    /// Identifiant lisible (minuscules, chiffres, tirets).
    pub slug: String,
    /// Nom affiché.
    pub name: String,
    /// Description.
    pub description: Option<String>,
    /// Double facteur exigé.
    pub mfa_required: Option<bool>,
    /// Identité qui devient membre administrateur (texte `auth_identity:<clé>`).
    pub owner: Option<String>,
}

/// Paramètres de `fn::auth_organization_get` : identifiant ou slug.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct OrganizationGetParams {
    /// Organisation (texte `auth_organization:<clé>`).
    pub organization: Option<String>,
    /// Slug.
    pub slug: Option<String>,
}

/// Paramètres de `fn::auth_organization_member_add`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MemberAddParams {
    /// Organisation (texte).
    pub organization: String,
    /// Identité (texte).
    pub identity: String,
    /// Rôles d'organisation en plus des rôles par défaut (textes `auth_role:<clé>`).
    pub roles: Vec<String>,
}

/// Résultat de `fn::auth_organization_member_add`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MemberAdded {
    /// Adhésion créée (`auth_member_of`).
    pub membership: AuthRecordId,
    /// Rôles de l'adhésion.
    pub roles: Vec<AuthRecordId>,
}

/// Paramètres de `fn::auth_organization_member_remove`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MemberRemoveParams {
    /// Organisation (texte).
    pub organization: String,
    /// Identité (texte).
    pub identity: String,
}

/// Résultat de `fn::auth_organization_member_remove`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MemberRemoved {
    /// Adhésion retirée.
    pub removed: bool,
    /// Adhésion supprimée.
    pub membership: AuthRecordId,
}
