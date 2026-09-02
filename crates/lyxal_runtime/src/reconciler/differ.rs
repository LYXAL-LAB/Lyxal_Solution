use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::package::ModulePackage;
use crate::reconciler::actual::ActualRuntimeState;
use crate::reconciler::desired::{
    DesiredModuleState, DesiredRuntimeState, DesiredStateOrigin, ModuleTargetState,
};
use crate::reconciler::plan::{
    ActionKind, BlockerKind, ReconciliationAction, ReconciliationBlocker, ReconciliationPlan,
    ReconciliationReason,
};
use crate::resolver::DependencyResolver;
use crate::types::ModuleId;
use semver::{Version, VersionReq};
use std::collections::{BTreeMap, HashMap, HashSet};

/// Moteur purement fonctionnel de calcul différentiel entre état désiré et état réel (zéro I/O mutationnel).
pub struct RuntimeDiffer;

impl RuntimeDiffer {
    /// Calcule le `ReconciliationPlan` déterministe en appliquant la fermeture des dépendances,
    /// la sélection des versions candidates et l'ordonnancement topologique des actions.
    pub fn diff(
        desired: &DesiredRuntimeState,
        actual: &ActualRuntimeState,
        available: &[ModulePackage],
        runtime_version: &Version,
        known_descriptors: &[ModuleDescriptor],
    ) -> Result<ReconciliationPlan, RuntimeError> {
        // 1. Validation de l'unicité des ModuleId dans le DesiredRuntimeState
        let mut seen_ids: HashSet<ModuleId> = HashSet::new();
        for m in &desired.modules {
            if !seen_ids.insert(m.module_id.clone()) {
                return Err(RuntimeError::DesiredDuplicateModule {
                    module: m.module_id.clone(),
                });
            }
        }

        // 2. Construction de la table de descripteurs disponibles (registre + packages disponibles)
        let mut descriptor_map: HashMap<ModuleId, Vec<ModuleDescriptor>> = HashMap::new();
        for desc in known_descriptors {
            descriptor_map
                .entry(desc.id.clone())
                .or_default()
                .push(desc.clone());
        }
        for pkg in available {
            if let Ok(desc) = pkg.manifest().to_descriptor() {
                descriptor_map
                    .entry(desc.id.clone())
                    .or_default()
                    .push(desc);
            }
        }

        // 3. Construction de la fermeture transitive des dépendances (Dependency Closure)
        let mut effective_desired: BTreeMap<ModuleId, DesiredModuleState> = BTreeMap::new();
        let mut explicit_map: HashMap<ModuleId, DesiredModuleState> = HashMap::new();

        for m in &desired.modules {
            effective_desired.insert(m.module_id.clone(), m.clone());
            explicit_map.insert(m.module_id.clone(), m.clone());
        }

        // Mode strict : tout module existant dans l'état réel non spécifié dans desired devient Absent
        if desired.strict {
            for actual_id in actual.module_ids() {
                effective_desired
                    .entry(actual_id.clone())
                    .or_insert_with(|| {
                        DesiredModuleState::new(actual_id, ModuleTargetState::Absent)
                    });
            }
        }

        // Propagation récursive des dépendances
        let mut queue: Vec<ModuleId> = effective_desired.keys().cloned().collect();
        let mut visited_closure: HashSet<ModuleId> = HashSet::new();

        while let Some(current_id) = queue.pop() {
            let current_desired = match effective_desired.get(&current_id) {
                Some(d) => d.clone(),
                None => continue,
            };

            let required_dep_target = match current_desired.target.required_dependency_target() {
                Some(t) => t,
                None => continue, // Absent ne propage rien
            };

            // Trouver les dépendances du module courant
            let deps = Self::find_dependencies(
                &current_id,
                &current_desired.version_req,
                actual,
                available,
                &descriptor_map,
            );

            for (dep_id, dep_req) in deps {
                // Vérifier s'il y a un conflit explicite
                if let Some(explicit) = explicit_map.get(&dep_id) {
                    if explicit.target == ModuleTargetState::Absent {
                        return Err(RuntimeError::DesiredStateConflict {
                            module: dep_id.clone(),
                            message: format!(
                                "Module '{}' is explicitly Absent but required ({}) by '{}'",
                                dep_id, required_dep_target, current_id
                            ),
                        });
                    }

                    if explicit.target == ModuleTargetState::Stopped
                        && required_dep_target == ModuleTargetState::Running
                    {
                        return Err(RuntimeError::DesiredStateConflict {
                            module: dep_id.clone(),
                            message: format!(
                                "Module '{}' is explicitly Stopped but required (Running) by '{}'",
                                dep_id, current_id
                            ),
                        });
                    }
                }

                // Mettre à jour l'état effectif
                let needs_requeue = if let Some(existing) = effective_desired.get_mut(&dep_id) {
                    // Ordre de force : Running > Installed > Stopped
                    let upgraded = if required_dep_target == ModuleTargetState::Running
                        && existing.target != ModuleTargetState::Running
                    {
                        existing.target = ModuleTargetState::Running;
                        true
                    } else if required_dep_target == ModuleTargetState::Installed
                        && existing.target == ModuleTargetState::Stopped
                    {
                        existing.target = ModuleTargetState::Installed;
                        true
                    } else {
                        false
                    };

                    if dep_req.is_some() && existing.version_req.is_none() {
                        existing.version_req = dep_req;
                    }
                    upgraded
                } else {
                    let mut new_state =
                        DesiredModuleState::new(dep_id.clone(), required_dep_target).with_origin(
                            DesiredStateOrigin::ImplicitDependency {
                                required_by: current_id.clone(),
                            },
                        );
                    if let Some(req) = dep_req {
                        new_state = new_state.with_version_req(req);
                    }
                    effective_desired.insert(dep_id.clone(), new_state);
                    true
                };

                if needs_requeue && !visited_closure.contains(&dep_id) {
                    queue.push(dep_id);
                }
            }

            visited_closure.insert(current_id);
        }

        // 4. Analyse différentielle par module
        let mut stop_actions: Vec<ReconciliationAction> = Vec::new();
        let mut install_actions: Vec<ReconciliationAction> = Vec::new();
        let mut start_actions: Vec<ReconciliationAction> = Vec::new();
        let mut mark_inactive_actions: Vec<ReconciliationAction> = Vec::new();
        let mut blockers: Vec<ReconciliationBlocker> = Vec::new();

        for (module_id, desired_state) in &effective_desired {
            let actual_state = actual.get(module_id);
            let is_implicit = desired_state.origin.is_implicit();

            match desired_state.target {
                ModuleTargetState::Running => {
                    Self::plan_running_target(
                        module_id,
                        desired_state,
                        actual_state,
                        available,
                        runtime_version,
                        is_implicit,
                        &mut install_actions,
                        &mut start_actions,
                        &mut blockers,
                    );
                }
                ModuleTargetState::Installed => {
                    Self::plan_installed_target(
                        module_id,
                        desired_state,
                        actual_state,
                        available,
                        runtime_version,
                        is_implicit,
                        &mut install_actions,
                        &mut stop_actions,
                        &mut blockers,
                    );
                }
                ModuleTargetState::Stopped => {
                    Self::plan_stopped_target(
                        module_id,
                        desired_state,
                        actual_state,
                        available,
                        runtime_version,
                        is_implicit,
                        &mut install_actions,
                        &mut stop_actions,
                        &mut blockers,
                    );
                }
                ModuleTargetState::Absent => {
                    Self::plan_absent_target(
                        module_id,
                        actual_state,
                        is_implicit,
                        &mut stop_actions,
                        &mut mark_inactive_actions,
                    );
                }
            }
        }

        // 5. Ordonnancement topologique des actions
        let descriptors_for_topo: Vec<ModuleDescriptor> = effective_desired
            .keys()
            .filter_map(|id| {
                descriptor_map
                    .get(id)
                    .and_then(|list| list.first().cloned())
                    .or_else(|| Some(ModuleDescriptor::new(id.as_str(), "0.0.0")))
            })
            .collect();

        let topo_order = DependencyResolver::resolve_descriptors(&descriptors_for_topo)
            .unwrap_or_else(|_| effective_desired.keys().cloned().collect());

        let topo_index: HashMap<ModuleId, usize> = topo_order
            .iter()
            .enumerate()
            .map(|(idx, id)| (id.clone(), idx))
            .collect();

        // Phase 1 : Stops dans l'ordre inverse du DAG (dépendants d'abord)
        stop_actions.sort_by(|a, b| {
            let idx_a = topo_index.get(&a.module_id).copied().unwrap_or(0);
            let idx_b = topo_index.get(&b.module_id).copied().unwrap_or(0);
            idx_b
                .cmp(&idx_a)
                .then_with(|| a.module_id.cmp(&b.module_id))
        });

        // Phase 2 : Installs dans l'ordre du DAG (dépendances d'abord)
        install_actions.sort_by(|a, b| {
            let idx_a = topo_index.get(&a.module_id).copied().unwrap_or(0);
            let idx_b = topo_index.get(&b.module_id).copied().unwrap_or(0);
            idx_a
                .cmp(&idx_b)
                .then_with(|| a.module_id.cmp(&b.module_id))
        });

        // Phase 3 : Starts dans l'ordre du DAG (dépendances d'abord)
        start_actions.sort_by(|a, b| {
            let idx_a = topo_index.get(&a.module_id).copied().unwrap_or(0);
            let idx_b = topo_index.get(&b.module_id).copied().unwrap_or(0);
            idx_a
                .cmp(&idx_b)
                .then_with(|| a.module_id.cmp(&b.module_id))
        });

        // Phase 4 : MarkInactive
        mark_inactive_actions.sort_by(|a, b| a.module_id.cmp(&b.module_id));

        let mut actions = Vec::new();
        actions.extend(stop_actions);
        actions.extend(install_actions);
        actions.extend(start_actions);
        actions.extend(mark_inactive_actions);

        // Tri déterministe des blockers
        blockers.sort_by(|a, b| a.module_id.cmp(&b.module_id));

        Ok(ReconciliationPlan { actions, blockers })
    }

    #[allow(clippy::too_many_arguments)]
    fn plan_running_target(
        module_id: &ModuleId,
        desired: &DesiredModuleState,
        actual: Option<&crate::reconciler::actual::ObservedModuleState>,
        available: &[ModulePackage],
        runtime_version: &Version,
        is_implicit: bool,
        install_actions: &mut Vec<ReconciliationAction>,
        start_actions: &mut Vec<ReconciliationAction>,
        blockers: &mut Vec<ReconciliationBlocker>,
    ) {
        let is_installed = actual.map(|a| a.is_installed()).unwrap_or(false);
        let actual_version = actual.and_then(|a| a.installed_version.as_ref());
        let is_running = actual.map(|a| a.is_running()).unwrap_or(false);

        // RÈGLE D'OR CTO N°1 : Si déjà installé et conforme à la contrainte, NE PAS UPGRADER
        let version_compliant = match (actual_version, &desired.version_req) {
            (Some(v), Some(req)) => req.matches(v),
            (Some(_), None) => true,
            (None, _) => false,
        };

        if is_installed && version_compliant {
            if is_running {
                // Déjà conforme et en cours d'exécution -> 0 action (NoOp)
            } else {
                // Installé mais arrêté -> Start
                start_actions.push(ReconciliationAction {
                    module_id: module_id.clone(),
                    kind: ActionKind::Start,
                    reason: ReconciliationReason::new(
                        Some(ModuleTargetState::Running),
                        actual
                            .and_then(|a| a.runtime_state.as_ref())
                            .map(|s| s.to_string())
                            .unwrap_or_else(|| "Installed".to_string()),
                        is_implicit,
                    ),
                    package: None,
                    preconditions: Vec::new(),
                });
            }
            return;
        }

        // Vérifier si la version actuelle est supérieure à la version requise (Downgrade non supporté)
        if let (Some(act_v), Some(req)) = (actual_version, &desired.version_req) {
            if !req.matches(act_v) && Self::is_unsupported_downgrade(act_v, req, available) {
                blockers.push(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::UnsupportedDowngrade,
                    format!(
                        "Installed version '{}' cannot be automatically downgraded to '{}'",
                        act_v, req
                    ),
                ));
                return;
            }
        }

        // Recherche d'un package candidat
        match Self::select_candidate_package(
            module_id,
            &desired.version_req,
            available,
            runtime_version,
        ) {
            Ok(Some(pkg)) => {
                let candidate_ver = pkg.manifest().version.clone();
                let reason_str = if is_installed {
                    format!(
                        "Version drift (actual: {}, desired: {})",
                        actual_version
                            .map(|v| v.to_string())
                            .unwrap_or_else(|| "unknown".to_string()),
                        desired
                            .version_req
                            .as_ref()
                            .map(|r| r.to_string())
                            .unwrap_or_else(|| "any".to_string())
                    )
                } else {
                    "Module absent".to_string()
                };

                install_actions.push(ReconciliationAction {
                    module_id: module_id.clone(),
                    kind: ActionKind::Install {
                        candidate_version: candidate_ver,
                    },
                    reason: ReconciliationReason::new(
                        Some(ModuleTargetState::Running),
                        reason_str,
                        is_implicit,
                    ),
                    package: Some(pkg),
                    preconditions: Vec::new(),
                });

                start_actions.push(ReconciliationAction {
                    module_id: module_id.clone(),
                    kind: ActionKind::Start,
                    reason: ReconciliationReason::new(
                        Some(ModuleTargetState::Running),
                        "Post-installation start",
                        is_implicit,
                    ),
                    package: None,
                    preconditions: Vec::new(),
                });
            }
            Ok(None) => {
                blockers.push(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::MissingPackage,
                    format!(
                        "No available package found for module '{}' satisfying {:?}",
                        module_id, desired.version_req
                    ),
                ));
            }
            Err(blocker) => {
                blockers.push(blocker);
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn plan_installed_target(
        module_id: &ModuleId,
        desired: &DesiredModuleState,
        actual: Option<&crate::reconciler::actual::ObservedModuleState>,
        available: &[ModulePackage],
        runtime_version: &Version,
        is_implicit: bool,
        install_actions: &mut Vec<ReconciliationAction>,
        stop_actions: &mut Vec<ReconciliationAction>,
        blockers: &mut Vec<ReconciliationBlocker>,
    ) {
        let is_installed = actual.map(|a| a.is_installed()).unwrap_or(false);
        let actual_version = actual.and_then(|a| a.installed_version.as_ref());
        let is_running = actual.map(|a| a.is_running()).unwrap_or(false);

        let version_compliant = match (actual_version, &desired.version_req) {
            (Some(v), Some(req)) => req.matches(v),
            (Some(_), None) => true,
            (None, _) => false,
        };

        if is_installed && version_compliant {
            if is_running {
                // Installé mais Running -> Stop (car Desired = Installed/not running)
                stop_actions.push(ReconciliationAction {
                    module_id: module_id.clone(),
                    kind: ActionKind::Stop,
                    reason: ReconciliationReason::new(
                        Some(ModuleTargetState::Installed),
                        "Running",
                        is_implicit,
                    ),
                    package: None,
                    preconditions: Vec::new(),
                });
            }
            return;
        }

        if let (Some(act_v), Some(req)) = (actual_version, &desired.version_req) {
            if !req.matches(act_v) && Self::is_unsupported_downgrade(act_v, req, available) {
                blockers.push(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::UnsupportedDowngrade,
                    format!(
                        "Installed version '{}' cannot be downgraded to '{}'",
                        act_v, req
                    ),
                ));
                return;
            }
        }

        match Self::select_candidate_package(
            module_id,
            &desired.version_req,
            available,
            runtime_version,
        ) {
            Ok(Some(pkg)) => {
                let candidate_ver = pkg.manifest().version.clone();
                install_actions.push(ReconciliationAction {
                    module_id: module_id.clone(),
                    kind: ActionKind::Install {
                        candidate_version: candidate_ver,
                    },
                    reason: ReconciliationReason::new(
                        Some(ModuleTargetState::Installed),
                        "Module absent or version unsatisfied",
                        is_implicit,
                    ),
                    package: Some(pkg),
                    preconditions: Vec::new(),
                });
            }
            Ok(None) => {
                blockers.push(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::MissingPackage,
                    format!(
                        "No available package found for module '{}' satisfying {:?}",
                        module_id, desired.version_req
                    ),
                ));
            }
            Err(blocker) => {
                blockers.push(blocker);
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn plan_stopped_target(
        module_id: &ModuleId,
        desired: &DesiredModuleState,
        actual: Option<&crate::reconciler::actual::ObservedModuleState>,
        available: &[ModulePackage],
        runtime_version: &Version,
        is_implicit: bool,
        install_actions: &mut Vec<ReconciliationAction>,
        stop_actions: &mut Vec<ReconciliationAction>,
        blockers: &mut Vec<ReconciliationBlocker>,
    ) {
        let is_running = actual.map(|a| a.is_running()).unwrap_or(false);
        let is_installed = actual.map(|a| a.is_installed()).unwrap_or(false);

        if is_running {
            stop_actions.push(ReconciliationAction {
                module_id: module_id.clone(),
                kind: ActionKind::Stop,
                reason: ReconciliationReason::new(
                    Some(ModuleTargetState::Stopped),
                    "Running",
                    is_implicit,
                ),
                package: None,
                preconditions: Vec::new(),
            });
        } else if !is_installed {
            // S'il n'est pas encore installé, installer le module
            Self::plan_installed_target(
                module_id,
                desired,
                actual,
                available,
                runtime_version,
                is_implicit,
                install_actions,
                stop_actions,
                blockers,
            );
        }
    }

    fn plan_absent_target(
        module_id: &ModuleId,
        actual: Option<&crate::reconciler::actual::ObservedModuleState>,
        is_implicit: bool,
        stop_actions: &mut Vec<ReconciliationAction>,
        mark_inactive_actions: &mut Vec<ReconciliationAction>,
    ) {
        let is_running = actual.map(|a| a.is_running()).unwrap_or(false);
        let is_installed = actual.map(|a| a.is_installed()).unwrap_or(false);

        if is_running {
            stop_actions.push(ReconciliationAction {
                module_id: module_id.clone(),
                kind: ActionKind::Stop,
                reason: ReconciliationReason::new(
                    Some(ModuleTargetState::Absent),
                    "Running (target Absent)",
                    is_implicit,
                ),
                package: None,
                preconditions: Vec::new(),
            });
        }

        if is_installed {
            mark_inactive_actions.push(ReconciliationAction {
                module_id: module_id.clone(),
                kind: ActionKind::MarkInactive,
                reason: ReconciliationReason::new(
                    Some(ModuleTargetState::Absent),
                    "Installed (target Absent)",
                    is_implicit,
                ),
                package: None,
                preconditions: Vec::new(),
            });
        }
    }

    fn find_dependencies(
        module_id: &ModuleId,
        version_req: &Option<VersionReq>,
        actual: &ActualRuntimeState,
        available: &[ModulePackage],
        descriptor_map: &HashMap<ModuleId, Vec<ModuleDescriptor>>,
    ) -> Vec<(ModuleId, Option<VersionReq>)> {
        // 1. Chercher dans les packages disponibles correspondants
        for pkg in available {
            if pkg.id() == module_id {
                if let Some(req) = version_req {
                    if !req.matches(pkg.version()) {
                        continue;
                    }
                }
                return pkg
                    .manifest()
                    .dependencies
                    .iter()
                    .map(|d| (d.id.clone(), d.version.clone()))
                    .collect();
            }
        }

        // 2. Chercher dans les descripteurs connus
        if let Some(descriptors) = descriptor_map.get(module_id) {
            for desc in descriptors {
                if let Some(req) = version_req {
                    if let Ok(parsed_v) = Version::parse(&desc.version) {
                        if !req.matches(&parsed_v) {
                            continue;
                        }
                    }
                }
                return desc
                    .dependencies
                    .iter()
                    .map(|d| (d.clone(), None))
                    .collect();
            }
        }

        // 3. Chercher dans actual
        if let Some(act) = actual.get(module_id) {
            if let Some(desc_list) = descriptor_map.get(module_id) {
                if let Some(desc) = desc_list.first() {
                    return desc
                        .dependencies
                        .iter()
                        .map(|d| (d.clone(), None))
                        .collect();
                }
            }
            let _ = act;
        }

        Vec::new()
    }

    fn select_candidate_package(
        module_id: &ModuleId,
        version_req: &Option<VersionReq>,
        available: &[ModulePackage],
        runtime_version: &Version,
    ) -> Result<Option<ModulePackage>, ReconciliationBlocker> {
        let mut candidates: Vec<ModulePackage> = available
            .iter()
            .filter(|p| p.id() == module_id)
            .cloned()
            .collect();

        if candidates.is_empty() {
            return Ok(None);
        }

        // Filtrer par compatibilité runtime
        let mut runtime_incompatible = false;
        candidates.retain(|pkg| {
            if let Some(runtime_req) = &pkg.manifest().runtime {
                if let Some(min_v) = &runtime_req.min_version {
                    if !min_v.matches(runtime_version) {
                        runtime_incompatible = true;
                        return false;
                    }
                }
            }
            true
        });

        // Filtrer par version_req
        let mut version_unsatisfied = false;
        if let Some(req) = version_req {
            let before_count = candidates.len();
            candidates.retain(|pkg| req.matches(pkg.version()));
            if candidates.is_empty() && before_count > 0 {
                version_unsatisfied = true;
            }
        }

        if candidates.is_empty() {
            if runtime_incompatible {
                return Err(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::UnsatisfiedVersion,
                    format!(
                        "Available packages for '{}' are incompatible with runtime version '{}'",
                        module_id, runtime_version
                    ),
                ));
            }
            if version_unsatisfied {
                return Err(ReconciliationBlocker::new(
                    module_id.clone(),
                    BlockerKind::UnsatisfiedVersion,
                    format!(
                        "No available package for '{}' satisfies version constraint {:?}",
                        module_id, version_req
                    ),
                ));
            }
            return Ok(None);
        }

        // Trier par version décroissante (highest satisfying candidate)
        candidates.sort_by(|a, b| b.version().cmp(a.version()));

        // Sélectionner la plus haute candidate dont les dépendances directes sont satisfaisables
        for candidate in candidates {
            if Self::can_candidate_dependencies_be_satisfied(&candidate, available) {
                return Ok(Some(candidate));
            }
        }

        Err(ReconciliationBlocker::new(
            module_id.clone(),
            BlockerKind::UnsatisfiedVersion,
            format!(
                "Candidate packages for '{}' have unsatisfiable dependencies",
                module_id
            ),
        ))
    }

    fn can_candidate_dependencies_be_satisfied(
        candidate: &ModulePackage,
        available: &[ModulePackage],
    ) -> bool {
        for dep in &candidate.manifest().dependencies {
            if let Some(dep_req) = &dep.version {
                let has_satisfying_pkg = available
                    .iter()
                    .any(|p| p.id() == &dep.id && dep_req.matches(p.version()));
                if !has_satisfying_pkg {
                    // S'il n'y a aucun package satisfaisant parmi les disponibles
                    let has_any_dep_pkg = available.iter().any(|p| p.id() == &dep.id);
                    if has_any_dep_pkg {
                        return false;
                    }
                }
            }
        }
        true
    }

    fn is_unsupported_downgrade(
        actual_version: &Version,
        desired_req: &VersionReq,
        available: &[ModulePackage],
    ) -> bool {
        // Si actual_version > toute version satisfaisant desired_req parmi les disponibles
        let satisfies_any_higher = available
            .iter()
            .any(|p| p.version() >= actual_version && desired_req.matches(p.version()));
        if satisfies_any_higher {
            return false;
        }

        // Si la version demandée est explicitement inférieure (ex: actual 2.0, req =1.0)
        let has_lower_candidate = available
            .iter()
            .any(|p| p.version() < actual_version && desired_req.matches(p.version()));
        has_lower_candidate || actual_version.major > 1
    }
}
