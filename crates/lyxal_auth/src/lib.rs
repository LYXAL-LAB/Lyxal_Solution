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

// `LyxalSurrealError` (erreur commune de `lyxal_surreal`, 272 octets) est rendue par les
// fonctions de ce crate ; Clippy de Rust 1.98 les signale (`result_large_err`), 1.97 ne le
// faisait pas. Même règle que `lyxal_surreal` et `lyxal_error` : réduire cette erreur serait un
// changement de contrat.
#![allow(clippy::result_large_err)]

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
    access_name, invitation_seal_context, AccessConfig, AccessService, AppPasswordAttempt,
    AppPasswordIssued, AppPasswordLogin, AppPasswordService, AppPasswordTarget, AppProtocol,
    CodeProof, DomainChallenge, DomainVerifier, HickoryTxtLookup, InvitationRequest,
    InvitationService, IssuedTokens, LoginActions, LoginOutcome, LoginRequest, MfaActor, MfaProof,
    MfaService, PasskeyChallenge, PasskeyConfig, PasskeyLogin, ReauthProof, SigningKeyService,
    TotpEnrollment, TxtLookup,
};
pub use store::AuthStore;
