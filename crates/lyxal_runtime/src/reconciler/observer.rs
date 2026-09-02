use crate::error::RuntimeError;
use crate::lifecycle::LifecycleManager;
use crate::package::types::ModuleReleaseStatus;
use crate::reconciler::actual::{ActualRuntimeState, ObservedModuleState};
use crate::registry::ModuleRegistry;
use crate::store::RuntimeStore;
use crate::types::{ModuleId, ModuleState};
use semver::Version;
use std::collections::HashMap;
use std::str::FromStr;
use std::sync::Arc;

/// Observateur de l'état réel du Runtime (I/O read-only pure, zéro mutation).
///
/// Responsable d'agréger les informations du `RuntimeStore`, du `ModuleRegistry`
/// et du `LifecycleManager` en une photographie déterministe `ActualRuntimeState`.
pub struct RuntimeObserver<'a> {
    store: Option<&'a Arc<dyn RuntimeStore>>,
    registry: &'a ModuleRegistry,
    lifecycle: &'a LifecycleManager,
}

impl<'a> RuntimeObserver<'a> {
    /// Crée un nouvel observateur avec les composants injectés.
    pub fn new(
        store: Option<&'a Arc<dyn RuntimeStore>>,
        registry: &'a ModuleRegistry,
        lifecycle: &'a LifecycleManager,
    ) -> Self {
        Self {
            store,
            registry,
            lifecycle,
        }
    }

    /// Observe l'état réel actuel et retourne une photographie structurée `ActualRuntimeState`.
    ///
    /// Cette opération est strictement read-only : elle ne modifie ni la base SurrealDB,
    /// ni le registre, ni les états du cycle de vie.
    pub async fn observe(&self) -> Result<ActualRuntimeState, RuntimeError> {
        let mut modules_map: HashMap<ModuleId, ObservedModuleState> = HashMap::new();

        // 1. Observation depuis le RuntimeStore persistant si présent
        if let Some(store) = self.store {
            let stored_modules = store.list_modules().await?;
            for stored_mod in stored_modules {
                let id = stored_mod.module_id;
                let releases = store.list_releases(&id).await?;

                // Trouver la release installée / active prioritaire (ou la plus récente)
                let mut installed_rel: Option<(Version, ModuleReleaseStatus)> = None;
                let mut fallback_rel: Option<(Version, ModuleReleaseStatus)> = None;

                for rel in releases {
                    let version = match Version::parse(&rel.version) {
                        Ok(v) => v,
                        Err(_) => continue,
                    };
                    let status = match ModuleReleaseStatus::from_str(&rel.status) {
                        Ok(s) => s,
                        Err(_) => continue,
                    };

                    if matches!(
                        status,
                        ModuleReleaseStatus::Installed | ModuleReleaseStatus::Active
                    ) {
                        match &installed_rel {
                            Some((best_v, _)) if version > *best_v => {
                                installed_rel = Some((version, status));
                            }
                            None => {
                                installed_rel = Some((version, status));
                            }
                            _ => {}
                        }
                    } else {
                        match &fallback_rel {
                            Some((best_v, _)) if version > *best_v => {
                                fallback_rel = Some((version, status));
                            }
                            None => {
                                fallback_rel = Some((version, status));
                            }
                            _ => {}
                        }
                    }
                }

                let (installed_version, release_status) = if let Some((v, s)) = installed_rel {
                    (Some(v), Some(s))
                } else if let Some((v, s)) = fallback_rel {
                    (Some(v), Some(s))
                } else {
                    (None, None)
                };

                modules_map.insert(
                    id.clone(),
                    ObservedModuleState {
                        module_id: id,
                        installed_version,
                        release_status,
                        runtime_state: None,
                        is_registered: false,
                    },
                );
            }
        }

        // 2. Observation du ModuleRegistry en mémoire
        for desc in self.registry.descriptors() {
            let id = desc.id.clone();
            let parsed_v = Version::parse(&desc.version).ok();
            let entry = modules_map
                .entry(id.clone())
                .or_insert_with(|| ObservedModuleState {
                    module_id: id.clone(),
                    installed_version: parsed_v.clone(),
                    release_status: None,
                    runtime_state: None,
                    is_registered: true,
                });

            entry.is_registered = true;
            if entry.installed_version.is_none() {
                entry.installed_version = parsed_v;
            }
        }

        // 3. Observation du LifecycleManager local
        let local_states = self.lifecycle.all_states();
        for (id, state) in local_states {
            let entry = modules_map
                .entry(id.clone())
                .or_insert_with(|| ObservedModuleState {
                    module_id: id.clone(),
                    installed_version: None,
                    release_status: None,
                    runtime_state: Some(state.clone()),
                    is_registered: false,
                });

            // Si le cycle de vie local indique Installed/Running/Stopped mais qu'aucun release_status n'était persisté
            if entry.release_status.is_none()
                && matches!(
                    state,
                    ModuleState::Installed | ModuleState::Running | ModuleState::Stopped
                )
            {
                entry.release_status = Some(ModuleReleaseStatus::Installed);
            }

            entry.runtime_state = Some(state);
        }

        Ok(ActualRuntimeState {
            modules: modules_map,
        })
    }
}
