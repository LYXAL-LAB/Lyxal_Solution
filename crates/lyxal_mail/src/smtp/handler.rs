// SPDX-License-Identifier: AGPL-3.0-only

//! Handler de l'écoute `smtp` : ce que l'hôte remet à la réception SMTP et ce qu'elle partage
//! entre toutes ses sessions (plan du lot 5, §11.1).

use async_trait::async_trait;
use lyxal_mail_proto::smtp::SmtpLimits;
use std::collections::BTreeMap;
use std::sync::Arc;
use std::time::Duration;

use super::block::BlockList;
use super::config::{SmtpConfig, SmtpConfigError};
use super::metrics::SmtpMetrics;
use super::resolver::CountingResolver;
use super::session::SmtpSession;
use crate::auth::{EmbeddedSuffixList, OrganizationalDomain};
use crate::delivery::{DeliveryPipeline, Reception};
use crate::dns::MailResolver;
use crate::net::{
    IpRateLimiter, MailProtocol, MemoryBudget, Session, SessionEnd, SessionHandler, WindowLimit,
    DEFAULT_MAX_TRACKED_NETWORKS,
};
use crate::store::MailStore;

/// Services remis par l'hôte à la réception SMTP.
pub struct SmtpServices {
    /// Session système de l'hôte (résolution des destinataires, bannissements).
    pub store: MailStore,
    /// Résolveur DNS du nœud (un par nœud, cache partagé).
    pub resolver: Arc<dyn MailResolver>,
    /// Chaîne de remise.
    pub pipeline: DeliveryPipeline,
    /// Budget mémoire des connexions du nœud (classe « réception SMTP » pour les messages).
    pub budget: MemoryBudget,
    /// Liste de blocage du nœud (relue par [`super::BlockRefreshWorker`]).
    pub blocks: BlockList,
}

/// Ce que partagent les sessions d'un nœud.
pub(crate) struct Shared {
    pub(crate) config: SmtpConfig,
    pub(crate) limits: SmtpLimits,
    pub(crate) store: MailStore,
    pub(crate) budget: MemoryBudget,
    pub(crate) blocks: BlockList,
    pub(crate) metrics: Arc<SmtpMetrics>,
    pub(crate) message_rate: IpRateLimiter,
    /// Réception du port 25, ou dépôt authentifié des ports 587 et 465.
    pub(crate) mode: Mode,
}

/// Rôle des sessions : la machine d'états, la lecture des données et les limites sont
/// communes ; les contrôles et le traitement du message diffèrent.
pub(crate) enum Mode {
    /// Réception des autres serveurs (lot 5).
    Inbound(Box<Inbound>),
    /// Dépôt authentifié des logiciels de courrier (lot 6, §8).
    Submission(crate::submission::SubmissionShared),
}

/// Ce que demande la réception : contrôles d'authenticité et chemin de réception commun.
pub(crate) struct Inbound {
    pub(crate) resolver: Arc<dyn MailResolver>,
    pub(crate) organizational: Arc<dyn OrganizationalDomain>,
    /// Chemin de réception commun avec la route locale : chaîne de remise, avis reçus, transferts.
    pub(crate) reception: Reception,
}

impl Shared {
    /// Réglages et limites communs aux deux rôles, sous les réglages `config` (contrôlés ici).
    pub(crate) fn new(
        config: SmtpConfig,
        store: MailStore,
        budget: MemoryBudget,
        blocks: BlockList,
        metrics: Arc<SmtpMetrics>,
        mode: Mode,
    ) -> Result<Self, SmtpConfigError> {
        config.validate()?;
        let message_rate = IpRateLimiter::with_max_tracked_networks(
            vec![WindowLimit {
                window: Duration::from_secs(60),
                limits: config.messages_per_network_per_minute,
            }],
            DEFAULT_MAX_TRACKED_NETWORKS,
        );
        Ok(Self {
            limits: config.syntax_limits(),
            config,
            store,
            budget,
            blocks,
            metrics,
            message_rate,
            mode,
        })
    }
}

/// Réception SMTP (écoute `protocol = "smtp"`). Clonable : les clones partagent les mesures,
/// la liste de blocage et les limites par réseau.
#[derive(Clone)]
pub struct SmtpInboundHandler {
    shared: Arc<Shared>,
    pipeline: DeliveryPipeline,
}

impl SmtpInboundHandler {
    /// Réception sous les réglages `config` (contrôlés ici), avec la liste des suffixes publics
    /// embarquée pour DMARC.
    pub fn new(config: SmtpConfig, services: SmtpServices) -> Result<Self, SmtpConfigError> {
        Self::with_suffix_list(config, services, Arc::new(EmbeddedSuffixList))
    }

    /// Réception avec une source de domaines d'organisation choisie (essais).
    pub fn with_suffix_list(
        config: SmtpConfig,
        services: SmtpServices,
        organizational: Arc<dyn OrganizationalDomain>,
    ) -> Result<Self, SmtpConfigError> {
        let metrics = Arc::new(SmtpMetrics::default());
        let pipeline = services.pipeline;
        let inbound = Inbound {
            resolver: Arc::new(CountingResolver::new(services.resolver, metrics.clone())),
            organizational,
            reception: Reception::new(services.store.clone(), pipeline.clone()),
        };
        Ok(Self {
            shared: Arc::new(Shared::new(
                config,
                services.store,
                services.budget,
                services.blocks,
                metrics,
                Mode::Inbound(Box::new(inbound)),
            )?),
            pipeline,
        })
    }

    /// Réglages en vigueur.
    pub fn config(&self) -> &SmtpConfig {
        &self.shared.config
    }

    /// Liste de blocage du nœud.
    pub fn blocks(&self) -> &BlockList {
        &self.shared.blocks
    }

    /// Chaîne de remise.
    pub fn pipeline(&self) -> &DeliveryPipeline {
        &self.pipeline
    }

    /// Mesures de la réception (sonde : transferts non faits).
    pub fn metrics(&self) -> Arc<SmtpMetrics> {
        self.shared.metrics.clone()
    }

    /// Mesures de la réception (aucune adresse) : compteurs de la session, de l'ordre des
    /// inscriptions (lots, conflits rejoués) et de la liste de blocage.
    pub fn snapshot(&self) -> BTreeMap<String, u64> {
        let mut values = self.shared.metrics.snapshot();
        let queue = self.pipeline.ingest().delivery_stats();
        for (name, value) in [
            ("commit_batches", queue.batches),
            ("commit_items", queue.items),
            ("commit_largest_batch", queue.largest_batch),
            ("commit_conflicts_replayed", queue.conflicts),
            ("commit_split_batches", queue.split_batches),
            ("bans_written", self.shared.blocks.bans()),
            ("blocked_networks", self.shared.blocks.len() as u64),
            (
                "block_refresh_failures",
                self.shared.blocks.refresh_failures(),
            ),
        ] {
            values.insert(name.to_string(), value);
        }
        values
    }
}

#[async_trait]
impl SessionHandler for SmtpInboundHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Smtp
    }

    async fn handle(&self, session: Session) -> SessionEnd {
        SmtpSession::new(self.shared.clone(), session).run().await
    }
}
