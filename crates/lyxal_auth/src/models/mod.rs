//! Contrats publics des fonctions SurrealQL `fn::auth_*` : paramètres (`XxxParams`) et résultats
//! (`XxxResult` ou modèles). Les identifiants transmis à SurrealDB sont des textes `table:clé`
//! (règle `record` de `lyxal_core`) ; ceux qui en reviennent sont des `RecordId`.

mod access;
mod context;
mod domain;
mod identity;
mod invitation;
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
    RegistrationStarted, RequiredActionCompleteParams, ServiceSessionParams, SessionCaller,
    SessionCheckParams, SessionCreateParams, SessionIssued, SessionListParams,
    SessionRefreshParams, SessionRevokeAllParams, SessionRevokeParams, SessionRevoked,
    SessionSummary, SessionSwitchParams, SetupStartParams, SetupStarted, SigningKeyGetParams,
    SigningKeyRecord, SigningKeyRotateParams, SigningKeyRotated, SigningKeys,
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
pub use organization::{
    MemberAddParams, MemberAdded, MemberRemoveParams, MemberRemoved, Organization,
    OrganizationCreateParams, OrganizationGetParams, OrganizationState,
};
pub use role::{
    IdentityPermissions, IdentityPermissionsParams, PermissionRegisterParams, PermissionRegistered,
    PermissionScope, RoleAssignParams, RoleAssigned, RoleUnassigned,
};
pub use types::{AuthDatetime, AuthRecordId, AuthValue, PolicyGetParams};
