//! Consommateur des événements de `lyxal_auth` : `auth.verification.requested`,
//! `auth.recovery.requested`, `auth.invitation.created` (contrat du plan V1-a, §2.1).
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
pub const AUTH_SUBSCRIPTIONS: [(&str, &str); 3] = [
    ("notification_auth_verification", VerificationRequested::EVENT_TYPE),
    ("notification_auth_recovery", RecoveryRequested::EVENT_TYPE),
    ("notification_auth_invitation", InvitationCreated::EVENT_TYPE),
];

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
    pub async fn deliver<E: AuthMessage>(&self, event: &E, event_id: &str) -> NotificationResult<()> {
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
                tenant: message.tenant.as_ref().map(|key| format!("auth_organization:{key}")),
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
        Ok(())
    }
}
