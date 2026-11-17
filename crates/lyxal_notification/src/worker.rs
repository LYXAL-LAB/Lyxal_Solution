//! Workers supervisés : envoi par canal (e-mail, SMS, messagerie, adresse web, fil dans
//! l'application), diffusions et attentes des parcours.
//!
//! Un worker d'envoi par canal réserve les étapes dues de son canal
//! (`fn::notification_job_claim`, chacune avec l'intégration retenue : D1, bascule D3), reporte
//! celles qui tombent dans les heures calmes de l'abonné (jamais pour l'adresse web), ouvre le
//! secret, rend le message (lien de désabonnement compris), lit les identifiants de
//! l'intégration dans `lyxal_secrets` et l'envoie par son fournisseur, puis termine l'étape ou
//! enregistre l'échec (avec l'intégration utilisée). Messagerie et adresse web : chaque adresse
//! de l'abonné est ouverte en mémoire (`SecretString`, jamais journalisée) le temps de son appel ;
//! une adresse servie n'est pas rappelée par la tentative suivante. Fil (`in_app`) : ni
//! fournisseur, ni intégration, ni secret, ni heures calmes ; le message est rendu (variables
//! échappées) puis livré par `fn::notification_inbox_deliver`, qui contrôle les liens rendus.
//! Délai avant une nouvelle
//! tentative : attente exponentielle plafonnée avec gigue complète (comme `lyxal_event`). Une
//! erreur de base n'interrompt pas le worker : la réservation expire et l'étape est reprise.
//!
//! Le worker des diffusions réserve une diffusion (`fn::notification_broadcast_claim`) et la
//! traite par paquets de 500 abonnés (`fn::notification_broadcast_step`) ; arrêté en cours de
//! route, il laisse expirer sa réservation et la diffusion reprend au paquet suivant, sans
//! doublon.
//!
//! Le worker d'étapes confie à `lyxal_scheduler` les attentes et les regroupements engagés
//! (`fn::notification_wait_schedule`) ; le planificateur reprend chaque déclenchement à leur fin
//! (`fn::notification_run_resume`). La purge est une planification horaire du planificateur
//! (tâche `notification.purge`), créée à l'installation du module.

use async_trait::async_trait;
use lyxal_crypto::{HmacKey, KeyResolver, SecretString};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::sync::Arc;
use std::time::Duration;

use crate::error::NotificationError;
use crate::models::{
    BroadcastClaimParams, BroadcastCompleteParams, BroadcastStepParams, ClaimedEndpoint,
    ClaimedIntegration, ClaimedJob, EndpointOutcome, FailureClass, InboxDeliverParams,
    JobClaimParams, JobCompleteParams, JobFailParams, JobReleaseParams, JobRenewParams,
    NotificationDatetime, NotificationRecordId, WaitScheduleParams, WaitScheduleResult,
};
use crate::provider::{
    ChannelDispatcher, ChatService, EmailDispatcher, EmailMessage, ProviderError, ProviderReceipt,
};
use crate::quiet::quiet_until;
use crate::render::{RenderedInApp, RenderedText, Renderer};
use crate::secret::{EndpointField, SecretCodec};
use crate::segments::SmsSegments;
use crate::store::NotificationStore;
use crate::unsubscribe::UnsubscribeLinks;

/// Identifiant du module propriétaire des workers.
const MODULE: &str = "lyxal_notification";

/// Attente avant une nouvelle tentative : `min(plafond, base × 2^(tentative-1))`, tirée
/// uniformément entre 1 s et cette valeur (gigue complète).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RetryPolicy {
    /// Attente de base.
    pub base: Duration,
    /// Plafond.
    pub cap: Duration,
}

impl Default for RetryPolicy {
    fn default() -> Self {
        Self {
            base: Duration::from_secs(30),
            cap: Duration::from_secs(6 * 3600),
        }
    }
}

impl RetryPolicy {
    /// Plafond de l'attente pour une tentative (1 pour la première).
    pub fn ceiling(&self, attempt: u32) -> Duration {
        let factor = 2u32.saturating_pow(attempt.saturating_sub(1).min(30));
        self.base.saturating_mul(factor).min(self.cap)
    }

    /// Attente tirée pour une tentative.
    pub fn delay(&self, attempt: u32) -> Duration {
        let ceiling = self.ceiling(attempt).as_secs().max(1);
        Duration::from_secs(fastrand::u64(1..=ceiling))
    }
}

/// Réglages d'un worker d'envoi (tous les canaux).
#[derive(Debug, Clone)]
pub struct SendWorkerSettings {
    /// Attente entre deux réservations quand la file est vide.
    pub poll_interval: Duration,
    /// Étapes réservées par tour.
    pub batch_size: u32,
    /// Durée de la réservation, renouvelée juste avant chaque envoi (doit dépasser `job_budget`).
    pub lease: Duration,
    /// Durée maximale du traitement d'une étape (rendu, envoi, enregistrement de l'issue).
    pub job_budget: Duration,
    /// Attente avant une nouvelle tentative.
    pub retry: RetryPolicy,
}

impl Default for SendWorkerSettings {
    fn default() -> Self {
        Self {
            poll_interval: Duration::from_secs(5),
            batch_size: 5,
            lease: Duration::from_secs(300),
            job_budget: Duration::from_secs(120),
            retry: RetryPolicy::default(),
        }
    }
}

/// Issue du traitement d'une étape (journalisée, jamais de contenu).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum JobOutcome {
    /// Message envoyé.
    Sent,
    /// Échec enregistré (nouvelle tentative ou échec définitif).
    Failed(FailureClass),
    /// Réservation perdue ou base indisponible : l'étape sera reprise.
    Abandoned,
    /// Arrêt du worker avant l'envoi : étape rendue à la file sans tentative comptée.
    Released,
    /// Heures calmes de l'abonné : étape rendue à la file jusqu'à leur fin, sans tentative.
    Deferred,
}

/// Envoi d'une étape réservée, propre au canal.
#[async_trait]
trait JobProcessor: Send + Sync {
    async fn process(&self, job: ClaimedJob) -> JobOutcome;
}

/// Envoi accepté : de quoi terminer l'étape.
pub(crate) struct Delivery {
    pub(crate) receipt: Option<ProviderReceipt>,
    pub(crate) subject: Option<String>,
    pub(crate) parts: Option<i64>,
    pub(crate) endpoints: Vec<EndpointOutcome>,
}

/// File d'un canal : réservation, heures calmes, renouvellement, issue enregistrée.
pub(crate) struct JobQueue {
    pub(crate) store: NotificationStore,
    pub(crate) settings: SendWorkerSettings,
    pub(crate) worker_id: String,
    pub(crate) channel: &'static str,
}

impl JobQueue {
    /// Un tour : réserve et traite les étapes dues, une à la fois. Avant chaque envoi, la
    /// réservation est renouvelée (une étape reprise entre-temps par un autre worker n'est pas
    /// envoyée) ; après l'annulation, aucun envoi ne commence et les étapes restantes sont
    /// rendues à la file.
    async fn run_once(
        &self,
        cancellation: &CancellationToken,
        processor: &dyn JobProcessor,
    ) -> Result<Vec<JobOutcome>, NotificationError> {
        let jobs = self.claim().await?;
        let mut outcomes = Vec::with_capacity(jobs.len());
        for job in jobs {
            if cancellation.is_cancelled() {
                outcomes.push(self.release(&job, None).await);
                continue;
            }
            if let Some(end) = job
                .quiet_hours
                .as_ref()
                .and_then(|rule| quiet_until(rule, jiff::Timestamp::now()))
            {
                outcomes.push(self.defer(&job, end).await);
                continue;
            }
            if let Err(error) = self
                .store
                .job_renew(JobRenewParams {
                    job_id: job.job_id.to_sql(),
                    claim_token: job.claim_token.clone(),
                    lease_seconds: self.lease_seconds(),
                })
                .await
            {
                tracing::warn!(job = %job.job_id.to_sql(), code = %NotificationError::from(error).code(), "réservation perdue avant l'envoi : étape non envoyée");
                outcomes.push(JobOutcome::Abandoned);
                continue;
            }
            let job_id = job.job_id.to_sql();
            match tokio::time::timeout(self.settings.job_budget, processor.process(job)).await {
                Ok(outcome) => outcomes.push(outcome),
                Err(_) => {
                    tracing::warn!(job = %job_id, "traitement de l'étape trop long : reprise à l'expiration de la réservation");
                    outcomes.push(JobOutcome::Abandoned);
                }
            }
        }
        Ok(outcomes)
    }

    /// Réserve les étapes dues du canal.
    pub(crate) async fn claim(&self) -> Result<Vec<ClaimedJob>, NotificationError> {
        Ok(self
            .store
            .job_claim(JobClaimParams {
                worker_id: self.worker_id.clone(),
                channel: self.channel.to_string(),
                limit: i64::from(self.settings.batch_size),
                lease_seconds: self.lease_seconds(),
            })
            .await?)
    }

    /// Renouvelle la réservation d'une étape juste avant son envoi.
    pub(crate) async fn renew(&self, job: &ClaimedJob) -> Result<(), NotificationError> {
        self.store
            .job_renew(JobRenewParams {
                job_id: job.job_id.to_sql(),
                claim_token: job.claim_token.clone(),
                lease_seconds: self.lease_seconds(),
            })
            .await?;
        Ok(())
    }

    pub(crate) fn lease_seconds(&self) -> i64 {
        i64::try_from(self.settings.lease.as_secs())
            .unwrap_or(300)
            .clamp(10, 3600)
    }

    /// Étape reportée à la fin des heures calmes de l'abonné.
    pub(crate) async fn defer(&self, job: &ClaimedJob, end: jiff::Timestamp) -> JobOutcome {
        match end.to_string().parse::<NotificationDatetime>() {
            Ok(not_before) => match self.release(job, Some(not_before)).await {
                JobOutcome::Released => JobOutcome::Deferred,
                other => other,
            },
            Err(_) => {
                tracing::warn!(job = %job.job_id.to_sql(), "fin des heures calmes illisible : reprise à l'expiration de la réservation");
                JobOutcome::Abandoned
            }
        }
    }

    pub(crate) async fn release(
        &self,
        job: &ClaimedJob,
        not_before: Option<NotificationDatetime>,
    ) -> JobOutcome {
        match self
            .store
            .job_release(JobReleaseParams {
                job_id: job.job_id.to_sql(),
                claim_token: job.claim_token.clone(),
                not_before,
            })
            .await
        {
            Ok(_) => JobOutcome::Released,
            Err(error) => {
                tracing::warn!(job = %job.job_id.to_sql(), code = %NotificationError::from(error).code(), "étape non rendue : reprise à l'expiration de la réservation");
                JobOutcome::Abandoned
            }
        }
    }

    /// Enregistre l'issue d'un envoi : étape terminée, ou échec (nouvelle tentative selon la
    /// classe), avec l'intégration utilisée et l'issue de chaque adresse servie.
    pub(crate) async fn finish(
        &self,
        job: &ClaimedJob,
        result: Result<Delivery, (ProviderError, Vec<EndpointOutcome>)>,
    ) -> JobOutcome {
        let attempt = u32::try_from(job.attempt).unwrap_or(1);
        let job_id = job.job_id.to_sql();
        let integration = job.integration.as_ref().map(|i| i.id.to_sql());
        // Envoi sans intégration (impossible hors du fil, qui ne passe pas par ici) : refusé
        let result = match (result, &integration) {
            (Ok(_), None) => Err((
                ProviderError::configuration("étape sans intégration"),
                Vec::new(),
            )),
            (result, _) => result,
        };
        let recorded = match (result, integration.clone()) {
            (Ok(delivery), Some(integration)) => self
                .store
                .job_complete(JobCompleteParams {
                    job_id: job_id.clone(),
                    claim_token: job.claim_token.clone(),
                    integration,
                    provider_message_id: delivery
                        .receipt
                        .as_ref()
                        .and_then(|r| r.message_id.clone()),
                    response_code: delivery.receipt.as_ref().map(|r| i64::from(r.code)),
                    subject: delivery.subject,
                    parts: delivery.parts,
                    endpoints: delivery.endpoints,
                })
                .await
                .map(|_| JobOutcome::Sent),
            (Ok(_), None) => return JobOutcome::Abandoned,
            (Err((failure, endpoints)), integration) => {
                let class = failure.class;
                self.store
                    .job_fail(JobFailParams {
                        job_id: job_id.clone(),
                        claim_token: job.claim_token.clone(),
                        integration,
                        class: class.as_str().to_string(),
                        code: failure.code,
                        detail: Some(truncate(&failure.detail, 512)),
                        retry_delay_seconds: i64::try_from(
                            self.settings.retry.delay(attempt).as_secs(),
                        )
                        .unwrap_or(30),
                        endpoints,
                    })
                    .await
                    .map(|_| JobOutcome::Failed(class))
            }
        };
        match recorded {
            Ok(outcome) => outcome,
            Err(error) => {
                tracing::warn!(job = %job_id, code = %NotificationError::from(error).code(), "issue de l'étape non enregistrée : reprise à l'expiration de la réservation");
                JobOutcome::Abandoned
            }
        }
    }
}

/// Descripteur d'un worker d'envoi.
pub(crate) fn send_descriptor(
    name: &str,
    label: &str,
    description: &str,
    settings: &SendWorkerSettings,
) -> Result<WorkerDescriptor, RuntimeError> {
    let module_id = ModuleId::new(MODULE);
    let mut descriptor = WorkerDescriptor::new(WorkerId::new(&module_id, name)?, module_id, label);
    descriptor.description = Some(description.to_string());
    descriptor.criticality = WorkerCriticality::Optional;
    // L'étape en cours se termine avant l'arrêt (traitement borné par `job_budget`)
    descriptor.shutdown_timeout = settings.job_budget + Duration::from_secs(30);
    Ok(descriptor)
}

/// Échec avant l'envoi (secret, rendu, réglage) : définitif.
pub(crate) fn permanent(error: &NotificationError) -> ProviderError {
    ProviderError {
        class: FailureClass::Permanent,
        code: error.code(),
        detail: error.to_string(),
    }
}

/// Boucle supervisée d'un worker d'envoi.
async fn run_send_loop(
    ctx: WorkerContext,
    queue: &JobQueue,
    processor: &dyn JobProcessor,
) -> Result<(), RuntimeError> {
    while !ctx.is_cancelled() {
        let busy = match queue.run_once(&ctx.cancellation, processor).await {
            Ok(outcomes) => outcomes.len() >= queue.settings.batch_size as usize,
            Err(error) => {
                tracing::warn!(channel = queue.channel, code = %error.code(), "réservation des envois impossible");
                false
            }
        };
        if busy {
            continue;
        }
        tokio::select! {
            _ = ctx.cancellation.cancelled() => break,
            _ = tokio::time::sleep(queue.settings.poll_interval) => {}
        }
    }
    Ok(())
}

/// Ouvre le secret d'une étape (variables sensibles du gabarit).
fn open_secret<R: KeyResolver>(
    codec: &SecretCodec<R>,
    job: &ClaimedJob,
) -> Result<Option<serde_json::Map<String, serde_json::Value>>, NotificationError> {
    match &job.secret {
        Some(envelope) => Ok(Some(
            codec
                .open_queue_secret(envelope, job.tenant_key.as_deref(), &job.idempotency_key)?
                .to_json()?,
        )),
        None => Ok(None),
    }
}

/// Lien de désabonnement d'un message non critique (liens configurés).
fn unsubscribe_url(
    links: Option<&UnsubscribeLinks>,
    job: &ClaimedJob,
) -> Result<Option<String>, NotificationError> {
    match (links, &job.unsubscribe) {
        (Some(links), Some(target)) if !job.critical => links.url(target).map(Some),
        _ => Ok(None),
    }
}

/// Worker d'envoi des e-mails.
pub struct NotificationEmailWorker<R: KeyResolver> {
    descriptor: WorkerDescriptor,
    queue: JobQueue,
    codec: SecretCodec<R>,
    dispatcher: EmailDispatcher,
    renderer: Renderer,
    links: Option<Arc<UnsubscribeLinks>>,
}

impl<R: KeyResolver + 'static> NotificationEmailWorker<R> {
    /// Worker sur la session système de l'hôte, le trousseau applicatif et l'envoi par les
    /// intégrations (fournisseurs et coffre-fort).
    pub fn new(
        store: NotificationStore,
        codec: SecretCodec<R>,
        dispatcher: EmailDispatcher,
        settings: SendWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let descriptor = send_descriptor(
            "email_sender",
            "Lyxal Notification Email Sender",
            "Envoi des e-mails de la file de notifications",
            &settings,
        )?;
        Ok(Self {
            queue: JobQueue {
                store,
                settings,
                worker_id: descriptor.id.to_string(),
                channel: "email",
            },
            descriptor,
            codec,
            dispatcher,
            renderer: Renderer::default(),
            links: None,
        })
    }

    /// Liens de désabonnement en un clic dans chaque e-mail non critique (sans eux : aucun lien
    /// ni en-tête `List-Unsubscribe`).
    pub fn with_unsubscribe_links(mut self, links: Arc<UnsubscribeLinks>) -> Self {
        self.links = Some(links);
        self
    }

    /// Un tour : réserve et traite les étapes e-mail dues (voir le module).
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<Vec<JobOutcome>, NotificationError> {
        self.queue.run_once(cancellation, self).await
    }

    /// Ouvre le secret et rend le message.
    fn prepare(&self, job: &ClaimedJob) -> Result<EmailMessage, NotificationError> {
        let secret = open_secret(&self.codec, job)?;
        let unsubscribe = unsubscribe_url(self.links.as_deref(), job)?;
        let content = self
            .renderer
            .render(job, secret.as_ref(), unsubscribe.as_deref())?;
        let to = job.recipient.email.clone().ok_or_else(|| {
            NotificationError::Render("destinataire sans adresse e-mail".to_string())
        })?;
        Ok(EmailMessage {
            to,
            to_name: job.recipient.name.clone(),
            list_unsubscribe: unsubscribe,
            content,
        })
    }

    /// Objet conservé dans le message : rendu sans secret, jamais pour un parcours sensible.
    fn rendered_subject(&self, job: &ClaimedJob) -> Option<String> {
        if job.sensitive {
            return None;
        }
        let unsubscribe = unsubscribe_url(self.links.as_deref(), job).ok().flatten();
        self.renderer
            .render(job, None, unsubscribe.as_deref())
            .ok()
            .map(|email| email.subject)
    }
}

#[async_trait]
impl<R: KeyResolver + 'static> JobProcessor for NotificationEmailWorker<R> {
    async fn process(&self, job: ClaimedJob) -> JobOutcome {
        let result = match self.prepare(&job) {
            Ok(email) => match claimed_integration(&job) {
                Ok(integration) => self.dispatcher.send(integration, &email).await,
                Err(error) => Err(error),
            }
            .map(|receipt| Delivery {
                receipt: Some(receipt),
                subject: self.rendered_subject(&job),
                parts: None,
                endpoints: Vec::new(),
            })
            .map_err(|failure| (failure, Vec::new())),
            Err(error) => Err((permanent(&error), Vec::new())),
        };
        self.queue.finish(&job, result).await
    }
}

#[async_trait]
impl<R: KeyResolver + 'static> LyxalWorker for NotificationEmailWorker<R> {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        run_send_loop(ctx, &self.queue, self).await
    }
}

/// Canal d'un worker d'envoi de texte.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TextChannel {
    /// SMS au téléphone de l'abonné.
    Sms,
    /// Messageries d'équipe (adresses de l'abonné).
    Chat,
    /// Appel signé des adresses web de l'abonné.
    Webhook,
    /// Fil dans l'application (sans fournisseur ni intégration, décision F3).
    InApp,
}

impl TextChannel {
    /// Valeur du canal en base.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Sms => "sms",
            Self::Chat => "chat",
            Self::Webhook => "webhook",
            Self::InApp => "in_app",
        }
    }
}

/// Envoi d'un canal de texte : par les intégrations (SMS, messagerie, adresse web), ou livraison
/// dans le fil (ni secret ni fournisseur).
enum ChannelSender<R: KeyResolver> {
    Providers {
        codec: SecretCodec<R>,
        dispatcher: ChannelDispatcher,
    },
    Feed,
}

/// Worker d'envoi des SMS, des messages de messagerie, des appels d'adresse web ou des messages
/// du fil (un par canal).
pub struct NotificationChannelWorker<R: KeyResolver> {
    descriptor: WorkerDescriptor,
    queue: JobQueue,
    channel: TextChannel,
    sender: ChannelSender<R>,
    renderer: Renderer,
    links: Option<Arc<UnsubscribeLinks>>,
}

impl<R: KeyResolver + 'static> NotificationChannelWorker<R> {
    /// Worker du canal `channel` sur la session système de l'hôte, le trousseau applicatif
    /// (secrets des messages, adresses scellées) et l'envoi par les intégrations.
    pub fn new(
        channel: TextChannel,
        store: NotificationStore,
        codec: SecretCodec<R>,
        dispatcher: ChannelDispatcher,
        settings: SendWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        Self::build(
            channel,
            store,
            ChannelSender::Providers { codec, dispatcher },
            settings,
        )
    }

    /// Worker du fil dans l'application (canal `in_app`) : rendu puis livraison par
    /// `fn::notification_inbox_deliver`, sans clé ni coffre-fort (aucun secret ni fournisseur).
    pub fn in_app(
        store: NotificationStore,
        settings: SendWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        Self::build(TextChannel::InApp, store, ChannelSender::Feed, settings)
    }

    fn build(
        channel: TextChannel,
        store: NotificationStore,
        sender: ChannelSender<R>,
        settings: SendWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let (name, label, description) = match channel {
            TextChannel::InApp => (
                "in_app_sender",
                "Lyxal Notification In-App Feed",
                "Livraison des messages du fil dans l'application",
            ),
            TextChannel::Sms => (
                "sms_sender",
                "Lyxal Notification SMS Sender",
                "Envoi des SMS de la file de notifications",
            ),
            TextChannel::Chat => (
                "chat_sender",
                "Lyxal Notification Chat Sender",
                "Envoi des messages de messagerie d'équipe de la file de notifications",
            ),
            TextChannel::Webhook => (
                "webhook_sender",
                "Lyxal Notification Webhook Caller",
                "Appels signés des adresses web de la file de notifications",
            ),
        };
        let descriptor = send_descriptor(name, label, description, &settings)?;
        Ok(Self {
            queue: JobQueue {
                store,
                settings,
                worker_id: descriptor.id.to_string(),
                channel: channel.as_str(),
            },
            descriptor,
            channel,
            sender,
            renderer: Renderer::default(),
            links: None,
        })
    }

    /// Lien de désabonnement (variable `unsubscribe_url` des gabarits) dans chaque message non
    /// critique ; jamais pour l'adresse web (appel de machine à machine) ni pour le fil.
    pub fn with_unsubscribe_links(mut self, links: Arc<UnsubscribeLinks>) -> Self {
        if !matches!(self.channel, TextChannel::Webhook | TextChannel::InApp) {
            self.links = Some(links);
        }
        self
    }

    /// Un tour : réserve et traite les étapes dues du canal (voir le module).
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<Vec<JobOutcome>, NotificationError> {
        self.queue.run_once(cancellation, self).await
    }

    /// Trousseau et envoi par les intégrations (absents pour le fil).
    fn providers(&self) -> Result<(&SecretCodec<R>, &ChannelDispatcher), NotificationError> {
        match &self.sender {
            ChannelSender::Providers { codec, dispatcher } => Ok((codec, dispatcher)),
            ChannelSender::Feed => Err(NotificationError::Configuration(
                "canal sans fournisseur".to_string(),
            )),
        }
    }

    /// Ouvre le secret et rend le titre et le texte.
    fn prepare(&self, job: &ClaimedJob) -> Result<RenderedText, NotificationError> {
        let (codec, _) = self.providers()?;
        let secret = open_secret(codec, job)?;
        let unsubscribe = unsubscribe_url(self.links.as_deref(), job)?;
        self.renderer
            .render_text(job, secret.as_ref(), unsubscribe.as_deref())
    }

    /// Titre conservé dans le message : rendu sans secret, jamais pour un parcours sensible.
    fn rendered_title(&self, job: &ClaimedJob) -> Option<String> {
        if job.sensitive {
            return None;
        }
        let unsubscribe = unsubscribe_url(self.links.as_deref(), job).ok().flatten();
        self.renderer
            .render_text(job, None, unsubscribe.as_deref())
            .ok()
            .and_then(|text| text.title)
    }

    /// SMS : 10 parties au plus (E5), Unicode hors de l'alphabet GSM.
    async fn send_sms(
        &self,
        job: &ClaimedJob,
        text: &RenderedText,
    ) -> Result<Delivery, (ProviderError, Vec<EndpointOutcome>)> {
        let segments = SmsSegments::count(&text.text);
        if !segments.fits() {
            let error = ProviderError {
                class: FailureClass::Permanent,
                code: "NOTIFICATION_SMS_TOO_LONG".to_string(),
                detail: format!("{} parties", segments.parts),
            };
            return Err((error, Vec::new()));
        }
        let Some(to) = job.recipient.phone.as_deref() else {
            return Err((
                ProviderError::configuration("abonné sans téléphone"),
                Vec::new(),
            ));
        };
        let (_, dispatcher) = self
            .providers()
            .map_err(|error| (permanent(&error), Vec::new()))?;
        let integration = claimed_integration(job).map_err(|failure| (failure, Vec::new()))?;
        let receipt = dispatcher
            .send_sms(integration, to, &text.text, segments.unicode())
            .await
            .map_err(|failure| (failure, Vec::new()))?;
        Ok(Delivery {
            receipt: Some(receipt),
            subject: None,
            parts: Some(i64::from(segments.parts)),
            endpoints: Vec::new(),
        })
    }

    /// Appel d'une adresse de messagerie ou web pour une étape.
    async fn call_endpoint(
        &self,
        job: &ClaimedJob,
        endpoint: &ClaimedEndpoint,
        text: &RenderedText,
    ) -> Result<ProviderReceipt, ProviderError> {
        let delivery_id = format!(
            "{}.{}",
            record_key(&job.job_id).unwrap_or_default(),
            record_key(&endpoint.id).unwrap_or_default()
        );
        let (codec, dispatcher) = self.providers().map_err(|error| permanent(&error))?;
        let now = jiff::Timestamp::now();
        let body = serde_json::json!({
            "id": delivery_id,
            "type": "notification.message",
            "workflow": job.workflow_key,
            "step": job.step_key,
            "run": job.run_id.to_sql(),
            "subscriber_id": job.subscriber_id,
            "payload": job.payload,
            "text": text.text,
            "sent_at": now.to_string(),
        });
        deliver_to_endpoint(
            codec,
            dispatcher,
            endpoint,
            &EndpointMessage {
                title: text.title.as_deref(),
                text: &text.text,
                delivery_id: &delivery_id,
                body: &body,
            },
            &job.allowed_hosts,
            now.as_second(),
        )
        .await
    }

    /// Messagerie, adresse web : chaque adresse servie à son tour. Toutes servies (ou refusées
    /// définitivement après au moins une servie, dans cette tentative ou une précédente) : étape
    /// terminée ; un échec temporaire : nouvel essai des seules adresses non servies ; aucune
    /// servie : échec de la première.
    async fn send_endpoints(
        &self,
        job: &ClaimedJob,
        text: &RenderedText,
    ) -> Result<Delivery, (ProviderError, Vec<EndpointOutcome>)> {
        let mut outcomes = Vec::with_capacity(job.endpoints.len());
        let mut first_failure: Option<ProviderError> = None;
        let mut transient: Option<ProviderError> = None;
        for endpoint in &job.endpoints {
            let result = self.call_endpoint(job, endpoint, text).await;
            let (ok, code, message_id, response) = match &result {
                Ok(receipt) => (
                    true,
                    None,
                    receipt.message_id.clone(),
                    Some(i64::from(receipt.code)),
                ),
                Err(error) => (false, Some(error.code.clone()), None, None),
            };
            outcomes.push(EndpointOutcome {
                endpoint: endpoint.id.to_sql(),
                integration: endpoint.integration.id.to_sql(),
                ok,
                code,
                provider_message_id: message_id,
                response_code: response,
            });
            if let Err(error) = result {
                tracing::warn!(job = %job.job_id.to_sql(), endpoint = %endpoint.id.to_sql(), host = %endpoint.host, code = %error.code, "appel d'une adresse refusé");
                if error.class == FailureClass::Transient && transient.is_none() {
                    transient = Some(error.clone());
                }
                first_failure.get_or_insert(error);
            }
        }
        if let Some(error) = transient {
            return Err((error, outcomes));
        }
        if nothing_delivered(job.served_endpoints, &outcomes) {
            let error = first_failure
                .unwrap_or_else(|| ProviderError::configuration("aucune adresse à servir"));
            return Err((error, outcomes));
        }
        Ok(Delivery {
            receipt: None,
            subject: self.rendered_title(job),
            parts: None,
            endpoints: outcomes,
        })
    }
}

#[async_trait]
impl<R: KeyResolver + 'static> JobProcessor for NotificationChannelWorker<R> {
    async fn process(&self, job: ClaimedJob) -> JobOutcome {
        if self.channel == TextChannel::InApp {
            return self.deliver_in_app(&job).await;
        }
        let result = match self.prepare(&job) {
            Ok(text) => match self.channel {
                TextChannel::Sms => self.send_sms(&job, &text).await,
                TextChannel::Chat | TextChannel::Webhook | TextChannel::InApp => {
                    self.send_endpoints(&job, &text).await
                }
            },
            Err(error) => Err((permanent(&error), Vec::new())),
        };
        self.queue.finish(&job, result).await
    }
}

impl<R: KeyResolver + 'static> NotificationChannelWorker<R> {
    /// Fil : message rendu (variables échappées, sans secret) puis livré. Un refus de la base
    /// (lien rendu refusé, donnée trop longue) est un échec définitif ; une base indisponible
    /// laisse expirer la réservation (l'étape est reprise).
    async fn deliver_in_app(&self, job: &ClaimedJob) -> JobOutcome {
        let rendered = match self.renderer.render_in_app(job) {
            Ok(rendered) => rendered,
            Err(error) => {
                return self
                    .queue
                    .finish(job, Err((permanent(&error), Vec::new())))
                    .await
            }
        };
        match self
            .queue
            .store
            .inbox_deliver(inbox_params(job, rendered))
            .await
        {
            Ok(_) => JobOutcome::Sent,
            Err(error) => {
                let error = NotificationError::from(error);
                if is_refusal(&error) && error.code() != "NOTIFICATION_JOB_CLAIM_LOST" {
                    tracing::warn!(job = %job.job_id.to_sql(), code = %error.code(), "message du fil refusé");
                    self.queue
                        .finish(job, Err((permanent(&error), Vec::new())))
                        .await
                } else {
                    tracing::warn!(job = %job.job_id.to_sql(), code = %error.code(), "message du fil non livré : reprise à l'expiration de la réservation");
                    JobOutcome::Abandoned
                }
            }
        }
    }
}

/// Paramètres de livraison d'un message du fil rendu.
fn inbox_params(job: &ClaimedJob, rendered: RenderedInApp) -> InboxDeliverParams {
    InboxDeliverParams {
        job_id: job.job_id.to_sql(),
        claim_token: job.claim_token.clone(),
        title: rendered.title,
        text: rendered.text,
        avatar: rendered.avatar,
        redirect: rendered.redirect,
        actions: rendered.actions,
        data: serde_json::Value::Object(rendered.data),
    }
}

/// Refus métier de la base (code `NOTIFICATION_*`), par opposition à une panne.
fn is_refusal(error: &NotificationError) -> bool {
    matches!(
        error,
        NotificationError::Surreal(inner)
            if matches!(inner.as_ref(), lyxal_surreal::LyxalSurrealError::Call(lyxal_surreal::LyxalCallError::Business(_)))
    )
}

/// Intégration retenue à la réservation (toujours présente hors du fil).
fn claimed_integration(job: &ClaimedJob) -> Result<&ClaimedIntegration, ProviderError> {
    job.integration
        .as_ref()
        .ok_or_else(|| ProviderError::configuration("étape sans intégration"))
}

#[async_trait]
impl<R: KeyResolver + 'static> LyxalWorker for NotificationChannelWorker<R> {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        run_send_loop(ctx, &self.queue, self).await
    }
}

/// Aucune adresse servie, ni dans cette tentative ni dans une précédente : l'étape échoue. Une
/// adresse servie plus tôt suffit (les adresses refusées définitivement ensuite n'annulent pas
/// ce qui est déjà parti).
pub(crate) fn nothing_delivered(served_before: i64, outcomes: &[EndpointOutcome]) -> bool {
    served_before == 0 && !outcomes.iter().any(|outcome| outcome.ok)
}

/// Message d'une adresse de messagerie ou web.
pub struct EndpointMessage<'a> {
    /// Titre facultatif (messagerie).
    pub title: Option<&'a str>,
    /// Texte.
    pub text: &'a str,
    /// Identifiant de livraison (en-tête `Lyxal-Delivery` d'une adresse web).
    pub delivery_id: &'a str,
    /// Corps JSON d'un appel d'adresse web.
    pub body: &'a serde_json::Value,
}

/// Ouvre en mémoire une valeur scellée d'une adresse (contexte lié à l'organisation et à
/// l'adresse).
fn open_endpoint<R: KeyResolver>(
    codec: &SecretCodec<R>,
    endpoint: &ClaimedEndpoint,
    envelope: &str,
    field: EndpointField,
) -> Result<lyxal_crypto::SecretBytes, ProviderError> {
    let key =
        record_key(&endpoint.id).ok_or_else(|| ProviderError::configuration("adresse sans clé"))?;
    codec
        .open_endpoint_value(envelope, endpoint.tenant_key.as_deref(), &key, field)
        .map_err(|error| permanent(&error))
}

/// Appel d'une adresse de messagerie (service de l'adresse) ou d'une adresse web (corps signé) :
/// adresse et clé de signature ouvertes en mémoire le temps de l'appel, jamais journalisées.
/// Sert aux workers et à l'essai d'une intégration par l'hôte ; `now` : secondes Unix.
pub async fn deliver_to_endpoint<R: KeyResolver>(
    codec: &SecretCodec<R>,
    dispatcher: &ChannelDispatcher,
    endpoint: &ClaimedEndpoint,
    message: &EndpointMessage<'_>,
    allowed_hosts: &[String],
    now: i64,
) -> Result<ProviderReceipt, ProviderError> {
    let url = match &endpoint.url {
        Some(envelope) => Some(
            open_endpoint(codec, endpoint, envelope, EndpointField::Url)?
                .into_utf8()
                .map_err(|_| ProviderError::configuration("adresse illisible"))?,
        ),
        None => None,
    };
    if endpoint.provider != "webhook" {
        let service = ChatService::parse(&endpoint.provider)
            .ok_or_else(|| ProviderError::configuration("service de messagerie inconnu"))?;
        return dispatcher
            .send_chat(
                &endpoint.integration,
                service,
                url.as_ref(),
                endpoint.chat_id.as_deref(),
                message.title,
                message.text,
                allowed_hosts,
            )
            .await;
    }
    let url: SecretString = url.ok_or_else(|| ProviderError::configuration("adresse absente"))?;
    let envelope = endpoint
        .signing_secret
        .as_deref()
        .ok_or_else(|| ProviderError::configuration("clé de signature absente"))?;
    let key = HmacKey::import(open_endpoint(
        codec,
        endpoint,
        envelope,
        EndpointField::SigningSecret,
    )?)
    .map_err(|_| ProviderError::configuration("clé de signature illisible"))?;
    dispatcher
        .call_webhook(
            &url,
            &key,
            message.delivery_id,
            message.body,
            allowed_hosts,
            now,
        )
        .await
}

/// Clé d'un enregistrement (contexte de scellement, identifiant de livraison).
pub(crate) fn record_key(id: &NotificationRecordId) -> Option<String> {
    match &id.key {
        surrealdb::types::RecordIdKey::String(key) => Some(key.clone()),
        surrealdb::types::RecordIdKey::Number(key) => Some(key.to_string()),
        _ => None,
    }
}

/// Réglages du worker des diffusions.
#[derive(Debug, Clone)]
pub struct BroadcastWorkerSettings {
    /// Attente entre deux réservations quand aucune diffusion n'attend.
    pub poll_interval: Duration,
    /// Abonnés par paquet (500 au plus).
    pub batch_size: u32,
    /// Durée de la réservation, renouvelée à chaque paquet.
    pub lease: Duration,
}

impl Default for BroadcastWorkerSettings {
    fn default() -> Self {
        Self {
            poll_interval: Duration::from_secs(5),
            batch_size: 500,
            lease: Duration::from_secs(120),
        }
    }
}

/// Bilan d'un passage sur une diffusion (journalisé, jamais d'adresse).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct BroadcastOutcome {
    /// Paquets traités par ce passage.
    pub batches: u32,
    /// Destinataires examinés par ce passage.
    pub processed: i64,
    /// Déclenchements créés par ce passage.
    pub created: i64,
    /// Diffusion terminée (sinon : arrêt du worker, reprise par un autre passage).
    pub completed: bool,
}

/// Worker des diffusions : un déclenchement par abonné, par paquets.
pub struct NotificationBroadcastWorker {
    descriptor: WorkerDescriptor,
    store: NotificationStore,
    settings: BroadcastWorkerSettings,
}

impl NotificationBroadcastWorker {
    /// Worker sur la session système de l'hôte.
    pub fn new(
        store: NotificationStore,
        settings: BroadcastWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "broadcast")?,
            module_id,
            "Lyxal Notification Broadcast",
        );
        descriptor.description =
            Some("Diffusions à un sujet ou à tous les abonnés, traitées par paquets".to_string());
        descriptor.criticality = WorkerCriticality::Optional;
        Ok(Self {
            descriptor,
            store,
            settings,
        })
    }

    /// Réserve une diffusion et la traite paquet par paquet jusqu'à sa fin ou à l'annulation ;
    /// `None` si aucune diffusion n'attend.
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<Option<BroadcastOutcome>, NotificationError> {
        let lease_seconds = i64::try_from(self.settings.lease.as_secs())
            .unwrap_or(120)
            .clamp(10, 3600);
        let Some(claim) = self
            .store
            .broadcast_claim(BroadcastClaimParams {
                worker_id: self.descriptor.id.to_string(),
                lease_seconds,
            })
            .await?
        else {
            return Ok(None);
        };
        let broadcast_id = claim.broadcast_id.to_sql();
        let mut outcome = BroadcastOutcome {
            batches: 0,
            processed: 0,
            created: 0,
            completed: false,
        };
        loop {
            // Arrêt : la réservation expire, un autre passage reprend au paquet suivant
            if cancellation.is_cancelled() {
                return Ok(Some(outcome));
            }
            let step = self
                .store
                .broadcast_step(BroadcastStepParams {
                    broadcast_id: broadcast_id.clone(),
                    claim_token: claim.claim_token.clone(),
                    size: i64::from(self.settings.batch_size.clamp(1, 500)),
                    lease_seconds,
                })
                .await?;
            outcome.batches += 1;
            outcome.processed += step.processed;
            outcome.created += step.created;
            if step.done {
                break;
            }
        }
        self.store
            .broadcast_complete(BroadcastCompleteParams {
                broadcast_id,
                claim_token: claim.claim_token,
            })
            .await?;
        outcome.completed = true;
        Ok(Some(outcome))
    }
}

#[async_trait]
impl LyxalWorker for NotificationBroadcastWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            let busy = match self.run_once(&ctx.cancellation).await {
                Ok(Some(outcome)) => {
                    tracing::info!(
                        batches = outcome.batches,
                        processed = outcome.processed,
                        created = outcome.created,
                        completed = outcome.completed,
                        "diffusion traitée"
                    );
                    true
                }
                Ok(None) => false,
                Err(error) => {
                    tracing::warn!(code = %error.code(), "diffusion interrompue : reprise à l'expiration de la réservation");
                    false
                }
            };
            if busy {
                continue;
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.settings.poll_interval) => {}
            }
        }
        Ok(())
    }
}

/// Réglages du worker d'étapes.
#[derive(Debug, Clone)]
pub struct StepWorkerSettings {
    /// Attente entre deux passages quand le dernier a trouvé du travail.
    pub busy_interval: Duration,
    /// Attente entre deux passages quand rien n'attendait.
    pub idle_interval: Duration,
    /// Attentes confiées au plus par passage (500 au plus).
    pub batch_size: u32,
}

impl Default for StepWorkerSettings {
    fn default() -> Self {
        Self {
            busy_interval: Duration::from_secs(1),
            idle_interval: Duration::from_secs(5),
            batch_size: 100,
        }
    }
}

/// Worker d'étapes : confie au planificateur les attentes et regroupements engagés par les
/// parcours (session système de l'hôte : la personne qui déclenche n'a besoin d'aucune
/// permission `scheduler.*`).
pub struct NotificationStepWorker {
    descriptor: WorkerDescriptor,
    store: NotificationStore,
    settings: StepWorkerSettings,
}

impl NotificationStepWorker {
    /// Worker sur la session système de l'hôte.
    pub fn new(
        store: NotificationStore,
        settings: StepWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "steps")?,
            module_id,
            "Lyxal Notification Steps",
        );
        descriptor.description =
            Some("Attentes et regroupements des parcours confiés au planificateur".to_string());
        descriptor.criticality = WorkerCriticality::Optional;
        Ok(Self {
            descriptor,
            store,
            settings,
        })
    }

    /// Un passage : un paquet d'attentes confiées au planificateur (ou reprises si déjà échues).
    pub async fn run_once(&self) -> Result<WaitScheduleResult, NotificationError> {
        Ok(self
            .store
            .wait_schedule(WaitScheduleParams {
                limit: Some(i64::from(self.settings.batch_size.clamp(1, 500))),
            })
            .await?)
    }
}

#[async_trait]
impl LyxalWorker for NotificationStepWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            let busy = match self.run_once().await {
                Ok(result) => {
                    if result.failed > 0 {
                        tracing::warn!(failed = result.failed, codes = ?result.codes, "attentes refusées par le planificateur : reprises au passage suivant");
                    }
                    result.more || result.scheduled + result.resumed + result.failed > 0
                }
                Err(error) => {
                    tracing::warn!(code = %error.code(), "attentes des parcours non confiées au planificateur");
                    false
                }
            };
            let pause = if busy {
                self.settings.busy_interval
            } else {
                self.settings.idle_interval
            };
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(pause) => {}
            }
        }
        Ok(())
    }
}

pub(crate) fn truncate(text: &str, max: usize) -> String {
    text.chars().take(max).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn an_endpoint_served_by_an_earlier_attempt_completes_the_step() {
        let refused = |endpoint: &str| EndpointOutcome {
            endpoint: endpoint.to_string(),
            integration: "notification_integration:essai".to_string(),
            ok: false,
            code: Some("NOTIFICATION_PROVIDER_REJECTED".to_string()),
            provider_message_id: None,
            response_code: Some(404),
        };
        let served = EndpointOutcome {
            ok: true,
            code: None,
            response_code: Some(200),
            ..refused("notification_endpoint:a")
        };
        // Adresse A servie à la tentative précédente, B refusée définitivement maintenant
        assert!(!nothing_delivered(1, &[refused("notification_endpoint:b")]));
        assert!(nothing_delivered(0, &[refused("notification_endpoint:b")]));
        assert!(!nothing_delivered(
            0,
            &[served, refused("notification_endpoint:b")]
        ));
        assert!(nothing_delivered(0, &[]));
    }

    #[test]
    fn lease_outlasts_the_job_budget() {
        let settings = SendWorkerSettings::default();
        assert!(settings.lease > settings.job_budget);
    }

    #[test]
    fn retry_delay_grows_and_is_capped() {
        let policy = RetryPolicy::default();
        assert_eq!(policy.ceiling(1), Duration::from_secs(30));
        assert_eq!(policy.ceiling(2), Duration::from_secs(60));
        assert_eq!(policy.ceiling(5), Duration::from_secs(480));
        assert_eq!(policy.ceiling(40), Duration::from_secs(6 * 3600));
        for attempt in 1..12 {
            let delay = policy.delay(attempt);
            assert!(delay >= Duration::from_secs(1) && delay <= policy.ceiling(attempt));
        }
    }
}
