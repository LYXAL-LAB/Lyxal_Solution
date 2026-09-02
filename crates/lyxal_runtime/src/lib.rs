//! # Lyxal Runtime
//!
//! Le moteur d'orchestration et de cycle de vie officiel des modules pour Lyxal OS.
//!
//! Ce crate fournit le socle runtime découplé de la persistance, permettant de :
//! - Enregistrer et inspecter les modules via [`ModuleRegistry`] ;
//! - Définir et implémenter le contrat universel [`LyxalModule`] ;
//! - Analyser et valider les fichiers déclaratifs `manifest.toml` via [`ManifestParser`] et [`ModuleManifest`] ;
//! - Manipuler le modèle déclaratif de migration via [`MigrationDefinition`], [`MigrationId`], [`MigrationChecksum`] ;
//! - Découvrir et charger les ressources SurrealQL via [`ResourceProvider`] et [`FilesystemResourceProvider`] ;
//! - Importer les schémas dans l'ordre strict via [`SchemaImportPlan`] et [`SchemaImporter`] ;
//! - Coordonner et verrouiller les migrations distribuées via [`MigrationLeaseManager`], [`SurrealMigrationLeaseManager`] ;
//! - Planifier et exécuter les migrations via [`MigrationPlan`] et [`MigrationRunner`] ;
//! - Persister l'état système dans SurrealDB via [`RuntimeStore`], [`SurrealRuntimeStore`] ou [`MemoryRuntimeStore`] ;
//! - Résoudre le graphe de dépendances (DAG) et le tri topologique via [`DependencyResolver`] ;
//! - Gérer les transitions d'état et les timeouts via [`LifecycleManager`] ;
//! - Orchestrer le démarrage et l'arrêt ordonné via la façade [`LyxalRuntime`].

pub mod config;
pub mod context;
pub mod controller;
pub mod descriptor;
pub mod error;
pub mod event;
pub mod event_engine;
pub mod health;
pub mod lifecycle;
pub mod lock;
pub mod manifest;
pub mod migration;
pub mod module;
pub mod package;
pub mod reconciler;
pub mod registry;
pub mod resolver;
pub mod resource;
pub mod runtime;
pub mod schema;
pub mod store;
pub mod types;
pub mod worker;

// Re-exports pour une API publique ergonomique et unifiée
pub use config::RuntimeConfig;
pub use context::ModuleContext;
pub use controller::{
    ContinuousReconciliationController, ReconciliationBackoff, ReconciliationLoopConfig,
    ReconciliationReportSummary, RuntimeStatusSnapshot,
};
pub use descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
pub use error::RuntimeError;
pub use event::{
    HealthEvent, InstallationEvent, LifecycleEvent, MemoryRuntimeEventBus,
    MemoryRuntimeEventJournal, MigrationEvent, ModuleEvent, ReconciliationEvent, RuntimeEvent,
    RuntimeEventBus, RuntimeEventBusStats, RuntimeEventDraft, RuntimeEventFilter, RuntimeEventId,
    RuntimeEventJournal, RuntimeEventKind, RuntimeEventPayload, RuntimeEventSubscription,
    RuntimeSystemEvent, SubscriptionError, SurrealRuntimeEventJournal, SystemRuntimeEventRow,
    WorkerEvent,
};
pub use event_engine::{
    EventConsumerModule, EventEngineConfig, EventGarbageCollectorService, EventWorkerService,
};
pub use health::{
    chrono_now_string, GlobalHealthStatus, HealthCheckResult, HealthConfig, HealthEngine,
    HealthRegistry, HealthSnapshot, HealthStatus, HealthStore, HealthTransition, MemoryHealthStore,
    ModuleHealthCheck, SurrealHealthStore,
};
pub use lifecycle::LifecycleManager;
pub use lock::{
    AcquireInstallationLeaseResult, AcquireLeaseResult, InstallationLease,
    InstallationLeaseManager, InstallationLockKey, MemoryInstallationLeaseManager,
    MemoryMigrationLeaseManager, MigrationLease, MigrationLeaseManager, MigrationLockConfig,
    MigrationLockKey, MigrationRecoveryPolicy, NodeId, SurrealInstallationLeaseManager,
    SurrealMigrationLeaseManager,
};
pub use manifest::{
    ManifestParser, ManifestValidator, ModuleDependency, ModuleManifest, RuntimeRequirement,
    CURRENT_MANIFEST_VERSION,
};
pub use migration::{
    validate_migration_definitions, MigrationChecksum, MigrationDefinition, MigrationDiscovery,
    MigrationDryRunResult, MigrationId, MigrationPlan, MigrationPlanAction, MigrationPlanItem,
    MigrationRecord, MigrationRunResult, MigrationRunner, MigrationStatus,
};
pub use module::LyxalModule;
pub use package::{
    InstallationNature, InstallationPhase, ModuleBatchInstallationResult,
    ModuleInstallationOutcome, ModuleInstallationPlan, ModuleInstallationReport, ModuleInstaller,
    ModulePackage, ModuleReleaseStatus,
};
pub use reconciler::{
    ActionKind, ActionOutcome, ActionPrecondition, ActualRuntimeState, BlockerKind,
    ConvergenceStatus, DesiredModuleState, DesiredRuntimeState, DesiredStateOrigin, DriftItem,
    ModuleTargetState, NotAttemptedAction, ObservedModuleState, ReconciliationAction,
    ReconciliationActionFailure, ReconciliationBlocker, ReconciliationPlan, ReconciliationReason,
    ReconciliationReport, RuntimeDiffer, RuntimeObserver, RuntimeReconciler,
    SkippedRevalidationAction, SkippedRevalidationReason,
};
pub use registry::ModuleRegistry;
pub use resolver::DependencyResolver;
pub use resource::{
    FilesystemResourceProvider, ModuleResource, ResourceDiscovery, ResourceKind, ResourceProvider,
    DEFAULT_MAX_RESOURCE_SIZE,
};
pub use runtime::LyxalRuntime;
pub use schema::{SchemaImportPlan, SchemaImportResult, SchemaImporter};
pub use store::{
    MemoryRuntimeStore, RuntimeStore, StoredModule, StoredModuleRelease, SurrealRuntimeStore,
};
pub use types::{ModuleId, ModuleState};
pub use worker::{
    CancellationToken, LyxalWorker, MemoryWorkerStore, RestartPolicy, SurrealWorkerStore,
    WorkerBatchReport, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerExitReason,
    WorkerHandle, WorkerHealth, WorkerId, WorkerMetrics, WorkerOperationReport, WorkerRegistry,
    WorkerRestartBackoff, WorkerState, WorkerStore, WorkerStoreRow, WorkerSupervisor,
};
