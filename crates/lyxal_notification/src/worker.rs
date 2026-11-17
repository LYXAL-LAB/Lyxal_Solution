//! Workers supervisés : envoi des e-mails, diffusions et attentes des parcours.
//!
//! Le worker d'envoi réserve les étapes dues (`fn::notification_job_claim`, chacune avec
//! l'intégration retenue : D1, bascule D3), reporte celles qui tombent dans les heures calmes de
//! l'abonné, ouvre le secret, rend le message (lien de désabonnement compris), lit les
//! identifiants de l'intégration dans `lyxal_secrets` et l'envoie par son fournisseur, puis
//! termine l'étape ou enregistre l'échec (avec l'intégration utilisée). Délai avant une
//! nouvelle tentative : attente exponentielle plafonnée avec gigue complète (comme `lyxal_event`).
//! Une erreur de base n'interrompt pas le worker : la réservation expire et l'étape est reprise.
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
use lyxal_crypto::KeyResolver;
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
    BroadcastClaimParams, BroadcastCompleteParams, BroadcastStepParams, ClaimedJob, FailureClass,
    JobClaimParams, JobCompleteParams, JobFailParams, JobReleaseParams, JobRenewParams,
    NotificationDatetime, WaitScheduleParams, WaitScheduleResult,
};
use crate::provider::{EmailDispatcher, EmailMessage, ProviderError};
use crate::quiet::quiet_until;
use crate::render::Renderer;
use crate::secret::SecretCodec;
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

/// Réglages du worker d'envoi.
#[derive(Debug, Clone)]
pub struct EmailWorkerSettings {
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

impl Default for EmailWorkerSettings {
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

/// Worker d'envoi des e-mails.
pub struct NotificationEmailWorker<R: KeyResolver> {
    descriptor: WorkerDescriptor,
    store: NotificationStore,
    codec: SecretCodec<R>,
    dispatcher: EmailDispatcher,
    renderer: Renderer,
    settings: EmailWorkerSettings,
    links: Option<Arc<UnsubscribeLinks>>,
}

impl<R: KeyResolver> NotificationEmailWorker<R> {
    /// Worker sur la session système de l'hôte, le trousseau applicatif et l'envoi par les
    /// intégrations (fournisseurs et coffre-fort).
    pub fn new(
        store: NotificationStore,
        codec: SecretCodec<R>,
        dispatcher: EmailDispatcher,
        settings: EmailWorkerSettings,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "email_sender")?,
            module_id,
            "Lyxal Notification Email Sender",
        );
        descriptor.description = Some("Envoi des e-mails de la file de notifications".to_string());
        descriptor.criticality = WorkerCriticality::Optional;
        // L'étape en cours se termine avant l'arrêt (traitement borné par `job_budget`)
        descriptor.shutdown_timeout = settings.job_budget + Duration::from_secs(30);
        Ok(Self {
            descriptor,
            store,
            codec,
            dispatcher,
            renderer: Renderer::default(),
            settings,
            links: None,
        })
    }

    /// Liens de désabonnement en un clic dans chaque e-mail non critique (sans eux : aucun lien
    /// ni en-tête `List-Unsubscribe`).
    pub fn with_unsubscribe_links(mut self, links: Arc<UnsubscribeLinks>) -> Self {
        self.links = Some(links);
        self
    }

    /// Un tour : réserve et traite les étapes dues, une à la fois. Avant chaque envoi, la
    /// réservation est renouvelée (une étape reprise entre-temps par un autre worker n'est pas
    /// envoyée) ; après l'annulation, aucun envoi ne commence et les étapes restantes sont
    /// rendues à la file.
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<Vec<JobOutcome>, NotificationError> {
        let jobs = self
            .store
            .job_claim(JobClaimParams {
                worker_id: self.descriptor.id.to_string(),
                limit: i64::from(self.settings.batch_size),
                lease_seconds: self.lease_seconds(),
            })
            .await?;
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
            match tokio::time::timeout(self.settings.job_budget, self.process(job)).await {
                Ok(outcome) => outcomes.push(outcome),
                Err(_) => {
                    tracing::warn!(job = %job_id, "traitement de l'étape trop long : reprise à l'expiration de la réservation");
                    outcomes.push(JobOutcome::Abandoned);
                }
            }
        }
        Ok(outcomes)
    }

    fn lease_seconds(&self) -> i64 {
        i64::try_from(self.settings.lease.as_secs())
            .unwrap_or(300)
            .clamp(10, 3600)
    }

    /// Étape reportée à la fin des heures calmes de l'abonné.
    async fn defer(&self, job: &ClaimedJob, end: jiff::Timestamp) -> JobOutcome {
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

    async fn release(
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

    async fn process(&self, job: ClaimedJob) -> JobOutcome {
        let attempt = u32::try_from(job.attempt).unwrap_or(1);
        let prepared = self.prepare(&job);
        let result = match prepared {
            Ok(email) => self.dispatcher.send(&job.integration, &email).await,
            Err(error) => Err(ProviderError {
                class: FailureClass::Permanent,
                code: error.code(),
                detail: error.to_string(),
            }),
        };
        let job_id = job.job_id.to_sql();
        let integration = job.integration.id.to_sql();
        let recorded = match result {
            Ok(receipt) => self
                .store
                .job_complete(JobCompleteParams {
                    job_id: job_id.clone(),
                    claim_token: job.claim_token.clone(),
                    integration,
                    provider_message_id: receipt.message_id,
                    response_code: Some(i64::from(receipt.code)),
                    subject: self.rendered_subject(&job),
                })
                .await
                .map(|_| JobOutcome::Sent),
            Err(failure) => {
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

    /// Ouvre le secret et rend le message.
    fn prepare(&self, job: &ClaimedJob) -> Result<EmailMessage, NotificationError> {
        let secret = match &job.secret {
            Some(envelope) => Some(
                self.codec
                    .open_queue_secret(envelope, job.tenant_key.as_deref(), &job.idempotency_key)?
                    .to_json()?,
            ),
            None => None,
        };
        let unsubscribe = self.unsubscribe_url(job)?;
        let content = self
            .renderer
            .render(job, secret.as_ref(), unsubscribe.as_deref())?;
        Ok(EmailMessage {
            to: job.recipient.email.clone(),
            to_name: job.recipient.name.clone(),
            list_unsubscribe: unsubscribe,
            content,
        })
    }

    /// Lien de désabonnement d'un message non critique (liens configurés).
    fn unsubscribe_url(&self, job: &ClaimedJob) -> Result<Option<String>, NotificationError> {
        match (&self.links, &job.unsubscribe) {
            (Some(links), Some(target)) if !job.critical => links.url(target).map(Some),
            _ => Ok(None),
        }
    }

    /// Objet conservé dans le message : rendu sans secret, jamais pour un parcours sensible.
    fn rendered_subject(&self, job: &ClaimedJob) -> Option<String> {
        if job.sensitive {
            return None;
        }
        let unsubscribe = self.unsubscribe_url(job).ok().flatten();
        self.renderer
            .render(job, None, unsubscribe.as_deref())
            .ok()
            .map(|email| email.subject)
    }
}

#[async_trait]
impl<R: KeyResolver + 'static> LyxalWorker for NotificationEmailWorker<R> {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            let busy = match self.run_once(&ctx.cancellation).await {
                Ok(outcomes) => outcomes.len() >= self.settings.batch_size as usize,
                Err(error) => {
                    tracing::warn!(code = %error.code(), "réservation des envois impossible");
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

fn truncate(text: &str, max: usize) -> String {
    text.chars().take(max).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn lease_outlasts_the_job_budget() {
        let settings = EmailWorkerSettings::default();
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
