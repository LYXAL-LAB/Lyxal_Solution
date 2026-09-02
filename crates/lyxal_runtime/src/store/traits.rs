use crate::error::RuntimeError;
use crate::migration::{MigrationId, MigrationRecord};
use crate::store::models::{StoredModule, StoredModuleRelease};
use crate::types::ModuleId;
use async_trait::async_trait;

/// Contrat d'abstraction universel pour la persistance système du Runtime Lyxal OS.
///
/// Ce trait isole le Runtime Core des spécificités SurrealQL et permet d'utiliser
/// indifféremment `SurrealRuntimeStore` en production et `MemoryRuntimeStore` pour les tests.
#[async_trait]
pub trait RuntimeStore: Send + Sync {
    /// Initialise et vérifie les tables et index système du Runtime de façon strictement idempotente.
    async fn bootstrap(&self) -> Result<(), RuntimeError>;

    /// Enregistre ou met à jour les métadonnées d'un module (`system_module`).
    async fn upsert_module(&self, module: &StoredModule) -> Result<(), RuntimeError>;

    /// Récupère un module par son identifiant.
    async fn get_module(&self, id: &ModuleId) -> Result<Option<StoredModule>, RuntimeError>;

    /// Liste l'ensemble des modules enregistrés dans le store système.
    async fn list_modules(&self) -> Result<Vec<StoredModule>, RuntimeError>;

    /// Enregistre une nouvelle release pour un module (`system_module_release`).
    async fn register_release(&self, release: &StoredModuleRelease) -> Result<(), RuntimeError>;

    /// Récupère une release spécifique d'un module par version.
    async fn get_release(
        &self,
        module_id: &ModuleId,
        version: &str,
    ) -> Result<Option<StoredModuleRelease>, RuntimeError>;

    /// Liste toutes les releases connues pour un module donné.
    async fn list_releases(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<StoredModuleRelease>, RuntimeError>;

    /// Met à jour le statut persistant et la phase d'une release existante.
    async fn update_release_status(
        &self,
        module_id: &ModuleId,
        version: &str,
        status: &str,
        phase: Option<&str>,
    ) -> Result<(), RuntimeError>;

    /// Enregistre ou met à jour l'historique d'une migration (`system_migration`).
    async fn record_migration(&self, migration: &MigrationRecord) -> Result<(), RuntimeError>;

    /// Récupère l'enregistrement d'une migration pour un module donné.
    async fn get_migration(
        &self,
        module_id: &ModuleId,
        migration_id: &MigrationId,
    ) -> Result<Option<MigrationRecord>, RuntimeError>;

    /// Liste les enregistrements de migrations d'un module ordonnés.
    async fn list_migrations(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<MigrationRecord>, RuntimeError>;
}
