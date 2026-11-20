// SPDX-License-Identifier: AGPL-3.0-only

//! Écoutes de courrier : liaison des ports, workers supervisés, pipeline d'acceptation, mesures
//! et sonde de santé. Les limites et le contrat des sessions viennent de `lyxal_mail::net`.

mod accept;
pub mod bind;
mod listener;
pub mod metrics;

use crate::config::{GroupwareConfig, LogClientIp};
use bind::BoundListener;
use lyxal_host::net::IpNetwork;
use lyxal_mail::net::{
    ConnectionLimiter, IpRateLimiter, MailProtocol, MemoryBudget, SessionHandler, TlsMode,
    WindowLimit,
};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::worker::LyxalWorker;
use lyxal_runtime::{ModuleContext, ModuleId, RuntimeError};
use metrics::{ListenerMetrics, ListenerSnapshot};
use serde::Serialize;
use std::collections::BTreeMap;
use std::net::SocketAddr;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::net::TcpListener;

pub use listener::ListenerWorker;

/// Écriture bloquée tolérée (client qui ne lit plus).
pub const WRITE_STALL: Duration = Duration::from_secs(60);

/// Seuil d'usage (en pour cent) au-delà duquel la sonde passe à « dégradé ».
const DEGRADED_PERCENT: u64 = 90;

/// Inactivité tolérée d'une session, par protocole (§6.9 du plan du lot 3).
pub fn idle_timeout(protocol: MailProtocol) -> Duration {
    match protocol {
        // RFC 5321 §4.5.3.2
        MailProtocol::Smtp | MailProtocol::Submission => Duration::from_secs(300),
        // RFC 9051 : déconnexion après 30 minutes au moins
        MailProtocol::Imap => Duration::from_secs(1800),
        // RFC 1939 §3 : 10 minutes au moins
        MailProtocol::Pop3 => Duration::from_secs(600),
        MailProtocol::ManageSieve => Duration::from_secs(300),
    }
}

/// Réglages et compteurs partagés par toutes les écoutes du nœud.
pub(crate) struct Acceptance {
    /// Connexions nouvelles par minute et par réseau.
    rate: IpRateLimiter,
    /// Connexions ouvertes par réseau (fenêtre sans fin).
    open: Arc<IpRateLimiter>,
    budget: MemoryBudget,
    deny: Vec<IpNetwork>,
    allow: Vec<IpNetwork>,
    exempt: Vec<IpNetwork>,
    connection_base: u64,
    log_client_ip: LogClientIp,
    drain: Duration,
    session_ids: AtomicU64,
}

impl Acceptance {
    fn new(config: &GroupwareConfig) -> Self {
        let limits = &config.limits;
        Self {
            rate: IpRateLimiter::with_max_tracked_networks(
                vec![WindowLimit {
                    window: Duration::from_secs(60),
                    limits: limits.connections_per_minute,
                }],
                limits.max_tracked_networks,
            ),
            open: Arc::new(IpRateLimiter::with_max_tracked_networks(
                vec![WindowLimit {
                    window: Duration::MAX,
                    limits: limits.connections_per_network,
                }],
                limits.max_tracked_networks,
            )),
            budget: MemoryBudget::new(limits.memory_budget_bytes),
            deny: limits.deny_networks.clone(),
            allow: limits.allow_networks.clone(),
            exempt: limits.exempt_networks.clone(),
            connection_base: limits.connection_base_bytes,
            log_client_ip: config.observability.log_client_ip,
            drain: config.drain(),
            session_ids: AtomicU64::new(1),
        }
    }

    fn next_session_id(&self) -> u64 {
        self.session_ids.fetch_add(1, Ordering::Relaxed)
    }
}

/// Une écoute : ses sockets liées, son plafond, le handler de son protocole, ses mesures.
pub(crate) struct Listener {
    id: String,
    protocol: MailProtocol,
    tls: TlsMode,
    local: Vec<SocketAddr>,
    /// Sockets liées au démarrage, gardées à travers les arrêts et redémarrages du worker (aucune
    /// fenêtre où le port serait libre) et refermées à l'arrêt de l'hôte (`MailNet::close`).
    sockets: Mutex<Option<Arc<Vec<TcpListener>>>>,
    limiter: ConnectionLimiter,
    handler: Arc<dyn SessionHandler>,
    acceptance: Arc<Acceptance>,
    metrics: ListenerMetrics,
}

impl Listener {
    fn snapshot(&self) -> ListenerSnapshot {
        self.metrics.snapshot(
            self.protocol.as_str(),
            self.limiter.in_use(),
            self.limiter.max(),
        )
    }

    fn near_capacity(&self) -> bool {
        u64::from(self.limiter.in_use()) * 100 > u64::from(self.limiter.max()) * DEGRADED_PERCENT
    }
}

/// Écoutes de courrier du nœud et leurs limites partagées.
#[derive(Clone)]
pub struct MailNet {
    acceptance: Arc<Acceptance>,
    listeners: Vec<Arc<Listener>>,
}

impl MailNet {
    /// Écoutes `bound` (déjà liées) ; `handler_for` donne la session de chaque protocole.
    pub fn new(
        config: &GroupwareConfig,
        bound: Vec<BoundListener>,
        handler_for: &dyn Fn(MailProtocol) -> Arc<dyn SessionHandler>,
    ) -> Self {
        let acceptance = Arc::new(Acceptance::new(config));
        let listeners = bound
            .into_iter()
            .map(|bound| {
                let local = bound.local_addrs();
                let max = bound
                    .config
                    .max_connections
                    .unwrap_or(config.limits.max_connections);
                Arc::new(Listener {
                    id: bound.config.id.clone(),
                    protocol: bound.config.protocol,
                    tls: bound.config.tls,
                    local,
                    sockets: Mutex::new(Some(Arc::new(bound.sockets))),
                    limiter: ConnectionLimiter::new(max),
                    handler: handler_for(bound.config.protocol),
                    acceptance: acceptance.clone(),
                    metrics: ListenerMetrics::default(),
                })
            })
            .collect();
        Self {
            acceptance,
            listeners,
        }
    }

    /// Workers des écoutes (`lyxal_mail:mail.listener.<id>`), à inscrire au runtime.
    pub fn workers(&self) -> Result<Vec<Arc<dyn LyxalWorker>>, RuntimeError> {
        self.listeners
            .iter()
            .map(|listener| {
                Ok(Arc::new(ListenerWorker::new(listener.clone())?) as Arc<dyn LyxalWorker>)
            })
            .collect()
    }

    /// Referme les sockets de toutes les écoutes : arrêt définitif de l'hôte, après l'arrêt des
    /// workers. Un worker relancé ensuite échoue au lieu de servir un port refermé.
    pub fn close(&self) {
        for listener in &self.listeners {
            listener
                .sockets
                .lock()
                .unwrap_or_else(|poisoned| poisoned.into_inner())
                .take();
        }
    }

    /// Sonde de santé des écoutes, rattachée au module `lyxal_mail`.
    pub fn health_check(&self) -> MailListenersHealthCheck {
        MailListenersHealthCheck {
            module_id: ModuleId::new(lyxal_mail::MODULE_ID),
            net: self.clone(),
        }
    }

    /// Adresses liées de l'écoute `id`.
    pub fn local_addrs(&self, id: &str) -> Vec<SocketAddr> {
        self.listeners
            .iter()
            .find(|listener| listener.id == id)
            .map(|listener| listener.local.clone())
            .unwrap_or_default()
    }

    /// Mesures des écoutes et du budget mémoire.
    pub fn snapshot(&self) -> MailSnapshot {
        let budget = &self.acceptance.budget;
        MailSnapshot {
            listeners: self
                .listeners
                .iter()
                .map(|listener| (listener.id.clone(), listener.snapshot()))
                .collect(),
            memory: MemorySnapshot {
                used_bytes: budget.used(),
                limit_bytes: budget.limit(),
            },
            tracked_networks: self.acceptance.rate.tracked() + self.acceptance.open.tracked(),
        }
    }

    fn memory_near_limit(&self) -> bool {
        let budget = &self.acceptance.budget;
        u128::from(budget.used()) * 100 > u128::from(budget.limit()) * u128::from(DEGRADED_PERCENT)
    }
}

/// Mesures des écoutes, pour `/metrics`.
#[derive(Debug, Serialize)]
pub struct MailSnapshot {
    pub listeners: BTreeMap<String, ListenerSnapshot>,
    pub memory: MemorySnapshot,
    /// Réseaux suivis par les limites par réseau.
    pub tracked_networks: usize,
}

/// Budget mémoire des connexions.
#[derive(Debug, Serialize)]
pub struct MemorySnapshot {
    pub used_bytes: u64,
    pub limit_bytes: u64,
}

/// Sonde des écoutes (`ModuleHealthCheck` de `lyxal_mail`) : « dégradé » si le budget mémoire
/// ou le plafond d'une écoute dépasse 90 % ; une écoute arrêtée est portée par la supervision
/// des workers (criticité `Required` : module « malade »).
pub struct MailListenersHealthCheck {
    module_id: ModuleId,
    net: MailNet,
}

#[async_trait::async_trait]
impl ModuleHealthCheck for MailListenersHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let id = self.module_id.clone();
        if self.net.memory_near_limit() {
            return Ok(HealthCheckResult::degraded(
                id,
                0,
                Some("budget mémoire des connexions utilisé à plus de 90 %".into()),
            ));
        }
        if let Some(listener) = self.net.listeners.iter().find(|l| l.near_capacity()) {
            return Ok(HealthCheckResult::degraded(
                id,
                0,
                Some(format!(
                    "écoute {} à plus de 90 % de son plafond de connexions",
                    listener.id
                )),
            ));
        }
        Ok(HealthCheckResult::healthy(
            id,
            0,
            Some(format!(
                "{} écoute(s) de courrier",
                self.net.listeners.len()
            )),
        ))
    }
}
