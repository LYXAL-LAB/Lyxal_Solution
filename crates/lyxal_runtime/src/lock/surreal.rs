use crate::error::RuntimeError;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::{AcquireLeaseResult, MigrationLease};
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use crate::migration::id::MigrationId;
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Structure de persistance interne d'un verrou dans la table `system_migration_lock`.
#[derive(Debug, Serialize, Deserialize)]
struct SystemMigrationLockRow {
    lock_key: String,
    module_id: String,
    migration_id: String,
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

static MIGRATION_INIT_MUTEX: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());

/// Implémentation officielle de `MigrationLeaseManager` persistée dans SurrealDB via `lyxal_surreal`.
pub struct SurrealMigrationLeaseManager {
    client: Surreal<Any>,
}

impl SurrealMigrationLeaseManager {
    /// Crée un nouveau gestionnaire de baux de migration basé sur SurrealDB.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Retourne la référence au client SurrealDB.
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }

    /// Extrait le timestamp Unix actuel en secondes.
    fn now_secs() -> u64 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    }

    /// Convertit une ligne brute de base de données en modèle de domaine `MigrationLease`.
    fn row_to_lease(row: SystemMigrationLockRow) -> Result<MigrationLease, RuntimeError> {
        let key = MigrationLockKey::new(
            ModuleId::new(row.module_id),
            MigrationId::new(row.migration_id)?,
        );
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

        Ok(MigrationLease {
            key,
            owner: NodeId::new(row.owner_node_id),
            generation: row.generation as u64,
            acquired_at,
            renewed_at,
            expires_at,
        })
    }
}

impl LyxalSurrealCall for SurrealMigrationLeaseManager {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
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
        let now_secs = Self::now_secs();
        let ttl_secs = ttl.as_secs().max(1);
        let expires_at_secs = now_secs + ttl_secs;
        let lock_key_str = key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        // 1. Initialisation idempotente du record sentinel si absent (generation = 0, is_released = true, expires_at = 0)
        {
            let _guard = MIGRATION_INIT_MUTEX.lock().await;
            let check_query = "SELECT id FROM type::thing('system_migration_lock', $key_id);";
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
                    CREATE ONLY type::thing('system_migration_lock', $key_id) SET
                        lock_key = $lock_key,
                        module_id = $module_id,
                        migration_id = $migration_id,
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
                    .bind(("migration_id", key.migration_id.to_string()))
                    .await;
            }
        }

        // 2. Lecture de l'état actuel du verrou
        let select_query = "SELECT * FROM type::thing('system_migration_lock', $key_id);";
        let mut sel_res = self
            .client
            .query(select_query)
            .bind(("key_id", key_record_id.clone()))
            .await
            .map_err(|err| RuntimeError::MigrationLockAcquireFailed {
                key: lock_key_str.clone(),
                message: format!("Failed to inspect current lock state: {}", err),
            })?;

        let rows: Vec<SystemMigrationLockRow> = sel_res.take(0).unwrap_or_default();
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
                    return Ok(AcquireLeaseResult::AlreadyOwned(lease));
                } else {
                    return Ok(AcquireLeaseResult::HeldByOther {
                        owner: lease.owner,
                        expires_at: lease.expires_at,
                    });
                }
            }
        }

        // 3. Vrai Compare-And-Swap conditionnel : atomicité basée sur generation == expected_generation
        let next_gen = expected_gen + 1;
        let cas_query = r#"
            UPDATE type::thing('system_migration_lock', $key_id) SET
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
            .map_err(|err| RuntimeError::MigrationLockAcquireFailed {
                key: lock_key_str.clone(),
                message: format!("Failed to dispatch CAS lease acquire: {}", err),
            })?;

        let updated_rows: Vec<SystemMigrationLockRow> = res.take(0).unwrap_or_default();

        // 4. Succès déterminé EXCLUSIVEMENT par exactement 1 record modifié par le UPDATE CAS
        if let Some(row) = updated_rows.into_iter().next() {
            let lease = Self::row_to_lease(row)?;
            if lease.generation == 1 {
                Ok(AcquireLeaseResult::Acquired(lease))
            } else {
                Ok(AcquireLeaseResult::RecoveredExpiredLease(lease))
            }
        } else {
            // Le CAS a échoué (un autre concurrent a modifié la génération entre le SELECT et le UPDATE)
            let mut check_res = self
                .client
                .query(select_query)
                .bind(("key_id", key_record_id))
                .await
                .map_err(|err| RuntimeError::MigrationLockAcquireFailed {
                    key: lock_key_str.clone(),
                    message: format!("Failed to inspect winning lock state: {}", err),
                })?;

            let check_rows: Vec<SystemMigrationLockRow> = check_res.take(0).unwrap_or_default();
            if let Some(r) = check_rows.into_iter().next() {
                let lease = Self::row_to_lease(r)?;
                if &lease.owner == node_id && lease.is_active_at(now_secs) {
                    Ok(AcquireLeaseResult::AlreadyOwned(lease))
                } else {
                    Ok(AcquireLeaseResult::HeldByOther {
                        owner: lease.owner,
                        expires_at: lease.expires_at,
                    })
                }
            } else {
                Ok(AcquireLeaseResult::HeldByOther {
                    owner: NodeId::new("unknown"),
                    expires_at: 0,
                })
            }
        }
    }

    async fn renew(
        &self,
        lease: &MigrationLease,
        ttl: Duration,
    ) -> Result<MigrationLease, RuntimeError> {
        let now_secs = Self::now_secs();
        let ttl_secs = ttl.as_secs().max(1);
        let expires_at_secs = now_secs + ttl_secs;
        let lock_key_str = lease.key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        let update_query = r#"
            UPDATE type::thing('system_migration_lock', $key_id) SET
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
            .map_err(|err| RuntimeError::MigrationLeaseLost {
                key: lock_key_str.clone(),
                owner: lease.owner.to_string(),
                message: format!("Failed to renew lease: {}", err),
            })?;

        let updated_rows: Vec<SystemMigrationLockRow> =
            res.take(0)
                .map_err(|err| RuntimeError::MigrationLeaseLost {
                    key: lock_key_str.clone(),
                    owner: lease.owner.to_string(),
                    message: format!("Failed to parse renewal response: {}", err),
                })?;

        if updated_rows.is_empty() {
            return Err(RuntimeError::MigrationLeaseLost {
                key: lock_key_str,
                owner: lease.owner.to_string(),
                message: "Lease has expired, was released, or was acquired by another node"
                    .to_string(),
            });
        }

        let mut renewed_lease = lease.clone();
        renewed_lease.renewed_at = now_secs;
        renewed_lease.expires_at = expires_at_secs;

        Ok(renewed_lease)
    }

    async fn release(&self, lease: &MigrationLease) -> Result<(), RuntimeError> {
        let now_secs = Self::now_secs();
        let lock_key_str = lease.key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");

        // AUCUN DELETE ! Invariant Fencing : libération logique avec maintien de la génération N
        let update_query = r#"
            UPDATE type::thing('system_migration_lock', $key_id) SET
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
                code: "RUNTIME_MIGRATION_LOCK_RELEASE_FAILED",
                message: format!("Failed to release lease '{}': {}", lock_key_str, err),
            })?;

        let updated_rows: Vec<SystemMigrationLockRow> = res.take(0).unwrap_or_default();
        if updated_rows.is_empty() {
            return Err(RuntimeError::MigrationLockNotOwner {
                key: lock_key_str,
                caller: lease.owner.to_string(),
                actual_owner: "unknown or stale generation".to_string(),
            });
        }

        Ok(())
    }

    async fn inspect(
        &self,
        key: &MigrationLockKey,
    ) -> Result<Option<MigrationLease>, RuntimeError> {
        let lock_key_str = key.canonical_string();
        let key_record_id = lock_key_str.replace([':', '.', '-'], "_");
        let query = "SELECT * FROM type::thing('system_migration_lock', $key_id);";

        let mut res = self
            .client
            .query(query)
            .bind(("key_id", key_record_id))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!("Failed to inspect lease for '{}': {}", lock_key_str, err),
            })?;

        let rows: Vec<SystemMigrationLockRow> =
            res.take(0).map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_DATA_INVALID",
                message: format!("Failed to deserialize lease inspection row: {}", err),
            })?;

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
