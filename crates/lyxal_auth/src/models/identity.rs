//! Identités.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId, AuthValue};

/// État d'une identité.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum IdentityState {
    /// Active.
    Active,
    /// Inactive.
    Inactive,
    /// Verrouillée.
    Locked,
    /// Supprimée (purge différée).
    Deleted,
}

/// Identité (sans secret : les moyens de connexion arrivent au lot 3, dans des tables à part).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Identity {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Schéma de traits appliqué.
    pub schema: AuthRecordId,
    /// Traits validés (e-mail, nom, langue…).
    pub traits: AuthValue,
    /// État.
    pub state: IdentityState,
    /// Identifiant externe.
    pub external_id: Option<String>,
    /// Niveau d'assurance atteignable.
    pub available_aal: i64,
    /// Version des droits.
    pub permissions_version: i64,
    /// Création.
    pub created_at: AuthDatetime,
}

/// Paramètres de `fn::auth_identity_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct IdentityCreateParams {
    /// Clé du schéma (défaut : schéma par défaut).
    pub schema_key: Option<String>,
    /// Traits (validés par le schéma).
    pub traits: AuthValue,
    /// Identifiant externe (unique).
    pub external_id: Option<String>,
    /// Organisation dont l'identité devient membre (texte).
    pub organization: Option<String>,
    /// Rôles d'organisation demandés (textes).
    pub roles: Vec<String>,
    /// État initial : `active` (défaut) ou `inactive`.
    pub state: Option<String>,
    /// Métadonnées lisibles par l'identité.
    pub public_metadata: Option<AuthValue>,
    /// Métadonnées réservées à l'administration.
    pub admin_metadata: Option<AuthValue>,
}

/// Paramètres de `fn::auth_identity_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct IdentityGetParams {
    /// Identité (texte `auth_identity:<clé>`).
    pub identity: String,
}
