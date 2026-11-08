//! Accès aux fonctions SurrealQL publiques de `lyxal_auth` : un appel typé d'une ligne par
//! fonction (`LyxalSurrealCall::call_fn`). Les règles (droits, unicité, états) restent dans
//! SurrealQL ; la session SurrealDB du client détermine l'appelant.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    AuthContext, AuthValue, ContextParams, DomainAddParams, DomainVerifyParams, Identity,
    IdentityCreateParams, IdentityGetParams, IdentityPermissions, IdentityPermissionsParams,
    Invitation, InvitationAcceptParams, InvitationAccepted, InvitationCreateParams,
    InvitationRevokeParams, MemberAddParams, MemberAdded, MemberRemoveParams, MemberRemoved,
    Organization, OrganizationCreateParams, OrganizationDomain, OrganizationDomainCreated,
    OrganizationGetParams, PermissionRegisterParams, PermissionRegistered, PolicyGetParams,
    RoleAssignParams, RoleAssigned, RoleUnassigned,
};

/// Store de `lyxal_auth` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct AuthStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for AuthStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

impl AuthStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Client SurrealDB sous-jacent.
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    /// `fn::auth_context` : contexte de l'appelant.
    pub async fn context(&self) -> Result<AuthContext, LyxalSurrealError> {
        self.call_fn("auth_context", ContextParams::default()).await
    }

    /// `fn::auth_organization_create`.
    pub async fn organization_create(
        &self,
        params: OrganizationCreateParams,
    ) -> Result<Organization, LyxalSurrealError> {
        self.call_fn("auth_organization_create", params).await
    }

    /// `fn::auth_organization_get`.
    pub async fn organization_get(
        &self,
        params: OrganizationGetParams,
    ) -> Result<Organization, LyxalSurrealError> {
        self.call_fn("auth_organization_get", params).await
    }

    /// `fn::auth_organization_member_add`.
    pub async fn member_add(
        &self,
        params: MemberAddParams,
    ) -> Result<MemberAdded, LyxalSurrealError> {
        self.call_fn("auth_organization_member_add", params).await
    }

    /// `fn::auth_organization_member_remove`.
    pub async fn member_remove(
        &self,
        params: MemberRemoveParams,
    ) -> Result<MemberRemoved, LyxalSurrealError> {
        self.call_fn("auth_organization_member_remove", params)
            .await
    }

    /// `fn::auth_identity_create`.
    pub async fn identity_create(
        &self,
        params: IdentityCreateParams,
    ) -> Result<Identity, LyxalSurrealError> {
        self.call_fn("auth_identity_create", params).await
    }

    /// `fn::auth_identity_get`.
    pub async fn identity_get(
        &self,
        params: IdentityGetParams,
    ) -> Result<Identity, LyxalSurrealError> {
        self.call_fn("auth_identity_get", params).await
    }

    /// `fn::auth_permission_register` (création seule, rejouable).
    pub async fn permission_register(
        &self,
        params: PermissionRegisterParams,
    ) -> Result<PermissionRegistered, LyxalSurrealError> {
        self.call_fn("auth_permission_register", params).await
    }

    /// `fn::auth_role_assign`.
    pub async fn role_assign(
        &self,
        params: RoleAssignParams,
    ) -> Result<RoleAssigned, LyxalSurrealError> {
        self.call_fn("auth_role_assign", params).await
    }

    /// `fn::auth_role_unassign`.
    pub async fn role_unassign(
        &self,
        params: RoleAssignParams,
    ) -> Result<RoleUnassigned, LyxalSurrealError> {
        self.call_fn("auth_role_unassign", params).await
    }

    /// `fn::auth_identity_permissions` : permissions effectives (émission des jetons, lot 3).
    pub async fn identity_permissions(
        &self,
        params: IdentityPermissionsParams,
    ) -> Result<IdentityPermissions, LyxalSurrealError> {
        self.call_fn("auth_identity_permissions", params).await
    }

    /// `fn::auth_invitation_create` (paramètres construits par `InvitationService`).
    pub async fn invitation_create(
        &self,
        params: InvitationCreateParams,
    ) -> Result<Invitation, LyxalSurrealError> {
        self.call_fn("auth_invitation_create", params).await
    }

    /// `fn::auth_invitation_accept`.
    pub async fn invitation_accept(
        &self,
        params: InvitationAcceptParams,
    ) -> Result<InvitationAccepted, LyxalSurrealError> {
        self.call_fn("auth_invitation_accept", params).await
    }

    /// `fn::auth_invitation_revoke`.
    pub async fn invitation_revoke(
        &self,
        params: InvitationRevokeParams,
    ) -> Result<Invitation, LyxalSurrealError> {
        self.call_fn("auth_invitation_revoke", params).await
    }

    /// `fn::auth_organization_domain_add` (paramètres construits par `DomainVerifier`).
    pub async fn domain_add(
        &self,
        params: DomainAddParams,
    ) -> Result<OrganizationDomainCreated, LyxalSurrealError> {
        self.call_fn("auth_organization_domain_add", params).await
    }

    /// `fn::auth_organization_domain_verify`.
    pub async fn domain_verify(
        &self,
        params: DomainVerifyParams,
    ) -> Result<OrganizationDomain, LyxalSurrealError> {
        self.call_fn("auth_organization_domain_verify", params)
            .await
    }

    /// `fn::auth_policy_get` : politique effective (installation ou organisation).
    pub async fn policy_get(
        &self,
        params: PolicyGetParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_policy_get", params).await
    }
}
