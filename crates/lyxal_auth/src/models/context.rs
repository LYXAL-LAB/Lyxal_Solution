//! Contexte de l'appelant et contrôle des droits.

use lyxal_surreal::SurrealValue;

use super::types::AuthRecordId;

/// Paramètres de `fn::auth_context` (aucun champ requis).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ContextParams {
    /// Langue des messages d'erreur (défaut `fr`).
    pub language: Option<String>,
}

/// Contexte de l'appelant renvoyé par `fn::auth_context`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AuthContext {
    /// Session système (root de l'hôte).
    pub system: bool,
    /// Identité de la session.
    pub identity: Option<AuthRecordId>,
    /// Session (`auth_session`).
    pub session: Option<AuthRecordId>,
    /// Organisation active.
    pub organization: Option<AuthRecordId>,
    /// Permissions portées par le jeton.
    pub permissions: Vec<String>,
    /// Niveau d'assurance de la session.
    pub aal: Option<i64>,
}
