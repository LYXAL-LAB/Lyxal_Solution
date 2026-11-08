//! Services Rust de `lyxal_auth` : seulement ce qui relève du système (aléa, empreintes,
//! scellement, DNS) ; les règles restent dans les fonctions SurrealQL.

pub mod access;
pub mod domain;
pub mod invitation;
pub mod keys;
pub mod password;
pub mod tokens;

pub use access::{
    AccessConfig, AccessService, CodeProof, LoginActions, LoginOutcome, LoginRequest,
};
pub use domain::{DomainChallenge, DomainVerifier, HickoryTxtLookup, TxtLookup, CHALLENGE_PREFIX};
pub use invitation::{
    invitation_seal_context, InvitationRequest, InvitationService, INVITATION_SEAL_FIELD,
    INVITATION_SEAL_MODULE, INVITATION_SEAL_RESOURCE,
};
pub use keys::{access_name, ActiveSigningKey, SigningKeyService};
pub use password::{PasswordCheck, PasswordPolicy, PasswordService};
pub use tokens::{opaque_token, token_hash, IssuedTokens, OpaqueToken};
