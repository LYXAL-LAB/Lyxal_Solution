//! Permissions et rôles.

use lyxal_surreal::SurrealValue;

use super::types::{AuthRecordId, AuthValue};

/// Portée d'une permission ou d'un rôle.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum PermissionScope {
    /// Installation (attribuée à une identité).
    Installation,
    /// Organisation (attribuée à une adhésion).
    Organization,
}

/// Paramètres de `fn::auth_permission_register` (création seule, rejouable).
#[derive(Debug, Clone, SurrealValue)]
pub struct PermissionRegisterParams {
    /// Code (`module.objet.action`).
    pub code: String,
    /// Module déclarant.
    pub module: String,
    /// Portée.
    pub scope: PermissionScope,
    /// Description par langue (`{ fr, en }`).
    pub description: AuthValue,
}

/// Résultat de `fn::auth_permission_register`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PermissionRegistered {
    /// Code.
    pub code: String,
    /// Portée.
    pub scope: PermissionScope,
    /// Vrai si la permission vient d'être créée.
    pub created: bool,
}

/// Paramètres de `fn::auth_role_assign` et `fn::auth_role_unassign`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RoleAssignParams {
    /// Rôle (texte `auth_role:<clé>`).
    pub role: String,
    /// Identité (texte).
    pub identity: String,
    /// Organisation, pour un rôle d'organisation (texte).
    pub organization: Option<String>,
}

/// Résultat de `fn::auth_role_assign`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RoleAssigned {
    /// Titulaire : identité ou adhésion.
    pub holder: AuthRecordId,
    /// Rôle.
    pub role: AuthRecordId,
    /// Faux si le rôle était déjà attribué.
    pub assigned: bool,
}

/// Résultat de `fn::auth_role_unassign`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RoleUnassigned {
    /// Titulaire.
    pub holder: AuthRecordId,
    /// Rôle.
    pub role: AuthRecordId,
    /// Faux si le rôle n'était pas attribué.
    pub unassigned: bool,
}

/// Paramètres de `fn::auth_identity_permissions`.
#[derive(Debug, Clone, SurrealValue)]
pub struct IdentityPermissionsParams {
    /// Identité (texte).
    pub identity: String,
    /// Organisation (texte), pour inclure les permissions de l'adhésion.
    pub organization: Option<String>,
}

/// Permissions effectives d'une identité (rôles inclus compris).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct IdentityPermissions {
    /// Identité.
    pub identity: AuthRecordId,
    /// Organisation prise en compte.
    pub organization: Option<AuthRecordId>,
    /// Permissions d'installation.
    pub installation: Vec<String>,
    /// Permissions de l'adhésion à l'organisation.
    pub organization_permissions: Vec<String>,
    /// Union triée (claim `permissions` du jeton, lot 3).
    pub permissions: Vec<String>,
    /// Version des droits (claim `pv`).
    pub version: i64,
}
