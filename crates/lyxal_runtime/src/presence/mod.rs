//! # Hôtes et présence des nœuds
//!
//! - [`HostId`] : le rôle d'un binaire, constante de son code, le même pour toutes ses copies ;
//! - [`NodePresence`] et [`PresenceWorker`] : chaque nœud écrit dans `runtime_node` son hôte et
//!   ses modules, au démarrage puis à chaque battement, et retire sa ligne à l'arrêt ;
//! - [`PresenceStore`] : fonctions `fn::runtime_node_*` et `fn::runtime_foundation_*` ;
//! - [`FoundationHealthCheck`] : sonde « dégradé » quand un autre binaire a remplacé le socle.

pub mod host_id;
pub mod store;
pub mod worker;

pub use crate::store::dto::{
    RuntimeFoundation, RuntimeNode, RuntimeNodeListParams, RuntimeNodePurgeParams,
    RuntimeNodePurged, RuntimeNodeRemoveParams, RuntimeNodeRemoved, RuntimeNodeUpsertParams,
};
pub use host_id::HostId;
pub use store::PresenceStore;
pub use worker::{
    FoundationHealthCheck, FoundationObservation, FoundationWatch, NodePresence, PresenceWorker,
    PRESENCE_MODULE_ID, PRESENCE_WORKER_NAME,
};

use std::time::Duration;

/// Réglages de la présence d'un nœud.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PresenceConfig {
    /// Intervalle entre deux battements (par défaut : 10 s).
    pub heartbeat_interval: Duration,
    /// Âge maximal du dernier battement d'un nœud considéré vivant (par défaut : 30 s).
    pub alive_within: Duration,
    /// Intervalle entre deux purges des nœuds disparus (par défaut : 1 h).
    pub purge_interval: Duration,
    /// Âge du dernier battement au-delà duquel un nœud est purgé avec ses lignes
    /// `runtime_worker` et `runtime_health` (par défaut : 7 jours ; 1 minute au moins).
    pub purge_after: Duration,
}

impl Default for PresenceConfig {
    fn default() -> Self {
        Self {
            heartbeat_interval: Duration::from_secs(10),
            alive_within: Duration::from_secs(30),
            purge_interval: Duration::from_secs(3600),
            purge_after: Duration::from_secs(7 * 24 * 3600),
        }
    }
}
