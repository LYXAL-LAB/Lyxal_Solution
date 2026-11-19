use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::presence::host_id::HostId;
use crate::store::dto::{
    ListParams, RuntimeFoundation, RuntimeFoundationClearParams, RuntimeFoundationCleared,
    RuntimeFoundationRecordParams, RuntimeNode, RuntimeNodeListParams, RuntimeNodePurgeParams,
    RuntimeNodePurged, RuntimeNodeRemoveParams, RuntimeNodeRemoved, RuntimeNodeUpsertParams,
};
use crate::store::surreal::store_error;
use lyxal_surreal::LyxalSurrealCall;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Présence des nœuds et socle installé dans SurrealDB : chaque opération appelle une fonction
/// `fn::runtime_node_*` ou `fn::runtime_foundation_*` par `call_fn`.
#[derive(Clone)]
pub struct PresenceStore {
    client: Surreal<Any>,
}

impl LyxalSurrealCall for PresenceStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

impl PresenceStore {
    /// Crée un store de présence sur la session système donnée.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Battement : crée ou rafraîchit la ligne de présence d'un nœud.
    pub async fn upsert_node(
        &self,
        params: RuntimeNodeUpsertParams,
    ) -> Result<RuntimeNode, RuntimeError> {
        self.call_fn("runtime_node_upsert", params)
            .await
            .map_err(|e| store_error("runtime_node_upsert", e))
    }

    /// Retire un nœud arrêté, avec ses lignes `runtime_worker` et `runtime_health`.
    pub async fn remove_node(&self, node_id: &NodeId) -> Result<RuntimeNodeRemoved, RuntimeError> {
        self.call_fn(
            "runtime_node_remove",
            RuntimeNodeRemoveParams {
                node_id: node_id.to_string(),
            },
        )
        .await
        .map_err(|e| store_error("runtime_node_remove", e))
    }

    /// Nœuds connus de la base ; `alive` est vrai si le dernier battement date de moins que
    /// `alive_within` à l'heure de la base.
    pub async fn list_nodes(
        &self,
        alive_within: Duration,
    ) -> Result<Vec<RuntimeNode>, RuntimeError> {
        self.call_fn(
            "runtime_node_list",
            RuntimeNodeListParams {
                alive_within: Some(surrealdb::types::Duration::from_std(alive_within)),
            },
        )
        .await
        .map_err(|e| store_error("runtime_node_list", e))
    }

    /// Purge les nœuds sans battement depuis `older_than`, avec leurs lignes.
    pub async fn purge_nodes(
        &self,
        older_than: Duration,
    ) -> Result<RuntimeNodePurged, RuntimeError> {
        self.call_fn(
            "runtime_node_purge",
            RuntimeNodePurgeParams {
                older_than: Some(surrealdb::types::Duration::from_std(older_than)),
            },
        )
        .await
        .map_err(|e| store_error("runtime_node_purge", e))
    }

    /// Socle enregistré dans la base, ou `None` si aucun ne l'a été.
    pub async fn foundation(&self) -> Result<Option<RuntimeFoundation>, RuntimeError> {
        self.call_fn("runtime_foundation_get", ListParams::default())
            .await
            .map_err(|e| store_error("runtime_foundation_get", e))
    }

    /// Efface l'empreinte du socle avant son remplacement, sous le bail d'installation
    /// « foundation » détenu par `node_id` (génération `generation`) : une installation
    /// interrompue laisse la base sans empreinte, et le prochain démarrage réinstalle le socle.
    /// `RuntimeError::LeaseFenced` si le bail n'est plus détenu.
    pub(crate) async fn clear_foundation(
        &self,
        node_id: &NodeId,
        generation: u64,
    ) -> Result<(), RuntimeError> {
        let params = RuntimeFoundationClearParams {
            node_id: node_id.to_string(),
            generation: i64::try_from(generation).map_err(|_| RuntimeError::StoreFailed {
                operation: "runtime_foundation_clear",
                message: format!("génération hors bornes : {generation}"),
            })?,
        };
        self.call_fn::<RuntimeFoundationCleared, _>("runtime_foundation_clear", params)
            .await
            .map(|_| ())
            .map_err(|e| {
                if e.is_business_code("RUNTIME_LEASE_FENCED") {
                    RuntimeError::LeaseFenced {
                        key: crate::schema::FOUNDATION_LEASE_KEY.to_string(),
                        owner: node_id.to_string(),
                        generation,
                    }
                } else {
                    store_error("runtime_foundation_clear", e)
                }
            })
    }

    /// Enregistre le socle installé par `node_id` sous le bail d'installation « foundation »
    /// (génération `generation`) ; `RuntimeError::LeaseFenced` si le bail n'est plus détenu.
    pub(crate) async fn record_foundation(
        &self,
        checksum: &str,
        host: &HostId,
        node_id: &NodeId,
        generation: u64,
    ) -> Result<RuntimeFoundation, RuntimeError> {
        let params = RuntimeFoundationRecordParams {
            checksum: checksum.to_string(),
            host: host.to_string(),
            node_id: node_id.to_string(),
            generation: i64::try_from(generation).map_err(|_| RuntimeError::StoreFailed {
                operation: "runtime_foundation_record",
                message: format!("génération hors bornes : {generation}"),
            })?,
        };
        self.call_fn("runtime_foundation_record", params)
            .await
            .map_err(|e| {
                if e.is_business_code("RUNTIME_LEASE_FENCED") {
                    RuntimeError::LeaseFenced {
                        key: crate::schema::FOUNDATION_LEASE_KEY.to_string(),
                        owner: node_id.to_string(),
                        generation,
                    }
                } else {
                    store_error("runtime_foundation_record", e)
                }
            })
    }
}
