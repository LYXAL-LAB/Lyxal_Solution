use crate::error::RuntimeError;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::{AcquireLeaseResult, MigrationLease};
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use async_trait::async_trait;
use std::collections::HashMap;
use std::sync::Arc;
use std::time::{Duration, SystemTime};
use tokio::sync::Mutex;

/// Implémentation en mémoire de `MigrationLeaseManager` pour les tests unitaires / single-process.
pub struct MemoryMigrationLeaseManager {
    leases: Arc<Mutex<HashMap<MigrationLockKey, MigrationLease>>>,
}

impl Default for MemoryMigrationLeaseManager {
    fn default() -> Self {
        Self::new()
    }
}

impl MemoryMigrationLeaseManager {
    /// Crée un nouveau gestionnaire de baux en mémoire.
    pub fn new() -> Self {
        Self {
            leases: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    fn now_secs() -> u64 {
        SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    }
}

#[async_trait]
impl MigrationLeaseManager for MemoryMigrationLeaseManager {
    async fn acquire(
        &self,
        key: &MigrationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireLeaseResult, RuntimeError> {
        let mut guard = self.leases.lock().await;
        let now = Self::now_secs();
        let expires_at = now + ttl.as_secs().max(1);

        if let Some(existing) = guard.get_mut(key) {
            if existing.expires_at > now {
                if &existing.owner == node_id {
                    return Ok(AcquireLeaseResult::AlreadyOwned(existing.clone()));
                } else {
                    return Ok(AcquireLeaseResult::HeldByOther {
                        owner: existing.owner.clone(),
                        expires_at: existing.expires_at,
                    });
                }
            } else {
                // Lease expiré : récupération atomique avec incrément de génération
                existing.generation += 1;
                existing.owner = node_id.clone();
                existing.acquired_at = now;
                existing.renewed_at = now;
                existing.expires_at = expires_at;
                return Ok(AcquireLeaseResult::RecoveredExpiredLease(existing.clone()));
            }
        }

        // Nouvel enregistrement
        let lease = MigrationLease {
            key: key.clone(),
            owner: node_id.clone(),
            generation: 1,
            acquired_at: now,
            renewed_at: now,
            expires_at,
        };

        guard.insert(key.clone(), lease.clone());
        Ok(AcquireLeaseResult::Acquired(lease))
    }

    async fn renew(
        &self,
        lease: &MigrationLease,
        ttl: Duration,
    ) -> Result<MigrationLease, RuntimeError> {
        let mut guard = self.leases.lock().await;
        let now = Self::now_secs();

        if let Some(existing) = guard.get_mut(&lease.key) {
            if existing.owner == lease.owner && existing.generation == lease.generation {
                existing.renewed_at = now;
                existing.expires_at = now + ttl.as_secs().max(1);
                return Ok(existing.clone());
            }
        }

        Err(RuntimeError::MigrationLeaseLost {
            key: lease.key.to_string(),
            owner: lease.owner.to_string(),
            message: "Lease does not exist or has been reassigned to another node/generation"
                .to_string(),
        })
    }

    async fn release(&self, lease: &MigrationLease) -> Result<(), RuntimeError> {
        let mut guard = self.leases.lock().await;

        if let Some(existing) = guard.get_mut(&lease.key) {
            if existing.owner != lease.owner || existing.generation != lease.generation {
                return Err(RuntimeError::MigrationLockNotOwner {
                    key: lease.key.to_string(),
                    caller: lease.owner.to_string(),
                    actual_owner: existing.owner.to_string(),
                });
            }
            existing.expires_at = 0;
        }

        Ok(())
    }

    async fn inspect(
        &self,
        key: &MigrationLockKey,
    ) -> Result<Option<MigrationLease>, RuntimeError> {
        let guard = self.leases.lock().await;
        let now = Self::now_secs();
        if let Some(existing) = guard.get(key) {
            if existing.expires_at > now {
                return Ok(Some(existing.clone()));
            }
        }
        Ok(None)
    }
}
