//! Appelant d'une session, d'après le contrat public `fn::auth_context` de `lyxal_auth` (utilisé
//! pour journaliser une lecture refusée au nom de l'appelant).

use lyxal_surreal::SurrealValue;

use super::types::SecretsRecordId;

/// Paramètres de `fn::auth_context` (aucun).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct CallerContextParams {}

/// Appelant d'une session.
#[derive(Debug, Clone, SurrealValue)]
pub struct CallerContext {
    /// Session système de l'hôte.
    pub system: bool,
    /// Identité (session interactive ou clé d'API).
    pub identity: Option<SecretsRecordId>,
    /// Application (compte de service).
    pub application: Option<SecretsRecordId>,
    /// Type de session : `interactive`, `service`, `api_key`.
    pub kind: Option<String>,
    /// Session (`auth_session:<clé>`).
    pub session: Option<SecretsRecordId>,
}
