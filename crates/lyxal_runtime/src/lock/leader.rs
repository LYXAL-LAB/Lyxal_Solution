//! Baux d'élection (`runtime_lease.kind = leader`) : un seul nœud tient un rôle à la fois (ex. le
//! planificateur de `lyxal_scheduler`, clé `scheduler`). Même table, mêmes fonctions et même garde
//! de génération que les baux de migration et d'installation ; les échéances sont calculées à
//! l'heure de la base.

use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::lock::store::{instant, LeaseKind, LeaseOutcome, LeaseRow, LeaseStore};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Bail d'élection détenu par un nœud.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LeaderLease {
    /// Rôle élu (clé du bail, ex. `scheduler`).
    pub key: String,
    /// Nœud qui tient le rôle.
    pub owner: NodeId,
    /// Génération (jeton de clôture monotone).
    pub generation: u64,
    /// Prise du bail (secondes Unix, heure de la base).
    pub acquired_at: u64,
    /// Dernier renouvellement (secondes Unix).
    pub renewed_at: u64,
    /// Échéance (secondes Unix).
    pub expires_at: u64,
}

/// Issue d'une prise de bail d'élection.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AcquireLeaderLeaseResult {
    /// Bail libre ou libéré pris (nouvelle génération).
    Acquired(LeaderLease),
    /// Bail déjà détenu par ce nœud.
    AlreadyOwned(LeaderLease),
    /// Bail expiré repris (nouvelle génération).
    RecoveredExpiredLease(LeaderLease),
    /// Bail détenu par un autre nœud jusqu'à `expires_at`.
    HeldByOther {
        /// Nœud qui tient le rôle.
        owner: NodeId,
        /// Échéance de son bail (secondes Unix).
        expires_at: u64,
    },
}

impl AcquireLeaderLeaseResult {
    /// Bail détenu par ce nœud après la prise, s'il l'est.
    pub fn lease(&self) -> Option<&LeaderLease> {
        match self {
            Self::Acquired(lease) | Self::AlreadyOwned(lease) | Self::RecoveredExpiredLease(lease) => {
                Some(lease)
            }
            Self::HeldByOther { .. } => None,
        }
    }
}

/// Gestionnaire des baux d'élection persistants dans SurrealDB (`fn::runtime_lease_*`, nature
/// `leader`).
pub struct SurrealLeaderLeaseManager {
    store: LeaseStore,
}

fn leader_lease(key: &str, row: LeaseRow) -> LeaderLease {
    LeaderLease {
        key: key.to_string(),
        owner: NodeId::new(row.owner_node_id),
        generation: instant(row.generation),
        acquired_at: instant(row.acquired_at),
        renewed_at: instant(row.renewed_at),
        expires_at: instant(row.expires_at),
    }
}

impl SurrealLeaderLeaseManager {
    /// Gestionnaire sur le client donné (session système de l'hôte).
    pub fn new(client: Surreal<Any>) -> Self {
        Self {
            store: LeaseStore::new(client),
        }
    }

    /// Prend le bail du rôle `key` pour `ttl` (au moins une seconde), s'il est libre, libéré ou
    /// expiré.
    pub async fn acquire(
        &self,
        key: &str,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireLeaderLeaseResult, RuntimeError> {
        let outcome = self
            .store
            .acquire(LeaseKind::Leader, key, node_id, ttl)
            .await
            .map_err(|e| RuntimeError::StoreFailed {
                operation: "runtime_lease_acquire",
                message: e.to_string(),
            })?;
        Ok(match outcome {
            LeaseOutcome::Acquired(row) => {
                AcquireLeaderLeaseResult::Acquired(leader_lease(key, row))
            }
            LeaseOutcome::Recovered(row) => {
                AcquireLeaderLeaseResult::RecoveredExpiredLease(leader_lease(key, row))
            }
            LeaseOutcome::AlreadyOwned(row) => {
                AcquireLeaderLeaseResult::AlreadyOwned(leader_lease(key, row))
            }
            LeaseOutcome::HeldByOther(row) => AcquireLeaderLeaseResult::HeldByOther {
                owner: NodeId::new(row.owner_node_id),
                expires_at: instant(row.expires_at),
            },
        })
    }

    /// Prolonge un bail encore détenu ; `None` s'il est perdu (expiré, libéré ou repris par un
    /// autre nœud).
    pub async fn renew(
        &self,
        lease: &LeaderLease,
        ttl: Duration,
    ) -> Result<Option<LeaderLease>, RuntimeError> {
        Ok(self
            .store
            .renew(
                LeaseKind::Leader,
                &lease.key,
                &lease.owner,
                lease.generation,
                ttl,
            )
            .await?
            .map(|row| leader_lease(&lease.key, row)))
    }

    /// Libère le bail ; `false` s'il n'était plus détenu par ce nœud dans cette génération.
    pub async fn release(&self, lease: &LeaderLease) -> Result<bool, RuntimeError> {
        self.store
            .release(LeaseKind::Leader, &lease.key, &lease.owner, lease.generation)
            .await
    }

    /// Bail actif du rôle `key` (détenu et non expiré à l'heure de la base).
    pub async fn inspect(&self, key: &str) -> Result<Option<LeaderLease>, RuntimeError> {
        Ok(self
            .store
            .get(LeaseKind::Leader, key)
            .await?
            .map(|row| leader_lease(key, row)))
    }
}
