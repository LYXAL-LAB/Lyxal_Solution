use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::lock::store::{instant, LeaseKind, LeaseOutcome, LeaseRow, LeaseStore};
use crate::types::ModuleId;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::RwLock;
use std::time::{Duration, SystemTime};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Clé d'identification canonique d'un verrou d'installation global de release (`module_id:version`).
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct InstallationLockKey {
    pub module_id: ModuleId,
    pub version: String,
}

impl InstallationLockKey {
    /// Crée une nouvelle clé de verrou d'installation.
    pub fn new(module_id: impl Into<ModuleId>, version: impl Into<String>) -> Self {
        Self {
            module_id: module_id.into(),
            version: version.into(),
        }
    }

    /// Représentation textuelle canonique sous la forme `module_id:version`.
    pub fn canonical_string(&self) -> String {
        format!("{}:{}", self.module_id.as_str(), self.version)
    }
}

impl std::fmt::Display for InstallationLockKey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.canonical_string())
    }
}

/// Bail distribué accordé pour l'exécution exclusive du pipeline d'installation d'une release.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct InstallationLease {
    /// Clé identifiant le module et la release sous verrou.
    pub key: InstallationLockKey,
    /// Identifiant du nœud propriétaire du bail.
    pub owner: NodeId,
    /// Jeton de clôture (fencing token) monotone.
    pub generation: u64,
    /// Timestamp Unix (secondes) d'acquisition.
    pub acquired_at: u64,
    /// Timestamp Unix (secondes) de dernier renouvellement.
    pub renewed_at: u64,
    /// Timestamp Unix (secondes) d'expiration.
    pub expires_at: u64,
}

impl InstallationLease {
    /// Vérifie si le bail est encore actif au timestamp spécifié.
    pub fn is_active_at(&self, timestamp: u64) -> bool {
        self.expires_at > timestamp
    }
}

/// Résultat d'une tentative d'acquisition d'un bail d'installation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AcquireInstallationLeaseResult {
    /// Le bail a été créé et acquis avec succès (première génération).
    Acquired(InstallationLease),
    /// Le bail était déjà détenu par le nœud appelant.
    AlreadyOwned(InstallationLease),
    /// Le bail est actuellement détenu par un autre nœud actif.
    HeldByOther { owner: NodeId, expires_at: u64 },
    /// Le bail précédent était expiré et a été récupéré avec succès (nouvelle génération).
    RecoveredExpiredLease(InstallationLease),
}

/// Contrat d'abstraction pour la gestion des baux distribués d'installation.
#[async_trait]
pub trait InstallationLeaseManager: Send + Sync {
    /// Tente d'acquérir le bail d'installation pour la clé donnée.
    async fn acquire(
        &self,
        key: &InstallationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireInstallationLeaseResult, RuntimeError>;

    /// Renouvelle un bail d'installation actif.
    async fn renew(
        &self,
        lease: &InstallationLease,
        ttl: Duration,
    ) -> Result<InstallationLease, RuntimeError>;

    /// Libère un bail d'installation.
    async fn release(&self, lease: &InstallationLease) -> Result<(), RuntimeError>;

    /// Inspecte l'état courant d'un bail d'installation sans le modifier.
    async fn inspect(
        &self,
        key: &InstallationLockKey,
    ) -> Result<Option<InstallationLease>, RuntimeError>;
}

/// Implémentation mémoire pour les tests unitaires.
#[derive(Default)]
pub struct MemoryInstallationLeaseManager {
    leases: RwLock<HashMap<InstallationLockKey, InstallationLease>>,
}

impl MemoryInstallationLeaseManager {
    /// Crée un nouveau gestionnaire de baux mémoire.
    pub fn new() -> Self {
        Self::default()
    }

    fn now_secs() -> u64 {
        SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    }
}

#[async_trait]
impl InstallationLeaseManager for MemoryInstallationLeaseManager {
    async fn acquire(
        &self,
        key: &InstallationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireInstallationLeaseResult, RuntimeError> {
        let now = Self::now_secs();
        let mut leases = self.leases.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Write lock poisoned in MemoryInstallationLeaseManager".to_string(),
        })?;

        if let Some(existing) = leases.get_mut(key) {
            if existing.is_active_at(now) {
                if &existing.owner == node_id {
                    return Ok(AcquireInstallationLeaseResult::AlreadyOwned(
                        existing.clone(),
                    ));
                } else {
                    return Ok(AcquireInstallationLeaseResult::HeldByOther {
                        owner: existing.owner.clone(),
                        expires_at: existing.expires_at,
                    });
                }
            } else {
                // Bail libéré (échéance 0) ou expiré : nouvelle génération. Seul un bail expiré
                // compte comme une reprise.
                let was_released = existing.expires_at == 0;
                existing.generation += 1;
                existing.owner = node_id.clone();
                existing.acquired_at = now;
                existing.renewed_at = now;
                existing.expires_at = now + ttl.as_secs().max(1);
                return Ok(if was_released {
                    AcquireInstallationLeaseResult::Acquired(existing.clone())
                } else {
                    AcquireInstallationLeaseResult::RecoveredExpiredLease(existing.clone())
                });
            }
        }

        let lease = InstallationLease {
            key: key.clone(),
            owner: node_id.clone(),
            generation: 1,
            acquired_at: now,
            renewed_at: now,
            expires_at: now + ttl.as_secs().max(1),
        };
        leases.insert(key.clone(), lease.clone());
        Ok(AcquireInstallationLeaseResult::Acquired(lease))
    }

    async fn renew(
        &self,
        lease: &InstallationLease,
        ttl: Duration,
    ) -> Result<InstallationLease, RuntimeError> {
        let now = Self::now_secs();
        let mut leases = self.leases.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Write lock poisoned in MemoryInstallationLeaseManager".to_string(),
        })?;

        if let Some(existing) = leases.get_mut(&lease.key) {
            if existing.owner == lease.owner
                && existing.generation == lease.generation
                && existing.expires_at > now
            {
                existing.renewed_at = now;
                existing.expires_at = now + ttl.as_secs().max(1);
                return Ok(existing.clone());
            }
        }

        Err(RuntimeError::InstallationLeaseAcquireFailed {
            module: lease.key.module_id.clone(),
            version: lease.key.version.clone(),
            message: "Lease has expired or was acquired by another node".to_string(),
        })
    }

    async fn release(&self, lease: &InstallationLease) -> Result<(), RuntimeError> {
        let mut leases = self.leases.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Write lock poisoned in MemoryInstallationLeaseManager".to_string(),
        })?;

        if let Some(existing) = leases.get_mut(&lease.key) {
            if existing.owner != lease.owner || existing.generation != lease.generation {
                return Err(RuntimeError::InstallationLeaseAcquireFailed {
                    module: lease.key.module_id.clone(),
                    version: lease.key.version.clone(),
                    message: "Cannot release lease: not the active owner or generation mismatch"
                        .to_string(),
                });
            }
            // Maintien du record persistant et de sa génération (zéro DELETE)
            existing.expires_at = 0;
        }
        Ok(())
    }

    async fn inspect(
        &self,
        key: &InstallationLockKey,
    ) -> Result<Option<InstallationLease>, RuntimeError> {
        let leases = self.leases.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Read lock poisoned in MemoryInstallationLeaseManager".to_string(),
        })?;
        let now = Self::now_secs();
        if let Some(existing) = leases.get(key) {
            if existing.is_active_at(now) {
                return Ok(Some(existing.clone()));
            }
        }
        Ok(None)
    }
}

/// `InstallationLeaseManager` persistant dans SurrealDB (`fn::runtime_lease_*`, nature
/// `installation`). Les échéances sont calculées à l'heure de la base.
pub struct SurrealInstallationLeaseManager {
    client: Surreal<Any>,
    store: LeaseStore,
}

impl SurrealInstallationLeaseManager {
    /// Crée un gestionnaire de baux d'installation sur le client donné.
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

fn installation_lease(key: &InstallationLockKey, row: LeaseRow) -> InstallationLease {
    InstallationLease {
        key: key.clone(),
        owner: NodeId::new(row.owner_node_id),
        generation: instant(row.generation),
        acquired_at: instant(row.acquired_at),
        renewed_at: instant(row.renewed_at),
        expires_at: instant(row.expires_at),
    }
}

fn installation_failure(key: &InstallationLockKey, message: impl Into<String>) -> RuntimeError {
    RuntimeError::InstallationLeaseAcquireFailed {
        module: key.module_id.clone(),
        version: key.version.clone(),
        message: message.into(),
    }
}

#[async_trait]
impl InstallationLeaseManager for SurrealInstallationLeaseManager {
    async fn acquire(
        &self,
        key: &InstallationLockKey,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<AcquireInstallationLeaseResult, RuntimeError> {
        let outcome = self
            .store
            .acquire(
                LeaseKind::Installation,
                &key.canonical_string(),
                node_id,
                ttl,
            )
            .await
            .map_err(|e| installation_failure(key, e.to_string()))?;
        Ok(match outcome {
            LeaseOutcome::Acquired(row) => {
                AcquireInstallationLeaseResult::Acquired(installation_lease(key, row))
            }
            LeaseOutcome::Recovered(row) => {
                AcquireInstallationLeaseResult::RecoveredExpiredLease(installation_lease(key, row))
            }
            LeaseOutcome::AlreadyOwned(row) => {
                AcquireInstallationLeaseResult::AlreadyOwned(installation_lease(key, row))
            }
            LeaseOutcome::HeldByOther(row) => AcquireInstallationLeaseResult::HeldByOther {
                owner: NodeId::new(row.owner_node_id),
                expires_at: instant(row.expires_at),
            },
        })
    }

    async fn renew(
        &self,
        lease: &InstallationLease,
        ttl: Duration,
    ) -> Result<InstallationLease, RuntimeError> {
        self.store
            .renew(
                LeaseKind::Installation,
                &lease.key.canonical_string(),
                &lease.owner,
                lease.generation,
                ttl,
            )
            .await?
            .map(|row| installation_lease(&lease.key, row))
            .ok_or_else(|| {
                installation_failure(
                    &lease.key,
                    "bail expiré, libéré ou repris par un autre nœud",
                )
            })
    }

    async fn release(&self, lease: &InstallationLease) -> Result<(), RuntimeError> {
        if self
            .store
            .release(
                LeaseKind::Installation,
                &lease.key.canonical_string(),
                &lease.owner,
                lease.generation,
            )
            .await?
        {
            Ok(())
        } else {
            Err(installation_failure(
                &lease.key,
                "libération refusée : bail non détenu par ce nœud dans cette génération",
            ))
        }
    }

    async fn inspect(
        &self,
        key: &InstallationLockKey,
    ) -> Result<Option<InstallationLease>, RuntimeError> {
        Ok(self
            .store
            .get(LeaseKind::Installation, &key.canonical_string())
            .await?
            .map(|row| installation_lease(key, row)))
    }
}
