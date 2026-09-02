use crate::config::RuntimeConfig;
use crate::context::ModuleContext;
use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{LifecycleEvent, RuntimeEventPayload};
use crate::module::LyxalModule;
use crate::types::{ModuleId, ModuleState};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

/// Gestionnaire du cycle de vie des modules dans Lyxal OS.
///
/// Supervise les transitions d'état, applique les timeouts configurables et
/// orchestre les phases d'installation, de démarrage et d'arrêt.
pub struct LifecycleManager {
    states: RwLock<HashMap<ModuleId, ModuleState>>,
    config: RuntimeConfig,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl LifecycleManager {
    /// Crée un nouveau gestionnaire avec une configuration de runtime donnée.
    pub fn new(config: RuntimeConfig) -> Self {
        Self {
            states: RwLock::new(HashMap::new()),
            config,
            event_bus: None,
        }
    }

    /// Attache un bus d'événements pour la publication des transitions de cycle de vie.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    async fn emit(&self, module_id: &ModuleId, payload: LifecycleEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Lifecycle,
                RuntimeEventPayload::Lifecycle(payload),
            )
            .with_module_id(module_id.clone());
            let _ = bus.publish(draft).await;
        }
    }

    /// Enregistre l'état initial `Registered` pour un module donné.
    pub fn register_state(&self, module_id: ModuleId) {
        if let Ok(mut states) = self.states.write() {
            states.entry(module_id).or_insert(ModuleState::Registered);
        }
    }

    /// Retourne l'état courant d'un module.
    pub fn get_state(&self, module_id: &ModuleId) -> Option<ModuleState> {
        self.states.read().ok()?.get(module_id).cloned()
    }

    /// Retourne un snapshot de tous les états de modules.
    pub fn all_states(&self) -> HashMap<ModuleId, ModuleState> {
        match self.states.read() {
            Ok(guard) => (*guard).clone(),
            Err(_) => HashMap::new(),
        }
    }

    /// Exécute la phase d'installation pour un module individuel.
    pub async fn install_module(
        &self,
        module: &Arc<dyn LyxalModule>,
        ctx: &ModuleContext,
    ) -> Result<(), RuntimeError> {
        let id = module.id().clone();

        // 1. Validation de l'état actuel et transition vers Installing
        let current_state_before = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current = states.entry(id.clone()).or_insert(ModuleState::Registered);
            let next = ModuleState::Installing;

            if !current.can_transition_to(&next) {
                return Err(RuntimeError::InvalidStateTransition {
                    module: id,
                    from: current.clone(),
                    to: next,
                });
            }
            let from = current.clone();
            *current = next;
            from
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state_before,
                to: ModuleState::Installing,
            },
        )
        .await;

        // 2. Exécution protégée par timeout
        let result = tokio::time::timeout(self.config.install_timeout, module.install(ctx)).await;

        // 3. Mise à jour de l'état final
        let (current_state, final_state, op_result) = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current_state = states.get(&id).cloned().unwrap_or(ModuleState::Installing);

            match result {
                Ok(Ok(())) => {
                    states.insert(id.clone(), ModuleState::Installed);
                    (current_state, ModuleState::Installed, Ok(()))
                }
                Ok(Err(err)) => {
                    let err_msg = err.to_string();
                    let failed_state = ModuleState::failed(err_msg.clone(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (
                        current_state,
                        failed_state,
                        Err(RuntimeError::InstallFailure {
                            module: id.clone(),
                            message: err_msg,
                        }),
                    )
                }
                Err(_) => {
                    let timeout_err = RuntimeError::Timeout {
                        module: id.clone(),
                        operation: "install",
                        duration: self.config.install_timeout,
                    };
                    let failed_state =
                        ModuleState::failed(timeout_err.to_string(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (current_state, failed_state, Err(timeout_err))
                }
            }
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state,
                to: final_state,
            },
        )
        .await;

        op_result
    }

    /// Exécute la phase de démarrage pour un module individuel.
    pub async fn start_module(
        &self,
        module: &Arc<dyn LyxalModule>,
        ctx: &ModuleContext,
    ) -> Result<(), RuntimeError> {
        let id = module.id().clone();
        self.emit(&id, LifecycleEvent::StartRequested).await;

        // 1. Validation de l'état actuel et transition vers Starting
        let current_state_before = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current = states.entry(id.clone()).or_insert(ModuleState::Registered);
            let next = ModuleState::Starting;

            if !current.can_transition_to(&next) {
                return Err(RuntimeError::InvalidStateTransition {
                    module: id,
                    from: current.clone(),
                    to: next,
                });
            }
            let from = current.clone();
            *current = next;
            from
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state_before,
                to: ModuleState::Starting,
            },
        )
        .await;

        // 2. Exécution protégée par timeout
        let result = tokio::time::timeout(self.config.start_timeout, module.start(ctx)).await;

        // 3. Mise à jour de l'état final
        let (current_state, final_state, op_result, err_payload) = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current_state = states.get(&id).cloned().unwrap_or(ModuleState::Starting);

            match result {
                Ok(Ok(())) => {
                    states.insert(id.clone(), ModuleState::Running);
                    (current_state, ModuleState::Running, Ok(()), None)
                }
                Ok(Err(err)) => {
                    let err_msg = err.to_string();
                    let failed_state = ModuleState::failed(err_msg.clone(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (
                        current_state,
                        failed_state,
                        Err(RuntimeError::StartFailure {
                            module: id.clone(),
                            message: err_msg.clone(),
                        }),
                        Some(err_msg),
                    )
                }
                Err(_) => {
                    let timeout_err = RuntimeError::Timeout {
                        module: id.clone(),
                        operation: "start",
                        duration: self.config.start_timeout,
                    };
                    let err_msg = timeout_err.to_string();
                    let failed_state = ModuleState::failed(err_msg.clone(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (current_state, failed_state, Err(timeout_err), Some(err_msg))
                }
            }
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state,
                to: final_state,
            },
        )
        .await;

        if let Some(err_msg) = err_payload {
            self.emit(&id, LifecycleEvent::StartFailed { error: err_msg })
                .await;
        } else {
            self.emit(&id, LifecycleEvent::Started).await;
        }

        op_result
    }

    /// Exécute la phase d'arrêt pour un module individuel.
    pub async fn stop_module(
        &self,
        module: &Arc<dyn LyxalModule>,
        ctx: &ModuleContext,
    ) -> Result<(), RuntimeError> {
        let id = module.id().clone();
        self.emit(&id, LifecycleEvent::StopRequested).await;

        // 1. Validation de l'état actuel et transition vers Stopping
        let current_state_before = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current = states.entry(id.clone()).or_insert(ModuleState::Running);
            let next = ModuleState::Stopping;

            if !current.can_transition_to(&next) {
                return Err(RuntimeError::InvalidStateTransition {
                    module: id,
                    from: current.clone(),
                    to: next,
                });
            }
            let from = current.clone();
            *current = next;
            from
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state_before,
                to: ModuleState::Stopping,
            },
        )
        .await;

        // 2. Exécution protégée par timeout
        let result = tokio::time::timeout(self.config.stop_timeout, module.stop(ctx)).await;

        // 3. Mise à jour de l'état final
        let (current_state, final_state, op_result, err_payload) = {
            let mut states = self.states.write().map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock on module states".to_string(),
            })?;
            let current_state = states.get(&id).cloned().unwrap_or(ModuleState::Stopping);

            match result {
                Ok(Ok(())) => {
                    states.insert(id.clone(), ModuleState::Stopped);
                    (current_state, ModuleState::Stopped, Ok(()), None)
                }
                Ok(Err(err)) => {
                    let err_msg = err.to_string();
                    let failed_state = ModuleState::failed(err_msg.clone(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (
                        current_state,
                        failed_state,
                        Err(RuntimeError::StopFailure {
                            module: id.clone(),
                            message: err_msg.clone(),
                        }),
                        Some(err_msg),
                    )
                }
                Err(_) => {
                    let timeout_err = RuntimeError::Timeout {
                        module: id.clone(),
                        operation: "stop",
                        duration: self.config.stop_timeout,
                    };
                    let err_msg = timeout_err.to_string();
                    let failed_state = ModuleState::failed(err_msg.clone(), current_state.clone());
                    states.insert(id.clone(), failed_state.clone());
                    (current_state, failed_state, Err(timeout_err), Some(err_msg))
                }
            }
        };

        self.emit(
            &id,
            LifecycleEvent::StateChanged {
                from: current_state,
                to: final_state,
            },
        )
        .await;

        if let Some(err_msg) = err_payload {
            self.emit(&id, LifecycleEvent::StopFailed { error: err_msg })
                .await;
        } else {
            self.emit(&id, LifecycleEvent::Stopped).await;
        }

        op_result
    }
}
