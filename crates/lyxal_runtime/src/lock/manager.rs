use crate::error::RuntimeError;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::{AcquireLeaseResult, MigrationLease};
use crate::lock::node_id::NodeId;
use async_trait::async_trait;
use std::time::Duration;

/// Trait d'abstraction pour la coordination et l'acquisition atomique de baux distribués.
#[async_trait]
pub trait MigrationLeaseManager: Send + Sync {
    /// Tente d'acquérir de manière atomique un bail sur une clé de migration.
    async fn acquire(
        &self,
        key: &MigrationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireLeaseResult, RuntimeError>;

    /// Renouvelle un bail existant s'il appartient toujours au nœud appelant et que la génération correspond.
    async fn renew(
        &self,
        lease: &MigrationLease,
        ttl: Duration,
    ) -> Result<MigrationLease, RuntimeError>;

    /// Libère un bail s'il est détenu par l'instance appelante avec la génération correcte.
    async fn release(&self, lease: &MigrationLease) -> Result<(), RuntimeError>;

    /// Inspecte l'état actuel d'un bail sans le modifier.
    async fn inspect(&self, key: &MigrationLockKey)
        -> Result<Option<MigrationLease>, RuntimeError>;
}
