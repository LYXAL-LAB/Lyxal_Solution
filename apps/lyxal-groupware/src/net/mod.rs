// SPDX-License-Identifier: AGPL-3.0-only

//! Écoutes de courrier : liaison des ports, workers supervisés, pipeline d'acceptation (PROXY,
//! listes, limites, budget, TLS), certificats rechargés à chaud, mesures et sonde de santé. Les
//! limites et le contrat des sessions viennent de `lyxal_mail::net`.

mod accept;
pub mod bind;
pub mod certificates;
mod listener;
pub mod metrics;
pub mod proxy;
pub mod tls;

use crate::config::{GroupwareConfig, LogClientIp};
use crate::error::GroupwareError;
use bind::BoundListener;
use certificates::{Certificates, CertificatesSnapshot};
use lyxal_host::net::IpNetwork;
use lyxal_mail::net::{
    ConnectionLimiter, IpRateLimiter, MailProtocol, MemoryBudget, SessionHandler, TlsMode,
    WindowLimit,
};
use lyxal_runtime::health::{HealthCheckResult, HealthStatus, ModuleHealthCheck};
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
use tls::ListenerTls;

/// Écriture bloquée tolérée (client qui ne lit plus).
pub const WRITE_STALL: Duration = Duration::from_secs(60);

/// Seuil d'usage (en pour cent) au-delà duquel la sonde passe à « dégradé ».
const DEGRADED_PERCENT: u64 = 90;

/// Inactivité tolérée d'une session, par protocole (RFC citées ci-dessous).
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
    proxy_header_timeout: Duration,
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
            proxy_header_timeout: config.proxy_header_timeout(),
            session_ids: AtomicU64::new(1),
        }
    }

    fn next_session_id(&self) -> u64 {
        self.session_ids.fetch_add(1, Ordering::Relaxed)
    }
}

/// TLS d'une écoute, avec l'accepteur de son mode.
pub(crate) enum ListenerTlsMode {
    None,
    StartTls(ListenerTls),
    Implicit(ListenerTls),
}

impl ListenerTlsMode {
    fn mode(&self) -> TlsMode {
        match self {
            Self::None => TlsMode::None,
            Self::StartTls(_) => TlsMode::StartTls,
            Self::Implicit(_) => TlsMode::Implicit,
        }
    }
}

/// Une écoute : ses sockets liées, son plafond, son TLS, ses répartiteurs, le handler de son
/// protocole, ses mesures.
pub(crate) struct Listener {
    id: String,
    protocol: MailProtocol,
    tls: ListenerTlsMode,
    /// Réseaux des répartiteurs : en-tête PROXY exigé depuis eux, jamais lu ailleurs.
    proxy_networks: Vec<IpNetwork>,
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
    certificates: Option<Arc<Certificates>>,
}

impl MailNet {
    /// Écoutes `bound` (déjà liées), servies avec les certificats `certificates` (chargés au
    /// démarrage, obligatoires pour une écoute chiffrée) ; `handler_for` donne la session de
    /// chaque protocole.
    pub fn new(
        config: &GroupwareConfig,
        bound: Vec<BoundListener>,
        certificates: Option<Arc<Certificates>>,
        handler_for: &dyn Fn(MailProtocol) -> Arc<dyn SessionHandler>,
    ) -> Result<Self, GroupwareError> {
        let acceptance = Arc::new(Acceptance::new(config));
        let listeners = bound
            .into_iter()
            .map(|bound| {
                let local = bound.local_addrs();
                let max = bound
                    .config
                    .max_connections
                    .unwrap_or(config.limits.max_connections);
                let tls = match bound.config.tls {
                    TlsMode::None => ListenerTlsMode::None,
                    mode => {
                        let store = certificates
                            .as_ref()
                            .ok_or_else(|| GroupwareError::Configuration {
                                message: format!(
                                    "listeners.{}.tls = « {} » : aucun certificat chargé",
                                    bound.config.id,
                                    mode.as_str()
                                ),
                            })?
                            .store();
                        let acceptor = ListenerTls::new(
                            store,
                            &bound.config.id,
                            &tls::alpn(bound.config.protocol)
                                .into_iter()
                                .collect::<Vec<_>>(),
                            bound.config.tls_min_version.unwrap_or_default(),
                            config.handshake_timeout(),
                        )?;
                        if mode == TlsMode::Implicit {
                            ListenerTlsMode::Implicit(acceptor)
                        } else {
                            ListenerTlsMode::StartTls(acceptor)
                        }
                    }
                };
                Ok(Arc::new(Listener {
                    id: bound.config.id.clone(),
                    protocol: bound.config.protocol,
                    tls,
                    proxy_networks: bound.config.proxy_networks.clone(),
                    local,
                    sockets: Mutex::new(Some(Arc::new(bound.sockets))),
                    limiter: ConnectionLimiter::new(max),
                    handler: handler_for(bound.config.protocol),
                    acceptance: acceptance.clone(),
                    metrics: ListenerMetrics::default(),
                }))
            })
            .collect::<Result<_, GroupwareError>>()?;
        Ok(Self {
            acceptance,
            listeners,
            certificates,
        })
    }

    /// Workers des écoutes (`lyxal_mail:mail.listener.<id>`) et, si des certificats sont
    /// déclarés, de leur relecture (`lyxal_mail:mail.tls_reload`), à inscrire au runtime.
    pub fn workers(&self) -> Result<Vec<Arc<dyn LyxalWorker>>, RuntimeError> {
        let mut workers = self
            .listeners
            .iter()
            .map(|listener| {
                Ok(Arc::new(ListenerWorker::new(listener.clone())?) as Arc<dyn LyxalWorker>)
            })
            .collect::<Result<Vec<_>, RuntimeError>>()?;
        if let Some(certificates) = &self.certificates {
            workers.push(Arc::new(certificates.worker()?));
        }
        Ok(workers)
    }

    /// Certificats des écoutes chiffrées.
    pub fn certificates(&self) -> Option<&Arc<Certificates>> {
        self.certificates.as_ref()
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
            service: None,
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
            certificates: self.certificates.as_ref().map(|c| c.snapshot()),
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
    /// Certificats et rechargements ; absent sans écoute chiffrée.
    pub certificates: Option<CertificatesSnapshot>,
}

/// Budget mémoire des connexions.
#[derive(Debug, Serialize)]
pub struct MemorySnapshot {
    pub used_bytes: u64,
    pub limit_bytes: u64,
}

/// Sonde des écoutes (`ModuleHealthCheck` de `lyxal_mail`) : d'abord celle du service du
/// courrier si elle est donnée (`with_service_probe` : base, supports, clés des fichiers), puis
/// « dégradé » si le dernier rechargement des certificats a échoué, ou si le budget mémoire ou le
/// plafond d'une écoute dépasse 90 % ; une écoute arrêtée est portée par la supervision des
/// workers (criticité `Required` : module « malade »). Le runtime n'admet qu'une sonde par
/// module.
pub struct MailListenersHealthCheck {
    module_id: ModuleId,
    net: MailNet,
    service: Option<Arc<dyn ModuleHealthCheck>>,
}

impl MailListenersHealthCheck {
    /// Interroge d'abord la sonde du service du courrier : un résultat autre que « sain » est
    /// rendu tel quel.
    pub fn with_service_probe(mut self, probe: Arc<dyn ModuleHealthCheck>) -> Self {
        self.service = Some(probe);
        self
    }
}

#[async_trait::async_trait]
impl ModuleHealthCheck for MailListenersHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let id = self.module_id.clone();
        if let Some(service) = &self.service {
            let result = service.check(ctx).await?;
            if result.status != HealthStatus::Healthy {
                return Ok(result);
            }
        }
        if self.net.certificates.as_ref().is_some_and(|c| c.degraded()) {
            return Ok(HealthCheckResult::degraded(
                id,
                0,
                Some("dernier rechargement des certificats TLS en échec : anciens certificats en service".into()),
            ));
        }
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
