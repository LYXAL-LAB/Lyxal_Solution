//! Worker du canal `push` : réserve les étapes push dues (`fn::notification_job_claim`,
//! canal `push` : appareils scellés de l'abonné, chacun avec l'intégration de son service), les
//! reporte dans les heures calmes de l'abonné, rend la notification (`Renderer::render_push`,
//! jamais le secret), contrôle ses liens (`fn::notification_push_links_check`, règles du fil),
//! la ramène à 4 Kio (texte tronqué), puis l'envoie à chaque appareil : jeton et clés ouverts en
//! mémoire le temps de l'envoi, identifiants de l'intégration lus une fois par étape dans
//! `lyxal_secrets`. Un appareil que son service déclare invalide est retiré
//! (`fn::notification_device_remove`, événement `notification.endpoint.removed`) ; l'étape réussit
//! si un appareil a reçu la notification, dans cette tentative ou une précédente (décision G5).
//!
//! Annulation coopérative : la réservation, le renouvellement, le contrôle des liens, la lecture
//! des identifiants et chaque envoi sont mis en course avec l'arrêt du worker. Après l'arrêt,
//! aucun envoi ne commence ; les écritures qui enregistrent ce qui est déjà parti (ou rendent
//! l'étape à la file) restent faites, bornées par `cleanup` : les couper renverrait la
//! notification aux appareils déjà servis.

use async_trait::async_trait;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{KeyResolver, SecretString};
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext, WorkerDescriptor};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::collections::HashMap;
use std::future::Future;
use std::time::Duration;
use zeroize::Zeroizing;

use crate::error::NotificationError;
use crate::models::{
    ClaimedEndpoint, ClaimedJob, DeviceRemoveParams, EndpointOutcome, FailureClass, PushLinksParams,
};
use crate::provider::{
    DeviceRemoval, ProviderError, ProviderReceipt, PushCredentials, PushDispatcher, PushFailure,
    PushMessage, PushService, PushTarget,
};
use crate::quiet::quiet_until;
use crate::render::Renderer;
use crate::secret::{DeviceField, SecretCodec};
use crate::store::NotificationStore;
use crate::worker::{
    nothing_delivered, permanent, send_descriptor, Delivery, JobOutcome, JobQueue,
    SendWorkerSettings,
};

/// Borne par défaut des écritures faites après l'arrêt (étape rendue, issue enregistrée).
pub const PUSH_CLEANUP_BUDGET: Duration = Duration::from_secs(10);

/// Worker d'envoi des notifications push.
pub struct NotificationPushWorker<R: KeyResolver> {
    descriptor: WorkerDescriptor,
    queue: JobQueue,
    codec: SecretCodec<R>,
    dispatcher: PushDispatcher,
    renderer: Renderer,
    cleanup: Duration,
}

/// Issue de la course entre une attente et l'arrêt du worker.
enum Raced<T> {
    Done(T),
    Stopped,
}

async fn race<T>(cancellation: &CancellationToken, future: impl Future<Output = T>) -> Raced<T> {
    tokio::select! {
        biased;
        _ = cancellation.cancelled() => Raced::Stopped,
        value = future => Raced::Done(value),
    }
}

impl<R: KeyResolver + 'static> NotificationPushWorker<R> {
    /// Worker sur la session système de l'hôte, le trousseau applicatif (jetons et clés scellés
    /// des appareils) et l'envoi par les intégrations push.
    pub fn new(
        store: NotificationStore,
        codec: SecretCodec<R>,
        dispatcher: PushDispatcher,
        settings: SendWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let descriptor = send_descriptor(
            "push_sender",
            "Lyxal Notification Push Sender",
            "Envoi des notifications push (Web Push, FCM, APNs) de la file de notifications",
            &settings,
        )?;
        Ok(Self {
            queue: JobQueue {
                store,
                settings,
                worker_id: descriptor.id.to_string(),
                channel: "push",
            },
            descriptor,
            codec,
            dispatcher,
            renderer: Renderer::default(),
            cleanup: PUSH_CLEANUP_BUDGET,
        })
    }

    /// Borne des écritures faites après l'arrêt (10 s par défaut).
    pub fn with_cleanup_budget(mut self, cleanup: Duration) -> Self {
        self.cleanup = cleanup;
        self
    }

    /// Écriture de nettoyage bornée : au-delà, l'étape est reprise à l'expiration de sa
    /// réservation.
    async fn bounded(&self, future: impl Future<Output = JobOutcome>) -> JobOutcome {
        tokio::time::timeout(self.cleanup, future)
            .await
            .unwrap_or(JobOutcome::Abandoned)
    }

    /// Un tour : réserve et traite les étapes push dues, une à la fois (voir le module).
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<Vec<JobOutcome>, NotificationError> {
        if cancellation.is_cancelled() {
            return Ok(Vec::new());
        }
        // Arrêt pendant la réservation : les étapes réservées sont reprises à l'expiration
        let jobs = match race(cancellation, self.queue.claim()).await {
            Raced::Done(jobs) => jobs?,
            Raced::Stopped => return Ok(Vec::new()),
        };
        let mut outcomes = Vec::with_capacity(jobs.len());
        for job in jobs {
            if cancellation.is_cancelled() {
                outcomes.push(self.bounded(self.queue.release(&job, None)).await);
                continue;
            }
            if let Some(end) = job
                .quiet_hours
                .as_ref()
                .and_then(|rule| quiet_until(rule, jiff::Timestamp::now()))
            {
                outcomes.push(self.queue.defer(&job, end).await);
                continue;
            }
            match race(cancellation, self.queue.renew(&job)).await {
                Raced::Stopped => {
                    outcomes.push(self.bounded(self.queue.release(&job, None)).await);
                    continue;
                }
                Raced::Done(Err(error)) => {
                    tracing::warn!(job = %job.job_id.to_sql(), code = %error.code(), "réservation perdue avant l'envoi : notification non envoyée");
                    outcomes.push(JobOutcome::Abandoned);
                    continue;
                }
                Raced::Done(Ok(())) => {}
            }
            let job_id = job.job_id.to_sql();
            match tokio::time::timeout(
                self.queue.settings.job_budget,
                self.process(&job, cancellation),
            )
            .await
            {
                Ok(outcome) => outcomes.push(outcome),
                Err(_) => {
                    tracing::warn!(job = %job_id, "traitement de l'étape trop long : reprise à l'expiration de la réservation");
                    outcomes.push(JobOutcome::Abandoned);
                }
            }
        }
        Ok(outcomes)
    }

    /// Rend la notification, contrôle ses liens et la ramène à 4 Kio.
    async fn message(
        &self,
        job: &ClaimedJob,
        cancellation: &CancellationToken,
    ) -> Result<Raced<PushMessage>, ProviderError> {
        let rendered = self
            .renderer
            .render_push(job)
            .map_err(|error| permanent(&error))?;
        let checked = match race(
            cancellation,
            self.queue.store.push_links_check(PushLinksParams {
                link: rendered.link.clone(),
                icon: rendered.icon.clone(),
            }),
        )
        .await
        {
            Raced::Stopped => return Ok(Raced::Stopped),
            Raced::Done(checked) => checked.map_err(|error| {
                ProviderError::unavailable(format!(
                    "contrôle des liens impossible ({})",
                    NotificationError::from(error).code()
                ))
            })?,
        };
        if !checked.refused.is_empty() {
            return Err(permanent(&NotificationError::Render(format!(
                "lien rendu refusé : {}",
                checked.refused.join(", ")
            ))));
        }
        Ok(Raced::Done(
            PushMessage {
                title: rendered.title,
                body: rendered.text,
                link: rendered.link,
                icon: rendered.icon,
                data: rendered.data,
                urgent: job.critical,
            }
            .fitted()?,
        ))
    }

    async fn process(&self, job: &ClaimedJob, cancellation: &CancellationToken) -> JobOutcome {
        let message = match self.message(job, cancellation).await {
            Ok(Raced::Done(message)) => message,
            Ok(Raced::Stopped) => return self.bounded(self.queue.release(job, None)).await,
            Err(error) => return self.queue.finish(job, Err((error, Vec::new()))).await,
        };
        let mut outcomes = Vec::with_capacity(job.endpoints.len());
        let mut first_failure: Option<ProviderError> = None;
        let mut transient: Option<ProviderError> = None;
        let mut credentials: HashMap<String, Result<PushCredentials, ProviderError>> =
            HashMap::new();
        let mut stopped = false;
        for endpoint in &job.endpoints {
            if cancellation.is_cancelled() {
                stopped = true;
                break;
            }
            let integration = endpoint.integration.id.to_sql();
            if !credentials.contains_key(&integration) {
                match race(
                    cancellation,
                    self.dispatcher.credentials(&endpoint.integration),
                )
                .await
                {
                    Raced::Done(read) => {
                        credentials.insert(integration.clone(), read);
                    }
                    Raced::Stopped => {
                        stopped = true;
                        break;
                    }
                }
            }
            let result = match credentials.get(&integration) {
                Some(Ok(keys)) => {
                    let sent =
                        send_to_device(&self.codec, &self.dispatcher, endpoint, keys, &message);
                    match race(cancellation, sent).await {
                        Raced::Done(result) => result,
                        Raced::Stopped => {
                            stopped = true;
                            break;
                        }
                    }
                }
                Some(Err(error)) => Err(PushFailure::from(error.clone())),
                None => Err(ProviderError::secret("identifiants absents").into()),
            };
            if let Err(failure) = &result {
                tracing::warn!(job = %job.job_id.to_sql(), endpoint = %endpoint.id.to_sql(), provider = %endpoint.provider, code = %failure.error.code, "notification push refusée");
                if let Some(removal) = failure.removal {
                    self.remove(endpoint, removal.as_str(), cancellation).await;
                }
                if failure.error.class == FailureClass::Transient && transient.is_none() {
                    transient = Some(failure.error.clone());
                }
                first_failure.get_or_insert(failure.error.clone());
            }
            outcomes.push(match result {
                Ok(receipt) => EndpointOutcome {
                    endpoint: endpoint.id.to_sql(),
                    integration,
                    ok: true,
                    code: None,
                    provider_message_id: receipt.message_id,
                    response_code: Some(i64::from(receipt.code)),
                },
                Err(failure) => EndpointOutcome {
                    endpoint: endpoint.id.to_sql(),
                    integration,
                    ok: false,
                    code: Some(failure.error.code),
                    provider_message_id: None,
                    response_code: None,
                },
            });
        }
        if stopped {
            // Arrêt : rien de parti, l'étape est rendue ; sinon ce qui est parti est enregistré
            // et les appareils restants sont servis à la tentative suivante
            if outcomes.is_empty() {
                return self.bounded(self.queue.release(job, None)).await;
            }
            let stop = ProviderError::unavailable("arrêt du worker pendant l'envoi");
            return self
                .bounded(self.queue.finish(job, Err((stop, outcomes))))
                .await;
        }
        let result = if let Some(error) = transient {
            Err((error, outcomes))
        } else if nothing_delivered(job.served_endpoints, &outcomes) {
            let error = first_failure
                .unwrap_or_else(|| ProviderError::configuration("aucun appareil à servir"));
            Err((error, outcomes))
        } else {
            Ok(Delivery {
                receipt: None,
                subject: Some(message.title.clone()),
                parts: None,
                endpoints: outcomes,
            })
        };
        self.queue.finish(job, result).await
    }

    /// Retire un appareil invalide (décision G5) ; un appareil déjà retiré ou une base
    /// indisponible n'empêchent pas d'enregistrer l'issue de l'étape.
    async fn remove(
        &self,
        endpoint: &ClaimedEndpoint,
        reason: &str,
        cancellation: &CancellationToken,
    ) {
        let params = DeviceRemoveParams {
            endpoint: endpoint.id.to_sql(),
            reason: reason.to_string(),
        };
        match race(cancellation, self.queue.store.device_remove(params)).await {
            Raced::Done(Ok(_)) => {
                tracing::info!(endpoint = %endpoint.id.to_sql(), provider = %endpoint.provider, reason, "appareil push retiré");
            }
            Raced::Done(Err(error)) => {
                tracing::warn!(endpoint = %endpoint.id.to_sql(), code = %NotificationError::from(error).code(), "appareil push non retiré");
            }
            Raced::Stopped => {}
        }
    }
}

/// Notification à un appareil (essai d'une intégration push par l'hôte) : identifiants de
/// l'intégration lus dans le coffre-fort, jeton et clés ouverts en mémoire le temps de l'envoi.
pub async fn push_to_device<R: KeyResolver>(
    codec: &SecretCodec<R>,
    dispatcher: &PushDispatcher,
    endpoint: &ClaimedEndpoint,
    message: &PushMessage,
) -> Result<ProviderReceipt, ProviderError> {
    let credentials = dispatcher.credentials(&endpoint.integration).await?;
    let message = message.clone().fitted()?;
    send_to_device(codec, dispatcher, endpoint, &credentials, &message)
        .await
        .map_err(|failure| failure.error)
}

/// Envoi à un appareil : jeton et clés ouverts en mémoire le temps de l'envoi.
async fn send_to_device<R: KeyResolver>(
    codec: &SecretCodec<R>,
    dispatcher: &PushDispatcher,
    endpoint: &ClaimedEndpoint,
    credentials: &PushCredentials,
    message: &PushMessage,
) -> Result<ProviderReceipt, PushFailure> {
    let service = PushService::parse(&endpoint.provider)
        .ok_or_else(|| ProviderError::configuration("service push inconnu"))?;
    let token = open_text(
        codec,
        endpoint,
        DeviceField::Token,
        endpoint.token.as_deref(),
    )?;
    let target = match service {
        PushService::WebPush => PushTarget::WebPush {
            endpoint: &token,
            p256dh: open_key::<65, R>(
                codec,
                endpoint,
                DeviceField::P256dh,
                endpoint.p256dh.as_deref(),
            )?,
            auth: Zeroizing::new(open_key::<16, R>(
                codec,
                endpoint,
                DeviceField::Auth,
                endpoint.auth.as_deref(),
            )?),
        },
        PushService::Fcm => PushTarget::Fcm { token: &token },
        PushService::Apns => PushTarget::Apns { token: &token },
    };
    dispatcher
        .send(&endpoint.integration, credentials, &target, message)
        .await
}

/// Valeur scellée d'un appareil ouverte en texte (contexte : organisation et empreinte).
fn open_text<R: KeyResolver>(
    codec: &SecretCodec<R>,
    endpoint: &ClaimedEndpoint,
    field: DeviceField,
    envelope: Option<&str>,
) -> Result<SecretString, ProviderError> {
    let envelope =
        envelope.ok_or_else(|| ProviderError::configuration("valeur de l'appareil absente"))?;
    let fingerprint = endpoint
        .fingerprint
        .as_deref()
        .ok_or_else(|| ProviderError::configuration("empreinte de l'appareil absente"))?;
    codec
        .open_device_value(envelope, endpoint.tenant_key.as_deref(), fingerprint, field)
        .map_err(|error| permanent(&error))?
        .into_utf8()
        .map_err(|_| ProviderError::configuration("valeur de l'appareil illisible"))
}

/// Clé du navigateur (Base64url scellé) ouverte et décodée en `N` octets ; une clé illisible
/// rend l'abonnement inutilisable : l'appareil est retiré.
fn open_key<const N: usize, R: KeyResolver>(
    codec: &SecretCodec<R>,
    endpoint: &ClaimedEndpoint,
    field: DeviceField,
    envelope: Option<&str>,
) -> Result<[u8; N], PushFailure> {
    let text = open_text(codec, endpoint, field, envelope)?;
    let decoded = Zeroizing::new(
        URL_SAFE_NO_PAD
            .decode(text.expose_secret().trim_end_matches('='))
            .unwrap_or_default(),
    );
    <[u8; N]>::try_from(decoded.as_slice()).map_err(|_| PushFailure {
        error: ProviderError {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_DEVICE_INVALID".to_string(),
            detail: "clés du navigateur illisibles".to_string(),
        },
        removal: Some(DeviceRemoval::Invalid),
    })
}

#[async_trait]
impl<R: KeyResolver + 'static> LyxalWorker for NotificationPushWorker<R> {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            let busy = match self.run_once(&ctx.cancellation).await {
                Ok(outcomes) => outcomes.len() >= self.queue.settings.batch_size as usize,
                Err(error) => {
                    tracing::warn!(channel = "push", code = %error.code(), "réservation des envois push impossible");
                    false
                }
            };
            if busy {
                continue;
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.queue.settings.poll_interval) => {}
            }
        }
        Ok(())
    }
}
