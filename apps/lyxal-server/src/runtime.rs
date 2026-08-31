use crate::{
    config::{ModulesConfig, RuntimeConfig},
    error::ServerError,
    health::{HealthRegistry, HealthState},
    metrics::Metrics,
    modules::{LyxalModule, ModuleContext, ModuleDescriptor, ModuleId, ModuleState, SharedModule},
};
use axum::Router;
use serde::Serialize;
use std::{
    collections::{BTreeMap, BTreeSet},
    sync::Arc,
    time::Duration,
};
use surrealdb::sql::Thing;
use tokio::{sync::RwLock, time::timeout};

#[derive(Clone)]
pub struct RuntimeHandle {
    inner: Arc<RuntimeInner>,
}

struct RuntimeInner {
    modules: BTreeMap<ModuleId, SharedModule>,
    states: RwLock<BTreeMap<ModuleId, ModuleState>>,
    start_order: Vec<ModuleId>,
    config: RuntimeConfig,
    context: ModuleContext,
}

#[derive(Clone, Debug, Serialize)]
pub struct ModuleStatus {
    pub descriptor: ModuleDescriptor,
    pub state: ModuleState,
}

impl RuntimeHandle {
    pub fn build(
        available: Vec<Arc<dyn LyxalModule>>,
        selection: &ModulesConfig,
        config: RuntimeConfig,
        context: ModuleContext,
    ) -> Result<Self, ServerError> {
        let mut all = BTreeMap::new();
        for module in available {
            let id = module.descriptor().id;
            if all.insert(id.clone(), module).is_some() {
                return Err(ServerError::Runtime(format!(
                    "module déclaré plusieurs fois : {id}"
                )));
            }
        }

        let selected = select_modules(&all, selection)?;
        let start_order = topological_order(&selected)?;
        let states = start_order
            .iter()
            .cloned()
            .map(|id| (id, ModuleState::Discovered))
            .collect();

        Ok(Self {
            inner: Arc::new(RuntimeInner {
                modules: selected,
                states: RwLock::new(states),
                start_order,
                config,
                context,
            }),
        })
    }

    pub async fn install_and_start(&self) -> Result<(), ServerError> {
        for id in &self.inner.start_order {
            self.set_state(id, ModuleState::Validated).await;
        }

        for id in &self.inner.start_order {
            let module = self.module(id)?;
            self.set_state(id, ModuleState::Installing).await;

            if self.inner.config.run_migrations {
                self.run_migrations(&module).await?;
            }

            let install = timeout(
                Duration::from_secs(self.inner.config.module_start_timeout_seconds),
                module.install(&self.inner.context),
            )
            .await
            .map_err(|_| self.module_error(id, "délai d'installation dépassé"))?;

            if let Err(error) = install {
                self.fail(id, error.to_string()).await;
                if self.inner.config.fail_fast || module.descriptor().required {
                    return Err(error);
                }
                continue;
            }
            self.set_state(id, ModuleState::Installed).await;
        }

        for id in &self.inner.start_order {
            let module = self.module(id)?;
            self.set_state(id, ModuleState::Starting).await;

            let started = timeout(
                Duration::from_secs(self.inner.config.module_start_timeout_seconds),
                module.start(&self.inner.context),
            )
            .await
            .map_err(|_| self.module_error(id, "délai de démarrage dépassé"))?;

            match started {
                Ok(()) => {
                    self.set_state(id, ModuleState::Ready).await;
                    self.inner
                        .context
                        .health
                        .set(format!("module:{id}"), HealthState::Healthy, None)
                        .await;
                }
                Err(error) => {
                    self.fail(id, error.to_string()).await;
                    if self.inner.config.fail_fast || module.descriptor().required {
                        return Err(error);
                    }
                }
            }
        }
        Ok(())
    }

    pub async fn stop_all(&self) {
        for id in self.inner.start_order.iter().rev() {
            let state = self.state(id).await;
            if !matches!(state, Some(ModuleState::Ready | ModuleState::Starting)) {
                continue;
            }
            self.set_state(id, ModuleState::Stopping).await;
            let module = match self.module(id) {
                Ok(module) => module,
                Err(error) => {
                    tracing::error!(module = %id, %error, "module introuvable pendant l'arrêt");
                    continue;
                }
            };
            match timeout(
                Duration::from_secs(self.inner.config.module_stop_timeout_seconds),
                module.stop(&self.inner.context),
            )
            .await
            {
                Ok(Ok(())) => {
                    self.set_state(id, ModuleState::Stopped).await;
                    self.inner
                        .context
                        .health
                        .set(format!("module:{id}"), HealthState::Stopping, None)
                        .await;
                }
                Ok(Err(error)) => {
                    tracing::error!(module = %id, %error, "échec de l'arrêt du module");
                    self.fail(id, error.to_string()).await;
                }
                Err(_) => {
                    tracing::error!(module = %id, "délai d'arrêt dépassé");
                    self.fail(id, "délai d'arrêt dépassé".into()).await;
                }
            }
        }
    }

    pub fn router(&self) -> Router {
        self.inner
            .start_order
            .iter()
            .filter_map(|id| self.inner.modules.get(id))
            .fold(Router::new(), |router, module| router.merge(module.router()))
    }

    pub async fn statuses(&self) -> Vec<ModuleStatus> {
        let states = self.inner.states.read().await;
        self.inner
            .start_order
            .iter()
            .filter_map(|id| {
                self.inner.modules.get(id).map(|module| ModuleStatus {
                    descriptor: module.descriptor(),
                    state: states
                        .get(id)
                        .copied()
                        .unwrap_or(ModuleState::Discovered),
                })
            })
            .collect()
    }

    async fn run_migrations(&self, module: &SharedModule) -> Result<(), ServerError> {
        let descriptor = module.descriptor();
        for migration in module.migrations() {
            let key = format!("{}:{}", descriptor.id, migration.id);
            let existing: Option<Thing> = self
                .inner
                .context
                .database
                .select(("lyxal_module_migration", key.as_str()))
                .await
                .map_err(|error| ServerError::Database(error.to_string()))?;

            if existing.is_some() {
                continue;
            }

            self.inner
                .context
                .database
                .query("BEGIN TRANSACTION;")
                .query(&migration.query)
                .query(
                    "CREATE type::thing('lyxal_module_migration', $key) CONTENT {
                        module_id: $module_id,
                        migration_id: $migration_id,
                        checksum: $checksum,
                        applied_at: time::now()
                    };",
                )
                .bind(("key", key))
                .bind(("module_id", descriptor.id.to_string()))
                .bind(("migration_id", migration.id))
                .bind(("checksum", migration.checksum))
                .query("COMMIT TRANSACTION;")
                .await
                .map_err(|error| ServerError::Module {
                    module: descriptor.id.to_string(),
                    message: format!("migration échouée : {error}"),
                })?;
        }
        Ok(())
    }

    fn module(&self, id: &ModuleId) -> Result<SharedModule, ServerError> {
        self.inner
            .modules
            .get(id)
            .cloned()
            .ok_or_else(|| self.module_error(id, "module introuvable"))
    }

    fn module_error(&self, id: &ModuleId, message: impl Into<String>) -> ServerError {
        ServerError::Module {
            module: id.to_string(),
            message: message.into(),
        }
    }

    async fn set_state(&self, id: &ModuleId, state: ModuleState) {
        self.inner.states.write().await.insert(id.clone(), state);
    }

    async fn state(&self, id: &ModuleId) -> Option<ModuleState> {
        self.inner.states.read().await.get(id).copied()
    }

    async fn fail(&self, id: &ModuleId, message: String) {
        self.set_state(id, ModuleState::Failed).await;
        self.inner.context.metrics.module_failed();
        self.inner
            .context
            .health
            .set(
                format!("module:{id}"),
                HealthState::Unhealthy,
                Some(message),
            )
            .await;
    }
}

fn select_modules(
    all: &BTreeMap<ModuleId, SharedModule>,
    selection: &ModulesConfig,
) -> Result<BTreeMap<ModuleId, SharedModule>, ServerError> {
    let mut wanted = BTreeSet::new();

    if selection.enabled.is_empty() {
        wanted.extend(all.keys().cloned());
    } else {
        for id in &selection.enabled {
            wanted.insert(ModuleId::new(id.clone())?);
        }
    }
    for id in &selection.disabled {
        wanted.remove(&ModuleId::new(id.clone())?);
    }

    let mut changed = true;
    while changed {
        changed = false;
        let snapshot: Vec<_> = wanted.iter().cloned().collect();
        for id in snapshot {
            let module = all.get(&id).ok_or_else(|| {
                ServerError::Runtime(format!("module demandé mais non compilé : {id}"))
            })?;
            for dependency in module.descriptor().dependencies {
                if !wanted.contains(&dependency) {
                    if selection.disabled.contains(dependency.as_str()) {
                        return Err(ServerError::Runtime(format!(
                            "{id} dépend du module explicitement désactivé {dependency}"
                        )));
                    }
                    wanted.insert(dependency);
                    changed = true;
                }
            }
        }
    }

    wanted
        .into_iter()
        .map(|id| {
            all.get(&id)
                .cloned()
                .map(|module| (id.clone(), module))
                .ok_or_else(|| ServerError::Runtime(format!("module non compilé : {id}")))
        })
        .collect()
}

fn topological_order(
    modules: &BTreeMap<ModuleId, SharedModule>,
) -> Result<Vec<ModuleId>, ServerError> {
    fn visit(
        id: &ModuleId,
        modules: &BTreeMap<ModuleId, SharedModule>,
        temporary: &mut BTreeSet<ModuleId>,
        permanent: &mut BTreeSet<ModuleId>,
        output: &mut Vec<ModuleId>,
    ) -> Result<(), ServerError> {
        if permanent.contains(id) {
            return Ok(());
        }
        if !temporary.insert(id.clone()) {
            return Err(ServerError::Runtime(format!(
                "cycle de dépendances détecté autour de {id}"
            )));
        }
        let module = modules
            .get(id)
            .ok_or_else(|| ServerError::Runtime(format!("module absent : {id}")))?;
        for dependency in module.descriptor().dependencies {
            if !modules.contains_key(&dependency) {
                return Err(ServerError::Runtime(format!(
                    "{id} dépend de {dependency}, qui n'est pas sélectionné"
                )));
            }
            visit(&dependency, modules, temporary, permanent, output)?;
        }
        temporary.remove(id);
        permanent.insert(id.clone());
        output.push(id.clone());
        Ok(())
    }

    let mut temporary = BTreeSet::new();
    let mut permanent = BTreeSet::new();
    let mut output = Vec::new();

    for id in modules.keys() {
        visit(
            id,
            modules,
            &mut temporary,
            &mut permanent,
            &mut output,
        )?;
    }
    Ok(output)
}
