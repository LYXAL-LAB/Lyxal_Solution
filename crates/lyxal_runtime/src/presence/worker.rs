use crate::context::ModuleContext;
use crate::error::RuntimeError;
use crate::health::check::{HealthCheckResult, ModuleHealthCheck};
use crate::lock::node_id::NodeId;
use crate::presence::host_id::HostId;
use crate::presence::store::PresenceStore;
use crate::presence::PresenceConfig;
use crate::registry::ModuleRegistry;
use crate::store::dto::{
    RuntimeFoundation, RuntimeNode, RuntimeNodePurged, RuntimeNodeRemoved, RuntimeNodeUpsertParams,
};
use crate::types::ModuleId;
use crate::worker::context::WorkerContext;
use crate::worker::definition::LyxalWorker;
use crate::worker::descriptor::{WorkerCriticality, WorkerDescriptor};
use crate::worker::id::WorkerId;
use async_trait::async_trait;
use std::sync::{Arc, RwLock};
use std::time::Instant;

/// Module propriétaire du worker de présence.
pub const PRESENCE_MODULE_ID: &str = "lyxal_runtime";

/// Nom du worker de présence (`lyxal_runtime:presence`).
pub const PRESENCE_WORKER_NAME: &str = "presence";

/// Ce que le dernier battement a lu du socle installé dans la base.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct FoundationObservation {
    /// Vrai dès qu'un battement a réussi.
    pub observed: bool,
    /// Socle enregistré dans la base au dernier battement réussi.
    pub installed: Option<RuntimeFoundation>,
    /// Erreur du dernier battement, s'il a échoué.
    pub error: Option<String>,
}

/// Dernière observation du socle, écrite par le battement et lue par la sonde de santé.
#[derive(Debug, Default)]
pub struct FoundationWatch {
    state: RwLock<FoundationObservation>,
}

impl FoundationWatch {
    /// Dernière observation.
    pub fn observation(&self) -> Result<FoundationObservation, RuntimeError> {
        self.state
            .read()
            .map(|state| state.clone())
            .map_err(|_| RuntimeError::LockPoisoned {
                context: "FoundationWatch read lock poisoned",
            })
    }

    fn record(
        &self,
        outcome: Result<Option<RuntimeFoundation>, String>,
    ) -> Result<(), RuntimeError> {
        let mut state = self.state.write().map_err(|_| RuntimeError::LockPoisoned {
            context: "FoundationWatch write lock poisoned",
        })?;
        match outcome {
            Ok(installed) => {
                state.observed = true;
                state.installed = installed;
                state.error = None;
            }
            Err(error) => state.error = Some(error),
        }
        Ok(())
    }
}

/// Présence d'un nœud dans la base : battement, retrait à l'arrêt, purge des nœuds disparus.
pub struct NodePresence {
    store: PresenceStore,
    node_id: NodeId,
    host: HostId,
    registry: Arc<ModuleRegistry>,
    foundation_checksum: Option<String>,
    watch: Arc<FoundationWatch>,
    config: PresenceConfig,
}

impl NodePresence {
    /// Présence du nœud `node_id` de l'hôte `host`, dont les modules sont ceux de `registry`.
    pub(crate) fn new(
        store: PresenceStore,
        node_id: NodeId,
        host: HostId,
        registry: Arc<ModuleRegistry>,
        foundation_checksum: Option<String>,
        watch: Arc<FoundationWatch>,
        config: PresenceConfig,
    ) -> Self {
        Self {
            store,
            node_id,
            host,
            registry,
            foundation_checksum,
            watch,
            config,
        }
    }

    /// Battement : écrit la ligne de présence du nœud (hôte, modules enregistrés, empreinte du
    /// socle de son binaire) et relit le socle installé dans la base. Un échec est gardé pour
    /// la sonde de santé et renvoyé.
    pub async fn beat(&self) -> Result<RuntimeNode, RuntimeError> {
        let mut modules: Vec<String> = self
            .registry
            .ids()
            .into_iter()
            .map(|id| id.to_string())
            .collect();
        modules.sort();
        let outcome = async {
            let node = self
                .store
                .upsert_node(RuntimeNodeUpsertParams {
                    node_id: self.node_id.to_string(),
                    host: self.host.to_string(),
                    modules,
                    foundation_checksum: self.foundation_checksum.clone(),
                })
                .await?;
            let foundation = self.store.foundation().await?;
            Ok::<_, RuntimeError>((node, foundation))
        }
        .await;
        match outcome {
            Ok((node, foundation)) => {
                self.watch.record(Ok(foundation))?;
                Ok(node)
            }
            Err(error) => {
                self.watch.record(Err(error.to_string()))?;
                Err(error)
            }
        }
    }

    /// Retire le nœud de la base (arrêt propre), avec ses lignes `runtime_worker` et
    /// `runtime_health`.
    pub async fn leave(&self) -> Result<RuntimeNodeRemoved, RuntimeError> {
        self.store.remove_node(&self.node_id).await
    }

    /// Purge les nœuds sans battement depuis `PresenceConfig::purge_after`, avec leurs lignes.
    pub async fn purge(&self) -> Result<RuntimeNodePurged, RuntimeError> {
        self.store.purge_nodes(self.config.purge_after).await
    }
}

/// Worker `lyxal_runtime:presence` : battement du nœud à intervalle fixe, purge périodique des
/// nœuds disparus. Un échec est journalisé et réessayé au battement suivant.
pub struct PresenceWorker {
    descriptor: WorkerDescriptor,
    presence: Arc<NodePresence>,
}

impl PresenceWorker {
    /// Crée le worker de présence d'un nœud.
    pub(crate) fn new(presence: Arc<NodePresence>) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(PRESENCE_MODULE_ID);
        let id = WorkerId::new(&module_id, PRESENCE_WORKER_NAME)?;
        let descriptor = WorkerDescriptor::new(id, module_id, "Lyxal Runtime Presence")
            .with_description("Battement de présence du nœud et purge des nœuds disparus")
            .with_criticality(WorkerCriticality::Optional);
        Ok(Self {
            descriptor,
            presence,
        })
    }
}

#[async_trait]
impl LyxalWorker for PresenceWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let config = &self.presence.config;
        // Première purge au démarrage du worker, puis une par intervalle
        let mut last_purge: Option<Instant> = None;
        while !ctx.is_cancelled() {
            if last_purge.is_none_or(|at| at.elapsed() >= config.purge_interval) {
                match self.presence.purge().await {
                    Ok(purged) if purged.nodes + purged.workers + purged.health > 0 => {
                        tracing::info!(
                            nodes = purged.nodes,
                            workers = purged.workers,
                            health = purged.health,
                            "Nœuds disparus purgés"
                        );
                    }
                    Ok(_) => {}
                    Err(error) => {
                        tracing::warn!(error = %error, "Purge des nœuds disparus impossible : réessayée au prochain intervalle");
                    }
                }
                last_purge = Some(Instant::now());
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(config.heartbeat_interval) => {
                    if let Err(error) = self.presence.beat().await {
                        tracing::warn!(error = %error, "Battement de présence impossible : réessayé au prochain intervalle");
                    }
                }
            }
        }
        Ok(())
    }
}

/// Sonde du socle : « dégradé » quand le socle installé dans la base n'est plus celui du binaire
/// de ce nœud (un autre binaire l'a remplacé), ou quand le battement de présence échoue. Elle
/// lit la dernière observation du battement, sans accès à la base.
pub struct FoundationHealthCheck {
    module_id: ModuleId,
    expected: Option<String>,
    watch: Arc<FoundationWatch>,
}

impl FoundationHealthCheck {
    /// Sonde rattachée au module `module_id` (un module du socle hébergé par l'hôte, par
    /// exemple `lyxal_core`), pour un binaire dont le socle a l'empreinte `expected`.
    pub(crate) fn new(
        module_id: ModuleId,
        expected: Option<String>,
        watch: Arc<FoundationWatch>,
    ) -> Self {
        Self {
            module_id,
            expected,
            watch,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for FoundationHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let observation = self.watch.observation()?;
        let degraded = |message: String| {
            Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                0,
                Some(message),
            ))
        };
        if let Some(error) = observation.error {
            return degraded(format!("Battement de présence en échec : {error}"));
        }
        let Some(expected) = &self.expected else {
            return Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                0,
                Some("Aucune empreinte de socle déclarée par ce nœud".to_string()),
            ));
        };
        if !observation.observed {
            return Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                0,
                Some("Socle non encore observé (premier battement à venir)".to_string()),
            ));
        }
        match observation.installed {
            Some(installed) if &installed.checksum == expected => Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                0,
                Some("Socle de la base identique à celui de ce binaire".to_string()),
            )),
            Some(installed) => degraded(format!(
                "Socle remplacé par l'hôte {} (nœud {}) : empreinte {} en base, {} dans ce binaire",
                installed.host, installed.node_id, installed.checksum, expected
            )),
            None => degraded("Aucun socle enregistré dans la base".to_string()),
        }
    }
}
