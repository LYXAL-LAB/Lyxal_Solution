//! Services Rust de `lyxal_auth` : seulement ce qui relève du système (aléa, empreintes,
//! scellement, DNS) ; les règles restent dans les fonctions SurrealQL.

pub mod domain;
pub mod invitation;

pub use domain::{DomainChallenge, DomainVerifier, HickoryTxtLookup, TxtLookup, CHALLENGE_PREFIX};
pub use invitation::{
    invitation_seal_context, InvitationRequest, InvitationService, INVITATION_SEAL_FIELD,
    INVITATION_SEAL_MODULE, INVITATION_SEAL_RESOURCE,
};
