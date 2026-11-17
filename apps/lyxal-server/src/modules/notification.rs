//! Module `lyxal_notification` : implémentation `LyxalModule` (planification de la purge par
//! `lyxal_scheduler` à l'installation), consommateur des événements `auth.*`, workers d'envoi, de
//! diffusion et d'étapes (attentes confiées au planificateur), sonde de santé, liens de
//! désabonnement, aperçu des étapes, retours des fournisseurs et essai des intégrations.
//!
//! L'envoi passe par les intégrations du module (fournisseur par canal et par portée), dont les
//! identifiants sont lus dans `lyxal_secrets` : il demande la clé applicative
//! (`LYXAL__CRYPTO__APPLICATION_KEY`, secrets scellés des messages) et la clé maîtresse du
//! coffre-fort (`LYXAL__SECRETS__MASTER_KEY`). Sans l'une des deux : aucun e-mail n'est envoyé,
//! les abonnements aux événements `auth.*` sont suspendus (les événements attendent en file) et la
//! sonde le signale. Sans intégration e-mail, les e-mails attendent en file (sonde « dégradé »)
//! jusqu'à ce qu'un administrateur de la plateforme crée celle de l'installation. Les diffusions
//! sont toujours découpées en déclenchements. Les liens de désabonnement en un clic demandent la
//! clé applicative (clé de signature dérivée par HKDF) et l'adresse publique de l'hôte
//! (`LYXAL__NOTIFICATION__PUBLIC_URL`). SMS, messageries d'équipe et adresses web (lot 4) : un
//! worker par canal, sous les mêmes conditions que l'e-mail ; les adresses de messagerie et web
//! sont scellées par les routes de l'hôte avec la clé applicative ; les retours de livraison des
//! SMS sont demandés à l'adresse publique de l'hôte.

use crate::config::AppConfig;
use crate::error::ServerError;
use crate::modules::secrets::SecretsHost;
use lyxal_crypto::{CryptoEngine, StaticKeyResolver};
use lyxal_event::EventSubscription;
use lyxal_notification::{
    BroadcastWorkerSettings, ChannelDispatcher, ChatSender, EmailDispatcher, EmailProviders,
    NotificationBroadcastWorker, NotificationChannelWorker, NotificationConsumer,
    NotificationEmailWorker, NotificationHealthCheck, NotificationModule, NotificationStepWorker,
    NotificationStore, OutboundClient, SecretCodec, SendWorkerSettings, SmsApi, StepWorkerSettings,
    TextChannel, UnsubscribeLinks, AUTH_HANDLER, AUTH_SUBSCRIPTIONS, CONSUMER_MODULE,
    SECRETS_CONSUMER,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_notification::MODULE_ID;

/// Tentatives de livraison d'un événement `auth.*` avant lettre morte.
const AUTH_EVENT_MAX_ATTEMPTS: u32 = 10;

/// Ce que les routes `/notification/*` reçoivent de l'hôte : la session système, les liens de
/// désabonnement s'ils sont configurés, l'envoi par les intégrations (retours des fournisseurs,
/// essai) si le coffre-fort a sa clé maîtresse, le scellement des adresses de messagerie et web
/// si la clé applicative est configurée, et l'adresse publique de l'hôte (signature des retours
/// Twilio).
#[derive(Clone)]
pub struct NotificationHost {
    pub store: NotificationStore,
    pub links: Option<Arc<UnsubscribeLinks>>,
    pub dispatcher: Option<EmailDispatcher>,
    pub channels: Option<ChannelDispatcher>,
    pub codec: Option<SecretCodec<StaticKeyResolver>>,
    pub public_url: Option<String>,
}

/// Services du module enregistrés auprès du runtime.
pub struct NotificationServices {
    /// Envoi configuré (clé applicative et clé maîtresse du coffre-fort).
    pub delivery: bool,
    /// Routes de l'hôte.
    pub host: NotificationHost,
}

/// Module sur la session système de l'hôte (planification de la purge à l'installation).
pub fn module(client: &Surreal<Any>) -> Arc<dyn LyxalModule> {
    Arc::new(NotificationModule::new(client.clone()))
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
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

/// Attentes des parcours, diffusions, sonde et, si la clé applicative et la clé maîtresse du
/// coffre-fort sont configurées, consommateur des événements `auth.*` et worker d'envoi par les
/// intégrations (avec les liens de désabonnement s'ils sont configurés).
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
    secrets: &SecretsHost,
) -> Result<NotificationServices, ServerError> {
    let store = NotificationStore::new(client.clone());
    runtime.register_worker(Arc::new(NotificationStepWorker::new(
        store.clone(),
        StepWorkerSettings::default(),
    )?))?;
    runtime.register_worker(Arc::new(NotificationBroadcastWorker::new(
        store.clone(),
        BroadcastWorkerSettings::default(),
    )?))?;
    let links = unsubscribe_links(config)?;
    let providers = Arc::new(
        EmailProviders::new().map_err(|e| configuration_error("fournisseurs d'e-mail", e))?,
    );
    // Identifiants lus par la session système, le module annoncé comme consommateur
    let dispatcher = secrets
        .has_master_key()
        .then(|| EmailDispatcher::new(providers, secrets.client(SECRETS_CONSUMER)));
    let public_url = config.notification.public_url.clone();
    let sms = Arc::new(SmsApi::new().map_err(|e| configuration_error("fournisseurs de SMS", e))?);
    let chat = Arc::new(
        ChatSender::new(OutboundClient::new())
            .map_err(|e| configuration_error("messageries", e.detail))?,
    );
    let channels = secrets.has_master_key().then(|| {
        ChannelDispatcher::new(
            sms,
            chat,
            secrets.client(SECRETS_CONSUMER),
            public_url.as_deref(),
        )
    });
    let codec = crypto.map(SecretCodec::new);
    let delivery = match (codec.clone(), dispatcher.clone(), channels.clone()) {
        (Some(codec), Some(dispatcher), Some(channels)) => {
            runtime
                .register_event_consumer(Arc::new(NotificationConsumer::new(
                    store.clone(),
                    codec.clone(),
                )))
                .await;
            let worker = NotificationEmailWorker::new(
                store.clone(),
                codec.clone(),
                dispatcher,
                SendWorkerSettings::default(),
            )?;
            let worker = match &links {
                Some(links) => worker.with_unsubscribe_links(links.clone()),
                None => worker,
            };
            runtime.register_worker(Arc::new(worker))?;
            // Un worker par canal de texte : SMS, messagerie, adresse web
            for channel in [TextChannel::Sms, TextChannel::Chat, TextChannel::Webhook] {
                let worker = NotificationChannelWorker::new(
                    channel,
                    store.clone(),
                    codec.clone(),
                    channels.clone(),
                    SendWorkerSettings::default(),
                )?;
                let worker = match &links {
                    Some(links) => worker.with_unsubscribe_links(links.clone()),
                    None => worker,
                };
                runtime.register_worker(Arc::new(worker))?;
            }
            true
        }
        (codec, dispatcher, _) => {
            tracing::warn!(
                application_key = codec.is_some(),
                secrets_master_key = dispatcher.is_some(),
                "envoi des notifications désactivé : LYXAL__CRYPTO__APPLICATION_KEY et LYXAL__SECRETS__MASTER_KEY requis"
            );
            false
        }
    };
    runtime
        .health_registry()
        .register_check(Arc::new(NotificationHealthCheck::new(
            store.clone(),
            delivery,
        )))?;
    Ok(NotificationServices {
        delivery,
        host: NotificationHost {
            store,
            links,
            dispatcher,
            channels,
            codec,
            public_url,
        },
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
