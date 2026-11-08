//! Invitations. Le jeton n'apparaît dans aucun modèle : la base n'en connaît que l'empreinte, et
//! le lien scellé ne traverse que l'événement `auth.invitation.created`.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId};

/// État d'une invitation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum InvitationState {
    /// En attente.
    Pending,
    /// Acceptée.
    Accepted,
    /// Révoquée.
    Revoked,
    /// Expirée.
    Expired,
}

/// Invitation (sans empreinte de jeton).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Invitation {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Organisation.
    pub organization: AuthRecordId,
    /// Adresse invitée.
    pub email: String,
    /// Rôles prévus.
    pub roles: Vec<AuthRecordId>,
    /// État.
    pub state: InvitationState,
    /// Fin de validité.
    pub expires_at: AuthDatetime,
}

/// Paramètres de `fn::auth_invitation_create` (construits par `InvitationService`).
#[derive(SurrealValue)]
pub struct InvitationCreateParams {
    /// Organisation (texte).
    pub organization: String,
    /// Adresse invitée.
    pub email: String,
    /// Rôles prévus (textes).
    pub roles: Vec<String>,
    /// Identifiant d'événement (UUID v7) utilisé dans le contexte de scellement.
    pub event_id: String,
    /// Empreinte BLAKE3 (hex) du jeton.
    pub token_hash: String,
    /// Lien scellé (`enc:v2`).
    pub secret: String,
    /// Fin de validité (défaut : politique).
    pub expires_at: Option<AuthDatetime>,
}

impl std::fmt::Debug for InvitationCreateParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("InvitationCreateParams")
            .field("organization", &self.organization)
            .field("email", &self.email)
            .field("roles", &self.roles)
            .field("event_id", &self.event_id)
            .field("token_hash", &"[REDACTED]")
            .field("secret", &"[REDACTED]")
            .field("expires_at", &self.expires_at)
            .finish()
    }
}

/// Paramètres de `fn::auth_invitation_accept`.
#[derive(SurrealValue)]
pub struct InvitationAcceptParams {
    /// Empreinte BLAKE3 (hex) du jeton présenté.
    pub token_hash: String,
}

impl std::fmt::Debug for InvitationAcceptParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("InvitationAcceptParams { token_hash: [REDACTED] }")
    }
}

/// Résultat de `fn::auth_invitation_accept`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct InvitationAccepted {
    /// Organisation rejointe.
    pub organization: AuthRecordId,
    /// Adhésion créée.
    pub membership: AuthRecordId,
    /// Rôles de l'adhésion.
    pub roles: Vec<AuthRecordId>,
}

/// Paramètres de `fn::auth_invitation_revoke`.
#[derive(Debug, Clone, SurrealValue)]
pub struct InvitationRevokeParams {
    /// Invitation (texte).
    pub invitation: String,
}
