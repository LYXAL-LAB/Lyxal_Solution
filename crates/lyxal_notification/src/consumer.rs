//! Consommateur des événements de `lyxal_auth` : `auth.verification.requested`,
//! `auth.recovery.requested`, `auth.invitation.created` (contrat du plan V1-a, §2.1), et les
//! alertes de sécurité du double facteur (`auth.mfa.*`, `auth.passkey.clone_detected`,
//! `auth.password.changed`), sans secret, envoyées par le parcours `auth_security_alert`.
//!
//! Pour chaque événement : ouverture du secret sous le contexte du producteur (lié à
//! l'événement), rescellement sous le contexte de la file, puis `fn::notification_trigger`
//! idempotent par l'identifiant d'événement (livraison au moins une fois). Un secret illisible,
//! une charge utile invalide ou un parcours absent partent en lettre morte (`terminal: true`) ;
//! une base indisponible est rejouée (`terminal: false`).

use async_trait::async_trait;
use lyxal_crypto::KeyResolver;
use lyxal_event::{Event, Handler, HandlerContext, HandlerRegistry, LyxalEventError};
use lyxal_runtime::{EventConsumerModule, RuntimeError};
use serde::{Deserialize, Serialize};
use std::str::FromStr;

use crate::error::{NotificationError, NotificationResult};
use crate::models::{NotificationDatetime, Recipient, TriggerParams};
use crate::secret::SecretCodec;
use crate::store::NotificationStore;

/// Producteur des événements consommés.
pub const AUTH_PRODUCER: &str = "lyxal_auth";
/// Nom du handler (abonnements persistants).
pub const AUTH_HANDLER: &str = "notification.auth_messages";
/// Module consommateur.
pub const CONSUMER_MODULE: &str = "lyxal_notification";
/// Abonnements persistants : (nom, type d'événement).
pub const AUTH_SUBSCRIPTIONS: [(&str, &str); 9] = [
    (
        "notification_auth_verification",
        VerificationRequested::EVENT_TYPE,
    ),
    ("notification_auth_recovery", RecoveryRequested::EVENT_TYPE),
    (
        "notification_auth_invitation",
        InvitationCreated::EVENT_TYPE,
    ),
    ("notification_auth_mfa_enrolled", MfaEnrolled::EVENT_TYPE),
    ("notification_auth_mfa_removed", MfaRemoved::EVENT_TYPE),
    (
        "notification_auth_recovery_codes",
        RecoveryCodesGenerated::EVENT_TYPE,
    ),
    (
        "notification_auth_recovery_code_used",
        RecoveryCodeUsed::EVENT_TYPE,
    ),
    (
        "notification_auth_password_changed",
        PasswordChanged::EVENT_TYPE,
    ),
    (
        "notification_auth_passkey_clone",
        PasskeyCloneDetected::EVENT_TYPE,
    ),
];

/// Parcours des alertes de sécurité.
pub const SECURITY_ALERT_WORKFLOW: &str = "auth_security_alert";

/// Champs communs des événements `auth.*` adressés à une personne.
#[derive(Clone, Serialize, Deserialize)]
pub struct AuthMessagePayload {
    /// Clé de l'organisation (absente pour l'installation).
    pub tenant: Option<String>,
    /// Identité concernée.
    pub identity_id: Option<String>,
    /// Adresse de destination.
    pub recipient_email: String,
    /// Langue (BCP 47).
    pub recipient_locale: Option<String>,
    /// Nom affiché.
    pub recipient_name: Option<String>,
    /// Fin de validité du code ou du lien (date ISO 8601).
    pub expires_at: String,
    /// Variables sensibles scellées (`enc:v2`).
    pub secret: String,
}

impl std::fmt::Debug for AuthMessagePayload {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AuthMessagePayload")
            .field("tenant", &self.tenant)
            .field("identity_id", &self.identity_id)
            .field("expires_at", &self.expires_at)
            .field("secret", &"[REDACTED]")
            .finish_non_exhaustive()
    }
}

/// `auth.verification.requested` : code ou lien de vérification d'adresse.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VerificationRequested {
    /// Champs communs.
    #[serde(flatten)]
    pub message: AuthMessagePayload,
}

impl Event for VerificationRequested {
    const EVENT_TYPE: &'static str = "auth.verification.requested";
}

/// `auth.recovery.requested` : code ou lien de récupération de compte.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecoveryRequested {
    /// Champs communs.
    #[serde(flatten)]
    pub message: AuthMessagePayload,
}

impl Event for RecoveryRequested {
    const EVENT_TYPE: &'static str = "auth.recovery.requested";
}

/// `auth.invitation.created` : lien d'acceptation d'une invitation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvitationCreated {
    /// Champs communs.
    #[serde(flatten)]
    pub message: AuthMessagePayload,
    /// Invitation.
    pub invitation_id: String,
    /// Organisation invitante.
    pub organization_name: String,
    /// Auteur de l'invitation.
    pub inviter_name: Option<String>,
}

impl Event for InvitationCreated {
    const EVENT_TYPE: &'static str = "auth.invitation.created";
}

/// Événement `auth.*` transformé en déclenchement.
pub trait AuthMessage: Event {
    /// Champs communs.
    fn message(&self) -> &AuthMessagePayload;
    /// Variables non sensibles du parcours.
    fn variables(&self) -> serde_json::Value;
}

impl AuthMessage for VerificationRequested {
    fn message(&self) -> &AuthMessagePayload {
        &self.message
    }
    fn variables(&self) -> serde_json::Value {
        compact(serde_json::json!({ "identity_id": self.message.identity_id }))
    }
}

impl AuthMessage for RecoveryRequested {
    fn message(&self) -> &AuthMessagePayload {
        &self.message
    }
    fn variables(&self) -> serde_json::Value {
        compact(serde_json::json!({ "identity_id": self.message.identity_id }))
    }
}

impl AuthMessage for InvitationCreated {
    fn message(&self) -> &AuthMessagePayload {
        &self.message
    }
    fn variables(&self) -> serde_json::Value {
        compact(serde_json::json!({
            "invitation_id": self.invitation_id,
            "organization_name": self.organization_name,
            "inviter_name": self.inviter_name
        }))
    }
}

/// Champs d'une alerte de sécurité (aucun secret).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SecurityAlertPayload {
    /// Identité concernée.
    pub identity_id: String,
    /// Adresse de destination.
    pub recipient_email: Option<String>,
    /// Langue (BCP 47).
    pub recipient_locale: Option<String>,
    /// Nom affiché.
    pub recipient_name: Option<String>,
    /// Méthode (`totp`, `passkey`, `all`).
    #[serde(default)]
    pub method: Option<String>,
    /// Nom de la passkey.
    #[serde(default)]
    pub label: Option<String>,
    /// Motif (`owner`, `admin_reset`).
    #[serde(default)]
    pub reason: Option<String>,
    /// Codes de secours restants.
    #[serde(default)]
    pub remaining: Option<i64>,
    /// Premier mot de passe (création du compte) : aucune alerte.
    #[serde(default)]
    pub first: Option<bool>,
}

/// Alerte de sécurité : nature transmise au gabarit (`payload.alert`).
pub trait SecurityAlert: Event {
    /// Nature (`mfa_enrolled`, `mfa_removed`, …).
    const ALERT: &'static str;
    /// Champs de l'alerte.
    fn alert(&self) -> &SecurityAlertPayload;
}

macro_rules! security_alert {
    ($name:ident, $event:literal, $alert:literal, $doc:literal) => {
        #[doc = $doc]
        #[derive(Debug, Clone, Serialize, Deserialize)]
        pub struct $name {
            /// Champs de l'alerte.
            #[serde(flatten)]
            pub alert: SecurityAlertPayload,
        }

        impl Event for $name {
            const EVENT_TYPE: &'static str = $event;
        }

        impl SecurityAlert for $name {
            const ALERT: &'static str = $alert;
            fn alert(&self) -> &SecurityAlertPayload {
                &self.alert
            }
        }
    };
}

security_alert!(
    MfaEnrolled,
    "auth.mfa.enrolled",
    "mfa_enrolled",
    "`auth.mfa.enrolled` : second facteur ajouté."
);
security_alert!(
    MfaRemoved,
    "auth.mfa.removed",
    "mfa_removed",
    "`auth.mfa.removed` : second facteur retiré (titulaire ou administrateur)."
);
security_alert!(
    RecoveryCodesGenerated,
    "auth.mfa.recovery_codes_generated",
    "recovery_codes_generated",
    "`auth.mfa.recovery_codes_generated` : nouveaux codes de secours."
);
security_alert!(
    RecoveryCodeUsed,
    "auth.mfa.recovery_code_used",
    "recovery_code_used",
    "`auth.mfa.recovery_code_used` : code de secours utilisé."
);
security_alert!(
    PasswordChanged,
    "auth.password.changed",
    "password_changed",
    "`auth.password.changed` : mot de passe changé."
);
security_alert!(
    PasskeyCloneDetected,
    "auth.passkey.clone_detected",
    "passkey_clone_detected",
    "`auth.passkey.clone_detected` : passkey possiblement clonée, refusée."
);

/// Handler des alertes de sécurité : déclenchement idempotent du parcours
/// `auth_security_alert` (sans secret).
pub struct SecurityAlertHandler {
    store: NotificationStore,
}

impl SecurityAlertHandler {
    /// Handler sur le store de la session système de l'hôte.
    pub fn new(store: NotificationStore) -> Self {
        Self { store }
    }

    /// Déclenche l'alerte (idempotent par l'identifiant d'événement) ; rien pour le premier mot
    /// de passe d'un compte ni sans adresse de destination.
    pub async fn deliver<E: SecurityAlert>(
        &self,
        event: &E,
        event_id: &str,
    ) -> NotificationResult<()> {
        let alert = event.alert();
        let Some(email) = alert.recipient_email.clone() else {
            return Ok(());
        };
        if alert.first == Some(true) {
            return Ok(());
        }
        self.store
            .trigger(TriggerParams {
                tenant: None,
                workflow_key: Some(SECURITY_ALERT_WORKFLOW.to_string()),
                trigger_event: None,
                idempotency_key: event_id.to_string(),
                event_id: Some(event_id.to_string()),
                recipient: Recipient {
                    email,
                    locale: alert.recipient_locale.clone(),
                    name: alert.recipient_name.clone(),
                },
                payload: compact(serde_json::json!({
                    "alert": E::ALERT,
                    "method": alert.method,
                    "label": alert.label,
                    "reason": alert.reason,
                    "remaining": alert.remaining
                })),
                secret: None,
                expires_at: None,
            })
            .await?;
        Ok(())
    }
}

#[async_trait]
impl<E: SecurityAlert> Handler<E> for SecurityAlertHandler {
    async fn handle(&self, event: E, ctx: &HandlerContext) -> Result<(), LyxalEventError> {
        let event_id = ctx.event_id.0.to_string();
        self.deliver(&event, &event_id)
            .await
            .map_err(|error| LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: E::EVENT_TYPE.to_string(),
                error: format!("{} : {error}", error.code()),
                terminal: !error.is_retryable(),
            })
    }
}

/// Retire les valeurs absentes (`null` serait refusé par le schéma des variables).
fn compact(value: serde_json::Value) -> serde_json::Value {
    match value {
        serde_json::Value::Object(map) => {
            serde_json::Value::Object(map.into_iter().filter(|(_, v)| !v.is_null()).collect())
        }
        other => other,
    }
}

/// Handler commun aux événements `auth.*`.
pub struct AuthMessageHandler<R: KeyResolver> {
    store: NotificationStore,
    codec: SecretCodec<R>,
}

impl<R: KeyResolver> AuthMessageHandler<R> {
    /// Handler sur le store de la session système de l'hôte et le trousseau applicatif.
    pub fn new(store: NotificationStore, codec: SecretCodec<R>) -> Self {
        Self { store, codec }
    }

    /// Ouvre, rescelle et déclenche (idempotent par l'identifiant d'événement).
    pub async fn deliver<E: AuthMessage>(
        &self,
        event: &E,
        event_id: &str,
    ) -> NotificationResult<()> {
        let message = event.message();
        let tenant = message.tenant.as_deref();
        let opened = self.codec.open_event_secret(
            &message.secret,
            tenant,
            AUTH_PRODUCER,
            E::EVENT_TYPE,
            event_id,
        )?;
        let sealed = self.codec.seal_for_queue(&opened, tenant, event_id)?;
        drop(opened);
        let expires_at = NotificationDatetime::from_str(&message.expires_at)
            .map_err(|_| NotificationError::Secret("expires_at invalide".to_string()))?;
        self.store
            .trigger(TriggerParams {
                tenant: message
                    .tenant
                    .as_ref()
                    .map(|key| format!("auth_organization:{key}")),
                workflow_key: None,
                trigger_event: Some(E::EVENT_TYPE.to_string()),
                idempotency_key: event_id.to_string(),
                event_id: Some(event_id.to_string()),
                recipient: Recipient {
                    email: message.recipient_email.clone(),
                    locale: message.recipient_locale.clone(),
                    name: message.recipient_name.clone(),
                },
                payload: event.variables(),
                secret: Some(sealed),
                expires_at: Some(expires_at),
            })
            .await?;
        Ok(())
    }
}

#[async_trait]
impl<R, E> Handler<E> for AuthMessageHandler<R>
where
    R: KeyResolver + 'static,
    E: AuthMessage,
{
    async fn handle(&self, event: E, ctx: &HandlerContext) -> Result<(), LyxalEventError> {
        let event_id = ctx.event_id.0.to_string();
        self.deliver(&event, &event_id)
            .await
            .map_err(|error| LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: E::EVENT_TYPE.to_string(),
                error: format!("{} : {error}", error.code()),
                terminal: !error.is_retryable(),
            })
    }
}

/// Consommateur des événements `auth.*` (enregistré par l'hôte quand la clé applicative est
/// configurée).
pub struct NotificationConsumer<R: KeyResolver> {
    store: NotificationStore,
    codec: SecretCodec<R>,
}

impl<R: KeyResolver> NotificationConsumer<R> {
    /// Consommateur sur le store de la session système de l'hôte et le trousseau applicatif.
    pub fn new(store: NotificationStore, codec: SecretCodec<R>) -> Self {
        Self { store, codec }
    }
}

impl<R: KeyResolver + 'static> EventConsumerModule for NotificationConsumer<R> {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        let error = |e: LyxalEventError| RuntimeError::EventEngineError {
            message: e.to_string(),
        };
        registry
            .register::<VerificationRequested, _>(AuthMessageHandler::new(
                self.store.clone(),
                self.codec.clone(),
            ))
            .map_err(error)?;
        registry
            .register::<RecoveryRequested, _>(AuthMessageHandler::new(
                self.store.clone(),
                self.codec.clone(),
            ))
            .map_err(error)?;
        registry
            .register::<InvitationCreated, _>(AuthMessageHandler::new(
                self.store.clone(),
                self.codec.clone(),
            ))
            .map_err(error)?;
        let alerts = || SecurityAlertHandler::new(self.store.clone());
        registry
            .register::<MfaEnrolled, _>(alerts())
            .map_err(error)?;
        registry
            .register::<MfaRemoved, _>(alerts())
            .map_err(error)?;
        registry
            .register::<RecoveryCodesGenerated, _>(alerts())
            .map_err(error)?;
        registry
            .register::<RecoveryCodeUsed, _>(alerts())
            .map_err(error)?;
        registry
            .register::<PasswordChanged, _>(alerts())
            .map_err(error)?;
        registry
            .register::<PasskeyCloneDetected, _>(alerts())
            .map_err(error)?;
        Ok(())
    }
}
