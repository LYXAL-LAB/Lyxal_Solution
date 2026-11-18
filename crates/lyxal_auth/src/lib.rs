#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_auth` : identités, organisations, rôles, permissions, invitations et contrôle des droits
//! de Lyxal OS.
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::auth_*` (installées par `lyxal_runtime`
//! depuis `manifest.toml`) ; ce crate fournit les appels typés (`AuthStore`), les services
//! système (mots de passe, jetons d'accès et de renouvellement, codes et liens, clés de signature,
//! jetons d'invitation scellés par `lyxal_crypto`, vérification DNS des domaines), le module
//! `LyxalModule`, sa sonde de santé et la purge (`AuthPurge`, exécutée par `lyxal_scheduler` sur
//! l'hôte).

pub mod error;
pub mod models;
pub mod module;
pub mod purge;
pub mod services;
pub mod store;

pub use error::{AuthError, AuthResult};
pub use module::{AuthHealthCheck, AuthModule, MODULE_ID};
pub use purge::AuthPurge;
pub use services::{
    access_name, invitation_seal_context, AccessConfig, AccessService, CodeProof, DomainChallenge,
    DomainVerifier, HickoryTxtLookup, InvitationRequest, InvitationService, IssuedTokens,
    LoginActions, LoginOutcome, LoginRequest, MfaActor, MfaProof, MfaService, PasskeyChallenge,
    PasskeyConfig, PasskeyLogin, ReauthProof, SigningKeyService, TotpEnrollment, TxtLookup,
};
pub use store::AuthStore;
