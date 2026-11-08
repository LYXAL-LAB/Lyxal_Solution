//! Module `lyxal_notification` : implémentation `LyxalModule`, consommateur des événements
//! `auth.*`, workers d'envoi et de purge, sonde de santé.
//!
//! L'envoi demande la clé applicative (`LYXAL__CRYPTO__APPLICATION_KEY`, secrets scellés) et le
//! relais SMTP (`LYXAL__NOTIFICATION__SMTP__*`). Sans l'un des deux : aucun e-mail n'est envoyé,
//! les abonnements aux événements `auth.*` sont suspendus (les événements attendent en file et
//! reprennent quand la configuration est complète) et la sonde le signale.

use crate::config::{AppConfig, CryptoConfig, SmtpConfig};
use crate::error::ServerError;
use lyxal_crypto::{
    CryptoEngine, EnvironmentKeyProvider, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver,
};
use lyxal_event::EventSubscription;
use lyxal_notification::{
    EmailTransport, EmailWorkerSettings, NotificationConsumer, NotificationEmailWorker,
    NotificationHealthCheck, NotificationModule, NotificationPurgeWorker, NotificationStore,
    SecretCodec, SmtpSecurity, SmtpSettings, SmtpTransport, AUTH_HANDLER, AUTH_SUBSCRIPTIONS,
    CONSUMER_MODULE,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_notification::MODULE_ID;

/// Variable d'environnement de la clé applicative.
const APPLICATION_KEY_VAR: &str = "LYXAL__CRYPTO__APPLICATION_KEY";
/// Intervalle de la purge.
const PURGE_INTERVAL: Duration = Duration::from_secs(600);
/// Éléments purgés par paquet.
const PURGE_BATCH: u32 = 500;
/// Tentatives de livraison d'un événement `auth.*` avant lettre morte.
const AUTH_EVENT_MAX_ATTEMPTS: u32 = 10;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(NotificationModule::new())
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Trousseau applicatif : une clé active lue par `EnvironmentKeyProvider`. `None` si la clé n'est
/// pas fournie ; une clé fournie mais invalide (ou sans identifiant) arrête le démarrage.
pub fn application_crypto(
    config: &CryptoConfig,
) -> Result<Option<Arc<CryptoEngine<StaticKeyResolver>>>, ServerError> {
    if config.application_key.is_none() {
        return Ok(None);
    }
    let id = config
        .application_key_id
        .as_deref()
        .ok_or_else(|| configuration_error("crypto.application_key_id", "obligatoire avec la clé"))
        .and_then(|id| KeyId::parse(id).map_err(|e| configuration_error("crypto.application_key_id", e)))?;
    let key = EnvironmentKeyProvider::load(APPLICATION_KEY_VAR, id)
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    let mut builder = KeyRingBuilder::new();
    builder
        .insert_resolved(key, KeyUse::Active)
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    let ring = builder
        .build()
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    Ok(Some(Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(ring))))))
}

fn smtp_transport(config: &SmtpConfig) -> Result<Arc<dyn EmailTransport>, ServerError> {
    let security = SmtpSecurity::parse(&config.security)
        .map_err(|e| configuration_error("notification.smtp.security", e))?;
    let password = config.password.as_ref().map(|p| p.to_secret()).transpose()?;
    let transport = SmtpTransport::new(SmtpSettings {
        host: config.host.clone(),
        port: config.port,
        security,
        username: config.username.clone(),
        password,
        from_address: config.from_address.clone(),
        from_name: config.from_name.clone(),
        timeout: Duration::from_secs(config.timeout_seconds.clamp(1, 300)),
    })
    .map_err(|e| configuration_error("notification.smtp", e))?;
    Ok(Arc::new(transport))
}

/// Purge, sonde et, si la clé applicative et le relais SMTP sont configurés, consommateur des
/// événements `auth.*` et worker d'envoi. Renvoie vrai si l'envoi est actif.
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
) -> Result<bool, ServerError> {
    let store = NotificationStore::new(client.clone());
    runtime.register_worker(Arc::new(NotificationPurgeWorker::new(
        store.clone(),
        PURGE_INTERVAL,
        PURGE_BATCH,
    )?))?;
    let crypto = application_crypto(&config.crypto)?;
    let transport = config.notification.smtp.as_ref().map(smtp_transport).transpose()?;
    let enabled = match (crypto, transport.clone()) {
        (Some(crypto), Some(transport)) => {
            let codec = SecretCodec::new(crypto);
            runtime
                .register_event_consumer(Arc::new(NotificationConsumer::new(store.clone(), codec.clone())))
                .await;
            runtime.register_worker(Arc::new(NotificationEmailWorker::new(
                store.clone(),
                codec,
                transport,
                EmailWorkerSettings::default(),
            )?))?;
            true
        }
        (crypto, transport) => {
            tracing::warn!(
                application_key = crypto.is_some(),
                smtp = transport.is_some(),
                "envoi des notifications désactivé : LYXAL__CRYPTO__APPLICATION_KEY et LYXAL__NOTIFICATION__SMTP__* requis"
            );
            false
        }
    };
    runtime.health_registry().register_check(Arc::new(NotificationHealthCheck::new(
        store,
        if enabled { transport } else { None },
    )))?;
    Ok(enabled)
}

/// Après l'installation des modules : abonnements aux événements `auth.*`, actifs si l'envoi est
/// configuré, suspendus sinon.
pub async fn reconcile_subscriptions(runtime: &LyxalRuntime, enabled: bool) -> Result<(), ServerError> {
    let event_store = runtime.event_store().ok_or(ServerError::Runtime(
        lyxal_runtime::RuntimeError::StoreMissing {
            component: "event_store",
        },
    ))?;
    for (name, event_type) in AUTH_SUBSCRIPTIONS {
        event_store
            .register_subscription(&EventSubscription {
                id: None,
                name: name.to_string(),
                target_module: CONSUMER_MODULE.to_string(),
                event_pattern: event_type.to_string(),
                handler_name: AUTH_HANDLER.to_string(),
                is_active: enabled,
                max_attempts: AUTH_EVENT_MAX_ATTEMPTS,
                created_at: None,
            })
            .await
            .map_err(|error| ServerError::Database {
                message: format!("abonnement {name} : {error}"),
            })?;
    }
    Ok(())
}
