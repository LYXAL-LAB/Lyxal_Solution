//! Moteur du planificateur (lot 3) : un seul nœud planifie, tous les nœuds exécutent.
//!
//! * [`SchedulerLeaderWorker`] : tient le bail d'élection `leader` du runtime (clé `scheduler`,
//!   W1) ; à chaque tour, transforme les échéances en exécutions (dates calculées par `spec`,
//!   rattrapage et chevauchement appliqués par SurrealQL, décalage aléatoire U5), rejoue les
//!   périodes demandées, reprend les baux expirés et élague l'historique.
//! * [`SchedulerExecutorWorker`] (un par file) : réserve les exécutions de sa file dans la limite
//!   des places du nœud (W3) et exécute chacune dans une tâche tenue par le worker (`JoinSet`),
//!   avec battement du bail, délai maximal (W4), annulation demandée et arrêt borné.
//!
//! Tout passe par les fonctions SurrealQL `fn::scheduler_*` du moteur, sur la session système
//! de l'hôte (T2). Le jeton de bail d'une exécution n'est jamais journalisé.

mod attempt;
mod executor;
mod leader;

pub use executor::{ExecutorTiming, SchedulerExecutorWorker};
pub use leader::{LeaderReport, LeaderTiming, SchedulerLeaderWorker};

use lyxal_runtime::lock::NodeId;
use std::collections::BTreeMap;
use std::sync::{Arc, Mutex, PoisonError};

use crate::handler::HandlerRegistry;
use crate::store::SchedulerStore;

/// Clé du bail d'élection du planificateur (`runtime_lease:['leader', 'scheduler']`).
pub const LEADER_KEY: &str = "scheduler";
/// Places par file et par nœud par défaut (W3).
pub const DEFAULT_WORKERS: u32 = 4;
/// Places par file et par nœud au plus (W3).
pub const MAX_WORKERS: u32 = 64;

/// Files servies par un exécuteur sur ce nœud (lu par la sonde de santé).
#[derive(Clone, Default)]
pub struct ExecutorSet {
    queues: Arc<Mutex<BTreeMap<String, usize>>>,
}

impl ExecutorSet {
    /// Files servies, dans l'ordre.
    pub fn queues(&self) -> Vec<String> {
        self.queues
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .keys()
            .cloned()
            .collect()
    }

    /// Marque la file servie tant que la garde rendue vit.
    pub(crate) fn serve(&self, queue: &str) -> ServeGuard {
        *self
            .queues
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .entry(queue.to_string())
            .or_insert(0) += 1;
        ServeGuard {
            set: self.clone(),
            queue: queue.to_string(),
        }
    }
}

/// Garde d'une file servie : rendue à l'arrêt de l'exécuteur.
pub(crate) struct ServeGuard {
    set: ExecutorSet,
    queue: String,
}

impl Drop for ServeGuard {
    fn drop(&mut self) {
        let mut queues = self
            .set
            .queues
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if let Some(count) = queues.get_mut(&self.queue) {
            *count = count.saturating_sub(1);
            if *count == 0 {
                queues.remove(&self.queue);
            }
        }
    }
}

/// Ce que partagent les workers et la sonde du moteur sur un nœud : la session système, le
/// registre des handlers, l'identifiant du nœud et les files servies.
#[derive(Clone)]
pub struct SchedulerEngine {
    store: SchedulerStore,
    handlers: HandlerRegistry,
    node: NodeId,
    executors: ExecutorSet,
}

impl SchedulerEngine {
    /// Moteur sur la session système `store` (T2), avec les handlers inscrits par les modules
    /// et l'identifiant du nœud (`LyxalRuntime::node_id`).
    pub fn new(store: SchedulerStore, handlers: HandlerRegistry, node: NodeId) -> Self {
        Self {
            store,
            handlers,
            node,
            executors: ExecutorSet::default(),
        }
    }

    /// Session système.
    pub fn store(&self) -> &SchedulerStore {
        &self.store
    }

    /// Registre des handlers.
    pub fn handlers(&self) -> &HandlerRegistry {
        &self.handlers
    }

    /// Identifiant du nœud.
    pub fn node(&self) -> &NodeId {
        &self.node
    }

    /// Files servies par un exécuteur sur ce nœud.
    pub fn executors(&self) -> &ExecutorSet {
        &self.executors
    }
}
