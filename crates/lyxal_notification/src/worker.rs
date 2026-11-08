//! Workers supervisés : envoi des e-mails et purge.
//!
//! Le worker d'envoi réserve les étapes dues (`fn::notification_job_claim`), ouvre le secret,
//! rend le message, l'envoie, puis termine l'étape ou enregistre l'échec. Délai avant une
//! nouvelle tentative : attente exponentielle plafonnée avec gigue complète (comme `lyxal_event`).
//! Une erreur de base n'interrompt pas le worker : la réservation expire et l'étape est reprise.

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
    ClaimedJob, FailureClass, JobClaimParams, JobCompleteParams, JobFailParams, JobReleaseParams,
    JobRenewParams, PurgeParams,
};
use crate::render::Renderer;
use crate::secret::SecretCodec;
use crate::smtp::{EmailTransport, OutgoingEmail, SendFailure};
use crate::store::NotificationStore;

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
}

/// Worker d'envoi des e-mails.
pub struct NotificationEmailWorker<R: KeyResolver> {
    descriptor: WorkerDescriptor,
    store: NotificationStore,
    codec: SecretCodec<R>,
    transport: Arc<dyn EmailTransport>,
    renderer: Renderer,
    settings: EmailWorkerSettings,
}

impl<R: KeyResolver> NotificationEmailWorker<R> {
    /// Worker sur la session système de l'hôte, le trousseau applicatif et un transport.
    pub fn new(
        store: NotificationStore,
        codec: SecretCodec<R>,
        transport: Arc<dyn EmailTransport>,
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
            transport,
            renderer: Renderer::default(),
            settings,
        })
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
                outcomes.push(self.release(&job).await);
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

    async fn release(&self, job: &ClaimedJob) -> JobOutcome {
        match self
            .store
            .job_release(JobReleaseParams {
                job_id: job.job_id.to_sql(),
                claim_token: job.claim_token.clone(),
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
            Ok(email) => self.transport.send(email).await,
            Err(error) => Err(SendFailure {
                class: FailureClass::Permanent,
                code: error.code(),
                detail: error.to_string(),
            }),
        };
        let job_id = job.job_id.to_sql();
        let recorded = match result {
            Ok(delivered) => self
                .store
                .job_complete(JobCompleteParams {
                    job_id: job_id.clone(),
                    claim_token: job.claim_token.clone(),
                    provider_message_id: Some(delivered.message_id),
                    smtp_code: Some(i64::from(delivered.code)),
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
    fn prepare(&self, job: &ClaimedJob) -> Result<OutgoingEmail, NotificationError> {
        let secret = match &job.secret {
            Some(envelope) => Some(
                self.codec
                    .open_queue_secret(envelope, job.tenant_key.as_deref(), &job.idempotency_key)?
                    .to_json()?,
            ),
            None => None,
        };
        let content = self.renderer.render(job, secret.as_ref())?;
        Ok(OutgoingEmail {
            to: job.recipient.email.clone(),
            to_name: job.recipient.name.clone(),
            from_name: job.from_name.clone(),
            reply_to: job.reply_to.clone(),
            content,
        })
    }

    /// Objet conservé dans le message : rendu sans secret, jamais pour un parcours sensible.
    fn rendered_subject(&self, job: &ClaimedJob) -> Option<String> {
        if job.sensitive {
            return None;
        }
        self.renderer
            .render(job, None)
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

/// Worker de purge : secrets expirés, journal et déclenchements au-delà de leur conservation.
pub struct NotificationPurgeWorker {
    descriptor: WorkerDescriptor,
    store: NotificationStore,
    interval: Duration,
    batch: u32,
}

impl NotificationPurgeWorker {
    /// Purge toutes les `interval`, par paquets de `batch` éléments.
    pub fn new(
        store: NotificationStore,
        interval: Duration,
        batch: u32,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "purge")?,
            module_id,
            "Lyxal Notification Purge",
        );
        descriptor.description = Some(
            "Effacement des secrets expirés et purge selon les durées de conservation".to_string(),
        );
        descriptor.criticality = WorkerCriticality::Optional;
        Ok(Self {
            descriptor,
            store,
            interval,
            batch,
        })
    }

    /// Une purge (paquets successifs tant qu'un paquet est plein).
    pub async fn run_once(&self) -> Result<(), NotificationError> {
        loop {
            let result = self
                .store
                .purge(PurgeParams {
                    limit: i64::from(self.batch),
                })
                .await?;
            if result.runs < i64::from(self.batch) && result.log_entries < i64::from(self.batch) {
                return Ok(());
            }
        }
    }
}

#[async_trait]
impl LyxalWorker for NotificationPurgeWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            if let Err(error) = self.run_once().await {
                tracing::warn!(code = %error.code(), "purge des notifications impossible");
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.interval) => {}
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
