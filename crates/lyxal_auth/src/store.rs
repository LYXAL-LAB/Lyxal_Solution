//! Accès aux fonctions SurrealQL publiques de `lyxal_auth` : un appel typé d'une ligne par
//! fonction (`LyxalSurrealCall::call_fn`). Les règles (droits, unicité, états) restent dans
//! SurrealQL ; la session SurrealDB du client détermine l'appelant.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    AddressChangeConfirmParams, AddressChangeRequestParams, AddressChangeRequested, AddressChanged,
    AddressVerifyParams, ApiKeyCreateParams, ApiKeyCreated, ApiKeySessionParams,
    ApplicationSecretAddParams, ApplicationSecretAdded, AssuranceCheckParams, AssuranceState,
    AuthContext, AuthPurgeParams, AuthPurgeResult, AuthValue, CodeIssueParams, CodeIssued,
    CodeVerified, CodeVerifyParams, ContextParams, CredentialUsed, DomainAddParams,
    DomainGetParams, DomainVerifyParams, FactorRemoveParams, FactorRemoved, Flow, FlowGetParams,
    FlowStartParams, FlowStateSaveParams, FlowStateTakeParams, FlowStateTaken, FlowSubmitParams,
    Identity, IdentityCreateParams, IdentityGetParams, IdentityPermissions,
    IdentityPermissionsParams, Invitation, InvitationAcceptParams, InvitationAccepted,
    InvitationCreateParams, InvitationRevokeParams, LoginFailureParams, LoginFailureResetParams,
    LoginFailureStatus, LoginRequirements, LoginRequirementsParams, MemberAddParams, MemberAdded,
    MemberRemoveParams, MemberRemoved, MfaFactorListParams, MfaFactors, MfaFailureKeyParams,
    MfaFailureParams, MfaFailureStatus, MfaReset, MfaResetParams, Organization,
    OrganizationCreateParams, OrganizationDomain, OrganizationDomainCreated, OrganizationGetParams,
    PasskeyFindParams, PasskeyFound, PasskeyListForParams, PasskeyRecord, PasskeyRenameParams,
    PasskeyRenamed, PasskeySaveParams, PasskeySaved, PasskeyUpdateParams, PasswordCredential,
    PasswordCredentialParams, PasswordSet, PasswordSetParams, PermissionRegisterParams,
    PermissionRegistered, PolicyGetParams, RecoveryCodeUseParams, RecoveryCodeUsed,
    RecoveryCodesReplaceParams, RecoveryCodesReplaced, RegistrationCompleteParams,
    RegistrationCompleted, RegistrationStartParams, RegistrationStarted, RequiredAction,
    RequiredActionCompleteParams, RequiredActionListParams, RoleAssignParams, RoleAssigned,
    RoleUnassigned, ServiceSessionParams, SessionCaller, SessionCheckParams, SessionCreateParams,
    SessionIssued, SessionListParams, SessionReauthenticateParams, SessionRefreshParams,
    SessionRevokeAllParams, SessionRevokeParams, SessionRevoked, SessionSummary,
    SessionSwitchParams, SetupStartParams, SetupStarted, SigningKeyGetParams,
    SigningKeyRotateParams, SigningKeyRotated, SigningKeys, TotpActivateParams, TotpActivated,
    TotpBeginParams, TotpBegun, TotpSecretGetParams, TotpSecretRecord, TotpStepUseParams,
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

    /// `fn::auth_organization_domain_get`.
    pub async fn domain_get(
        &self,
        params: DomainGetParams,
    ) -> Result<OrganizationDomain, LyxalSurrealError> {
        self.call_fn("auth_organization_domain_get", params).await
    }

    /// `fn::auth_organization_domain_verify` (session système seulement).
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

    /// `fn::auth_password_credential_get` : identité et empreinte scellée d'un identifiant (session système).
    pub async fn password_credential_get(
        &self,
        params: PasswordCredentialParams,
    ) -> Result<PasswordCredential, LyxalSurrealError> {
        self.call_fn("auth_password_credential_get", params).await
    }

    /// `fn::auth_password_set` : empreinte scellée enregistrée (session système).
    pub async fn password_set(
        &self,
        params: PasswordSetParams,
    ) -> Result<PasswordSet, LyxalSurrealError> {
        self.call_fn("auth_password_set", params).await
    }

    /// `fn::auth_required_action_list` : actions imposées en attente d'une identité.
    pub async fn required_action_list(
        &self,
        params: RequiredActionListParams,
    ) -> Result<Vec<RequiredAction>, LyxalSurrealError> {
        self.call_fn("auth_required_action_list", params).await
    }

    /// `fn::auth_required_action_complete` : action imposée levée (session système).
    pub async fn required_action_complete(
        &self,
        params: RequiredActionCompleteParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_required_action_complete", params).await
    }

    /// `fn::auth_flow_start` : parcours démarré (session système).
    pub async fn flow_start(&self, params: FlowStartParams) -> Result<Flow, LyxalSurrealError> {
        self.call_fn("auth_flow_start", params).await
    }

    /// `fn::auth_flow_get` : parcours en cours (session système).
    pub async fn flow_get(&self, params: FlowGetParams) -> Result<Flow, LyxalSurrealError> {
        self.call_fn("auth_flow_get", params).await
    }

    /// `fn::auth_flow_submit` : transition de parcours (session système).
    pub async fn flow_submit(&self, params: FlowSubmitParams) -> Result<Flow, LyxalSurrealError> {
        self.call_fn("auth_flow_submit", params).await
    }

    /// `fn::auth_code_issue` : code et lien émis, message publié (session système).
    pub async fn code_issue(
        &self,
        params: CodeIssueParams,
    ) -> Result<CodeIssued, LyxalSurrealError> {
        self.call_fn("auth_code_issue", params).await
    }

    /// `fn::auth_code_verify` : code ou lien vérifié (session système).
    pub async fn code_verify(
        &self,
        params: CodeVerifyParams,
    ) -> Result<CodeVerified, LyxalSurrealError> {
        self.call_fn("auth_code_verify", params).await
    }

    /// `fn::auth_login_failure_check` : état de verrouillage (session système).
    pub async fn login_failure_check(
        &self,
        params: LoginFailureParams,
    ) -> Result<LoginFailureStatus, LyxalSurrealError> {
        self.call_fn("auth_login_failure_check", params).await
    }

    /// `fn::auth_login_failure_record` : échec compté (session système).
    pub async fn login_failure_record(
        &self,
        params: LoginFailureParams,
    ) -> Result<LoginFailureStatus, LyxalSurrealError> {
        self.call_fn("auth_login_failure_record", params).await
    }

    /// `fn::auth_login_failure_reset` : compteur remis à zéro (session système).
    pub async fn login_failure_reset(
        &self,
        params: LoginFailureResetParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_login_failure_reset", params).await
    }

    /// `fn::auth_session_create` : session interactive ouverte (session système).
    pub async fn session_create(
        &self,
        params: SessionCreateParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_session_create", params).await
    }

    /// `fn::auth_session_refresh` : jeton de renouvellement échangé (session système).
    pub async fn session_refresh(
        &self,
        params: SessionRefreshParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_session_refresh", params).await
    }

    /// `fn::auth_session_revoke` : session révoquée (session système).
    pub async fn session_revoke(
        &self,
        params: SessionRevokeParams,
    ) -> Result<SessionRevoked, LyxalSurrealError> {
        self.call_fn("auth_session_revoke", params).await
    }

    /// `fn::auth_session_revoke_all` : sessions d'une identité révoquées (session système).
    pub async fn session_revoke_all(
        &self,
        params: SessionRevokeAllParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_session_revoke_all", params).await
    }

    /// `fn::auth_session_switch_organization` : organisation active changée (session système).
    pub async fn session_switch_organization(
        &self,
        params: SessionSwitchParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_session_switch_organization", params)
            .await
    }

    /// `fn::auth_session_list` : sessions visibles par l'appelant.
    pub async fn session_list(
        &self,
        params: SessionListParams,
    ) -> Result<Vec<SessionSummary>, LyxalSurrealError> {
        self.call_fn("auth_session_list", params).await
    }

    /// `fn::auth_registration_start` : inscription démarrée (session système).
    pub async fn registration_start(
        &self,
        params: RegistrationStartParams,
    ) -> Result<RegistrationStarted, LyxalSurrealError> {
        self.call_fn("auth_registration_start", params).await
    }

    /// `fn::auth_registration_complete` : inscription terminée (session système).
    pub async fn registration_complete(
        &self,
        params: RegistrationCompleteParams,
    ) -> Result<RegistrationCompleted, LyxalSurrealError> {
        self.call_fn("auth_registration_complete", params).await
    }

    /// `fn::auth_setup_start` : lien d'installation préparé (session système).
    pub async fn setup_start(
        &self,
        params: SetupStartParams,
    ) -> Result<SetupStarted, LyxalSurrealError> {
        self.call_fn("auth_setup_start", params).await
    }

    /// `fn::auth_address_verify` : adresse vérifiée (session système).
    pub async fn address_verify(
        &self,
        params: AddressVerifyParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_address_verify", params).await
    }

    /// `fn::auth_address_change_request` : changement d'adresse demandé (session système).
    pub async fn address_change_request(
        &self,
        params: AddressChangeRequestParams,
    ) -> Result<AddressChangeRequested, LyxalSurrealError> {
        self.call_fn("auth_address_change_request", params).await
    }

    /// `fn::auth_address_change_confirm` : changement d'adresse confirmé (session système).
    pub async fn address_change_confirm(
        &self,
        params: AddressChangeConfirmParams,
    ) -> Result<AddressChanged, LyxalSurrealError> {
        self.call_fn("auth_address_change_confirm", params).await
    }

    /// `fn::auth_signing_key_get_active` : clés actives scellées (session système).
    pub async fn signing_key_get_active(
        &self,
        params: SigningKeyGetParams,
    ) -> Result<SigningKeys, LyxalSurrealError> {
        self.call_fn("auth_signing_key_get_active", params).await
    }

    /// `fn::auth_signing_key_rotate` : nouvelle clé activée (session système).
    pub async fn signing_key_rotate(
        &self,
        params: SigningKeyRotateParams,
    ) -> Result<SigningKeyRotated, LyxalSurrealError> {
        self.call_fn("auth_signing_key_rotate", params).await
    }

    /// `fn::auth_service_session_create` : session de compte de service (session système).
    pub async fn service_session_create(
        &self,
        params: ServiceSessionParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_service_session_create", params).await
    }

    /// `fn::auth_api_key_session_create` : session d'une clé d'API (session système).
    pub async fn api_key_session_create(
        &self,
        params: ApiKeySessionParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_api_key_session_create", params).await
    }

    /// `fn::auth_api_key_create` : clé d'API de l'identité connectée.
    pub async fn api_key_create(
        &self,
        params: ApiKeyCreateParams,
    ) -> Result<ApiKeyCreated, LyxalSurrealError> {
        self.call_fn("auth_api_key_create", params).await
    }

    /// `fn::auth_application_secret_add` : secret client ajouté.
    pub async fn application_secret_add(
        &self,
        params: ApplicationSecretAddParams,
    ) -> Result<ApplicationSecretAdded, LyxalSurrealError> {
        self.call_fn("auth_application_secret_add", params).await
    }

    /// `fn::auth_purge` : purge par paquets (session système).
    pub async fn purge(
        &self,
        params: AuthPurgeParams,
    ) -> Result<AuthPurgeResult, LyxalSurrealError> {
        self.call_fn("auth_purge", params).await
    }

    /// `fn::auth_session_check` : validité d'une session désignée par un jeton vérifié (session système).
    pub async fn session_check(
        &self,
        params: SessionCheckParams,
    ) -> Result<SessionCaller, LyxalSurrealError> {
        self.call_fn("auth_session_check", params).await
    }
    // ------------------------------------------------------------------------------------------
    // Double facteur (lot 4)
    // ------------------------------------------------------------------------------------------

    /// `fn::auth_login_requirements` : exigences de connexion d'une identité (session système).
    pub async fn login_requirements(
        &self,
        params: LoginRequirementsParams,
    ) -> Result<LoginRequirements, LyxalSurrealError> {
        self.call_fn("auth_login_requirements", params).await
    }

    /// `fn::auth_assurance_check` : exigence d'assurance d'une session.
    pub async fn assurance_check(
        &self,
        params: AssuranceCheckParams,
    ) -> Result<AssuranceState, LyxalSurrealError> {
        self.call_fn("auth_assurance_check", params).await
    }

    /// `fn::auth_session_reauthenticate` : réauthentification d'une session (session système).
    pub async fn session_reauthenticate(
        &self,
        params: SessionReauthenticateParams,
    ) -> Result<SessionIssued, LyxalSurrealError> {
        self.call_fn("auth_session_reauthenticate", params).await
    }

    /// `fn::auth_mfa_failure_check` : verrouillage du second facteur (session système).
    pub async fn mfa_failure_check(
        &self,
        params: MfaFailureKeyParams,
    ) -> Result<MfaFailureStatus, LyxalSurrealError> {
        self.call_fn("auth_mfa_failure_check", params).await
    }

    /// `fn::auth_mfa_failure_record` : échec du second facteur compté (session système).
    pub async fn mfa_failure_record(
        &self,
        params: MfaFailureParams,
    ) -> Result<MfaFailureStatus, LyxalSurrealError> {
        self.call_fn("auth_mfa_failure_record", params).await
    }

    /// `fn::auth_mfa_failure_reset` : compteur du second facteur remis à zéro (session système).
    pub async fn mfa_failure_reset(
        &self,
        params: MfaFailureKeyParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_mfa_failure_reset", params).await
    }

    /// `fn::auth_flow_state_save` : état scellé d'une cérémonie conservé (session système).
    pub async fn flow_state_save(
        &self,
        params: FlowStateSaveParams,
    ) -> Result<AuthValue, LyxalSurrealError> {
        self.call_fn("auth_flow_state_save", params).await
    }

    /// `fn::auth_flow_state_take` : état scellé d'une cérémonie lu une fois (session système).
    pub async fn flow_state_take(
        &self,
        params: FlowStateTakeParams,
    ) -> Result<FlowStateTaken, LyxalSurrealError> {
        self.call_fn("auth_flow_state_take", params).await
    }

    /// `fn::auth_mfa_factor_list` : seconds facteurs d'une identité.
    pub async fn mfa_factor_list(
        &self,
        params: MfaFactorListParams,
    ) -> Result<MfaFactors, LyxalSurrealError> {
        self.call_fn("auth_mfa_factor_list", params).await
    }

    /// `fn::auth_mfa_totp_begin` : TOTP en attente enregistré (session système).
    pub async fn mfa_totp_begin(
        &self,
        params: TotpBeginParams,
    ) -> Result<TotpBegun, LyxalSurrealError> {
        self.call_fn("auth_mfa_totp_begin", params).await
    }

    /// `fn::auth_mfa_totp_secret_get` : secret TOTP scellé (session système).
    pub async fn mfa_totp_secret_get(
        &self,
        params: TotpSecretGetParams,
    ) -> Result<TotpSecretRecord, LyxalSurrealError> {
        self.call_fn("auth_mfa_totp_secret_get", params).await
    }

    /// `fn::auth_mfa_totp_activate` : TOTP activé (session système).
    pub async fn mfa_totp_activate(
        &self,
        params: TotpActivateParams,
    ) -> Result<TotpActivated, LyxalSurrealError> {
        self.call_fn("auth_mfa_totp_activate", params).await
    }

    /// `fn::auth_mfa_totp_step_use` : pas TOTP consommé, anti-rejeu (session système).
    pub async fn mfa_totp_step_use(
        &self,
        params: TotpStepUseParams,
    ) -> Result<CredentialUsed, LyxalSurrealError> {
        self.call_fn("auth_mfa_totp_step_use", params).await
    }

    /// `fn::auth_mfa_passkey_save` : passkey enregistrée (session système).
    pub async fn mfa_passkey_save(
        &self,
        params: PasskeySaveParams,
    ) -> Result<PasskeySaved, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_save", params).await
    }

    /// `fn::auth_mfa_passkey_find` : passkey retrouvée par son identifiant WebAuthn (session système).
    pub async fn mfa_passkey_find(
        &self,
        params: PasskeyFindParams,
    ) -> Result<PasskeyFound, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_find", params).await
    }

    /// `fn::auth_mfa_passkey_list_for` : passkeys actives d'une identité (session système).
    pub async fn mfa_passkey_list_for(
        &self,
        params: PasskeyListForParams,
    ) -> Result<Vec<PasskeyRecord>, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_list_for", params).await
    }

    /// `fn::auth_mfa_passkey_update` : passkey mise à jour après authentification (session système).
    pub async fn mfa_passkey_update(
        &self,
        params: PasskeyUpdateParams,
    ) -> Result<CredentialUsed, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_update", params).await
    }

    /// `fn::auth_mfa_passkey_flag` : passkey possiblement clonée signalée (session système).
    pub async fn mfa_passkey_flag(
        &self,
        params: PasskeyFindParams,
    ) -> Result<CredentialUsed, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_flag", params).await
    }

    /// `fn::auth_mfa_passkey_rename` : passkey renommée (session système).
    pub async fn mfa_passkey_rename(
        &self,
        params: PasskeyRenameParams,
    ) -> Result<PasskeyRenamed, LyxalSurrealError> {
        self.call_fn("auth_mfa_passkey_rename", params).await
    }

    /// `fn::auth_mfa_recovery_codes_replace` : codes de secours remplacés (session système).
    pub async fn mfa_recovery_codes_replace(
        &self,
        params: RecoveryCodesReplaceParams,
    ) -> Result<RecoveryCodesReplaced, LyxalSurrealError> {
        self.call_fn("auth_mfa_recovery_codes_replace", params)
            .await
    }

    /// `fn::auth_mfa_recovery_code_use` : code de secours consommé (session système).
    pub async fn mfa_recovery_code_use(
        &self,
        params: RecoveryCodeUseParams,
    ) -> Result<RecoveryCodeUsed, LyxalSurrealError> {
        self.call_fn("auth_mfa_recovery_code_use", params).await
    }

    /// `fn::auth_mfa_factor_remove` : second facteur retiré par son titulaire (session système).
    pub async fn mfa_factor_remove(
        &self,
        params: FactorRemoveParams,
    ) -> Result<FactorRemoved, LyxalSurrealError> {
        self.call_fn("auth_mfa_factor_remove", params).await
    }

    /// `fn::auth_mfa_reset` : remise à zéro par un administrateur (session système).
    pub async fn mfa_reset(&self, params: MfaResetParams) -> Result<MfaReset, LyxalSurrealError> {
        self.call_fn("auth_mfa_reset", params).await
    }
}
