use crate::error::RuntimeError;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::{AcquireLeaseResult, MigrationLease};
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use crate::lock::store::{instant, LeaseKind, LeaseOutcome, LeaseRow, LeaseStore};
use async_trait::async_trait;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// `MigrationLeaseManager` persistant dans SurrealDB (`fn::runtime_lease_*`, nature
/// `migration`). Les échéances sont calculées à l'heure de la base : deux nœuds dont les
/// horloges divergent voient le même bail.
pub struct SurrealMigrationLeaseManager {
    client: Surreal<Any>,
    store: LeaseStore,
}

impl SurrealMigrationLeaseManager {
    /// Crée un gestionnaire de baux de migration sur le client donné.
    pub fn new(client: Surreal<Any>) -> Self {
        Self {
            store: LeaseStore::new(client.clone()),
            client,
        }
    }

    /// Retourne la référence au client SurrealDB.
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }
}

fn lease_from_row(key: &MigrationLockKey, row: LeaseRow) -> MigrationLease {
    MigrationLease {
        key: key.clone(),
        owner: NodeId::new(row.owner_node_id),
        generation: instant(row.generation),
        acquired_at: instant(row.acquired_at),
        renewed_at: instant(row.renewed_at),
        expires_at: instant(row.expires_at),
    }
}

#[async_trait]
impl MigrationLeaseManager for SurrealMigrationLeaseManager {
    async fn acquire(
        &self,
        key: &MigrationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireLeaseResult, RuntimeError> {
        let outcome = self
            .store
            .acquire(LeaseKind::Migration, &key.canonical_string(), node_id, ttl)
            .await
            .map_err(|e| RuntimeError::MigrationLockAcquireFailed {
                key: key.canonical_string(),
                message: e.to_string(),
            })?;
        Ok(match outcome {
            LeaseOutcome::Acquired(row) => AcquireLeaseResult::Acquired(lease_from_row(key, row)),
            LeaseOutcome::Recovered(row) => {
                AcquireLeaseResult::RecoveredExpiredLease(lease_from_row(key, row))
            }
            LeaseOutcome::AlreadyOwned(row) => {
                AcquireLeaseResult::AlreadyOwned(lease_from_row(key, row))
            }
            LeaseOutcome::HeldByOther(row) => AcquireLeaseResult::HeldByOther {
                owner: NodeId::new(row.owner_node_id),
                expires_at: instant(row.expires_at),
            },
        })
    }

    async fn renew(
        &self,
        lease: &MigrationLease,
        ttl: Duration,
    ) -> Result<MigrationLease, RuntimeError> {
        let key = lease.key.canonical_string();
        match self
            .store
            .renew(
                LeaseKind::Migration,
                &key,
                &lease.owner,
                lease.generation,
                ttl,
            )
            .await?
        {
            Some(row) => Ok(lease_from_row(&lease.key, row)),
            None => Err(RuntimeError::MigrationLeaseLost {
                key,
                owner: lease.owner.to_string(),
                message: "bail expiré, libéré ou repris par un autre nœud".to_string(),
            }),
        }
    }

    async fn release(&self, lease: &MigrationLease) -> Result<(), RuntimeError> {
        let key = lease.key.canonical_string();
        if self
            .store
            .release(LeaseKind::Migration, &key, &lease.owner, lease.generation)
            .await?
        {
            return Ok(());
        }
        let actual_owner = self
            .store
            .get(LeaseKind::Migration, &key)
            .await?
            .map(|row| format!("{} (génération {})", row.owner_node_id, row.generation))
            .unwrap_or_else(|| "aucun détenteur actif".to_string());
        Err(RuntimeError::MigrationLockNotOwner {
            key,
            caller: lease.owner.to_string(),
            actual_owner,
        })
    }

    async fn inspect(
        &self,
        key: &MigrationLockKey,
    ) -> Result<Option<MigrationLease>, RuntimeError> {
        Ok(self
            .store
            .get(LeaseKind::Migration, &key.canonical_string())
            .await?
            .map(|row| lease_from_row(key, row)))
    }
}
