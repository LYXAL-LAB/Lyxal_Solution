// SPDX-License-Identifier: AGPL-3.0-only

//! Worker d'envoi `lyxal_mail:mail.outbound`, un par nœud (plan du lot 6, §5.3, §5.4, §6, §7,
//! §10 ; décisions E4, E7, E11).
//!
//! Boucle : réservation (`fn::mail_queue_claim`, lots de `claim_batch`, domaines saturés du
//! nœud écartés), préparation des envois qui ne le sont pas, regroupement par (envoi,
//! destination), un envoi par groupe dans le `JoinSet` du worker (aucune tâche hors de lui),
//! limites par nœud et par destination ; résultat écrit **après chaque transaction**
//! (`fn::mail_queue_complete`, `_fail`), avis dus produits ; bail renouvelé toutes les 2 minutes
//! pendant les envois longs. Réveil immédiat par [`OutboundDispatcher::waker`] (dépôt sur le
//! nœud), sinon lecture de la file toutes les secondes, toutes les 5 s après une lecture vide.
//!
//! Arrêt propre : plus aucune réservation ; les envois en cours ont `drain_timeout` pour finir,
//! puis sont abandonnés ; leurs destinataires non écrits sont rendus sans essai compté
//! (`fn::mail_queue_release`) ; les connexions gardées sont closes par `QUIT`. Arrêt brutal :
//! les baux expirent et la réservation suivante reprend les destinataires, sans essai compté.

use async_trait::async_trait;
use bytes::Bytes;
use futures::StreamExt;
use lyxal_mail_proto::smtp::{
    Domain, DsnNotify as ProtoNotify, DsnOrcpt, DsnRet, ForwardPath, Mailbox, ReversePath,
};
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerRestartBackoff,
};
use lyxal_runtime::{ModuleId, RuntimeError};
use lyxal_secrets::{ClientRead, SecretsClient};
use lyxal_storage::StorageService;
use lyxal_surreal::ToSql;
use std::collections::{BTreeMap, HashMap, HashSet};
use std::net::IpAddr;
use std::sync::{Arc, Mutex, PoisonError};
use std::time::{Duration, Instant, SystemTime};
use tokio::sync::Notify;
use tokio::task::JoinSet;

use crate::auth::OrganizationalDomain;
use crate::delivery::DeliveryPipeline;
use crate::dkim::DkimKeyCache;
use crate::dns::MailResolver;
use crate::dsn::{DsnComposer, DsnOutcome};
use crate::error::{MailError, MailResult};
use crate::models::{
    AttemptStage, ClaimedRecipient, DeliveredItem, DestinationFailure, DsnDue, DsnNotify,
    DsnPendingParams, DsnReturn, FailedItem, MailDatetime, QueueClaimParams, QueueCompleteParams,
    QueueFailParams, QueueOutcome, QueueReleaseParams, QueueRenewParams, RecipientState, TlsInfo,
};
use crate::outbound::client::{
    ConnectTarget, Envelope, RcptPlan, RecipientOutcome, RelayCredentials, SmtpConnection,
    TargetTls, TlsConnectorProvider,
};
use crate::outbound::config::{IpFamily, OutboundConfig, OutboundTls, RelayTls};
use crate::outbound::content;
use crate::outbound::local::{LocalMessage, LocalOutcome, LocalRoute};
use crate::outbound::metrics::{stage_name, OutboundMetrics};
use crate::outbound::mx::{MxHost, MxPlan, ResolveFailure};
use crate::outbound::pool::{ConnectionPool, DestinationLimiter, PoolKey};
use crate::outbound::prepare::Preparer;
use crate::store::MailStore;
use crate::MODULE_ID;

/// Renouvellement des baux pendant les envois, au plus ; un bail plus court est renouvelé au
/// tiers de sa durée.
const RENEW_EVERY: Duration = Duration::from_secs(120);
/// Reprise des avis finaux dus et non produits (panne du dépôt de l'avis, arrêt du nœud).
const DSN_RECOVER_EVERY: Duration = Duration::from_secs(300);
/// Écritures de résultats par appel (`fn::mail_queue_complete`, `fn::mail_queue_fail`).
const WRITE_BATCH: usize = 100;
/// Marge du superviseur au-delà du drainage : retour des destinataires et fermeture des
/// connexions.
const SHUTDOWN_MARGIN: Duration = Duration::from_secs(15);
/// Lecture de la file sans réveil.
const POLL_EVERY: Duration = Duration::from_secs(1);
/// Lecture de la file après une lecture vide.
const IDLE_POLL_EVERY: Duration = Duration::from_secs(5);
/// Délai avant de reprendre un envoi dont la préparation ou le contenu a échoué.
const RETRY_LATER: Duration = Duration::from_secs(300);
/// Texte d'une réponse distante gardé au plus.
const MAX_REMOTE_TEXT: usize = 512;
/// Envois suivis au plus pour les contenus illisibles.
const MAX_CONTENT_FAILURES: usize = 10_000;

/// Services de l'hôte remis au worker d'envoi.
#[derive(Clone)]
pub struct OutboundServices {
    /// Session système de l'hôte.
    pub store: MailStore,
    /// Stockage de l'hôte (lecture des contenus, chiffrés).
    pub storage: StorageService,
    /// Résolveur DNS du nœud.
    pub resolver: Arc<dyn MailResolver>,
    /// TLS côté client de l'hôte (`tokio-rustls`) ; absent : aucun TLS possible.
    pub tls: Option<Arc<dyn TlsConnectorProvider>>,
    /// Coffre-fort (consommateur `lyxal_mail`) : clés DKIM, identifiants du relais.
    pub secrets: Option<SecretsClient>,
    /// Chaîne de remise du lot 5 (route locale, avis).
    pub pipeline: DeliveryPipeline,
    /// Domaines d'organisation (DMARC de la route locale).
    pub organizational: Arc<dyn OrganizationalDomain>,
    /// Clés DKIM ouvertes du nœud.
    pub keys: Arc<DkimKeyCache>,
}

/// Destinataires réservés d'un groupe : même envoi, même destination.
struct Job {
    claim: String,
    domain: String,
    local: bool,
    items: Vec<ClaimedRecipient>,
}

struct Inner {
    config: OutboundConfig,
    services: OutboundServices,
    pool: ConnectionPool,
    limiter: DestinationLimiter,
    metrics: Arc<OutboundMetrics>,
    preparer: Preparer,
    local: LocalRoute,
    dsn: DsnComposer,
    /// Réservations en cours : jeton → destinataires non encore écrits.
    inflight: Mutex<HashMap<String, HashSet<String>>>,
    /// Contenus illisibles par envoi (nœud) : deux fois de suite → échec définitif `5.3.0`.
    content_failures: Mutex<HashMap<String, u32>>,
    wake: Arc<Notify>,
}

/// Worker d'envoi du nœud.
pub struct OutboundDispatcher {
    descriptor: WorkerDescriptor,
    inner: Arc<Inner>,
}

impl OutboundDispatcher {
    /// Worker sur les réglages `config` (validés) et les services de l'hôte.
    pub fn new(config: OutboundConfig, services: OutboundServices) -> Result<Self, RuntimeError> {
        config
            .validate()
            .map_err(|error| RuntimeError::ConfigInvalid {
                message: error.to_string(),
            })?;
        let module = ModuleId::new(MODULE_ID);
        let name = "mail.outbound";
        let descriptor = WorkerDescriptor::new(WorkerId::new(&module, name)?, module, name)
            .with_description("Envoi du courrier vers les MX, le relais et la route locale")
            .with_criticality(WorkerCriticality::Required)
            .with_shutdown_timeout(config.drain_timeout + SHUTDOWN_MARGIN)
            .with_restart_policy(RestartPolicy::OnFailure {
                max_retries: 10,
                backoff: WorkerRestartBackoff::default(),
            });
        let preparer = Preparer::new(
            services.store.clone(),
            services.storage.clone(),
            services.secrets.clone(),
            services.keys.clone(),
            config.hostname.clone(),
        );
        let local = LocalRoute::new(
            services.store.clone(),
            services.pipeline.clone(),
            services.resolver.clone(),
            services.organizational.clone(),
            config.hostname.clone(),
        );
        let dsn = DsnComposer::new(
            services.store.clone(),
            services.storage.clone(),
            services.pipeline.clone(),
            config.hostname.clone(),
        );
        Ok(Self {
            descriptor,
            inner: Arc::new(Inner {
                pool: ConnectionPool::new(&config),
                limiter: DestinationLimiter::new(&config),
                metrics: Arc::new(OutboundMetrics::default()),
                preparer,
                local,
                dsn,
                inflight: Mutex::new(HashMap::new()),
                content_failures: Mutex::new(HashMap::new()),
                wake: Arc::new(Notify::new()),
                config,
                services,
            }),
        })
    }

    /// Mesures de l'envoi du nœud.
    pub fn metrics(&self) -> Arc<OutboundMetrics> {
        self.inner.metrics.clone()
    }

    /// Réveil du worker (dépôt fait sur ce nœud).
    pub fn waker(&self) -> Arc<Notify> {
        self.inner.wake.clone()
    }
}

#[async_trait]
impl LyxalWorker for OutboundDispatcher {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let inner = &self.inner;
        let mut jobs: JoinSet<()> = JoinSet::new();
        let mut renewed = Instant::now();
        let renew_every = RENEW_EVERY.min(inner.config.lease / 3);
        let mut recovered = Instant::now();
        let max_jobs = usize::try_from(inner.config.max_connections).unwrap_or(100);
        while !ctx.is_cancelled() {
            while jobs.try_join_next().is_some() {}
            let mut found = false;
            if jobs.len() < max_jobs {
                match inner.claim().await {
                    Ok(batch) => {
                        found = !batch.is_empty();
                        for job in batch {
                            let inner = inner.clone();
                            jobs.spawn(async move { inner.run_job(job).await });
                        }
                    }
                    Err(error) => {
                        tracing::warn!(code = %error.code(), "réservation de la file d'envoi en échec");
                    }
                }
            }
            if renewed.elapsed() >= renew_every {
                inner.renew().await;
                renewed = Instant::now();
            }
            if recovered.elapsed() >= DSN_RECOVER_EVERY {
                inner.recover_dsn().await;
                recovered = Instant::now();
            }
            for connection in inner.pool.expired() {
                connection.quit().await;
            }
            let wait = if found {
                Duration::ZERO
            } else if jobs.is_empty() {
                IDLE_POLL_EVERY
            } else {
                POLL_EVERY
            };
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = inner.wake.notified() => {}
                Some(_) = jobs.join_next(), if !jobs.is_empty() => {}
                _ = tokio::time::sleep(wait) => {}
            }
        }
        // Arrêt propre : envois en cours drainés dans le délai, puis abandonnés et rendus
        let drained = tokio::time::timeout(inner.config.drain_timeout, async {
            while jobs.join_next().await.is_some() {}
        })
        .await;
        if drained.is_err() {
            jobs.abort_all();
            while jobs.join_next().await.is_some() {}
        }
        inner.release_all().await;
        for connection in inner.pool.drain() {
            connection.quit().await;
        }
        Ok(())
    }
}

/// Empreinte courte d'un domaine pour le journal (décision E28).
fn domain_label(config: &OutboundConfig, domain: &str) -> String {
    if config.log_domains {
        domain.to_string()
    } else {
        lyxal_crypto::blake3_hex(domain.as_bytes())[..12].to_string()
    }
}

/// Texte d'une réponse distante, assaini et coupé.
fn remote_text(reply: &lyxal_mail_proto::smtp::Response) -> String {
    let mut text = reply.lines().join(" ");
    if text.len() > MAX_REMOTE_TEXT {
        let mut end = MAX_REMOTE_TEXT;
        while !text.is_char_boundary(end) {
            end -= 1;
        }
        text.truncate(end);
    }
    text
}

fn notify(item: &ClaimedRecipient) -> Option<ProtoNotify> {
    let list = item.notify.as_ref()?;
    let mut notify = ProtoNotify::default();
    for value in list {
        match value {
            DsnNotify::Never => notify.never = true,
            DsnNotify::Success => notify.success = true,
            DsnNotify::Failure => notify.failure = true,
            DsnNotify::Delay => notify.delay = true,
        }
    }
    Some(notify)
}

fn wants_success(item: &ClaimedRecipient) -> bool {
    item.notify
        .as_ref()
        .is_some_and(|list| list.contains(&DsnNotify::Success))
}

fn orcpt(item: &ClaimedRecipient) -> Option<DsnOrcpt> {
    let (address_type, address) = item.orcpt.as_deref()?.split_once(';')?;
    let orcpt = DsnOrcpt {
        address_type: address_type.trim().to_string(),
        address: address.trim().to_string(),
    };
    orcpt.is_valid().then_some(orcpt)
}

/// Résultat à écrire pour un destinataire.
enum Written {
    Delivered(DeliveredItem),
    Failed(FailedItem),
    Released,
}

impl Inner {
    fn track(&self, claim: &str, recipients: impl IntoIterator<Item = String>) {
        let mut inflight = self.inflight.lock().unwrap_or_else(PoisonError::into_inner);
        inflight
            .entry(claim.to_string())
            .or_default()
            .extend(recipients);
    }

    fn untrack(&self, claim: &str, recipients: &[String]) {
        let mut inflight = self.inflight.lock().unwrap_or_else(PoisonError::into_inner);
        if let Some(set) = inflight.get_mut(claim) {
            for recipient in recipients {
                set.remove(recipient);
            }
            if set.is_empty() {
                inflight.remove(claim);
            }
        }
    }

    /// Une réservation, ses préparations et ses groupes.
    async fn claim(&self) -> MailResult<Vec<Job>> {
        let claimed = self
            .services
            .store
            .queue_claim(QueueClaimParams {
                node: self.config.node.clone(),
                limit: Some(i64::from(self.config.claim_batch)),
                lease_seconds: Some(i64::try_from(self.config.lease.as_secs()).unwrap_or(600)),
                exclude_domains: self.limiter.saturated(),
            })
            .await?;
        let Some(claim) = claimed.claim else {
            return Ok(Vec::new());
        };
        self.metrics.claim(claimed.items.len());
        self.track(
            &claim,
            claimed.items.iter().map(|item| item.recipient.to_sql()),
        );
        let mut items = claimed.items;
        // Préparation, une fois par envoi (premier destinataire réservé)
        let mut unprepared: BTreeMap<String, ClaimedRecipient> = BTreeMap::new();
        for item in &items {
            if !item.prepared {
                unprepared
                    .entry(item.submission.to_sql())
                    .or_insert_with(|| item.clone());
            }
        }
        let prepared = futures::future::join_all(unprepared.values().map(|item| async {
            (
                item.submission.to_sql(),
                self.preparer.prepare(&claim, item).await,
            )
        }))
        .await;
        for (submission, result) in prepared {
            let selected: Vec<String> = items
                .iter()
                .filter(|item| item.submission.to_sql() == submission)
                .map(|item| item.recipient.to_sql())
                .collect();
            match result {
                Ok(preparation) => {
                    self.metrics
                        .prepared(preparation.signatures, preparation.malformed);
                    self.produce_dsn(&preparation.dsn, &items).await;
                    if preparation.malformed {
                        // Destinataires mis en échec par fn::mail_queue_prepare
                        self.untrack(&claim, &selected);
                        items.retain(|item| item.submission.to_sql() != submission);
                        continue;
                    }
                    for item in items
                        .iter_mut()
                        .filter(|item| item.submission.to_sql() == submission)
                    {
                        item.prepared = true;
                        item.envelope_from = preparation.envelope_from.clone();
                        item.prefix =
                            (!preparation.prefix.is_empty()).then(|| preparation.prefix.clone());
                    }
                }
                Err(error) => {
                    tracing::warn!(code = %error.code(), "préparation d'un envoi en échec : reprise plus tard");
                    let later = SystemTime::now() + RETRY_LATER;
                    self.release(&claim, &selected, Some(later)).await;
                    items.retain(|item| item.submission.to_sql() != submission);
                }
            }
        }
        // Groupes (envoi, destination), `recipients_per_transaction` au plus
        let mut groups: BTreeMap<(String, String, bool), Vec<ClaimedRecipient>> = BTreeMap::new();
        for item in items {
            groups
                .entry((item.submission.to_sql(), item.domain.clone(), item.local))
                .or_default()
                .push(item);
        }
        let size = usize::try_from(self.config.recipients_per_transaction).unwrap_or(100);
        let mut jobs = Vec::new();
        for ((_, domain, local), group) in groups {
            for chunk in group.chunks(size) {
                jobs.push(Job {
                    claim: claim.clone(),
                    domain: domain.clone(),
                    local,
                    items: chunk.to_vec(),
                });
            }
        }
        Ok(jobs)
    }

    async fn run_job(self: Arc<Self>, job: Job) {
        let started = Instant::now();
        let mut unreachable = None;
        let written = if job.local {
            self.local_job(&job).await
        } else {
            self.remote_job(&job, &mut unreachable).await
        };
        self.write(&job, written, unreachable, started).await;
    }

    /// Octets du message : préfixe puis fichier.
    async fn message_stream(&self, item: &ClaimedRecipient) -> MailResult<content::ContentStream> {
        let object = item
            .content
            .object
            .as_ref()
            .map(ToSql::to_sql)
            .ok_or_else(|| MailError::Unavailable("contenu d'un envoi non clos".into()))?;
        content::open(&self.services.storage, &object).await
    }

    fn content_failure(&self, submission: &str) -> bool {
        let mut failures = self
            .content_failures
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if failures.len() >= MAX_CONTENT_FAILURES {
            failures.clear();
        }
        let count = failures.entry(submission.to_string()).or_insert(0);
        *count += 1;
        *count >= 2
    }

    fn failed_all(
        job: &Job,
        stage: AttemptStage,
        permanent: bool,
        code: Option<i64>,
        enhanced: Option<&str>,
        text: Option<String>,
        host: Option<String>,
    ) -> Vec<Written> {
        job.items
            .iter()
            .map(|item| {
                Written::Failed(FailedItem {
                    recipient: item.recipient.to_sql(),
                    permanent,
                    stage,
                    code,
                    enhanced: enhanced.map(str::to_string),
                    text: text.clone(),
                    host: host.clone(),
                })
            })
            .collect()
    }

    /// Route locale.
    async fn local_job(&self, job: &Job) -> Vec<Written> {
        let Some(first) = job.items.first() else {
            return Vec::new();
        };
        let submission = first.submission.to_sql();
        let mut bytes: Vec<u8> = first.prefix.clone().unwrap_or_default().into_bytes();
        let read = async {
            let mut stream = self.message_stream(first).await?;
            while let Some(chunk) = stream.next().await {
                bytes.extend_from_slice(&chunk?);
            }
            MailResult::Ok(())
        }
        .await;
        if let Err(error) = read {
            return self.content_failed(job, &submission, &error);
        }
        let mut records = HashMap::new();
        let domains: Vec<String> = first
            .header_from
            .iter()
            .filter_map(|address| {
                address
                    .rsplit_once('@')
                    .map(|(_, d)| d.to_ascii_lowercase())
            })
            .collect();
        match self
            .preparer
            .identities(&first.tenant.to_sql(), &domains)
            .await
        {
            Ok(identities) => {
                for identity in identities {
                    let k = match identity.key.algorithm() {
                        lyxal_crypto::DkimAlgorithm::RsaSha256 => "rsa",
                        lyxal_crypto::DkimAlgorithm::Ed25519Sha256 => "ed25519",
                    };
                    use base64::Engine as _;
                    let p = base64::engine::general_purpose::STANDARD
                        .encode(identity.key.public_key_record_bytes());
                    records.insert(
                        format!("{}._domainkey.{}", identity.selector, identity.domain),
                        format!("v=DKIM1; k={k}; p={p}"),
                    );
                }
            }
            Err(error) => {
                tracing::warn!(code = %error.code(), "route locale : clés DKIM illisibles, vérification par le DNS");
            }
        }
        let addresses: Vec<String> = job.items.iter().map(|item| item.address.clone()).collect();
        let outcomes = self
            .local
            .deliver(
                LocalMessage {
                    submission: &submission,
                    envelope_from: first.envelope_from.as_deref().unwrap_or_default(),
                    bytes: Bytes::from(bytes),
                    dkim_records: records,
                },
                &addresses,
            )
            .await;
        job.items
            .iter()
            .zip(outcomes)
            .map(|(item, outcome)| match outcome {
                LocalOutcome::Delivered => Written::Delivered(DeliveredItem {
                    recipient: item.recipient.to_sql(),
                    outcome: QueueOutcome::Delivered,
                    host: None,
                    code: Some(250),
                    enhanced: Some("2.0.0".into()),
                    tls: None,
                    at: Some(MailDatetime::now()),
                }),
                LocalOutcome::Failed {
                    permanent,
                    code,
                    enhanced,
                } => Written::Failed(FailedItem {
                    recipient: item.recipient.to_sql(),
                    permanent,
                    stage: AttemptStage::Local,
                    code: Some(i64::from(code)),
                    enhanced: Some(enhanced.to_string()),
                    text: None,
                    host: None,
                }),
            })
            .collect()
    }

    fn content_failed(&self, job: &Job, submission: &str, error: &MailError) -> Vec<Written> {
        self.metrics.content_unreadable();
        let permanent = self.content_failure(submission);
        tracing::warn!(code = %error.code(), permanent, "contenu d'un envoi illisible");
        Self::failed_all(
            job,
            AttemptStage::Content,
            permanent,
            permanent.then_some(554),
            Some(if permanent { "5.3.0" } else { "4.3.0" }),
            None,
            None,
        )
    }

    /// Serveurs de la destination : relais, ou MX.
    async fn hosts(&self, domain: &str) -> Result<Vec<MxHost>, ResolveFailure> {
        let Some(relay) = &self.config.relay else {
            return MxPlan::new(self.services.resolver.as_ref(), &self.config)
                .resolve(domain)
                .await;
        };
        let mut addresses = Vec::new();
        if let Ok(ip) = relay.host.parse::<IpAddr>() {
            addresses.push(ip);
        }
        for family in &self.config.ip_families {
            let found: Vec<IpAddr> = match family {
                IpFamily::Ipv4 => self
                    .services
                    .resolver
                    .ipv4(&relay.host)
                    .await
                    .map(|a| a.records.into_iter().map(IpAddr::V4).collect())
                    .unwrap_or_default(),
                IpFamily::Ipv6 => self
                    .services
                    .resolver
                    .ipv6(&relay.host)
                    .await
                    .map(|a| a.records.into_iter().map(IpAddr::V6).collect())
                    .unwrap_or_default(),
            };
            addresses.extend(found);
        }
        if addresses.is_empty() {
            return Err(ResolveFailure {
                permanent: false,
                enhanced: "4.4.3",
                reason: crate::outbound::mx::ResolveReason::DnsFailure,
            });
        }
        Ok(vec![MxHost {
            name: relay.host.clone(),
            addresses,
        }])
    }

    async fn relay_credentials(&self) -> MailResult<Option<RelayCredentials>> {
        let Some(path) = self
            .config
            .relay
            .as_ref()
            .and_then(|r| r.credentials_path.clone())
        else {
            return Ok(None);
        };
        let secrets = self.services.secrets.as_ref().ok_or_else(|| {
            MailError::Unavailable("coffre-fort sans clé maîtresse : identifiants du relais".into())
        })?;
        let revealed = secrets
            .read(ClientRead {
                tenant: None,
                path,
                label: None,
            })
            .await?;
        #[derive(serde::Deserialize)]
        struct Stored {
            username: String,
            password: String,
        }
        let parsed: Stored = serde_json::from_slice(revealed.value.expose_secret())
            .map_err(|_| MailError::Unavailable("identifiants du relais illisibles".into()))?;
        Ok(Some(RelayCredentials {
            username: parsed.username,
            password: zeroize::Zeroizing::new(parsed.password.into_bytes()),
        }))
    }

    fn target_tls(&self) -> TargetTls {
        match (&self.config.relay, self.config.tls) {
            (Some(relay), _) => match relay.tls {
                RelayTls::StartTls => TargetTls::RequiredStartTls,
                RelayTls::Implicit => TargetTls::Implicit,
            },
            (None, OutboundTls::Opportunistic) if self.services.tls.is_some() => {
                TargetTls::Opportunistic
            }
            (None, _) => TargetTls::Plain,
        }
    }

    fn source(&self, ip: IpAddr) -> Option<IpAddr> {
        match ip {
            IpAddr::V4(_) => self.config.source_ipv4.map(IpAddr::V4),
            IpAddr::V6(_) => self.config.source_ipv6.map(IpAddr::V6),
        }
    }

    /// Connexion vers un serveur : gardée, sinon ouverte (repli en clair une fois si la
    /// poignée de main opportuniste échoue). `Err(répondu)` si aucune connexion.
    async fn connect(
        &self,
        host: &MxHost,
        ehlo: &Domain,
    ) -> Result<(SmtpConnection, PoolKey), bool> {
        let tls = self.target_tls();
        let port = self
            .config
            .relay
            .as_ref()
            .map_or(self.config.smtp_port, |r| r.port);
        let mut answered = false;
        for ip in &host.addresses {
            let key = PoolKey {
                host: host.name.clone(),
                ip: *ip,
                tls,
            };
            if let Some(connection) = self.pool.take(&key) {
                self.metrics.connection(true);
                return Ok((connection, key));
            }
            let credentials = match self.relay_credentials().await {
                Ok(credentials) => credentials,
                Err(error) => {
                    tracing::warn!(code = %error.code(), "identifiants du relais illisibles");
                    return Err(false);
                }
            };
            let mut target = ConnectTarget {
                host: host.name.clone(),
                ip: *ip,
                port,
                tls,
                source: self.source(*ip),
            };
            let provider = self.services.tls.as_deref();
            let mut opened = SmtpConnection::open(
                &target,
                ehlo,
                provider,
                credentials.as_ref(),
                &self.config.timeouts,
            )
            .await;
            let mut fallback = false;
            if let Err(failure) = &opened {
                if failure.tls_failed && tls == TargetTls::Opportunistic {
                    // Une reconnexion en clair au même hôte (décision E9)
                    fallback = true;
                    target.tls = TargetTls::Plain;
                    opened =
                        SmtpConnection::open(&target, ehlo, provider, None, &self.config.timeouts)
                            .await;
                }
            }
            match opened {
                Ok(connection) => {
                    self.metrics.connection(false);
                    self.metrics.tls(connection.tls.is_some(), fallback);
                    return Ok((connection, key));
                }
                Err(failure) => {
                    answered |= failure.answered();
                    tracing::debug!(
                        stage = stage_name(failure.stage),
                        "connexion à un serveur en échec"
                    );
                }
            }
        }
        Err(answered)
    }

    /// Envoi vers les MX ou le relais.
    async fn remote_job(&self, job: &Job, unreachable: &mut Option<bool>) -> Vec<Written> {
        let Some(first) = job.items.first() else {
            return Vec::new();
        };
        let destination = if self.config.relay.is_some() {
            "relay".to_string()
        } else {
            job.domain.clone()
        };
        if let Err(wait) = self.limiter.take_message(&destination) {
            let later = SystemTime::now() + wait;
            let recipients: Vec<String> = job
                .items
                .iter()
                .map(|item| item.recipient.to_sql())
                .collect();
            self.release(&job.claim, &recipients, Some(later)).await;
            return Vec::new();
        }
        let Some(_slot) = self.limiter.acquire(&destination).await else {
            return Vec::new();
        };
        let hosts = match self.hosts(&job.domain).await {
            Ok(hosts) => hosts,
            Err(failure) => {
                return Self::failed_all(
                    job,
                    AttemptStage::Dns,
                    failure.permanent,
                    failure.permanent.then_some(550),
                    Some(failure.enhanced),
                    None,
                    None,
                )
            }
        };
        let Some(ehlo) = Domain::parse(&self.config.hostname) else {
            return Self::failed_all(job, AttemptStage::Connect, false, None, None, None, None);
        };
        let from = match first.envelope_from.as_deref() {
            Some(address) => match Mailbox::parse(address) {
                Some(mailbox) => ReversePath::Mailbox(mailbox),
                None => {
                    return Self::failed_all(
                        job,
                        AttemptStage::Mail,
                        true,
                        Some(553),
                        Some("5.1.7"),
                        None,
                        None,
                    )
                }
            },
            None => ReversePath::Null,
        };
        // Destinataires de l'enveloppe ; une adresse illisible échoue seule (5.1.3)
        let mut written: Vec<Option<Written>> = job.items.iter().map(|_| None).collect();
        let mut plans = Vec::new();
        let mut planned = Vec::new();
        for (index, item) in job.items.iter().enumerate() {
            match Mailbox::parse(&item.address) {
                Some(mailbox) => {
                    plans.push(RcptPlan {
                        path: ForwardPath::Mailbox(mailbox),
                        notify: notify(item),
                        orcpt: orcpt(item),
                    });
                    planned.push(index);
                }
                None => {
                    written[index] = Some(Written::Failed(FailedItem {
                        recipient: item.recipient.to_sql(),
                        permanent: true,
                        stage: AttemptStage::Rcpt,
                        code: Some(553),
                        enhanced: Some("5.1.3".into()),
                        text: None,
                        host: None,
                    }));
                }
            }
        }
        let prefix = first.prefix.clone().unwrap_or_default();
        let envelope = Envelope {
            from,
            recipients: plans,
            size: u64::try_from(first.size).unwrap_or(0) + prefix.len() as u64,
            eight_bit: first.eight_bit,
            smtputf8: first.smtputf8,
            ret: Some(match first.dsn.ret {
                DsnReturn::Full => DsnRet::Full,
                DsnReturn::Hdrs => DsnRet::Headers,
            }),
            envid: first.dsn.envid.clone(),
        };
        let mut connected = None;
        let mut answered = false;
        for host in &hosts {
            match self.connect(host, &ehlo).await {
                Ok(connection) => {
                    connected = Some(connection);
                    break;
                }
                Err(replied) => answered |= replied,
            }
        }
        let Some((mut connection, key)) = connected else {
            if !answered {
                self.metrics.unreachable();
            }
            let mut failed =
                Self::failed_all(job, AttemptStage::Connect, false, None, None, None, None);
            for (index, slot) in written.into_iter().enumerate() {
                if let Some(item) = slot {
                    failed[index] = item;
                }
            }
            // Destination injoignable : suspension (décision E7) ; attachée au lot écrit
            *unreachable = Some(!answered);
            return failed;
        };
        let stream = match self.message_stream(first).await {
            Ok(stream) => stream,
            Err(error) => {
                if connection.reset().await {
                    let _ = self.pool.put(key, connection);
                }
                return self.content_failed(job, &first.submission.to_sql(), &error);
            }
        };
        let tls = connection.tls.map(|info| TlsInfo {
            version: Some(info.version.to_string()),
            verified: info.verified,
        });
        let dsn_offered = connection.extensions.dsn;
        let host = connection.host.clone();
        let result = connection.send(&envelope, prefix.as_bytes(), stream).await;
        if result.content_failed {
            return self.content_failed(
                job,
                &first.submission.to_sql(),
                &MailError::Unavailable("flux du contenu interrompu".into()),
            );
        }
        if result.reusable {
            if let Some(extra) = self.pool.put(key, connection) {
                extra.quit().await;
            }
        }
        for (position, outcome) in planned.into_iter().zip(result.recipients) {
            let item = &job.items[position];
            written[position] = Some(match outcome {
                RecipientOutcome::Accepted { reply } => Written::Delivered(DeliveredItem {
                    recipient: item.recipient.to_sql(),
                    outcome: if !dsn_offered && wants_success(item) {
                        QueueOutcome::Relayed
                    } else {
                        QueueOutcome::Delivered
                    },
                    host: Some(host.clone()),
                    code: Some(i64::from(reply.code())),
                    enhanced: reply.status().map(|s| s.to_string()),
                    tls: tls.clone(),
                    at: Some(MailDatetime::now()),
                }),
                RecipientOutcome::Refused {
                    stage,
                    reply,
                    permanent,
                    enhanced,
                } => Written::Failed(FailedItem {
                    recipient: item.recipient.to_sql(),
                    permanent,
                    stage,
                    code: reply.as_ref().map(|r| i64::from(r.code())),
                    enhanced,
                    text: reply.as_ref().map(remote_text).filter(|t| !t.is_empty()),
                    host: Some(host.clone()),
                }),
            });
        }
        written
            .into_iter()
            .map(|slot| slot.unwrap_or(Written::Released))
            .collect()
    }

    /// Écrit les résultats d'une transaction, produit les avis dus, journalise.
    async fn write(
        &self,
        job: &Job,
        written: Vec<Written>,
        unreachable: Option<bool>,
        started: Instant,
    ) {
        let mut delivered = Vec::new();
        let mut failed = Vec::new();
        let mut released = Vec::new();
        for (item, result) in job.items.iter().zip(written) {
            match result {
                Written::Delivered(value) => delivered.push(value),
                Written::Failed(value) => failed.push(value),
                Written::Released => released.push(item.recipient.to_sql()),
            }
        }
        let mut dues: Vec<DsnDue> = Vec::new();
        let mut done: Vec<String> = Vec::new();
        let stage = failed.first().map(|f| f.stage);
        if !delivered.is_empty() {
            let recipients: Vec<String> = delivered.iter().map(|d| d.recipient.clone()).collect();
            for item in &delivered {
                match item.outcome {
                    QueueOutcome::Delivered => self.metrics.delivered(job.local),
                    QueueOutcome::Relayed => self.metrics.relayed(),
                }
            }
            for (items, recipients) in delivered
                .chunks(WRITE_BATCH)
                .zip(recipients.chunks(WRITE_BATCH))
            {
                match self
                    .services
                    .store
                    .queue_complete(QueueCompleteParams {
                        claim: job.claim.clone(),
                        items: items.to_vec(),
                    })
                    .await
                {
                    Ok(result) => {
                        self.metrics.lost(result.lost.len());
                        dues.extend(result.dsn);
                        done.extend_from_slice(recipients);
                    }
                    Err(error) => self.write_failed(&MailError::from(error)),
                }
            }
        }
        if !failed.is_empty() {
            let recipients: Vec<String> = failed.iter().map(|f| f.recipient.clone()).collect();
            for item in &failed {
                if item.permanent {
                    self.metrics.failed(item.stage);
                } else {
                    self.metrics.retried(item.stage);
                }
            }
            let destination = match (job.local, self.config.relay.is_some(), unreachable) {
                (false, false, Some(unreachable)) => Some(DestinationFailure {
                    domain: job.domain.clone(),
                    unreachable,
                    stage: Some(AttemptStage::Connect),
                }),
                (false, false, None)
                    if stage != Some(AttemptStage::Dns) && stage != Some(AttemptStage::Content) =>
                {
                    // Le serveur a répondu : compteur de la destination remis à zéro
                    Some(DestinationFailure {
                        domain: job.domain.clone(),
                        unreachable: false,
                        stage: None,
                    })
                }
                _ => None,
            };
            // Compteur de la destination tenu une seule fois par transaction (premier lot)
            let mut destination = destination;
            for (items, recipients) in failed
                .chunks(WRITE_BATCH)
                .zip(recipients.chunks(WRITE_BATCH))
            {
                match self
                    .services
                    .store
                    .queue_fail(QueueFailParams {
                        claim: job.claim.clone(),
                        items: items.to_vec(),
                        destination: destination.take(),
                    })
                    .await
                {
                    Ok(result) => {
                        self.metrics.lost(result.lost.len());
                        for item in &result.items {
                            if item.state == RecipientState::Expired {
                                self.metrics.expired();
                            }
                        }
                        dues.extend(result.dsn);
                        done.extend_from_slice(recipients);
                    }
                    Err(error) => self.write_failed(&MailError::from(error)),
                }
            }
        }
        if !released.is_empty() {
            self.release(&job.claim, &released, None).await;
        }
        self.untrack(&job.claim, &done);
        let millis = u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        if !job.local {
            self.metrics.transaction(millis);
        }
        let destination = domain_label(&self.config, &job.domain);
        tracing::info!(
            submission = %job.items.first().map(|i| i.submission.to_sql()).unwrap_or_default(),
            recipients = job.items.len(),
            destination = %destination,
            route = if job.local { "local" } else if self.config.relay.is_some() { "relay" } else { "mx" },
            stage = stage.map(stage_name).unwrap_or("data"),
            duration_ms = millis,
            "transaction d'envoi"
        );
        self.produce_dsn(&dues, &job.items).await;
    }

    fn write_failed(&self, error: &MailError) {
        self.metrics.result_write_failure();
        if error.code() == "MAIL_QUEUE_CLAIM_LOST" {
            tracing::info!("réservation perdue : destinataires repris par un autre nœud");
        } else {
            tracing::warn!(code = %error.code(), "résultat d'envoi non écrit : repris à l'expiration du bail");
        }
    }

    async fn produce_dsn(&self, dues: &[DsnDue], items: &[ClaimedRecipient]) {
        for due in dues {
            let object = items
                .iter()
                .find(|item| item.submission == due.submission)
                .and_then(|item| item.content.object.as_ref())
                .map(ToSql::to_sql);
            self.produce_one(due, object.as_deref()).await;
        }
    }

    /// Avis finaux restés dus (dépôt de l'avis en panne, nœud arrêté avant de le produire) : repris
    /// ici ; un avis non produit reste dû pour la reprise suivante.
    async fn recover_dsn(&self) {
        let pending = match self
            .services
            .store
            .queue_dsn_pending(DsnPendingParams::default())
            .await
        {
            Ok(pending) => pending,
            Err(error) => {
                tracing::warn!(code = %MailError::from(error).code(), "lecture des avis dus en échec");
                return;
            }
        };
        for item in pending.dsn {
            let object = item.object.as_ref().map(ToSql::to_sql);
            let due = DsnDue {
                submission: item.submission,
                action: item.action,
                recipients: item.recipients,
            };
            self.produce_one(&due, object.as_deref()).await;
        }
    }

    async fn produce_one(&self, due: &DsnDue, object: Option<&str>) {
        let mut attempt = 0;
        loop {
            attempt += 1;
            match self.dsn.produce(due, object).await {
                Ok(DsnOutcome::Delivered) => {
                    self.metrics.dsn(true);
                    break;
                }
                Ok(DsnOutcome::Suppressed) => {
                    self.metrics.dsn(false);
                    break;
                }
                Ok(DsnOutcome::Deferred) => break,
                Err(error) if error.is_retryable() && attempt < 3 => {
                    tokio::time::sleep(Duration::from_millis(200 * attempt)).await;
                }
                Err(error) => {
                    self.metrics.dsn(false);
                    tracing::warn!(code = %error.code(), "avis de non-remise non produit : repris plus tard");
                    break;
                }
            }
        }
    }

    async fn release(&self, claim: &str, recipients: &[String], not_before: Option<SystemTime>) {
        if recipients.is_empty() {
            return;
        }
        for batch in recipients.chunks(500) {
            let params = QueueReleaseParams {
                claim: claim.to_string(),
                recipients: batch.to_vec(),
                not_before: not_before.and_then(|at| {
                    let seconds = at.duration_since(SystemTime::UNIX_EPOCH).ok()?.as_secs();
                    MailDatetime::from_timestamp(i64::try_from(seconds).ok()?, 0)
                }),
            };
            match self.services.store.queue_release(params).await {
                Ok(result) => self
                    .metrics
                    .released(usize::try_from(result.released).unwrap_or(0)),
                Err(error) => self.write_failed(&MailError::from(error)),
            }
        }
        self.untrack(claim, recipients);
    }

    /// Baux renouvelés pour les destinataires en cours.
    async fn renew(&self) {
        let snapshot: Vec<(String, Vec<String>)> = {
            let inflight = self.inflight.lock().unwrap_or_else(PoisonError::into_inner);
            inflight
                .iter()
                .map(|(claim, set)| (claim.clone(), set.iter().cloned().collect()))
                .collect()
        };
        for (claim, recipients) in snapshot {
            for batch in recipients.chunks(500) {
                match self
                    .services
                    .store
                    .queue_renew(QueueRenewParams {
                        claim: claim.clone(),
                        recipients: batch.to_vec(),
                        lease_seconds: Some(
                            i64::try_from(self.config.lease.as_secs()).unwrap_or(600),
                        ),
                    })
                    .await
                {
                    Ok(renewed) => {
                        let lost: Vec<String> = renewed.lost.iter().map(ToSql::to_sql).collect();
                        self.untrack(&claim, &lost);
                    }
                    Err(error) => {
                        if error.is_business_code("MAIL_QUEUE_CLAIM_LOST") {
                            self.untrack(&claim, batch);
                        }
                    }
                }
            }
        }
    }

    /// Arrêt propre : tous les destinataires non écrits rendus sans essai compté.
    async fn release_all(&self) {
        let snapshot: Vec<(String, Vec<String>)> = {
            let inflight = self.inflight.lock().unwrap_or_else(PoisonError::into_inner);
            inflight
                .iter()
                .map(|(claim, set)| (claim.clone(), set.iter().cloned().collect()))
                .collect()
        };
        for (claim, recipients) in snapshot {
            self.release(&claim, &recipients, None).await;
        }
    }
}
