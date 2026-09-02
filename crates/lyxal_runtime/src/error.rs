use crate::types::{ModuleId, ModuleState};
use lyxal_error::{LyxalCallError, LyxalError, LyxalResult};
use serde_json::json;
use std::time::Duration;
use thiserror::Error;

/// Énumération typée des erreurs émises par le moteur Lyxal Runtime.
///
/// Tous les codes d'erreur suivent le standard canonique préfixé par `RUNTIME_*`.
#[derive(Debug, Error)]
pub enum RuntimeError {
    #[error("Duplicate module: module '{id}' is already registered in the runtime")]
    DuplicateModule { id: ModuleId },

    #[error("Unknown module: module '{id}' is not found in the runtime registry")]
    UnknownModule { id: ModuleId },

    #[error(
        "Missing dependency: module '{module}' requires '{dependency}' which is not registered"
    )]
    MissingDependency {
        module: ModuleId,
        dependency: ModuleId,
    },

    #[error("Dependency cycle detected involving modules: {cycle:?}")]
    DependencyCycle { cycle: Vec<ModuleId> },

    #[error(
        "Invalid state transition for module '{module}': cannot transition from '{from}' to '{to}'"
    )]
    InvalidStateTransition {
        module: ModuleId,
        from: ModuleState,
        to: ModuleState,
    },

    #[error("Installation failed for module '{module}': {message}")]
    InstallFailure { module: ModuleId, message: String },

    #[error("Start failed for module '{module}': {message}")]
    StartFailure { module: ModuleId, message: String },

    #[error("Stop failed for module '{module}': {message}")]
    StopFailure { module: ModuleId, message: String },

    #[error("Operation '{operation}' timed out after {duration:?} for module '{module}'")]
    Timeout {
        module: ModuleId,
        operation: &'static str,
        duration: Duration,
    },

    #[error("Invalid manifest: {message}")]
    InvalidManifest { message: String },

    #[error(
        "Unsupported manifest version '{version}', maximum supported version is '{supported}'"
    )]
    UnsupportedManifestVersion { version: u32, supported: u32 },

    #[error("Invalid module version '{version}': {message}")]
    InvalidModuleVersion { version: String, message: String },

    #[error("Self-dependency detected: module '{module}' cannot depend on itself")]
    SelfDependency { module: ModuleId },

    #[error("Duplicate dependency in manifest: module '{module}' declares dependency '{dependency}' multiple times")]
    DuplicateDependency {
        module: ModuleId,
        dependency: ModuleId,
    },

    #[error("Failed to parse manifest: {message}")]
    ManifestParseError { message: String },

    #[error("Invalid migration identifier '{id}': {reason}")]
    InvalidMigrationId { id: String, reason: String },

    #[error("Invalid migration checksum: expected '{expected}', found '{found}'")]
    InvalidChecksum { expected: String, found: String },

    #[error("Resource not found: '{path}'")]
    ResourceNotFound { path: String },

    #[error("Invalid resource path '{path}': {reason}")]
    InvalidResourcePath { path: String, reason: String },

    #[error("Resource '{path}' is too large ({size} bytes, maximum allowed is {max_size} bytes)")]
    ResourceTooLarge {
        path: String,
        size: usize,
        max_size: usize,
    },

    #[error("Resource '{path}' encoding error: {message}")]
    ResourceEncodingError { path: String, message: String },

    #[error("Schema import failed for module '{module}', resource '{resource}': {message}")]
    SchemaImportFailed {
        module: ModuleId,
        resource: String,
        message: String,
    },

    #[error("Migration discovery failed for module '{module}': {message}")]
    MigrationDiscoveryFailed { module: ModuleId, message: String },

    #[error(
        "Migration checksum drift for module '{module}', migration '{migration}': expected '{expected}', actual '{actual}'"
    )]
    MigrationChecksumMismatch {
        module: ModuleId,
        migration: String,
        expected: String,
        actual: String,
    },

    #[error(
        "Migration interrupted during previous run for module '{module}', migration '{migration}' (found in 'Applying' state)"
    )]
    MigrationInterrupted { module: ModuleId, migration: String },

    #[error(
        "Migration execution failed for module '{module}', migration '{migration}': {message}"
    )]
    MigrationExecutionFailed {
        module: ModuleId,
        migration: String,
        message: String,
    },

    #[error("Failed to acquire migration lock for key '{key}': {message}")]
    MigrationLockAcquireFailed { key: String, message: String },

    #[error("Timed out waiting to acquire migration lock for key '{key}' after {duration_ms}ms")]
    MigrationLockTimeout { key: String, duration_ms: u64 },

    #[error("Migration lock for key '{key}' is held by node '{owner}', expires at {expires_at}")]
    MigrationLockHeld {
        key: String,
        owner: String,
        expires_at: u64,
    },

    #[error("Migration lease lost for key '{key}' (owner '{owner}'): {message}")]
    MigrationLeaseLost {
        key: String,
        owner: String,
        message: String,
    },

    #[error("Migration lease for key '{key}' has expired at {expired_at}")]
    MigrationLeaseExpired { key: String, expired_at: u64 },

    #[error("Node '{caller}' is not the owner of migration lock '{key}' (current owner: '{actual_owner}')")]
    MigrationLockNotOwner {
        key: String,
        caller: String,
        actual_owner: String,
    },

    #[error(
        "Migration recovery required for module '{module}', migration '{migration}': {reason}"
    )]
    MigrationRecoveryRequired {
        module: ModuleId,
        migration: String,
        reason: String,
    },

    #[error(
        "Module implementation missing for module '{module}' (version '{version}'): LyxalModule is required for installation"
    )]
    ModuleImplementationMissing { module: ModuleId, version: String },

    #[error(
        "Runtime version incompatible for module '{module}': requires '{required}', current runtime is '{actual}'"
    )]
    RuntimeVersionIncompatible {
        module: ModuleId,
        required: String,
        actual: String,
    },

    #[error(
        "Dependency version incompatible for module '{module}': requires '{dependency}' '{required}', but found '{actual}'"
    )]
    DependencyVersionIncompatible {
        module: ModuleId,
        dependency: ModuleId,
        required: String,
        actual: String,
    },

    #[error(
        "Batch contains duplicate packages for module '{module}' with conflicting versions: {versions:?}"
    )]
    BatchDuplicateModule {
        module: ModuleId,
        versions: Vec<String>,
    },

    #[error(
        "Batch installation skipped for module '{module}' due to failure in dependency '{failed_dependency}'"
    )]
    BatchDependencyFailure {
        module: ModuleId,
        failed_dependency: ModuleId,
    },

    #[error(
        "Installation failed for module '{module}' (version '{version}') at phase '{phase}': {cause}"
    )]
    ModuleInstallFailed {
        module: ModuleId,
        version: String,
        phase: String,
        cause: String,
    },

    #[error("Module '{module}' is not installed")]
    ModuleNotInstalled { module: ModuleId },

    #[error(
        "Failed to acquire installation lease for module '{module}' (version '{version}'): {message}"
    )]
    InstallationLeaseAcquireFailed {
        module: ModuleId,
        version: String,
        message: String,
    },

    #[error("Timed out waiting for installation lease on module '{module}' (version '{version}')")]
    InstallationLeaseTimeout { module: ModuleId, version: String },

    #[error("Desired state conflict for module '{module}': {message}")]
    DesiredStateConflict { module: ModuleId, message: String },

    #[error("Duplicate module '{module}' declared in desired runtime state")]
    DesiredDuplicateModule { module: ModuleId },

    #[error(
        "Unsupported downgrade for module '{module}': current version '{current_version}' cannot be downgraded to '{desired_version}'"
    )]
    UnsupportedDowngrade {
        module: ModuleId,
        current_version: String,
        desired_version: String,
    },

    #[error("Reconciliation blocked for module '{module}': {reason}")]
    ReconciliationBlocked { module: ModuleId, reason: String },

    #[error("Worker '{worker}' is already registered")]
    WorkerDuplicate { worker: String },

    #[error("Worker '{worker}' was not found in registry")]
    WorkerNotFound { worker: String },

    #[error("Invalid state transition for worker '{worker}' from {from} to {to}")]
    WorkerInvalidTransition {
        worker: String,
        from: String,
        to: String,
    },

    #[error("Failed to start worker '{worker}': {message}")]
    WorkerStartFailed { worker: String, message: String },

    #[error("Failed to stop worker '{worker}': {message}")]
    WorkerStopFailed { worker: String, message: String },

    #[error("Worker '{worker}' timed out during graceful shutdown ({timeout_ms}ms) and was forcibly aborted")]
    WorkerStopTimeout { worker: String, timeout_ms: u64 },

    #[error("Worker '{worker}' panicked during execution: {message}")]
    WorkerPanicked { worker: String, message: String },

    #[error("Worker '{worker}' failed: {message}")]
    WorkerFailed { worker: String, message: String },

    #[error("Worker '{worker}' exhausted max restart attempts ({retries})")]
    WorkerRestartExhausted { worker: String, retries: u32 },

    #[error("Worker store operation failed for '{worker}': {message}")]
    WorkerStoreFailed { worker: String, message: String },

    #[error(
        "Event handler '{handler_name}' for event type '{event_type}' was not found in registry"
    )]
    EventHandlerNotFound {
        handler_name: String,
        event_type: String,
    },

    #[error("Event engine error: {message}")]
    EventEngineError { message: String },

    #[error("Runtime internal error [{code}]: {message}")]
    Internal { code: &'static str, message: String },
}

impl RuntimeError {
    /// Retourne le code d'erreur canonique Lyxal OS associé à cette erreur.
    pub fn code(&self) -> &'static str {
        match self {
            Self::DuplicateModule { .. } => "RUNTIME_DUPLICATE_MODULE",
            Self::UnknownModule { .. } => "RUNTIME_UNKNOWN_MODULE",
            Self::MissingDependency { .. } => "RUNTIME_MISSING_DEPENDENCY",
            Self::DependencyCycle { .. } => "RUNTIME_DEPENDENCY_CYCLE",
            Self::InvalidStateTransition { .. } => "RUNTIME_INVALID_STATE_TRANSITION",
            Self::InstallFailure { .. } => "RUNTIME_INSTALL_FAILURE",
            Self::StartFailure { .. } => "RUNTIME_START_FAILURE",
            Self::StopFailure { .. } => "RUNTIME_STOP_FAILURE",
            Self::Timeout { .. } => "RUNTIME_OPERATION_TIMEOUT",
            Self::InvalidManifest { .. } => "RUNTIME_INVALID_MANIFEST",
            Self::UnsupportedManifestVersion { .. } => "RUNTIME_UNSUPPORTED_MANIFEST_VERSION",
            Self::InvalidModuleVersion { .. } => "RUNTIME_INVALID_MODULE_VERSION",
            Self::SelfDependency { .. } => "RUNTIME_SELF_DEPENDENCY",
            Self::DuplicateDependency { .. } => "RUNTIME_DUPLICATE_DEPENDENCY",
            Self::ManifestParseError { .. } => "RUNTIME_MANIFEST_PARSE_ERROR",
            Self::InvalidMigrationId { .. } => "RUNTIME_INVALID_MIGRATION_ID",
            Self::InvalidChecksum { .. } => "RUNTIME_INVALID_CHECKSUM",
            Self::ResourceNotFound { .. } => "RUNTIME_RESOURCE_NOT_FOUND",
            Self::InvalidResourcePath { .. } => "RUNTIME_RESOURCE_INVALID_PATH",
            Self::ResourceTooLarge { .. } => "RUNTIME_RESOURCE_TOO_LARGE",
            Self::ResourceEncodingError { .. } => "RUNTIME_RESOURCE_ENCODING_ERROR",
            Self::SchemaImportFailed { .. } => "RUNTIME_SCHEMA_IMPORT_FAILED",
            Self::MigrationDiscoveryFailed { .. } => "RUNTIME_MIGRATION_DISCOVERY_FAILED",
            Self::MigrationChecksumMismatch { .. } => "RUNTIME_MIGRATION_CHECKSUM_MISMATCH",
            Self::MigrationInterrupted { .. } => "RUNTIME_MIGRATION_INTERRUPTED",
            Self::MigrationExecutionFailed { .. } => "RUNTIME_MIGRATION_EXECUTION_FAILED",
            Self::MigrationLockAcquireFailed { .. } => "RUNTIME_MIGRATION_LOCK_ACQUIRE_FAILED",
            Self::MigrationLockTimeout { .. } => "RUNTIME_MIGRATION_LOCK_TIMEOUT",
            Self::MigrationLockHeld { .. } => "RUNTIME_MIGRATION_LOCK_HELD",
            Self::MigrationLeaseLost { .. } => "RUNTIME_MIGRATION_LEASE_LOST",
            Self::MigrationLeaseExpired { .. } => "RUNTIME_MIGRATION_LEASE_EXPIRED",
            Self::MigrationLockNotOwner { .. } => "RUNTIME_MIGRATION_LOCK_NOT_OWNER",
            Self::MigrationRecoveryRequired { .. } => "RUNTIME_MIGRATION_RECOVERY_REQUIRED",
            Self::ModuleImplementationMissing { .. } => "RUNTIME_MODULE_IMPLEMENTATION_MISSING",
            Self::RuntimeVersionIncompatible { .. } => "RUNTIME_VERSION_INCOMPATIBLE",
            Self::DependencyVersionIncompatible { .. } => "RUNTIME_DEPENDENCY_VERSION_INCOMPATIBLE",
            Self::BatchDuplicateModule { .. } => "RUNTIME_BATCH_DUPLICATE_MODULE",
            Self::BatchDependencyFailure { .. } => "RUNTIME_BATCH_DEPENDENCY_FAILURE",
            Self::ModuleInstallFailed { .. } => "RUNTIME_MODULE_INSTALL_FAILED",
            Self::ModuleNotInstalled { .. } => "RUNTIME_MODULE_NOT_INSTALLED",
            Self::InstallationLeaseAcquireFailed { .. } => {
                "RUNTIME_INSTALLATION_LEASE_ACQUIRE_FAILED"
            }
            Self::InstallationLeaseTimeout { .. } => "RUNTIME_INSTALLATION_LEASE_TIMEOUT",
            Self::DesiredStateConflict { .. } => "RUNTIME_DESIRED_STATE_CONFLICT",
            Self::DesiredDuplicateModule { .. } => "RUNTIME_DESIRED_DUPLICATE_MODULE",
            Self::UnsupportedDowngrade { .. } => "RUNTIME_UNSUPPORTED_DOWNGRADE",
            Self::ReconciliationBlocked { .. } => "RUNTIME_RECONCILIATION_BLOCKED",
            Self::WorkerDuplicate { .. } => "RUNTIME_WORKER_DUPLICATE",
            Self::WorkerNotFound { .. } => "RUNTIME_WORKER_NOT_FOUND",
            Self::WorkerInvalidTransition { .. } => "RUNTIME_WORKER_INVALID_TRANSITION",
            Self::WorkerStartFailed { .. } => "RUNTIME_WORKER_START_FAILED",
            Self::WorkerStopFailed { .. } => "RUNTIME_WORKER_STOP_FAILED",
            Self::WorkerStopTimeout { .. } => "RUNTIME_WORKER_STOP_TIMEOUT",
            Self::WorkerPanicked { .. } => "RUNTIME_WORKER_PANICKED",
            Self::WorkerFailed { .. } => "RUNTIME_WORKER_FAILED",
            Self::WorkerRestartExhausted { .. } => "RUNTIME_WORKER_RESTART_EXHAUSTED",
            Self::WorkerStoreFailed { .. } => "RUNTIME_WORKER_STORE_FAILED",
            Self::EventHandlerNotFound { .. } => "RUNTIME_EVENT_HANDLER_NOT_FOUND",
            Self::EventEngineError { .. } => "RUNTIME_EVENT_ENGINE_ERROR",
            Self::Internal { code, .. } => code,
        }
    }

    /// Convertit l'erreur Runtime en `LyxalError` conforme à la charte d'architecture.
    pub fn to_lyxal_error(&self) -> LyxalError {
        let code = self.code().to_string();
        let message = self.to_string();
        let label = match self {
            Self::DuplicateModule { id } => format!("Module '{}' déjà enregistré", id),
            Self::UnknownModule { id } => format!("Module '{}' inconnu", id),
            Self::MissingDependency { module, dependency } => {
                format!(
                    "Dépendance '{}' manquante pour le module '{}'",
                    dependency, module
                )
            }
            Self::DependencyCycle { .. } => "Cycle de dépendances détecté".to_string(),
            Self::InvalidStateTransition { module, from, to } => {
                format!(
                    "Transition d'état invalide pour '{}' ({} -> {})",
                    module, from, to
                )
            }
            Self::InstallFailure { module, .. } => {
                format!("Échec d'installation du module '{}'", module)
            }
            Self::StartFailure { module, .. } => {
                format!("Échec de démarrage du module '{}'", module)
            }
            Self::StopFailure { module, .. } => format!("Échec d'arrêt du module '{}'", module),
            Self::Timeout {
                module, operation, ..
            } => {
                format!("Délai dépassé ({}) pour le module '{}'", operation, module)
            }
            Self::InvalidManifest { .. } => "Manifeste de module invalide".to_string(),
            Self::UnsupportedManifestVersion { version, .. } => {
                format!("Version de manifeste non supportée ({})", version)
            }
            Self::InvalidModuleVersion { version, .. } => {
                format!("Version sémantique de module invalide ({})", version)
            }
            Self::SelfDependency { module } => {
                format!("Le module '{}' ne peut dépendre de lui-même", module)
            }
            Self::DuplicateDependency { module, dependency } => {
                format!(
                    "Dépendance '{}' dupliquée dans le module '{}'",
                    dependency, module
                )
            }
            Self::ManifestParseError { .. } => {
                "Erreur de syntaxe dans le fichier manifeste".to_string()
            }
            Self::InvalidMigrationId { id, .. } => {
                format!("Identifiant de migration invalide ({})", id)
            }
            Self::InvalidChecksum { .. } => {
                "Checksum de migration invalide ou corrompu".to_string()
            }
            Self::ResourceNotFound { path } => format!("Ressource introuvable : {}", path),
            Self::InvalidResourcePath { path, .. } => {
                format!("Chemin de ressource invalide : {}", path)
            }
            Self::ResourceTooLarge { path, .. } => format!("Ressource trop volumineuse : {}", path),
            Self::ResourceEncodingError { path, .. } => {
                format!("Erreur d'encodage de la ressource : {}", path)
            }
            Self::SchemaImportFailed { module, .. } => {
                format!("Échec d'import du schéma du module '{}'", module)
            }
            Self::MigrationDiscoveryFailed { module, .. } => {
                format!("Échec de découverte des migrations du module '{}'", module)
            }
            Self::MigrationChecksumMismatch {
                module,
                migration,
                expected: _,
                actual: _,
            } => format!(
                "Altération détectée sur la migration '{}:{}'",
                module, migration
            ),
            Self::MigrationInterrupted { module, migration } => format!(
                "Migration interrompue détectée pour '{}:{}'",
                module, migration
            ),
            Self::MigrationExecutionFailed {
                module, migration, ..
            } => format!(
                "Échec d'exécution de la migration '{}:{}'",
                module, migration
            ),
            Self::MigrationLockAcquireFailed { key, .. } => {
                format!("Échec d'acquisition du verrou de migration pour '{}'", key)
            }
            Self::MigrationLockTimeout { key, .. } => {
                format!("Délai d'acquisition dépassé pour le verrou '{}'", key)
            }
            Self::MigrationLockHeld { key, owner, .. } => {
                format!(
                    "Le verrou de migration '{}' est détenu par le nœud '{}'",
                    key, owner
                )
            }
            Self::MigrationLeaseLost { key, owner, .. } => {
                format!("Bail de migration '{}' perdu par le nœud '{}'", key, owner)
            }
            Self::MigrationLeaseExpired { key, .. } => {
                format!("Bail de migration '{}' expiré", key)
            }
            Self::MigrationLockNotOwner { key, caller, .. } => {
                format!(
                    "Le nœud '{}' n'est pas propriétaire du verrou '{}'",
                    caller, key
                )
            }
            Self::MigrationRecoveryRequired {
                module, migration, ..
            } => format!(
                "Récupération requise pour la migration '{}:{}'",
                module, migration
            ),
            Self::ModuleImplementationMissing { module, version } => {
                format!(
                    "Implémentation manquante pour le module '{}' (v{})",
                    module, version
                )
            }
            Self::RuntimeVersionIncompatible { module, .. } => {
                format!(
                    "Version du runtime incompatible pour le module '{}'",
                    module
                )
            }
            Self::DependencyVersionIncompatible {
                module, dependency, ..
            } => {
                format!(
                    "Version incompatible de la dépendance '{}' pour '{}'",
                    dependency, module
                )
            }
            Self::BatchDuplicateModule { module, .. } => {
                format!(
                    "Versions dupliquées pour le module '{}' dans le batch",
                    module
                )
            }
            Self::BatchDependencyFailure {
                module,
                failed_dependency,
            } => {
                format!(
                    "Installation de '{}' ignorée en raison de l'échec de '{}'",
                    module, failed_dependency
                )
            }
            Self::ModuleInstallFailed {
                module,
                version,
                phase,
                ..
            } => {
                format!(
                    "Échec d'installation du module '{}' (v{}) à la phase '{}'",
                    module, version, phase
                )
            }
            Self::ModuleNotInstalled { module } => {
                format!("Le module '{}' n'est pas installé", module)
            }
            Self::InstallationLeaseAcquireFailed {
                module, version, ..
            } => {
                format!(
                    "Échec d'acquisition du bail d'installation pour '{}:{}'",
                    module, version
                )
            }
            Self::InstallationLeaseTimeout { module, version } => {
                format!(
                    "Délai d'attente du bail d'installation dépassé pour '{}:{}'",
                    module, version
                )
            }
            Self::DesiredStateConflict { module, .. } => {
                format!("Conflit dans l'état désiré pour le module '{}'", module)
            }
            Self::DesiredDuplicateModule { module } => {
                format!(
                    "Module '{}' déclaré plusieurs fois dans l'état désiré",
                    module
                )
            }
            Self::UnsupportedDowngrade { module, .. } => {
                format!("Rétrogradation non supportée pour le module '{}'", module)
            }
            Self::ReconciliationBlocked { module, .. } => {
                format!("Réconciliation bloquée pour le module '{}'", module)
            }
            Self::WorkerDuplicate { worker } => {
                format!("Worker '{}' déjà enregistré", worker)
            }
            Self::WorkerNotFound { worker } => {
                format!("Worker '{}' inconnu", worker)
            }
            Self::WorkerInvalidTransition { worker, from, to } => {
                format!(
                    "Transition d'état invalide pour le worker '{}' ({} -> {})",
                    worker, from, to
                )
            }
            Self::WorkerStartFailed { worker, .. } => {
                format!("Échec de démarrage du worker '{}'", worker)
            }
            Self::WorkerStopFailed { worker, .. } => {
                format!("Échec d'arrêt du worker '{}'", worker)
            }
            Self::WorkerStopTimeout { worker, timeout_ms } => {
                format!(
                    "Délai dépassé ({}ms) lors de l'arrêt du worker '{}'",
                    timeout_ms, worker
                )
            }
            Self::WorkerPanicked { worker, .. } => {
                format!("Panique du worker '{}'", worker)
            }
            Self::WorkerFailed { worker, .. } => {
                format!("Échec d'exécution du worker '{}'", worker)
            }
            Self::WorkerRestartExhausted { worker, retries } => {
                format!(
                    "Nombre maximal de redémarrages ({}) épuisé pour le worker '{}'",
                    retries, worker
                )
            }
            Self::WorkerStoreFailed { worker, .. } => {
                format!("Erreur de persistance pour le worker '{}'", worker)
            }
            Self::EventHandlerNotFound { handler_name, .. } => {
                format!("Handler d'événement '{}' introuvable", handler_name)
            }
            Self::EventEngineError { .. } => "Erreur du moteur d'événements".to_string(),
            Self::Internal { .. } => "Erreur interne du runtime".to_string(),
        };

        let details = match self {
            Self::DuplicateModule { id } => json!({ "module_id": id.as_str() }),
            Self::UnknownModule { id } => json!({ "module_id": id.as_str() }),
            Self::MissingDependency { module, dependency } => json!({
                "module_id": module.as_str(),
                "missing_dependency": dependency.as_str(),
            }),
            Self::DependencyCycle { cycle } => {
                let ids: Vec<&str> = cycle.iter().map(|m| m.as_str()).collect();
                json!({ "cycle": ids })
            }
            Self::InvalidStateTransition { module, from, to } => json!({
                "module_id": module.as_str(),
                "from_state": from.to_string(),
                "to_state": to.to_string(),
            }),
            Self::InstallFailure { module, message } => json!({
                "module_id": module.as_str(),
                "error": message,
            }),
            Self::StartFailure { module, message } => json!({
                "module_id": module.as_str(),
                "error": message,
            }),
            Self::StopFailure { module, message } => json!({
                "module_id": module.as_str(),
                "error": message,
            }),
            Self::Timeout {
                module,
                operation,
                duration,
            } => json!({
                "module_id": module.as_str(),
                "operation": operation,
                "duration_ms": duration.as_millis(),
            }),
            Self::InvalidManifest { message } => json!({ "validation_error": message }),
            Self::UnsupportedManifestVersion { version, supported } => json!({
                "manifest_version": version,
                "max_supported": supported,
            }),
            Self::InvalidModuleVersion { version, message } => json!({
                "version": version,
                "error": message,
            }),
            Self::SelfDependency { module } => json!({ "module_id": module.as_str() }),
            Self::DuplicateDependency { module, dependency } => json!({
                "module_id": module.as_str(),
                "duplicate_dependency": dependency.as_str(),
            }),
            Self::ManifestParseError { message } => json!({ "parse_error": message }),
            Self::InvalidMigrationId { id, reason } => json!({
                "migration_id": id,
                "reason": reason,
            }),
            Self::InvalidChecksum { expected, found } => json!({
                "expected_checksum": expected,
                "found_checksum": found,
            }),
            Self::ResourceNotFound { path } => json!({ "path": path }),
            Self::InvalidResourcePath { path, reason } => json!({
                "path": path,
                "reason": reason,
            }),
            Self::ResourceTooLarge {
                path,
                size,
                max_size,
            } => json!({
                "path": path,
                "size_bytes": size,
                "max_size_bytes": max_size,
            }),
            Self::ResourceEncodingError { path, message } => json!({
                "path": path,
                "error": message,
            }),
            Self::SchemaImportFailed {
                module,
                resource,
                message,
            } => json!({
                "module_id": module.as_str(),
                "resource": resource,
                "error": message,
            }),
            Self::MigrationDiscoveryFailed { module, message } => json!({
                "module_id": module.as_str(),
                "error": message,
            }),
            Self::MigrationChecksumMismatch {
                module,
                migration,
                expected,
                actual,
            } => json!({
                "module_id": module.as_str(),
                "migration_id": migration,
                "expected_checksum": expected,
                "actual_checksum": actual,
            }),
            Self::MigrationInterrupted { module, migration } => json!({
                "module_id": module.as_str(),
                "migration_id": migration,
                "state": "Applying",
            }),
            Self::MigrationExecutionFailed {
                module,
                migration,
                message,
            } => json!({
                "module_id": module.as_str(),
                "migration_id": migration,
                "error": message,
            }),
            Self::MigrationLockAcquireFailed { key, message } => json!({
                "lock_key": key,
                "error": message,
            }),
            Self::MigrationLockTimeout { key, duration_ms } => json!({
                "lock_key": key,
                "timeout_ms": duration_ms,
            }),
            Self::MigrationLockHeld {
                key,
                owner,
                expires_at,
            } => json!({
                "lock_key": key,
                "owner_node_id": owner,
                "expires_at": expires_at,
            }),
            Self::MigrationLeaseLost {
                key,
                owner,
                message,
            } => json!({
                "lock_key": key,
                "owner_node_id": owner,
                "error": message,
            }),
            Self::MigrationLeaseExpired { key, expired_at } => json!({
                "lock_key": key,
                "expired_at": expired_at,
            }),
            Self::MigrationLockNotOwner {
                key,
                caller,
                actual_owner,
            } => json!({
                "lock_key": key,
                "caller_node_id": caller,
                "actual_owner_node_id": actual_owner,
            }),
            Self::MigrationRecoveryRequired {
                module,
                migration,
                reason,
            } => json!({
                "module_id": module.as_str(),
                "migration_id": migration,
                "reason": reason,
            }),
            Self::ModuleImplementationMissing { module, version } => json!({
                "module_id": module.as_str(),
                "version": version,
            }),
            Self::RuntimeVersionIncompatible {
                module,
                required,
                actual,
            } => json!({
                "module_id": module.as_str(),
                "required_version": required,
                "actual_version": actual,
            }),
            Self::DependencyVersionIncompatible {
                module,
                dependency,
                required,
                actual,
            } => json!({
                "module_id": module.as_str(),
                "dependency_id": dependency.as_str(),
                "required_version": required,
                "actual_version": actual,
            }),
            Self::BatchDuplicateModule { module, versions } => json!({
                "module_id": module.as_str(),
                "conflicting_versions": versions,
            }),
            Self::BatchDependencyFailure {
                module,
                failed_dependency,
            } => json!({
                "module_id": module.as_str(),
                "failed_dependency": failed_dependency.as_str(),
            }),
            Self::ModuleInstallFailed {
                module,
                version,
                phase,
                cause,
            } => json!({
                "module_id": module.as_str(),
                "version": version,
                "phase": phase,
                "cause": cause,
            }),
            Self::ModuleNotInstalled { module } => json!({
                "module_id": module.as_str(),
            }),
            Self::InstallationLeaseAcquireFailed {
                module,
                version,
                message,
            } => json!({
                "module_id": module.as_str(),
                "version": version,
                "error": message,
            }),
            Self::InstallationLeaseTimeout { module, version } => json!({
                "module_id": module.as_str(),
                "version": version,
            }),
            Self::DesiredStateConflict { module, message } => json!({
                "module_id": module.as_str(),
                "conflict": message,
            }),
            Self::DesiredDuplicateModule { module } => json!({
                "module_id": module.as_str(),
            }),
            Self::UnsupportedDowngrade {
                module,
                current_version,
                desired_version,
            } => json!({
                "module_id": module.as_str(),
                "current_version": current_version,
                "desired_version": desired_version,
            }),
            Self::ReconciliationBlocked { module, reason } => json!({
                "module_id": module.as_str(),
                "reason": reason,
            }),
            Self::WorkerDuplicate { worker } => json!({
                "worker_id": worker,
            }),
            Self::WorkerNotFound { worker } => json!({
                "worker_id": worker,
            }),
            Self::WorkerInvalidTransition { worker, from, to } => json!({
                "worker_id": worker,
                "from_state": from,
                "to_state": to,
            }),
            Self::WorkerStartFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::WorkerStopFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::WorkerStopTimeout { worker, timeout_ms } => json!({
                "worker_id": worker,
                "timeout_ms": timeout_ms,
            }),
            Self::WorkerPanicked { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::WorkerFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::WorkerRestartExhausted { worker, retries } => json!({
                "worker_id": worker,
                "retries": retries,
            }),
            Self::WorkerStoreFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::EventHandlerNotFound {
                handler_name,
                event_type,
            } => json!({
                "handler_name": handler_name,
                "event_type": event_type,
            }),
            Self::EventEngineError { message } => json!({
                "error": message,
            }),
            Self::Internal { code, message } => json!({
                "code": code,
                "message": message,
            }),
        };

        LyxalError {
            code,
            message,
            label,
            description: None,
            resolution: None,
            category: "runtime".to_string(),
            severity: "error".to_string(),
            http_status: Some(500),
            retryable: false,
            documentation: json!({}),
            metadata: json!({}),
            details,
        }
    }

    /// Enveloppe un résultat dans le contrat `LyxalResult<T>`.
    pub fn into_lyxal_result<T>(self) -> LyxalResult<T> {
        LyxalResult {
            ok: false,
            data: None,
            error: Some(self.to_lyxal_error()),
        }
    }
}

impl From<RuntimeError> for LyxalCallError {
    fn from(err: RuntimeError) -> Self {
        LyxalCallError::Business(err.to_lyxal_error())
    }
}
