#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_notification` : notifications sortantes de Lyxal OS (lot V1-a : e-mail).
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::notification_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés
//! (`NotificationStore`), le consommateur des événements `auth.*` (secrets ouverts et rescellés
//! par `lyxal_crypto`), le rendu des gabarits (MiniJinja en bac à sable), l'envoi SMTP (`lettre`),
//! les workers supervisés, le module `LyxalModule` et sa sonde de santé.

pub mod consumer;
pub mod error;
pub mod models;
pub mod module;
pub mod render;
pub mod secret;
pub mod smtp;
pub mod store;
pub mod worker;

pub use consumer::{
    AuthMessageHandler, InvitationCreated, NotificationConsumer, RecoveryRequested,
    VerificationRequested, AUTH_HANDLER, AUTH_SUBSCRIPTIONS, CONSUMER_MODULE,
};
pub use error::{NotificationError, NotificationResult};
pub use module::{NotificationHealthCheck, NotificationModule, MODULE_ID};
pub use render::{RenderedEmail, Renderer};
pub use secret::{OpenedSecret, SecretCodec};
pub use smtp::{
    classify_smtp_code, Delivered, EmailTransport, OutgoingEmail, SendFailure, SmtpSecurity,
    SmtpSettings, SmtpTransport,
};
pub use store::NotificationStore;
pub use worker::{
    EmailWorkerSettings, JobOutcome, NotificationEmailWorker, NotificationPurgeWorker, RetryPolicy,
};
