//! Module `lyxal_notification` : implémentation `LyxalModule`, consommateur des événements
//! `auth.*`, workers d'envoi, de diffusion et de purge, sonde de santé, liens de désabonnement.
//!
//! L'envoi demande la clé applicative (`LYXAL__CRYPTO__APPLICATION_KEY`, secrets scellés) et le
//! relais SMTP (`LYXAL__NOTIFICATION__SMTP__*`). Sans l'un des deux : aucun e-mail n'est envoyé,
//! les abonnements aux événements `auth.*` sont suspendus (les événements attendent en file et
//! reprennent quand la configuration est complète) et la sonde le signale. Les diffusions sont
//! toujours découpées en déclenchements (leurs e-mails attendent l'envoi). Les liens de
//! désabonnement en un clic demandent la clé applicative (clé de signature dérivée par HKDF) et
//! l'adresse publique de l'hôte (`LYXAL__NOTIFICATION__PUBLIC_URL`).

use crate::config::{AppConfig, SmtpConfig};
use crate::error::ServerError;
use lyxal_crypto::{CryptoEngine, StaticKeyResolver};
use lyxal_event::EventSubscription;
use lyxal_notification::{
    BroadcastWorkerSettings, EmailTransport, EmailWorkerSettings, NotificationBroadcastWorker,
    NotificationConsumer, NotificationEmailWorker, NotificationHealthCheck, NotificationModule,
    NotificationPurgeWorker, NotificationStore, SecretCodec, SmtpSecurity, SmtpSettings,
    SmtpTransport, UnsubscribeLinks, AUTH_HANDLER, AUTH_SUBSCRIPTIONS, CONSUMER_MODULE,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_notification::MODULE_ID;

/// Intervalle de la purge.
const PURGE_INTERVAL: Duration = Duration::from_secs(600);
/// Éléments purgés par paquet.
const PURGE_BATCH: u32 = 500;
/// Tentatives de livraison d'un événement `auth.*` avant lettre morte.
const AUTH_EVENT_MAX_ATTEMPTS: u32 = 10;

/// Ce que les routes `/notification/*` reçoivent de l'hôte : la session système et, s'ils sont
/// configurés, les liens de désabonnement.
#[derive(Clone)]
pub struct NotificationHost {
    pub store: NotificationStore,
    pub links: Option<Arc<UnsubscribeLinks>>,
}

/// Services du module enregistrés auprès du runtime.
pub struct NotificationServices {
    /// Envoi configuré (clé applicative et relais SMTP).
    pub delivery: bool,
    /// Routes de l'hôte.
    pub host: NotificationHost,
}

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(NotificationModule::new())
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
}

fn smtp_transport(config: &SmtpConfig) -> Result<Arc<dyn EmailTransport>, ServerError> {
    let security = SmtpSecurity::parse(&config.security)
        .map_err(|e| configuration_error("notification.smtp.security", e))?;
    let password = config
        .password
        .as_ref()
        .map(|p| p.to_secret())
        .transpose()?;
    let transport = SmtpTransport::new(SmtpSettings {
        host: config.host.clone(),
        port: config.port,
        security,
        username: config.username.clone(),
        password,
        from_address: config.from_address.clone(),
        from_name: config.from_name.clone(),
        // Délai par commande SMTP, borné pour que l'envoi tienne dans le budget d'une étape
        timeout: Duration::from_secs(config.timeout_seconds.clamp(1, 30)),
    })
    .map_err(|e| configuration_error("notification.smtp", e))?;
    Ok(Arc::new(transport))
}

/// Liens de désabonnement : clé applicative et adresse publique requises ; une adresse invalide
/// arrête le démarrage.
pub fn unsubscribe_links(config: &AppConfig) -> Result<Option<Arc<UnsubscribeLinks>>, ServerError> {
    let material = crate::crypto::application_key_material(&config.crypto)?;
    match (material, config.notification.public_url.as_deref()) {
        (Some(material), Some(public_url)) => UnsubscribeLinks::new(public_url, &material)
            .map(|links| Some(Arc::new(links)))
            .map_err(|e| configuration_error("notification.public_url", e)),
        (material, public_url) => {
            tracing::warn!(
                application_key = material.is_some(),
                public_url = public_url.is_some(),
                "liens de désabonnement désactivés : LYXAL__CRYPTO__APPLICATION_KEY et LYXAL__NOTIFICATION__PUBLIC_URL requis"
            );
            Ok(None)
        }
    }
}

/// Purge, diffusions, sonde et, si la clé applicative et le relais SMTP sont configurés,
/// consommateur des événements `auth.*` et worker d'envoi (avec les liens de désabonnement s'ils
/// sont configurés).
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
) -> Result<NotificationServices, ServerError> {
    let store = NotificationStore::new(client.clone());
    runtime.register_worker(Arc::new(NotificationPurgeWorker::new(
        store.clone(),
        PURGE_INTERVAL,
        PURGE_BATCH,
    )?))?;
    runtime.register_worker(Arc::new(NotificationBroadcastWorker::new(
        store.clone(),
        BroadcastWorkerSettings::default(),
    )?))?;
    let links = unsubscribe_links(config)?;
    let transport = config
        .notification
        .smtp
        .as_ref()
        .map(smtp_transport)
        .transpose()?;
    let delivery = match (crypto, transport.clone()) {
        (Some(crypto), Some(transport)) => {
            let codec = SecretCodec::new(crypto);
            runtime
                .register_event_consumer(Arc::new(NotificationConsumer::new(
                    store.clone(),
                    codec.clone(),
                )))
                .await;
            let worker = NotificationEmailWorker::new(
                store.clone(),
                codec,
                transport,
                EmailWorkerSettings::default(),
            )?;
            let worker = match &links {
                Some(links) => worker.with_unsubscribe_links(links.clone()),
                None => worker,
            };
            runtime.register_worker(Arc::new(worker))?;
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
    runtime
        .health_registry()
        .register_check(Arc::new(NotificationHealthCheck::new(
            store.clone(),
            if delivery { transport } else { None },
        )))?;
    Ok(NotificationServices {
        delivery,
        host: NotificationHost { store, links },
    })
}

/// Après l'installation des modules : abonnements aux événements `auth.*`, actifs si l'envoi est
/// configuré, suspendus sinon.
pub async fn reconcile_subscriptions(
    runtime: &LyxalRuntime,
    enabled: bool,
) -> Result<(), ServerError> {
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
