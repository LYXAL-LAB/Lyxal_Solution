#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_auth` : identités, organisations, rôles, permissions, invitations et contrôle des droits
//! de Lyxal OS.
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::auth_*` (installées par `lyxal_runtime`
//! depuis `manifest.toml`) ; ce crate fournit les appels typés (`AuthStore`), les services
//! système (jetons d'invitation scellés par `lyxal_crypto`, vérification DNS des domaines), le
//! module `LyxalModule` et sa sonde de santé.

pub mod error;
pub mod models;
pub mod module;
pub mod services;
pub mod store;

pub use error::{AuthError, AuthResult};
pub use module::{AuthHealthCheck, AuthModule, MODULE_ID};
pub use services::{
    invitation_seal_context, DomainChallenge, DomainVerifier, HickoryTxtLookup, InvitationRequest,
    InvitationService, TxtLookup,
};
pub use store::AuthStore;
