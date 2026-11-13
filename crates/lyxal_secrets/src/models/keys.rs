//! Clés des organisations (`fn::secrets_tenant_key_*`, `fn::secrets_rewrap_list`). Les clés
//! scellées ne circulent que dans des types internes au crate, sans `Serialize` et au `Debug`
//! masqué.

use lyxal_surreal::SurrealValue;
use std::fmt;

use super::types::SecretsRecordId;

/// Portée d'une clé : organisation, ou installation.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct TenantRef {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// État d'une clé d'organisation utilisable.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum TenantKeyState {
    /// Scelle les nouvelles versions (une seule par portée).
    Active,
    /// Relit seulement (après une rotation), en attente de destruction.
    DecryptOnly,
}

/// Clé d'organisation scellée par la clé maîtresse.
#[derive(Clone, SurrealValue)]
pub(crate) struct TenantKeyEntry {
    pub key_id: String,
    pub wrapped: String,
    pub state: TenantKeyState,
}

impl fmt::Debug for TenantKeyEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("TenantKeyEntry")
            .field("key_id", &self.key_id)
            .field("wrapped", &"[REDACTED]")
            .field("state", &self.state)
            .finish()
    }
}

/// Résultat de `fn::secrets_tenant_key_ring`.
#[derive(Debug, Clone, SurrealValue)]
pub(crate) struct TenantKeyRing {
    pub items: Vec<TenantKeyEntry>,
}

/// Paramètres de `fn::secrets_tenant_key_create`.
#[derive(Clone, SurrealValue)]
pub(crate) struct TenantKeyCreateParams {
    pub tenant: Option<String>,
    pub key_id: String,
    pub wrapped: String,
    pub replaces: Option<String>,
    pub requested_by: Option<String>,
}

impl fmt::Debug for TenantKeyCreateParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("TenantKeyCreateParams")
            .field("tenant", &self.tenant)
            .field("key_id", &self.key_id)
            .field("wrapped", &"[REDACTED]")
            .field("replaces", &self.replaces)
            .field("requested_by", &self.requested_by)
            .finish()
    }
}

/// Résultat de `fn::secrets_tenant_key_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TenantKeyCreated {
    /// Identifiant de la nouvelle clé.
    pub key_id: String,
    /// État de la nouvelle clé (`active`).
    pub state: String,
    /// Clé remplacée, passée en lecture seule (rotation).
    pub retired: Option<String>,
}

/// Résultat de `fn::secrets_tenant_key_rotate_allowed`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotateAllowed {
    /// Rotation permise.
    pub allowed: bool,
    /// Identité qui la demande.
    pub requested_by: Option<SecretsRecordId>,
}

/// Paramètres de `fn::secrets_tenant_key_rewrap`.
#[derive(Clone, SurrealValue)]
pub(crate) struct TenantKeyRewrapParams {
    pub key_id: String,
    pub expected_master_key_id: String,
    pub wrapped: String,
}

impl fmt::Debug for TenantKeyRewrapParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("TenantKeyRewrapParams")
            .field("key_id", &self.key_id)
            .field("expected_master_key_id", &self.expected_master_key_id)
            .field("wrapped", &"[REDACTED]")
            .finish()
    }
}

/// Résultat de `fn::secrets_tenant_key_rewrap`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TenantKeyRewrapped {
    /// Clé rescellée.
    pub key_id: String,
    /// Clé maîtresse qui la scelle désormais.
    pub master_key_id: Option<String>,
}

/// Paramètres de `fn::secrets_tenant_key_destroy`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TenantKeyDestroyParams {
    /// Clé à détruire (en lecture seule, plus utilisée).
    pub key_id: String,
}

/// Résultat de `fn::secrets_tenant_key_destroy`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TenantKeyDestroyed {
    /// Clé détruite.
    pub key_id: String,
    /// Matière effacée.
    pub destroyed: bool,
}

/// Paramètres de `fn::secrets_rewrap_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RewrapListParams {
    /// Clé maîtresse active du coffre-fort.
    pub master_key_id: String,
    /// Éléments par liste (1000 au plus).
    pub limit: Option<i64>,
    /// Versions en échec à passer (elles n'empêchent pas le reste du travail).
    pub skip_versions: Option<i64>,
    /// Clés d'organisation en échec à passer.
    pub skip_keys: Option<i64>,
}

/// Version scellée par une clé d'organisation retirée.
#[derive(Clone, SurrealValue)]
pub(crate) struct RewrapVersion {
    pub secret: SecretsRecordId,
    pub tenant: Option<SecretsRecordId>,
    pub number: i64,
    pub key_id: String,
    pub envelope: String,
}

impl fmt::Debug for RewrapVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("RewrapVersion")
            .field("secret", &self.secret)
            .field("number", &self.number)
            .field("key_id", &self.key_id)
            .field("envelope", &"[REDACTED]")
            .finish()
    }
}

/// Clé d'organisation scellée par une autre clé maîtresse que l'active.
#[derive(Clone, SurrealValue)]
pub(crate) struct RewrapKey {
    pub key_id: String,
    pub tenant: Option<SecretsRecordId>,
    pub wrapped: String,
    pub master_key_id: Option<String>,
}

impl fmt::Debug for RewrapKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("RewrapKey")
            .field("key_id", &self.key_id)
            .field("wrapped", &"[REDACTED]")
            .field("master_key_id", &self.master_key_id)
            .finish()
    }
}

/// Résultat de `fn::secrets_rewrap_list`.
#[derive(Debug, Clone, SurrealValue)]
pub(crate) struct RewrapList {
    pub versions: Vec<RewrapVersion>,
    pub keys: Vec<RewrapKey>,
    pub unused: Vec<String>,
}
