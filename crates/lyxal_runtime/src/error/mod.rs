pub mod catalog;

pub use catalog::{RuntimeErrorInfo, RUNTIME_ERROR_CATALOG};

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

    #[error("Schema import failed for module '{module}', resource '{resource}': {message}")]
    SchemaImportFailed {
        module: ModuleId,
        resource: String,
        message: String,
    },

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

    #[error("Migration lease lost for key '{key}' (owner '{owner}'): {message}")]
    MigrationLeaseLost {
        key: String,
        owner: String,
        message: String,
    },

    /// Écriture refusée par la base : le bail n'est plus détenu par ce nœud dans cette génération.
    #[error("Lease '{key}' (owner '{owner}', generation {generation}) was fenced: write refused")]
    LeaseFenced {
        key: String,
        owner: String,
        generation: u64,
    },

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
        "Installation failed for module '{module}' (version '{version}') at phase '{phase}': {cause}"
    )]
    ModuleInstallFailed {
        module: ModuleId,
        version: String,
        phase: String,
        cause: String,
    },

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

    #[error("Worker '{worker}' failed: {message}")]
    WorkerFailed { worker: String, message: String },

    #[error("Worker store operation failed for '{worker}': {message}")]
    WorkerStoreFailed { worker: String, message: String },

    /// Échec d'un appel de persistance du runtime (`fn::runtime_*`).
    #[error("Runtime store operation '{operation}' failed: {message}")]
    StoreFailed {
        operation: &'static str,
        message: String,
    },

    #[error("Event engine error: {message}")]
    EventEngineError { message: String },

    #[error("Package for module '{module}' was not provided")]
    PackageMissing { module: ModuleId },

    #[error("A reconciliation pass is already running")]
    ReconciliationPassRunning,

    #[error("Invalid worker identifier '{id}': {reason}")]
    WorkerInvalidId { id: String, reason: String },

    /// Composant requis non configuré sur le runtime (store, client SurrealDB, store d'événements).
    #[error("Runtime component '{component}' is not configured")]
    StoreMissing { component: &'static str },

    #[error("Invalid runtime configuration: {message}")]
    ConfigInvalid { message: String },

    /// Verrou mémoire empoisonné par une panique d'une autre tâche.
    #[error("In-memory lock poisoned: {context}")]
    LockPoisoned { context: &'static str },

    #[error("A health check is already registered for module '{module}'")]
    HealthCheckerDuplicate { module: ModuleId },

    #[error("Unknown release status '{status}'")]
    InvalidReleaseStatus { status: String },
}

impl RuntimeError {
    /// Retourne le code d'erreur canonique Lyxal OS associé à cette erreur.
    pub fn code(&self) -> &'static str {
        self.info().code
    }

    /// Description de l'erreur, identique à sa définition dans `error/runtime.surql`.
    pub fn info(&self) -> &'static RuntimeErrorInfo {
        match self {
            Self::DuplicateModule { .. } => &catalog::DUPLICATE_MODULE,
            Self::UnknownModule { .. } => &catalog::UNKNOWN_MODULE,
            Self::MissingDependency { .. } => &catalog::MISSING_DEPENDENCY,
            Self::DependencyCycle { .. } => &catalog::DEPENDENCY_CYCLE,
            Self::InvalidStateTransition { .. } => &catalog::INVALID_STATE_TRANSITION,
            Self::InstallFailure { .. } => &catalog::INSTALL_FAILURE,
            Self::StartFailure { .. } => &catalog::START_FAILURE,
            Self::StopFailure { .. } => &catalog::STOP_FAILURE,
            Self::Timeout { .. } => &catalog::OPERATION_TIMEOUT,
            Self::InvalidManifest { .. } => &catalog::INVALID_MANIFEST,
            Self::UnsupportedManifestVersion { .. } => &catalog::UNSUPPORTED_MANIFEST_VERSION,
            Self::InvalidModuleVersion { .. } => &catalog::INVALID_MODULE_VERSION,
            Self::SelfDependency { .. } => &catalog::SELF_DEPENDENCY,
            Self::DuplicateDependency { .. } => &catalog::DUPLICATE_DEPENDENCY,
            Self::ManifestParseError { .. } => &catalog::MANIFEST_PARSE_ERROR,
            Self::InvalidMigrationId { .. } => &catalog::INVALID_MIGRATION_ID,
            Self::InvalidChecksum { .. } => &catalog::INVALID_CHECKSUM,
            Self::ResourceNotFound { .. } => &catalog::RESOURCE_NOT_FOUND,
            Self::SchemaImportFailed { .. } => &catalog::SCHEMA_IMPORT_FAILED,
            Self::MigrationChecksumMismatch { .. } => &catalog::MIGRATION_CHECKSUM_MISMATCH,
            Self::MigrationInterrupted { .. } => &catalog::MIGRATION_INTERRUPTED,
            Self::MigrationExecutionFailed { .. } => &catalog::MIGRATION_EXECUTION_FAILED,
            Self::MigrationLockAcquireFailed { .. } => &catalog::MIGRATION_LOCK_ACQUIRE_FAILED,
            Self::MigrationLockTimeout { .. } => &catalog::MIGRATION_LOCK_TIMEOUT,
            Self::MigrationLeaseLost { .. } => &catalog::MIGRATION_LEASE_LOST,
            Self::LeaseFenced { .. } => &catalog::LEASE_FENCED,
            Self::MigrationLockNotOwner { .. } => &catalog::MIGRATION_LOCK_NOT_OWNER,
            Self::MigrationRecoveryRequired { .. } => &catalog::MIGRATION_RECOVERY_REQUIRED,
            Self::ModuleImplementationMissing { .. } => &catalog::MODULE_IMPLEMENTATION_MISSING,
            Self::RuntimeVersionIncompatible { .. } => &catalog::VERSION_INCOMPATIBLE,
            Self::DependencyVersionIncompatible { .. } => &catalog::DEPENDENCY_VERSION_INCOMPATIBLE,
            Self::BatchDuplicateModule { .. } => &catalog::BATCH_DUPLICATE_MODULE,
            Self::PackageMissing { .. } => &catalog::PACKAGE_MISSING,
            Self::ModuleInstallFailed { .. } => &catalog::MODULE_INSTALL_FAILED,
            Self::InstallationLeaseAcquireFailed { .. } => {
                &catalog::INSTALLATION_LEASE_ACQUIRE_FAILED
            }
            Self::InstallationLeaseTimeout { .. } => &catalog::INSTALLATION_LEASE_TIMEOUT,
            Self::DesiredStateConflict { .. } => &catalog::DESIRED_STATE_CONFLICT,
            Self::DesiredDuplicateModule { .. } => &catalog::DESIRED_DUPLICATE_MODULE,
            Self::ReconciliationPassRunning { .. } => &catalog::RECONCILIATION_PASS_RUNNING,
            Self::WorkerDuplicate { .. } => &catalog::WORKER_DUPLICATE,
            Self::WorkerNotFound { .. } => &catalog::WORKER_NOT_FOUND,
            Self::WorkerInvalidId { .. } => &catalog::WORKER_INVALID_ID,
            Self::WorkerInvalidTransition { .. } => &catalog::WORKER_INVALID_TRANSITION,
            Self::WorkerStartFailed { .. } => &catalog::WORKER_START_FAILED,
            Self::WorkerStopFailed { .. } => &catalog::WORKER_STOP_FAILED,
            Self::WorkerFailed { .. } => &catalog::WORKER_FAILED,
            Self::WorkerStoreFailed { .. } => &catalog::WORKER_STORE_FAILED,
            Self::StoreFailed { .. } => &catalog::STORE_FAILED,
            Self::StoreMissing { .. } => &catalog::STORE_MISSING,
            Self::ConfigInvalid { .. } => &catalog::CONFIG_INVALID,
            Self::LockPoisoned { .. } => &catalog::LOCK_POISONED,
            Self::HealthCheckerDuplicate { .. } => &catalog::HEALTH_CHECKER_DUPLICATE,
            Self::InvalidReleaseStatus { .. } => &catalog::INVALID_RELEASE_STATUS,
            Self::EventEngineError { .. } => &catalog::EVENT_ENGINE_ERROR,
        }
    }

    /// Convertit l'erreur Runtime en `LyxalError` conforme à la charte d'architecture.
    pub fn to_lyxal_error(&self) -> LyxalError {
        let code = self.code().to_string();
        let message = self.to_string();
        let info = self.info();

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
            Self::SchemaImportFailed {
                module,
                resource,
                message,
            } => json!({
                "module_id": module.as_str(),
                "resource": resource,
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
            Self::LeaseFenced {
                key,
                owner,
                generation,
            } => json!({
                "lock_key": key,
                "owner_node_id": owner,
                "generation": generation,
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
            Self::WorkerFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::StoreFailed { operation, message } => json!({
                "operation": operation,
                "error": message,
            }),
            Self::WorkerStoreFailed { worker, message } => json!({
                "worker_id": worker,
                "error": message,
            }),
            Self::EventEngineError { message } => json!({
                "error": message,
            }),
            Self::PackageMissing { module } => json!({ "module_id": module.as_str() }),
            Self::ReconciliationPassRunning => json!({}),
            Self::WorkerInvalidId { id, reason } => json!({
                "worker_id": id,
                "reason": reason,
            }),
            Self::StoreMissing { component } => json!({ "component": component }),
            Self::ConfigInvalid { message } => json!({ "error": message }),
            Self::LockPoisoned { context } => json!({ "context": context }),
            Self::HealthCheckerDuplicate { module } => json!({ "module_id": module.as_str() }),
            Self::InvalidReleaseStatus { status } => json!({ "status": status }),
        };

        LyxalError {
            code,
            message,
            label: info.label.to_string(),
            description: None,
            resolution: None,
            category: info.category.to_string(),
            severity: "error".to_string(),
            http_status: Some(info.http_status),
            retryable: info.retryable,
            documentation: json!({}),
            metadata: json!({}),
            details,
        }
    }

    /// Enveloppe un résultat dans le contrat `LyxalResult<T>`.
    pub fn into_lyxal_result<T: lyxal_surreal::SurrealValue>(self) -> LyxalResult<T> {
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
