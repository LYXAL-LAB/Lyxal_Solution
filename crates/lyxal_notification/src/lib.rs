#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_notification` : notifications sortantes de Lyxal OS (e-mail, SMS, messageries
//! d'équipe, appel signé d'une adresse web, fil dans l'application, notifications push : Web Push,
//! FCM, APNs ; abonnés, leurs adresses et appareils, sujets, préférences,
//! diffusions, parcours à étapes : attente, regroupement, limitation, conditions ; intégrations
//! par fournisseur et retours des fournisseurs).
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::notification_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés
//! (`NotificationStore`), le consommateur des événements `auth.*` (secrets ouverts et rescellés
//! par `lyxal_crypto`), le rendu des gabarits (MiniJinja en bac à sable), l'envoi par les
//! fournisseurs (SMTP par `lettre`, API Brevo, Mailgun, Postmark, Resend par `reqwest`, identifiants
//! lus dans `lyxal_secrets`), les SMS (Brevo, Twilio, Vonage) et leurs parties, les messageries
//! (Slack, Teams, Discord, Mattermost, Google Chat, Telegram) et les adresses web par un client
//! sortant contrôlé (SSRF), les notifications push (jetons ES256 et RS256, chiffrement Web Push :
//! `lyxal_crypto`), la vérification des retours des fournisseurs (`lyxal_crypto`),
//! les heures calmes (`jiff`), les liens de désabonnement signés (`lyxal_crypto`), l'aperçu d'une
//! étape, les workers supervisés (envoi, diffusions, attentes confiées à `lyxal_scheduler`), le
//! module `LyxalModule` (planification de la purge à l'installation) et sa sonde de santé.

pub mod consumer;
pub mod error;
pub mod models;
pub mod module;
pub mod outbound;
pub mod preview;
pub mod provider;
pub mod push_worker;
pub mod quiet;
pub mod render;
pub mod secret;
pub mod segments;
pub mod store;
pub mod unsubscribe;
pub mod webhook;
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
pub use outbound::{
    forbidden_ip, HostResolver, HostRule, OutboundClient, OutboundResponse, StaticResolver,
    SystemResolver,
};
pub use preview::NotificationPreview;
pub use provider::{
    classify_smtp_code, system_clock, ApiEndpoints, ChannelDispatcher, ChatSender, ChatService,
    ChatTarget, Credentials, DeviceRemoval, EmailDispatcher, EmailMessage, EmailProvider,
    EmailProviders, IntegrationScope, Provider, ProviderError, ProviderReceipt, PushApi, PushClock,
    PushCredentials, PushDispatcher, PushEndpoints, PushFailure, PushMessage, PushService,
    PushTarget, SmsApi, SmsCredentials, SmsEndpoints, SmsMessage, SmsProvider, SmtpProvider,
    SmtpSecurity, DELIVERY_HEADER, MAX_PUSH_PAYLOAD_BYTES, SECRETS_CONSUMER, SIGNATURE_HEADER,
};
pub use push_worker::{push_to_device, NotificationPushWorker, PUSH_CLEANUP_BUDGET};
pub use quiet::quiet_until;
pub use render::{
    MessageSource, RenderedEmail, RenderedInApp, RenderedPush, RenderedText, Renderer,
};
pub use secret::{
    device_fingerprint, generate_signing_key, DeviceField, EndpointField, OpenedSecret, SecretCodec,
};
pub use segments::{SmsEncoding, SmsSegments, MAX_SMS_PARTS};
pub use store::NotificationStore;
pub use unsubscribe::{UnsubscribeLinks, UNSUBSCRIBE_PATH};
pub use webhook::{
    ProviderEvent, ProviderEventKind, ProviderWebhook, WebhookError, WebhookRequest,
    MAX_WEBHOOK_BYTES,
};
pub use worker::{
    deliver_to_endpoint, BroadcastOutcome, BroadcastWorkerSettings, EndpointMessage, JobOutcome,
    NotificationBroadcastWorker, NotificationChannelWorker, NotificationEmailWorker,
    NotificationStepWorker, RetryPolicy, SendWorkerSettings, StepWorkerSettings, TextChannel,
};
