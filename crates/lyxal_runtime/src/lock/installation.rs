use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_surreal::LyxalSurrealCall;
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
                existing.generation += 1;
                existing.owner = node_id.clone();
                existing.acquired_at = now;
                existing.renewed_at = now;
                existing.expires_at = now + ttl.as_secs().max(1);
                return Ok(AcquireInstallationLeaseResult::RecoveredExpiredLease(
                    existing.clone(),
                ));
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
            if existing.owner == lease.owner && existing.generation == lease.generation {
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

/// Structure de persistance interne pour `system_installation_lock`.
#[derive(Debug, Serialize, Deserialize)]
struct SystemInstallationLockRow {
    lock_key: String,
    module_id: String,
    version: String,
    owner_node_id: String,
    generation: i64,
    #[serde(default)]
    is_released: Option<bool>,
    #[serde(default)]
    acquired_at: Option<i64>,
    #[serde(default)]
    renewed_at: Option<i64>,
    #[serde(default)]
    expires_at: Option<i64>,
    #[serde(default)]
    released_at: Option<i64>,
}

static INSTALLATION_INIT_MUTEX: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());

/// Implémentation SurrealDB persistée du gestionnaire de baux d'installation.
pub struct SurrealInstallationLeaseManager {
    client: Surreal<Any>,
}

impl SurrealInstallationLeaseManager {
    /// Crée un nouveau gestionnaire de baux d'installation adossé à SurrealDB.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    fn now_secs() -> u64 {
        SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    }

    fn row_to_lease(row: SystemInstallationLockRow) -> Result<InstallationLease, RuntimeError> {
        let key = InstallationLockKey::new(ModuleId::new(row.module_id), row.version);
        let acquired_at = row
            .acquired_at
            .map(|v| v as u64)
            .unwrap_or_else(Self::now_secs);
        let renewed_at = row
            .renewed_at
            .map(|v| v as u64)
            .unwrap_or_else(Self::now_secs);
        let expires_at = row
            .expires_at
            .map(|v| v as u64)
            .unwrap_or_else(Self::now_secs);

        Ok(InstallationLease {
            key,
            owner: NodeId::new(row.owner_node_id),
            generation: row.generation as u64,
            acquired_at,
            renewed_at,
            expires_at,
        })
    }
}

impl LyxalSurrealCall for SurrealInstallationLeaseManager {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
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
        let now_secs = Self::now_secs();
        let ttl_secs = ttl.as_secs().max(1);
        let expires_at_secs = now_secs + ttl_secs;
        let lock_key_str = key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        // 1. Initialisation idempotente du record sentinel si absent (generation = 0, is_released = true, expires_at = 0)
        {
            let _guard = INSTALLATION_INIT_MUTEX.lock().await;
            let check_query = "SELECT id FROM type::thing('system_installation_lock', $key_id);";
            let check_res = self
                .client
                .query(check_query)
                .bind(("key_id", key_record_id.clone()))
                .await;

            let exists = if let Ok(mut r) = check_res {
                let rows: Vec<serde_json::Value> = r.take(0).unwrap_or_default();
                !rows.is_empty()
            } else {
                false
            };

            if !exists {
                let init_query = r#"
                    CREATE ONLY type::thing('system_installation_lock', $key_id) SET
                        lock_key = $lock_key,
                        module_id = $module_id,
                        version = $version,
                        owner_node_id = '',
                        generation = 0,
                        is_released = true,
                        expires_at = 0,
                        acquired_at = NONE,
                        renewed_at = NONE,
                        released_at = NONE,
                        updated_at = time::now();
                "#;
                let _ = self
                    .client
                    .query(init_query)
                    .bind(("key_id", key_record_id.clone()))
                    .bind(("lock_key", lock_key_str.clone()))
                    .bind(("module_id", key.module_id.to_string()))
                    .bind(("version", key.version.clone()))
                    .await;
            }
        }

        // 2. Lecture de l'état actuel du verrou
        let select_query = "SELECT * FROM type::thing('system_installation_lock', $key_id);";
        let mut sel_res = self
            .client
            .query(select_query)
            .bind(("key_id", key_record_id.clone()))
            .await
            .map_err(|err| RuntimeError::InstallationLeaseAcquireFailed {
                module: key.module_id.clone(),
                version: key.version.clone(),
                message: format!("Failed to inspect installation lock state: {}", err),
            })?;

        let rows: Vec<SystemInstallationLockRow> = sel_res.take(0).unwrap_or_default();
        let existing = rows.into_iter().next();

        let (expected_gen, is_released, expires_at) = match &existing {
            Some(row) => (
                row.generation,
                row.is_released.unwrap_or(false),
                row.expires_at.unwrap_or(0) as u64,
            ),
            None => (0, true, 0),
        };

        let is_active = !is_released && now_secs < expires_at;
        if is_active {
            if let Some(r) = existing {
                let lease = Self::row_to_lease(r)?;
                if &lease.owner == node_id {
                    return Ok(AcquireInstallationLeaseResult::AlreadyOwned(lease));
                } else {
                    return Ok(AcquireInstallationLeaseResult::HeldByOther {
                        owner: lease.owner,
                        expires_at: lease.expires_at,
                    });
                }
            }
        }

        // 3. Vrai Compare-And-Swap conditionnel : atomicité basée sur generation == expected_generation
        let next_gen = expected_gen + 1;
        let cas_query = r#"
            UPDATE type::thing('system_installation_lock', $key_id) SET
                owner_node_id = $owner_node_id,
                generation = $next_gen,
                is_released = false,
                acquired_at = $now_secs,
                renewed_at = $now_secs,
                expires_at = $expires_at_secs,
                released_at = NONE,
                updated_at = time::now()
            WHERE generation = $expected_gen
              AND (is_released = true OR expires_at <= $now_secs);
        "#;

        let mut res = self
            .client
            .query(cas_query)
            .bind(("key_id", key_record_id.clone()))
            .bind(("owner_node_id", node_id.to_string()))
            .bind(("next_gen", next_gen))
            .bind(("expected_gen", expected_gen))
            .bind(("now_secs", now_secs as i64))
            .bind(("expires_at_secs", expires_at_secs as i64))
            .await
            .map_err(|err| RuntimeError::InstallationLeaseAcquireFailed {
                module: key.module_id.clone(),
                version: key.version.clone(),
                message: format!("Failed to dispatch CAS installation lease acquire: {}", err),
            })?;

        let updated_rows: Vec<SystemInstallationLockRow> = res.take(0).unwrap_or_default();

        // 4. Succès déterminé EXCLUSIVEMENT par exactement 1 record modifié par le UPDATE CAS
        if let Some(row) = updated_rows.into_iter().next() {
            let lease = Self::row_to_lease(row)?;
            if lease.generation == 1 {
                Ok(AcquireInstallationLeaseResult::Acquired(lease))
            } else {
                Ok(AcquireInstallationLeaseResult::RecoveredExpiredLease(lease))
            }
        } else {
            // Le CAS a échoué (un autre concurrent a modifié la génération entre le SELECT et le UPDATE)
            let mut check_res = self
                .client
                .query(select_query)
                .bind(("key_id", key_record_id))
                .await
                .map_err(|err| RuntimeError::InstallationLeaseAcquireFailed {
                    module: key.module_id.clone(),
                    version: key.version.clone(),
                    message: format!("Failed to inspect winning lock state: {}", err),
                })?;

            let check_rows: Vec<SystemInstallationLockRow> = check_res.take(0).unwrap_or_default();
            if let Some(r) = check_rows.into_iter().next() {
                let lease = Self::row_to_lease(r)?;
                if &lease.owner == node_id && lease.is_active_at(now_secs) {
                    Ok(AcquireInstallationLeaseResult::AlreadyOwned(lease))
                } else {
                    Ok(AcquireInstallationLeaseResult::HeldByOther {
                        owner: lease.owner,
                        expires_at: lease.expires_at,
                    })
                }
            } else {
                Ok(AcquireInstallationLeaseResult::HeldByOther {
                    owner: NodeId::new("unknown"),
                    expires_at: 0,
                })
            }
        }
    }

    async fn renew(
        &self,
        lease: &InstallationLease,
        ttl: Duration,
    ) -> Result<InstallationLease, RuntimeError> {
        let now_secs = Self::now_secs();
        let ttl_secs = ttl.as_secs().max(1);
        let expires_at_secs = now_secs + ttl_secs;
        let lock_key_str = lease.key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        let update_query = r#"
            UPDATE type::thing('system_installation_lock', $key_id) SET
                renewed_at = $now_secs,
                expires_at = $expires_at_secs,
                updated_at = time::now()
            WHERE owner_node_id = $owner_node_id
              AND generation = $generation
              AND (is_released = false OR is_released = NONE)
              AND expires_at > $now_secs;
        "#;

        let mut res = self
            .client
            .query(update_query)
            .bind(("key_id", key_record_id))
            .bind(("now_secs", now_secs as i64))
            .bind(("expires_at_secs", expires_at_secs as i64))
            .bind(("owner_node_id", lease.owner.to_string()))
            .bind(("generation", lease.generation as i64))
            .await
            .map_err(|err| RuntimeError::InstallationLeaseAcquireFailed {
                module: lease.key.module_id.clone(),
                version: lease.key.version.clone(),
                message: format!("Failed to renew installation lease: {}", err),
            })?;

        let updated_rows: Vec<SystemInstallationLockRow> = res.take(0).unwrap_or_default();

        if updated_rows.is_empty() {
            return Err(RuntimeError::InstallationLeaseAcquireFailed {
                module: lease.key.module_id.clone(),
                version: lease.key.version.clone(),
                message:
                    "Installation lease has expired, was released, or was acquired by another node"
                        .to_string(),
            });
        }

        let mut renewed = lease.clone();
        renewed.renewed_at = now_secs;
        renewed.expires_at = expires_at_secs;
        Ok(renewed)
    }

    async fn release(&self, lease: &InstallationLease) -> Result<(), RuntimeError> {
        let now_secs = Self::now_secs();
        let lock_key_str = lease.key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        // AUCUN DELETE ! Invariant Fencing : libération logique avec maintien de la génération N
        let update_query = r#"
            UPDATE type::thing('system_installation_lock', $key_id) SET
                is_released = true,
                expires_at = 0,
                released_at = $now_secs,
                updated_at = time::now()
            WHERE owner_node_id = $owner_node_id AND generation = $generation AND (is_released = false OR is_released = NONE);
        "#;

        let mut res = self
            .client
            .query(update_query)
            .bind(("key_id", key_record_id))
            .bind(("now_secs", now_secs as i64))
            .bind(("owner_node_id", lease.owner.to_string()))
            .bind(("generation", lease.generation as i64))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_INSTALLATION_LEASE_RELEASE_FAILED",
                message: format!(
                    "Failed to release installation lease '{}': {}",
                    lock_key_str, err
                ),
            })?;

        let updated_rows: Vec<SystemInstallationLockRow> = res.take(0).unwrap_or_default();
        if updated_rows.is_empty() {
            return Err(RuntimeError::InstallationLeaseAcquireFailed {
                module: lease.key.module_id.clone(),
                version: lease.key.version.clone(),
                message:
                    "Cannot release installation lease: not the active owner or generation mismatch"
                        .to_string(),
            });
        }

        Ok(())
    }

    async fn inspect(
        &self,
        key: &InstallationLockKey,
    ) -> Result<Option<InstallationLease>, RuntimeError> {
        let lock_key_str = key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");
        let query = "SELECT * FROM type::thing('system_installation_lock', $key_id);";

        let mut res = self
            .client
            .query(query)
            .bind(("key_id", key_record_id))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!(
                    "Failed to inspect installation lock '{}': {}",
                    lock_key_str, err
                ),
            })?;

        let rows: Vec<SystemInstallationLockRow> = res.take(0).unwrap_or_default();

        match rows.into_iter().next() {
            Some(row) => {
                let now_secs = Self::now_secs();
                let is_released = row.is_released.unwrap_or(false);
                let expires_at = row.expires_at.unwrap_or(0) as u64;
                if is_released || now_secs >= expires_at {
                    Ok(None)
                } else {
                    Ok(Some(Self::row_to_lease(row)?))
                }
            }
            None => Ok(None),
        }
    }
}
