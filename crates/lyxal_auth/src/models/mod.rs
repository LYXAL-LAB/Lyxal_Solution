//! Contrats publics des fonctions SurrealQL `fn::auth_*` : paramètres (`XxxParams`) et résultats
//! (`XxxResult` ou modèles). Les identifiants transmis à SurrealDB sont des textes `table:clé`
//! (règle `record` de `lyxal_core`) ; ceux qui en reviennent sont des `RecordId`.

mod context;
mod domain;
mod identity;
mod invitation;
mod organization;
mod role;
mod types;

pub use context::{AuthContext, ContextParams};
pub use domain::{
    DomainAddParams, DomainVerifyParams, OrganizationDomain, OrganizationDomainCreated,
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
