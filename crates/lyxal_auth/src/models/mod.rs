//! Contrats publics des fonctions SurrealQL `fn::auth_*` : paramètres (`XxxParams`) et résultats
//! (`XxxResult` ou modèles). Les identifiants transmis à SurrealDB sont des textes `table:clé`
//! (règle `record` de `lyxal_core`) ; ceux qui en reviennent sont des `RecordId`.

/// `Debug` des paramètres porteurs d'empreintes : les champs `hidden` (empreintes, secrets)
/// sont affichés `[REDACTED]` ; une empreinte d'adresse non poivrée se retrouverait par
/// dictionnaire.
macro_rules! redacted_debug {
    ($name:ident { shown: [$($shown:ident),*], hidden: [$($hidden:ident),*] }) => {
        impl std::fmt::Debug for $name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                f.debug_struct(stringify!($name))
                    $(.field(stringify!($shown), &self.$shown))*
                    $(.field(stringify!($hidden), &"[REDACTED]"))*
                    .finish()
            }
        }
    };
}
pub(crate) use redacted_debug;

mod access;
mod context;
mod domain;
mod identity;
mod invitation;
mod mfa;
mod organization;
mod role;
mod types;

pub use access::{
    AddressChangeConfirmParams, AddressChangeRequestParams, AddressChangeRequested, AddressChanged,
    AddressVerifyParams, ApiKeyCreateParams, ApiKeyCreated, ApiKeySessionParams,
    ApplicationSecretAddParams, ApplicationSecretAdded, AuthPurgeParams, AuthPurgeResult,
    ClientInfo, CodeIssueParams, CodeIssued, CodeVerified, CodeVerifyParams, Flow, FlowGetParams,
    FlowStartParams, FlowSubmitParams, LoginFailureParams, LoginFailureResetParams,
    LoginFailureStatus, PasswordCredential, PasswordCredentialParams, PasswordSet,
    PasswordSetParams, RegistrationCompleteParams, RegistrationCompleted, RegistrationStartParams,
    RegistrationStarted, RequiredAction, RequiredActionCompleteParams, RequiredActionListParams,
    ServiceSessionOpenParams, ServiceSessionParams, SessionCaller, SessionCheckParams,
    SessionCreateParams, SessionIssued, SessionListParams, SessionRefreshParams,
    SessionRevokeAllParams, SessionRevokeParams, SessionRevoked, SessionSummary,
    SessionSwitchParams, SetupStartParams, SetupStarted, SigningKeyGetParams, SigningKeyRecord,
    SigningKeyRotateParams, SigningKeyRotated, SigningKeys,
};
pub use context::{AuthContext, ContextParams};
pub use domain::{
    DomainAddParams, DomainGetParams, DomainVerifyParams, OrganizationDomain,
    OrganizationDomainCreated,
};
pub use identity::{Identity, IdentityCreateParams, IdentityGetParams, IdentityState};
pub use invitation::{
    Invitation, InvitationAcceptParams, InvitationAccepted, InvitationCreateParams,
    InvitationRevokeParams, InvitationState,
};
pub use mfa::{
    AssuranceCheckParams, AssuranceState, CredentialUsed, FactorRemoveParams, FactorRemoved,
    FlowStateSaveParams, FlowStateTakeParams, FlowStateTaken, LoginRequirements,
    LoginRequirementsParams, MfaFactorListParams, MfaFactors, MfaFailureKeyParams,
    MfaFailureParams, MfaFailureStatus, MfaReset, MfaResetParams, PasskeyFactor, PasskeyFindParams,
    PasskeyFound, PasskeyListForParams, PasskeyRecord, PasskeyRenameParams, PasskeyRenamed,
    PasskeySaveParams, PasskeySaved, PasskeyUpdateParams, RecoveryCodeUseParams, RecoveryCodeUsed,
    RecoveryCodesReplaceParams, RecoveryCodesReplaced, RecoveryCodesSummary,
    SessionReauthenticateParams, TotpActivateParams, TotpActivated, TotpBeginParams, TotpBegun,
    TotpFactor, TotpSecretGetParams, TotpSecretRecord, TotpStepUseParams,
};
pub use organization::{
    MemberAddParams, MemberAdded, MemberRemoveParams, MemberRemoved, Organization,
    OrganizationCreateParams, OrganizationGetParams, OrganizationState,
};
pub use role::{
    IdentityPermissions, IdentityPermissionsParams, PermissionRegisterParams, PermissionRegistered,
    PermissionScope, RoleAssignParams, RoleAssigned, RoleUnassigned,
};
pub use types::{AuthDatetime, AuthRecordId, AuthValue, PolicyGetParams};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hashes_are_redacted_in_debug() {
        let failure = LoginFailureParams {
            identifier_hash: "aa11".repeat(16),
            ip_hash: Some("bb22".repeat(16)),
            identity: Some("auth_identity:x".into()),
        };
        let text = format!("{failure:?}");
        assert!(!text.contains("aa11") && !text.contains("bb22"), "{text}");
        assert!(
            text.contains("[REDACTED]") && text.contains("auth_identity:x"),
            "{text}"
        );
    }
}
