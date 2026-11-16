#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_notification` : notifications sortantes de Lyxal OS (e-mail ; abonnés, sujets,
//! préférences, diffusions, parcours à étapes : attente, regroupement, limitation, conditions).
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::notification_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés
//! (`NotificationStore`), le consommateur des événements `auth.*` (secrets ouverts et rescellés
//! par `lyxal_crypto`), le rendu des gabarits (MiniJinja en bac à sable), l'envoi SMTP (`lettre`),
//! les heures calmes (`jiff`), les liens de désabonnement signés (`lyxal_crypto`), l'aperçu d'une
//! étape, les workers supervisés (envoi, diffusions, attentes confiées à `lyxal_scheduler`), le
//! module `LyxalModule` (planification de la purge à l'installation) et sa sonde de santé.

pub mod consumer;
pub mod error;
pub mod models;
pub mod module;
pub mod preview;
pub mod quiet;
pub mod render;
pub mod secret;
pub mod smtp;
pub mod store;
pub mod unsubscribe;
pub mod worker;

pub use consumer::{
    auth_subscriber, AuthMessageHandler, InvitationCreated, MfaEnrolled, MfaRemoved,
    NotificationConsumer, PasskeyCloneDetected, PasswordChanged, RecoveryCodeUsed,
    RecoveryCodesGenerated, RecoveryRequested, SecurityAlert, SecurityAlertHandler,
    SecurityAlertPayload, VerificationRequested, AUTH_HANDLER, AUTH_SUBSCRIPTIONS, CONSUMER_MODULE,
    SECURITY_ALERT_WORKFLOW,
};
pub use error::{NotificationError, NotificationResult};
pub use module::{
    ensure_purge_schedule, NotificationHealthCheck, NotificationModule, MODULE_ID, PURGE_SCHEDULE,
    PURGE_TASK,
};
pub use preview::NotificationPreview;
pub use quiet::quiet_until;
pub use render::{MessageSource, RenderedEmail, Renderer};
pub use secret::{OpenedSecret, SecretCodec};
pub use smtp::{
    classify_smtp_code, Delivered, EmailTransport, OutgoingEmail, SendFailure, SmtpSecurity,
    SmtpSettings, SmtpTransport,
};
pub use store::NotificationStore;
pub use unsubscribe::{UnsubscribeLinks, UNSUBSCRIBE_PATH};
pub use worker::{
    BroadcastOutcome, BroadcastWorkerSettings, EmailWorkerSettings, JobOutcome,
    NotificationBroadcastWorker, NotificationEmailWorker, NotificationStepWorker, RetryPolicy,
    StepWorkerSettings,
};
