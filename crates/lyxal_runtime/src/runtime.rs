use crate::config::RuntimeConfig;
use crate::context::ModuleContext;
use crate::controller::config::ReconciliationLoopConfig;
use crate::controller::controller::ContinuousReconciliationController;
use crate::error::RuntimeError;
use crate::event::bus::{MemoryRuntimeEventBus, RuntimeEventBus};
use crate::event::filter::RuntimeEventFilter;
use crate::event::journal::RuntimeEventJournal;
use crate::event::subscription::RuntimeEventSubscription;
use crate::event_engine::{
    EventConsumerModule, EventEngineConfig, EventGarbageCollectorService, EventWorkerService,
};
use crate::health::engine::{HealthConfig, HealthEngine};
use crate::health::registry::HealthRegistry;
use crate::health::store::HealthStore;
use crate::lifecycle::LifecycleManager;
use crate::lock::installation::InstallationLeaseManager;
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use crate::migration::runner::MigrationRunner;
use crate::module::LyxalModule;
use crate::package::installer::ModuleInstaller;
use crate::package::model::ModulePackage;
use crate::package::plan::ModuleInstallationPlan;
use crate::package::types::{ModuleBatchInstallationResult, ModuleInstallationReport};
use crate::reconciler::reconciler::RuntimeReconciler;
use crate::registry::ModuleRegistry;
use crate::resolver::DependencyResolver;
use crate::schema::importer::SchemaImporter;
use crate::store::RuntimeStore;
use crate::types::{ModuleId, ModuleState};
use crate::worker::registry::WorkerRegistry;
use crate::worker::store::WorkerStore;
use crate::worker::supervisor::WorkerSupervisor;
use crate::worker::LyxalWorker;
use lyxal_event::{
    Event, EventPublisher, EventStore, EventWorker, GarbageCollector, Handler, HandlerRegistry,
};
use std::collections::HashMap;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::sync::RwLock;

/// Façade principale orchestrant le registre, le graphe de dépendances, le cycle de vie, les workers et la persistance de Lyxal OS.
pub struct LyxalRuntime {
    registry: ModuleRegistry,
    lifecycle: Arc<LifecycleManager>,
    config: RuntimeConfig,
    store: Option<Arc<dyn RuntimeStore>>,
    client: Option<Surreal<Any>>,
    migration_lease_manager: Option<Arc<dyn MigrationLeaseManager>>,
    installation_lease_manager: Option<Arc<dyn InstallationLeaseManager>>,
    node_id: NodeId,
    health_registry: HealthRegistry,
    health_store: Option<Arc<dyn HealthStore>>,
    worker_registry: Arc<WorkerRegistry>,
    worker_supervisor: Arc<WorkerSupervisor>,
    worker_store: Option<Arc<dyn WorkerStore>>,
    event_bus: Arc<dyn RuntimeEventBus>,
    // Intégration du moteur d'événements (isolé par instance)
    event_config: EventEngineConfig,
    event_registry: Arc<RwLock<HandlerRegistry>>,
    event_consumers: Arc<RwLock<Vec<Arc<dyn EventConsumerModule>>>>,
    event_store: Option<Arc<EventStore>>,
    event_publisher: Option<Arc<EventPublisher>>,
}

impl Default for LyxalRuntime {
    fn default() -> Self {
        Self::new(RuntimeConfig::default())
    }
}

impl LyxalRuntime {
    /// Crée une nouvelle instance de LyxalRuntime avec la configuration spécifiée.
    pub fn new(config: RuntimeConfig) -> Self {
        let node_id = NodeId::generate();
        let event_bus: Arc<dyn RuntimeEventBus> =
            Arc::new(MemoryRuntimeEventBus::new(node_id.clone()));
        let lifecycle =
            Arc::new(LifecycleManager::new(config.clone()).with_event_bus(event_bus.clone()));
        let worker_registry = Arc::new(WorkerRegistry::new());
        let worker_supervisor = Arc::new(
            WorkerSupervisor::new(worker_registry.clone(), node_id.clone())
                .with_event_bus(event_bus.clone()),
        );

        Self {
            registry: ModuleRegistry::new(),
            lifecycle,
            config,
            store: None,
            client: None,
            migration_lease_manager: None,
            installation_lease_manager: None,
            node_id,
            health_registry: HealthRegistry::new(),
            health_store: None,
            worker_registry,
            worker_supervisor,
            worker_store: None,
            event_bus,
            event_config: EventEngineConfig::default(),
            event_registry: Arc::new(RwLock::new(HandlerRegistry::new())),
            event_consumers: Arc::new(RwLock::new(Vec::new())),
            event_store: None,
            event_publisher: None,
        }
    }

    /// Associe un bus d'événements personnalisé au runtime.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.lifecycle =
            Arc::new(LifecycleManager::new(self.config.clone()).with_event_bus(event_bus.clone()));
        self.worker_supervisor = Arc::new(
            WorkerSupervisor::new(self.worker_registry.clone(), self.node_id.clone())
                .with_event_bus(event_bus.clone()),
        );
        self.event_bus = event_bus;
        self
    }

    /// Associe un journal d'audit des événements au runtime.
    pub fn with_event_journal(self, journal: Arc<dyn RuntimeEventJournal>) -> Self {
        let bus = Arc::new(MemoryRuntimeEventBus::new(self.node_id.clone()).with_journal(journal));
        self.with_event_bus(bus)
    }

    /// Retourne une référence vers le bus d'événements officiel du runtime.
    pub fn event_bus(&self) -> &Arc<dyn RuntimeEventBus> {
        &self.event_bus
    }

    /// Crée une nouvelle souscription au flux d'événements filtré du runtime.
    pub fn subscribe(&self, filter: RuntimeEventFilter) -> RuntimeEventSubscription {
        self.event_bus.subscribe(filter)
    }

    /// Associe un registre de vérificateurs de santé au runtime.
    pub fn with_health_registry(mut self, registry: HealthRegistry) -> Self {
        self.health_registry = registry;
        self
    }

    /// Associe un magasin de santé persistant au runtime.
    pub fn with_health_store(mut self, store: Arc<dyn HealthStore>) -> Self {
        self.health_store = Some(store);
        self
    }

    /// Associe un magasin de persistance pour les workers au runtime.
    pub fn with_worker_store(mut self, store: Arc<dyn WorkerStore>) -> Self {
        self.worker_supervisor = Arc::new(
            WorkerSupervisor::new(self.worker_registry.clone(), self.node_id.clone())
                .with_store(store.clone()),
        );
        self.worker_store = Some(store);
        self
    }

    /// Retourne une référence vers le registre de santé.
    pub fn health_registry(&self) -> &HealthRegistry {
        &self.health_registry
    }

    /// Retourne une référence vers le registre de workers.
    pub fn worker_registry(&self) -> &WorkerRegistry {
        &self.worker_registry
    }

    /// Retourne une référence vers le superviseur de workers.
    pub fn worker_supervisor(&self) -> &WorkerSupervisor {
        &self.worker_supervisor
    }

    /// Enregistre un worker d'arrière-plan auprès du Runtime.
    pub fn register_worker(&self, worker: Arc<dyn LyxalWorker>) -> Result<(), RuntimeError> {
        self.worker_registry.register(worker)
    }

    /// Construit une instance de `HealthEngine` avec la configuration spécifiée.
    pub fn health_engine(&self, config: HealthConfig) -> HealthEngine {
        HealthEngine::new(self.health_registry.clone(), config)
            .with_worker_supervisor(self.worker_supervisor.clone())
    }

    /// Construit une instance de `ContinuousReconciliationController` configurée pour ce runtime.
    pub fn continuous_controller(
        &self,
        reconciler: Arc<RuntimeReconciler>,
        config: ReconciliationLoopConfig,
    ) -> ContinuousReconciliationController {
        let health_engine = Arc::new(self.health_engine(HealthConfig::default()));
        let mut controller = ContinuousReconciliationController::new(
            reconciler,
            health_engine,
            self.node_id.clone(),
            config,
        )
        .with_worker_supervisor(self.worker_supervisor.clone());

        if let Some(hs) = &self.health_store {
            controller = controller.with_health_store(hs.clone());
        }
        controller
    }

    /// Associe un `RuntimeStore` persistant au runtime.
    pub fn with_store(mut self, store: Arc<dyn RuntimeStore>) -> Self {
        self.store = Some(store);
        self
    }

    /// Associe un client SurrealDB au runtime et configure le moteur d'événements.
    pub fn with_client(mut self, client: Surreal<Any>) -> Self {
        let event_store = Arc::new(EventStore::new(client.clone()));
        let instance_id = self
            .event_config
            .worker_config
            .instance_id
            .clone()
            .unwrap_or_else(|| "default".to_string());
        let context = lyxal_event::EventContext::new(instance_id, "default", "default");
        let event_publisher = Arc::new(EventPublisher::new(
            event_store.clone(),
            "lyxal_runtime",
            context,
        ));
        self.client = Some(client);
        self.event_store = Some(event_store);
        self.event_publisher = Some(event_publisher);
        self
    }

    /// Associe une configuration spécifique pour le moteur d'événements.
    pub fn with_event_config(mut self, config: EventEngineConfig) -> Self {
        if let Some(store) = &self.event_store {
            let instance_id = config
                .worker_config
                .instance_id
                .clone()
                .unwrap_or_else(|| "default".to_string());
            let context = lyxal_event::EventContext::new(instance_id, "default", "default");
            self.event_publisher = Some(Arc::new(EventPublisher::new(
                store.clone(),
                "lyxal_runtime",
                context,
            )));
        }
        self.event_config = config;
        self
    }

    /// Retourne une référence vers le store d'événements s'il est configuré.
    pub fn event_store(&self) -> Option<&Arc<EventStore>> {
        self.event_store.as_ref()
    }

    /// Retourne une référence vers le publisher d'événements s'il est configuré.
    pub fn event_publisher(&self) -> Option<&Arc<EventPublisher>> {
        self.event_publisher.as_ref()
    }

    /// Retourne le registre de handlers de cette instance de runtime.
    pub fn event_registry(&self) -> &Arc<RwLock<HandlerRegistry>> {
        &self.event_registry
    }

    /// Enregistre un gestionnaire d'événements typé auprès de cette instance de Runtime.
    pub async fn register_event_handler<E: Event, H: Handler<E>>(
        &self,
        handler: H,
    ) -> Result<(), RuntimeError> {
        let mut registry = self.event_registry.write().await;
        registry
            .register(handler)
            .map_err(|e| RuntimeError::Internal {
                code: "EVENT_HANDLER_REGISTRATION_FAILED",
                message: e.to_string(),
            })?;
        Ok(())
    }

    /// Enregistre un module consommateur d'événements auprès de cette instance de Runtime.
    pub async fn register_event_consumer(&self, consumer: Arc<dyn EventConsumerModule>) {
        let mut consumers = self.event_consumers.write().await;
        consumers.push(consumer);
    }

    /// Déclenche la reprise manuelle des fan-outs en attente pour cette instance.
    pub async fn recover_pending_fanouts(&self, limit: usize) -> Result<usize, RuntimeError> {
        let store = self
            .event_store
            .as_ref()
            .ok_or_else(|| RuntimeError::Internal {
                code: "EVENT_STORE_MISSING",
                message: "EventStore is not configured on this runtime instance".to_string(),
            })?;
        store
            .recover_pending_fanouts(limit)
            .await
            .map_err(|e| RuntimeError::EventEngineError {
                message: format!("Failed to recover pending fan-outs: {e}"),
            })
    }

    /// Initialise et démarre le moteur d'événements pour l'instance.
    pub async fn init_event_engine(&self) -> Result<(), RuntimeError> {
        if !self.event_config.enabled {
            return Ok(());
        }

        let store = match &self.event_store {
            Some(s) => s.clone(),
            None => return Ok(()),
        };

        // 1. Initialisation des schémas et fonctions SurrealQL si activé
        if self.event_config.auto_init_schema {
            store
                .init_schema()
                .await
                .map_err(|e| RuntimeError::EventEngineError {
                    message: format!("Failed to initialize event schemas: {e}"),
                })?;
        }

        // 2. Reprise automatique des fan-outs en attente si activé
        if self.event_config.auto_recover_fanouts {
            let recovered = store
                .recover_pending_fanouts(self.event_config.recover_fanout_batch_size)
                .await
                .map_err(|e| RuntimeError::EventEngineError {
                    message: format!("Failed to recover pending fan-outs during startup: {e}"),
                })?;
            if recovered > 0 {
                tracing::info!(
                    recovered_count = recovered,
                    "Recovered pending event fan-outs during runtime startup"
                );
            }
        }

        // 3. Construction du registre de handlers pour cette instance isolée
        let mut registry = {
            let reg = self.event_registry.read().await;
            reg.clone()
        };

        // Enregistrement des handlers déclarés par les modules consommateurs
        {
            let consumers = self.event_consumers.read().await;
            for consumer in consumers.iter() {
                consumer.register_event_handlers(&mut registry)?;
            }
        }

        // 4. Instanciation des workers
        let worker_config = self.event_config.worker_config.clone();

        let event_worker = Arc::new(EventWorker::new(
            store.clone(),
            registry,
            worker_config.clone(),
        ));
        let gc = Arc::new(GarbageCollector::new(
            store.clone(),
            self.event_config.retention_days,
            self.event_config.gc_interval,
        ));

        let event_worker_service = Arc::new(EventWorkerService::new(
            event_worker,
            worker_config.dispatch_timeout,
        ));
        let gc_service = Arc::new(EventGarbageCollectorService::new(
            gc,
            std::time::Duration::from_secs(5),
        ));

        // Enregistrement auprès du WorkerRegistry
        let _ = self.worker_registry.register(event_worker_service);
        let _ = self.worker_registry.register(gc_service);

        Ok(())
    }

    /// Associe un gestionnaire de baux de migration.
    pub fn with_migration_lease_manager(mut self, manager: Arc<dyn MigrationLeaseManager>) -> Self {
        self.migration_lease_manager = Some(manager);
        self
    }

    /// Associe un gestionnaire de baux d'installation.
    pub fn with_installation_lease_manager(
        mut self,
        manager: Arc<dyn InstallationLeaseManager>,
    ) -> Self {
        self.installation_lease_manager = Some(manager);
        self
    }

    /// Définit l'identifiant du nœud d'exécution.
    pub fn with_node_id(mut self, node_id: NodeId) -> Self {
        self.node_id = node_id;
        self
    }

    /// Définit le `RuntimeStore` après instanciation.
    pub fn set_store(&mut self, store: Arc<dyn RuntimeStore>) {
        self.store = Some(store);
    }

    /// Retourne la référence au `RuntimeStore` s'il est configuré.
    pub fn store(&self) -> Option<&Arc<dyn RuntimeStore>> {
        self.store.as_ref()
    }

    /// Retourne une référence vers la configuration du runtime.
    pub fn config(&self) -> &RuntimeConfig {
        &self.config
    }

    /// Retourne une référence vers le registre de modules.
    pub fn registry(&self) -> &ModuleRegistry {
        &self.registry
    }

    /// Retourne une référence vers le gestionnaire de cycle de vie.
    pub fn lifecycle(&self) -> &Arc<LifecycleManager> {
        &self.lifecycle
    }

    /// Retourne une référence vers l'identifiant de ce nœud.
    pub fn node_id(&self) -> &NodeId {
        &self.node_id
    }

    /// Construit une instance de `ModuleInstaller` injectée avec les composants du Runtime.
    pub fn installer(&self) -> Result<ModuleInstaller, RuntimeError> {
        let store = self.store.clone().ok_or_else(|| RuntimeError::Internal {
            code: "RUNTIME_STORE_MISSING",
            message: "RuntimeStore is required to create a ModuleInstaller".to_string(),
        })?;

        let client = self.client.clone().ok_or_else(|| RuntimeError::Internal {
            code: "RUNTIME_CLIENT_MISSING",
            message: "SurrealDB client is required to create a ModuleInstaller".to_string(),
        })?;

        let schema_importer = SchemaImporter::new(client.clone());
        let mut migration_runner = MigrationRunner::new(store.clone(), client)
            .with_node_id(self.node_id.clone())
            .with_event_bus(self.event_bus.clone());

        if let Some(mig_lease_mgr) = &self.migration_lease_manager {
            migration_runner = migration_runner.with_lease_manager(mig_lease_mgr.clone());
        }

        Ok(ModuleInstaller::new(
            store,
            schema_importer,
            migration_runner,
            self.lifecycle.clone(),
            self.installation_lease_manager.clone(),
            self.node_id.clone(),
            self.config.clone(),
        )
        .with_event_bus(self.event_bus.clone()))
    }

    /// Construit le plan d'installation d'un package (Dry-Run pur, zéro mutation).
    pub async fn plan_package(
        &self,
        package: &ModulePackage,
    ) -> Result<ModuleInstallationPlan, RuntimeError> {
        let installer = self.installer()?;
        installer.plan_package(package, &HashMap::new()).await
    }

    /// Exécute l'installation complète d'un package de module.
    pub async fn install_package(
        &self,
        package: ModulePackage,
    ) -> Result<ModuleInstallationReport, RuntimeError> {
        if let Some(m) = package.module_impl() {
            let _ = self.register(m.clone());
        }
        let installer = self.installer()?;
        installer.execute_installation(package).await
    }

    /// Exécute l'installation ordonnée d'un batch de packages en respectant le DAG.
    pub async fn install_packages(
        &self,
        packages: Vec<ModulePackage>,
    ) -> Result<ModuleBatchInstallationResult, RuntimeError> {
        for pkg in &packages {
            if let Some(m) = pkg.module_impl() {
                let _ = self.register(m.clone());
            }
        }
        let installer = self.installer()?;
        installer.execute_batch(packages).await
    }

    /// Enregistre un module dans le runtime via un `Arc<dyn LyxalModule>`.
    pub fn register(&self, module: Arc<dyn LyxalModule>) -> Result<(), RuntimeError> {
        let id = module.id().clone();
        self.registry.register(module)?;
        self.lifecycle.register_state(id);
        Ok(())
    }

    /// Raccourci pour enregistrer directement une instance implémentant `LyxalModule`.
    pub fn register_module<M: LyxalModule>(&self, module: M) -> Result<(), RuntimeError> {
        self.register(Arc::new(module))
    }

    /// Valide l'arbre de dépendances et retourne l'ordre topologique de démarrage calculé.
    pub fn validate(&self) -> Result<Vec<ModuleId>, RuntimeError> {
        DependencyResolver::resolve(&self.registry)
    }

    /// Calcule l'ordre de démarrage topologique déterministe.
    pub fn start_order(&self) -> Result<Vec<ModuleId>, RuntimeError> {
        self.validate()
    }

    /// Retourne la liste des modules enregistrés.
    pub fn modules(&self) -> Vec<Arc<dyn LyxalModule>> {
        self.registry.modules()
    }

    /// Récupère l'état courant d'un module.
    pub fn module_state(&self, id: &ModuleId) -> Option<ModuleState> {
        self.lifecycle.get_state(id)
    }

    /// Récupère l'ensemble des états des modules sous forme de map.
    pub fn all_states(&self) -> HashMap<ModuleId, ModuleState> {
        self.lifecycle.all_states()
    }

    /// Démarre un module individuel préalablement installé.
    pub async fn start_module(&self, module_id: &ModuleId) -> Result<(), RuntimeError> {
        let module = self
            .registry
            .get(module_id)
            .ok_or_else(|| RuntimeError::UnknownModule {
                id: module_id.clone(),
            })?;

        // Vérifier que le module est bien dans l'état Installed ou Stopped
        let current_state = self
            .module_state(module_id)
            .unwrap_or(ModuleState::Registered);
        if current_state != ModuleState::Installed && current_state != ModuleState::Stopped {
            return Err(RuntimeError::InvalidStateTransition {
                module: module_id.clone(),
                from: current_state,
                to: ModuleState::Starting,
            });
        }

        // Vérifier que toutes ses dépendances directes sont en cours d'exécution
        let descriptor = module.descriptor();
        for dep in &descriptor.dependencies {
            let dep_state = self.module_state(dep).unwrap_or(ModuleState::Registered);
            if dep_state != ModuleState::Running {
                return Err(RuntimeError::StartFailure {
                    module: module_id.clone(),
                    message: format!(
                        "Dependency '{}' must be Running before starting '{}' (current state: {})",
                        dep, module_id, dep_state
                    ),
                });
            }
        }

        let ctx = ModuleContext::new(module_id.clone());
        self.lifecycle.start_module(&module, &ctx).await?;

        // Démarrer les workers déclarés pour ce module
        let _ = self
            .worker_supervisor
            .start_module_workers(module_id)
            .await?;

        Ok(())
    }

    /// Arrête un module individuel en arrêtant préalablement ses workers d'arrière-plan.
    pub async fn stop_module(&self, module_id: &ModuleId) -> Result<(), RuntimeError> {
        let module = self
            .registry
            .get(module_id)
            .ok_or_else(|| RuntimeError::UnknownModule {
                id: module_id.clone(),
            })?;

        // 1. Arrêter d'abord les workers supervisés avant d'invoquer module.stop() (Invariant No Zombie)
        let _ = self
            .worker_supervisor
            .stop_module_workers(module_id)
            .await?;

        // 2. Exécuter l'arrêt du cycle de vie du module
        let ctx = ModuleContext::new(module_id.clone());
        self.lifecycle.stop_module(&module, &ctx).await
    }

    /// Installe l'ensemble des modules enregistrés selon l'ordre topologique.
    pub async fn install_all(&self) -> Result<(), RuntimeError> {
        let order = self.validate()?;

        for module_id in order {
            if let Some(module) = self.registry.get(&module_id) {
                let ctx = ModuleContext::new(module_id.clone());
                self.lifecycle.install_module(&module, &ctx).await?;
            }
        }

        Ok(())
    }

    /// Démarre l'ensemble des modules et services d'arrière-plan enregistrés selon l'ordre topologique.
    pub async fn start_all(&self) -> Result<(), RuntimeError> {
        let order = self.validate()?;

        // 1. Initialiser le moteur d'événements et enregistrer ses workers supervisés
        self.init_event_engine().await?;

        // 2. Démarrer les modules dans l'ordre topologique et leurs workers respectifs
        for module_id in order {
            if let Some(module) = self.registry.get(&module_id) {
                let ctx = ModuleContext::new(module_id.clone());
                let state = self
                    .module_state(&module_id)
                    .unwrap_or(ModuleState::Registered);
                if state == ModuleState::Registered {
                    self.lifecycle.install_module(&module, &ctx).await?;
                }
                self.lifecycle.start_module(&module, &ctx).await?;

                let _ = self
                    .worker_supervisor
                    .start_module_workers(&module_id)
                    .await?;
            }
        }

        // 3. Démarrer l'ensemble des workers supervisés du runtime (dont EventWorker et GC)
        let _ = self.worker_supervisor.start_all().await?;

        Ok(())
    }

    /// Arrête l'ensemble des workers et modules enregistrés dans l'ordre strictement inverse du démarrage.
    pub async fn stop_all(&self) -> Result<(), RuntimeError> {
        let mut order = self.validate()?;
        order.reverse();

        // 1. Arrêter d'abord tous les workers supervisés de manière coopérative (Invariant No-Zombie)
        let _ = self.worker_supervisor.stop_all().await?;

        // 2. Arrêter ensuite les modules dans l'ordre inverse
        for module_id in order {
            if let Some(module) = self.registry.get(&module_id) {
                let ctx = ModuleContext::new(module_id.clone());
                self.lifecycle.stop_module(&module, &ctx).await?;
            }
        }

        Ok(())
    }
}
