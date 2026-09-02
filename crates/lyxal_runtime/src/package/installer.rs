use crate::context::ModuleContext;
use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{InstallationEvent, ModuleEvent, RuntimeEventPayload};
use crate::lifecycle::LifecycleManager;
use crate::lock::installation::{
    AcquireInstallationLeaseResult, InstallationLeaseManager, InstallationLockKey,
};
use crate::lock::node_id::NodeId;
use crate::manifest::validation::ManifestValidator;
use crate::migration::discovery::MigrationDiscovery;
use crate::migration::plan::MigrationPlan;
use crate::migration::runner::MigrationRunner;
use crate::package::model::ModulePackage;
use crate::package::plan::{InstallationNature, ModuleInstallationPlan};
use crate::package::types::{
    InstallationPhase, ModuleBatchInstallationResult, ModuleInstallationOutcome,
    ModuleInstallationReport, ModuleReleaseStatus,
};
use crate::resolver::DependencyResolver;
use crate::schema::importer::SchemaImporter;
use crate::schema::plan::SchemaImportPlan;
use crate::store::models::{StoredModule, StoredModuleRelease};
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use crate::RuntimeConfig;
use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::time::sleep;

/// Orchestrateur officiel du pipeline d'installation et d'intégration du cycle de vie Lyxal OS.
pub struct ModuleInstaller {
    store: Arc<dyn RuntimeStore>,
    schema_importer: SchemaImporter,
    migration_runner: MigrationRunner,
    lifecycle_manager: Arc<LifecycleManager>,
    installation_lease_manager: Option<Arc<dyn InstallationLeaseManager>>,
    node_id: NodeId,
    config: RuntimeConfig,
    lease_duration: Duration,
    acquire_timeout: Duration,
    acquire_retry_delay: Duration,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl ModuleInstaller {
    /// Crée une nouvelle instance de `ModuleInstaller` avec injection de toutes les dépendances requises.
    pub fn new(
        store: Arc<dyn RuntimeStore>,
        schema_importer: SchemaImporter,
        migration_runner: MigrationRunner,
        lifecycle_manager: Arc<LifecycleManager>,
        installation_lease_manager: Option<Arc<dyn InstallationLeaseManager>>,
        node_id: NodeId,
        config: RuntimeConfig,
    ) -> Self {
        Self {
            store,
            schema_importer,
            migration_runner,
            lifecycle_manager,
            installation_lease_manager,
            node_id,
            config,
            lease_duration: Duration::from_secs(30),
            acquire_timeout: Duration::from_secs(10),
            acquire_retry_delay: Duration::from_millis(50),
            event_bus: None,
        }
    }

    /// Attache un bus d'événements pour la publication des étapes d'installation.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    async fn emit(&self, module_id: &ModuleId, payload: InstallationEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Installation,
                RuntimeEventPayload::Installation(payload),
            )
            .with_module_id(module_id.clone());
            let _ = bus.publish(draft).await;
        }
    }

    async fn emit_module(&self, module_id: &ModuleId, payload: ModuleEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Module,
                RuntimeEventPayload::Module(payload),
            )
            .with_module_id(module_id.clone());
            let _ = bus.publish(draft).await;
        }
    }

    /// Modifie la durée de bail d'installation.
    pub fn with_lease_duration(mut self, duration: Duration) -> Self {
        self.lease_duration = duration;
        self
    }

    /// Modifie le délai maximal d'attente pour acquérir un bail d'installation.
    pub fn with_acquire_timeout(mut self, timeout: Duration) -> Self {
        self.acquire_timeout = timeout;
        self
    }

    /// Modifie l'intervalle entre deux tentatives d'acquisition d'un bail d'installation.
    pub fn with_acquire_retry_delay(mut self, delay: Duration) -> Self {
        self.acquire_retry_delay = delay;
        self
    }

    /// Construit le plan d'installation statique d'un package (Dry-Run pur, zéro mutation).
    pub async fn plan_package(
        &self,
        package: &ModulePackage,
        candidate_releases: &HashMap<ModuleId, semver::Version>,
    ) -> Result<ModuleInstallationPlan, RuntimeError> {
        let manifest = package.manifest();

        // 1. Validation statique du manifeste
        ManifestValidator::validate(manifest)?;

        // 2. Vérification de compatibilité de la version du Runtime
        if let Some(runtime_req) = &manifest.runtime {
            if let Some(min_req) = &runtime_req.min_version {
                if !min_req.matches(&self.config.runtime_version) {
                    return Err(RuntimeError::RuntimeVersionIncompatible {
                        module: package.id().clone(),
                        required: min_req.to_string(),
                        actual: self.config.runtime_version.to_string(),
                    });
                }
            }
        }

        // 3. Résolution des dépendances et de leurs contraintes de versions
        for dep in &manifest.dependencies {
            let candidate_ver = if let Some(cv) = candidate_releases.get(&dep.id) {
                Some(cv.clone())
            } else {
                let installed = self.store.list_releases(&dep.id).await?;
                installed
                    .into_iter()
                    .filter(|r| {
                        r.status == ModuleReleaseStatus::Installed.as_str()
                            || r.status == ModuleReleaseStatus::Active.as_str()
                    })
                    .filter_map(|r| semver::Version::parse(&r.version).ok())
                    .max()
            };

            match candidate_ver {
                Some(found_version) => {
                    if !dep.matches(&found_version) {
                        return Err(RuntimeError::DependencyVersionIncompatible {
                            module: package.id().clone(),
                            dependency: dep.id.clone(),
                            required: dep
                                .version
                                .as_ref()
                                .map(|v| v.to_string())
                                .unwrap_or_else(|| "*".to_string()),
                            actual: found_version.to_string(),
                        });
                    }
                }
                None => {
                    return Err(RuntimeError::MissingDependency {
                        module: package.id().clone(),
                        dependency: dep.id.clone(),
                    });
                }
            }
        }

        // 4. Détermination de la nature de l'installation et des états persistés
        let version_str = package.version().to_string();
        let existing_release = self.store.get_release(package.id(), &version_str).await?;

        let nature = match &existing_release {
            Some(rel) => {
                if rel.status == ModuleReleaseStatus::Installed.as_str()
                    || rel.status == ModuleReleaseStatus::Active.as_str()
                {
                    InstallationNature::AlreadyInstalled
                } else if rel.status == ModuleReleaseStatus::Failed.as_str()
                    && rel.installation_phase.as_deref()
                        == Some(InstallationPhase::InstallHook.as_str())
                {
                    InstallationNature::HookRecovery
                } else {
                    InstallationNature::FreshInstall
                }
            }
            None => {
                let all_releases = self.store.list_releases(package.id()).await?;
                if let Some(prev) = all_releases.into_iter().last() {
                    InstallationNature::UpgradeCandidate {
                        current_version: prev.version,
                    }
                } else {
                    InstallationNature::FreshInstall
                }
            }
        };

        let schema_required = match nature {
            InstallationNature::AlreadyInstalled | InstallationNature::HookRecovery => false,
            InstallationNature::FreshInstall | InstallationNature::UpgradeCandidate { .. } => true,
        };

        // 5. Planification du schéma et des migrations
        let schema_plan = if schema_required {
            Some(
                SchemaImportPlan::from_provider(package.id().clone(), package.provider().as_ref())
                    .await?,
            )
        } else {
            None
        };

        let discovered_migrations = MigrationDiscovery::discover_migrations(
            package.id(),
            &version_str,
            package.provider().as_ref(),
        )
        .await?;

        let migration_plan = MigrationPlan::from_definitions_and_store(
            package.id(),
            &version_str,
            &discovered_migrations,
            self.store.as_ref(),
        )
        .await?;

        Ok(ModuleInstallationPlan {
            module_id: package.id().clone(),
            version: package.version().clone(),
            nature,
            manifest: manifest.clone(),
            schema_required,
            schema_plan,
            migration_plan,
        })
    }

    /// Exécute l'installation complète d'un package individuel.
    pub async fn execute_installation(
        &self,
        package: ModulePackage,
    ) -> Result<ModuleInstallationReport, RuntimeError> {
        let start_time = Instant::now();
        let plan = self.plan_package(&package, &HashMap::new()).await?;

        // Si le module est déjà installé avec succès, idempotence immédiate
        if !plan.is_mutation_required() {
            return Ok(ModuleInstallationReport {
                module_id: package.id().clone(),
                version: package.version().to_string(),
                outcome: ModuleInstallationOutcome::AlreadyInstalled,
                duration_ms: start_time.elapsed().as_millis() as u64,
                schema_resources_count: 0,
                migrations_applied: 0,
                migrations_skipped: 0,
                phase: InstallationPhase::Complete,
            });
        }

        // Exigence stricte : une implémentation Rust LyxalModule est obligatoire pour exécuter l'installation
        let module_impl = match package.module_impl() {
            Some(m) => m.clone(),
            None => {
                return Err(RuntimeError::ModuleImplementationMissing {
                    module: package.id().clone(),
                    version: package.version().to_string(),
                });
            }
        };

        let lock_key =
            InstallationLockKey::new(package.id().clone(), package.version().to_string());

        // A. Acquisition du bail distribué d'installation global
        self.emit(
            package.id(),
            InstallationEvent::Started {
                version: package.version().clone(),
            },
        )
        .await;

        let acquired_lease = if let Some(lease_mgr) = &self.installation_lease_manager {
            let acquire_start = Instant::now();
            let lease = loop {
                match lease_mgr
                    .acquire(&lock_key, &self.node_id, self.lease_duration)
                    .await?
                {
                    AcquireInstallationLeaseResult::Acquired(l)
                    | AcquireInstallationLeaseResult::AlreadyOwned(l)
                    | AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => break l,
                    AcquireInstallationLeaseResult::HeldByOther { .. } => {
                        if acquire_start.elapsed() >= self.acquire_timeout {
                            return Err(RuntimeError::InstallationLeaseTimeout {
                                module: package.id().clone(),
                                version: package.version().to_string(),
                            });
                        }
                        sleep(self.acquire_retry_delay).await;
                    }
                }
            };

            // TOCTOU Revalidation après acquisition du bail
            let mut latest_release = self
                .store
                .get_release(package.id(), &package.version().to_string())
                .await?;

            if let Some(r) = &latest_release {
                if r.status == ModuleReleaseStatus::Installing.as_str() {
                    for _ in 0..60 {
                        sleep(Duration::from_millis(25)).await;
                        latest_release = self
                            .store
                            .get_release(package.id(), &package.version().to_string())
                            .await?;
                        if let Some(r2) = &latest_release {
                            if r2.status == ModuleReleaseStatus::Installed.as_str()
                                || r2.status == ModuleReleaseStatus::Active.as_str()
                            {
                                break;
                            }
                        }
                    }
                }
            } else {
                // Si la release n'est pas encore visible, faire une brève vérification
                for _ in 0..10 {
                    sleep(Duration::from_millis(25)).await;
                    latest_release = self
                        .store
                        .get_release(package.id(), &package.version().to_string())
                        .await?;
                    if latest_release.is_some() {
                        break;
                    }
                }
            }

            if let Some(r) = latest_release {
                if r.status == ModuleReleaseStatus::Installed.as_str()
                    || r.status == ModuleReleaseStatus::Active.as_str()
                {
                    let _ = lease_mgr.release(&lease).await;
                    return Ok(ModuleInstallationReport {
                        module_id: package.id().clone(),
                        version: package.version().to_string(),
                        outcome: ModuleInstallationOutcome::AlreadyInstalled,
                        duration_ms: start_time.elapsed().as_millis() as u64,
                        schema_resources_count: 0,
                        migrations_applied: 0,
                        migrations_skipped: 0,
                        phase: InstallationPhase::Complete,
                    });
                }
            }

            Some(lease)
        } else {
            None
        };

        // Enregistrement de l'état initial dans le LifecycleManager
        self.lifecycle_manager.register_state(package.id().clone());

        // B. Enregistrement persistant de l'identité du module et de la release (Phase: Registration)
        self.emit(
            package.id(),
            InstallationEvent::PhaseChanged {
                phase: InstallationPhase::Registration,
            },
        )
        .await;

        let stored_module =
            StoredModule::new(package.id().clone(), package.manifest().name.clone())
                .with_description(package.manifest().description.clone().unwrap_or_default());
        self.store.upsert_module(&stored_module).await?;

        self.emit_module(
            package.id(),
            ModuleEvent::Registered {
                version: package.version().to_string(),
                description: package.manifest().description.clone(),
            },
        )
        .await;

        let stored_release = StoredModuleRelease::new(
            package.id().clone(),
            package.version().to_string(),
            package.manifest().manifest_version,
            ModuleReleaseStatus::Installing.as_str(),
        )
        .with_description(package.manifest().description.clone().unwrap_or_default())
        .with_installation_phase(InstallationPhase::Registration.as_str());
        self.store.register_release(&stored_release).await?;

        // C. Importation du Schéma Baseline
        let mut schema_count = 0;
        if plan.schema_required {
            if let Some(schema_plan) = &plan.schema_plan {
                schema_count = schema_plan.resources().len();
                self.emit(
                    package.id(),
                    InstallationEvent::PhaseChanged {
                        phase: InstallationPhase::Schema,
                    },
                )
                .await;

                self.store
                    .update_release_status(
                        package.id(),
                        &package.version().to_string(),
                        ModuleReleaseStatus::Installing.as_str(),
                        Some(InstallationPhase::Schema.as_str()),
                    )
                    .await?;

                if let Err(err) = self.schema_importer.execute_plan(schema_plan).await {
                    let err_msg = err.to_string();
                    self.emit(
                        package.id(),
                        InstallationEvent::Failed {
                            version: package.version().clone(),
                            phase: InstallationPhase::Schema,
                            error_code: "RUNTIME_SCHEMA_IMPORT_FAILED".to_string(),
                            message: err_msg.clone(),
                        },
                    )
                    .await;

                    self.store
                        .update_release_status(
                            package.id(),
                            &package.version().to_string(),
                            ModuleReleaseStatus::Failed.as_str(),
                            Some(InstallationPhase::Schema.as_str()),
                        )
                        .await?;
                    if let (Some(mgr), Some(l)) =
                        (&self.installation_lease_manager, &acquired_lease)
                    {
                        let _ = mgr.release(l).await;
                    }
                    return Err(RuntimeError::ModuleInstallFailed {
                        module: package.id().clone(),
                        version: package.version().to_string(),
                        phase: InstallationPhase::Schema.to_string(),
                        cause: err_msg,
                    });
                }
            }
        }

        // D. Exécution des Migrations séquentielles
        self.emit(
            package.id(),
            InstallationEvent::PhaseChanged {
                phase: InstallationPhase::Migration,
            },
        )
        .await;

        self.store
            .update_release_status(
                package.id(),
                &package.version().to_string(),
                ModuleReleaseStatus::Installing.as_str(),
                Some(InstallationPhase::Migration.as_str()),
            )
            .await?;

        let mig_report = match self
            .migration_runner
            .execute_plan(&plan.migration_plan, package.provider().as_ref())
            .await
        {
            Ok(rep) => rep,
            Err(err) => {
                let err_msg = err.to_string();
                self.emit(
                    package.id(),
                    InstallationEvent::Failed {
                        version: package.version().clone(),
                        phase: InstallationPhase::Migration,
                        error_code: "RUNTIME_MIGRATION_FAILED".to_string(),
                        message: err_msg.clone(),
                    },
                )
                .await;

                self.store
                    .update_release_status(
                        package.id(),
                        &package.version().to_string(),
                        ModuleReleaseStatus::Failed.as_str(),
                        Some(InstallationPhase::Migration.as_str()),
                    )
                    .await?;
                if let (Some(mgr), Some(l)) = (&self.installation_lease_manager, &acquired_lease) {
                    let _ = mgr.release(l).await;
                }
                return Err(RuntimeError::ModuleInstallFailed {
                    module: package.id().clone(),
                    version: package.version().to_string(),
                    phase: InstallationPhase::Migration.to_string(),
                    cause: err_msg,
                });
            }
        };

        // E. Exécution du Hook Rust `LyxalModule::install()`
        self.emit(
            package.id(),
            InstallationEvent::PhaseChanged {
                phase: InstallationPhase::InstallHook,
            },
        )
        .await;

        self.store
            .update_release_status(
                package.id(),
                &package.version().to_string(),
                ModuleReleaseStatus::Installing.as_str(),
                Some(InstallationPhase::InstallHook.as_str()),
            )
            .await?;

        let ctx = ModuleContext::new(package.id().clone());
        if let Err(err) = self
            .lifecycle_manager
            .install_module(&module_impl, &ctx)
            .await
        {
            let err_msg = err.to_string();
            self.emit(
                package.id(),
                InstallationEvent::Failed {
                    version: package.version().clone(),
                    phase: InstallationPhase::InstallHook,
                    error_code: "RUNTIME_INSTALL_HOOK_FAILED".to_string(),
                    message: err_msg.clone(),
                },
            )
            .await;

            self.store
                .update_release_status(
                    package.id(),
                    &package.version().to_string(),
                    ModuleReleaseStatus::Failed.as_str(),
                    Some(InstallationPhase::InstallHook.as_str()),
                )
                .await?;
            if let (Some(mgr), Some(l)) = (&self.installation_lease_manager, &acquired_lease) {
                let _ = mgr.release(l).await;
            }
            return Err(RuntimeError::ModuleInstallFailed {
                module: package.id().clone(),
                version: package.version().to_string(),
                phase: InstallationPhase::InstallHook.to_string(),
                cause: err_msg,
            });
        }

        // F. Finalisation et Marquage `Installed`
        self.store
            .update_release_status(
                package.id(),
                &package.version().to_string(),
                ModuleReleaseStatus::Installed.as_str(),
                Some(InstallationPhase::Complete.as_str()),
            )
            .await?;

        // G. Libération du bail d'installation
        if let (Some(mgr), Some(l)) = (&self.installation_lease_manager, &acquired_lease) {
            let _ = mgr.release(l).await;
        }

        let outcome = match plan.nature {
            InstallationNature::FreshInstall => ModuleInstallationOutcome::Installed,
            InstallationNature::UpgradeCandidate { current_version } => {
                ModuleInstallationOutcome::Updated {
                    previous_version: current_version,
                }
            }
            InstallationNature::HookRecovery => ModuleInstallationOutcome::Recovered,
            InstallationNature::AlreadyInstalled => ModuleInstallationOutcome::AlreadyInstalled,
        };

        self.emit(
            package.id(),
            InstallationEvent::Completed {
                version: package.version().clone(),
                outcome: outcome.clone(),
            },
        )
        .await;

        Ok(ModuleInstallationReport {
            module_id: package.id().clone(),
            version: package.version().to_string(),
            outcome,
            duration_ms: start_time.elapsed().as_millis() as u64,
            schema_resources_count: schema_count,
            migrations_applied: mig_report.applied.len(),
            migrations_skipped: mig_report.skipped.len(),
            phase: InstallationPhase::Complete,
        })
    }

    /// Exécute l'installation groupée d'un batch de packages en respectant le DAG des dépendances.
    pub async fn execute_batch(
        &self,
        packages: Vec<ModulePackage>,
    ) -> Result<ModuleBatchInstallationResult, RuntimeError> {
        // 1. Détection des doublons du même ModuleId avec des versions conflictuelles
        let mut seen_modules: HashMap<ModuleId, Vec<String>> = HashMap::new();
        for pkg in &packages {
            seen_modules
                .entry(pkg.id().clone())
                .or_default()
                .push(pkg.version().to_string());
        }

        for (module_id, versions) in seen_modules {
            if versions.len() > 1 {
                return Err(RuntimeError::BatchDuplicateModule {
                    module: module_id,
                    versions,
                });
            }
        }

        // 2. Construction de la table des candidats effectifs du batch
        let mut candidate_map: HashMap<ModuleId, semver::Version> = HashMap::new();
        for pkg in &packages {
            candidate_map.insert(pkg.id().clone(), pkg.version().clone());
        }

        // 3. Validation et ordonnancement topologique via DependencyResolver
        let mut package_map: HashMap<ModuleId, ModulePackage> = HashMap::new();
        let mut descriptors: Vec<ModuleDescriptor> = Vec::new();

        for pkg in packages {
            let desc = pkg.manifest().to_descriptor()?;
            descriptors.push(desc);
            package_map.insert(pkg.id().clone(), pkg);
        }

        let sorted_ids = DependencyResolver::resolve_descriptors(&descriptors)?;

        // 4. Validation préalable de compatibilité sur l'ensemble du batch (Dry-Run complet)
        for id in &sorted_ids {
            if let Some(pkg) = package_map.get(id) {
                self.plan_package(pkg, &candidate_map).await?;
            }
        }

        // 5. Exécution ordonnée avec isolation des pannes
        let mut result = ModuleBatchInstallationResult::new();
        let mut failed_ids: HashSet<ModuleId> = HashSet::new();

        for id in sorted_ids {
            let pkg = package_map.remove(&id).expect("Package must exist in map");

            // Vérifier si une dépendance directe de ce module a échoué
            let failed_dep = pkg
                .manifest()
                .dependencies
                .iter()
                .find(|d| failed_ids.contains(&d.id));

            if let Some(dep) = failed_dep {
                result.not_attempted.push((id.clone(), dep.id.clone()));
                failed_ids.insert(id);
                continue;
            }

            match self.execute_installation(pkg).await {
                Ok(report) => match report.outcome {
                    ModuleInstallationOutcome::Installed
                    | ModuleInstallationOutcome::Updated { .. }
                    | ModuleInstallationOutcome::Recovered => {
                        result.installed.push(id);
                    }
                    ModuleInstallationOutcome::AlreadyInstalled => {
                        result.already_installed.push(id);
                    }
                },
                Err(err) => {
                    failed_ids.insert(id.clone());
                    result.failed.push((id, err));
                }
            }
        }

        Ok(result)
    }
}
