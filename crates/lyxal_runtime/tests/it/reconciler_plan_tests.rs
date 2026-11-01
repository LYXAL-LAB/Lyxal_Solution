use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lifecycle::LifecycleManager;
use lyxal_runtime::manifest::model::{
    ModuleDependency, RuntimeRequirement, CURRENT_MANIFEST_VERSION,
};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::package::types::ModuleReleaseStatus;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::reconciler::actual::{ActualRuntimeState, ObservedModuleState};
use lyxal_runtime::reconciler::desired::DesiredRuntimeState;
use lyxal_runtime::reconciler::differ::RuntimeDiffer;
use lyxal_runtime::reconciler::observer::RuntimeObserver;
use lyxal_runtime::reconciler::plan::{ActionKind, BlockerKind};
use lyxal_runtime::registry::ModuleRegistry;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::store::memory::MemoryRuntimeStore;
use lyxal_runtime::store::models::{StoredModule, StoredModuleRelease};
use lyxal_runtime::store::traits::RuntimeStore;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::RuntimeConfig;
use semver::{Version, VersionReq};
use std::sync::Arc;

struct DummyResourceProvider;

#[async_trait::async_trait]
impl ResourceProvider for DummyResourceProvider {
    async fn read_resource(&self, path: &str) -> Result<ModuleResource, RuntimeError> {
        Ok(ModuleResource::new(
            path,
            ResourceKind::Tables,
            "DEFINE TABLE test SCHEMALESS;",
        ))
    }
    async fn list_resources(&self, _prefix: &str) -> Result<Vec<String>, RuntimeError> {
        Ok(Vec::new())
    }
    async fn exists(&self, _path: &str) -> bool {
        true
    }
}

fn make_package(id: &str, version: &str, deps: Vec<(&str, Option<&str>)>) -> ModulePackage {
    let dependencies = deps
        .into_iter()
        .map(|(dep_id, req)| {
            if let Some(r) = req {
                ModuleDependency::with_version(dep_id, VersionReq::parse(r).unwrap())
            } else {
                ModuleDependency::new(dep_id)
            }
        })
        .collect();

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new(id),
        name: format!("Module {}", id),
        version: Version::parse(version).unwrap(),
        description: None,
        runtime: None,
        dependencies,
        capabilities: Vec::new(),
    };

    ModulePackage::new(manifest, Arc::new(DummyResourceProvider))
}

fn make_package_with_runtime(id: &str, version: &str, min_runtime: &str) -> ModulePackage {
    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new(id),
        name: format!("Module {}", id),
        version: Version::parse(version).unwrap(),
        description: None,
        runtime: Some(RuntimeRequirement {
            min_version: Some(VersionReq::parse(min_runtime).unwrap()),
        }),
        dependencies: Vec::new(),
        capabilities: Vec::new(),
    };

    ModulePackage::new(manifest, Arc::new(DummyResourceProvider))
}

#[test]
fn test_compatible_installed_version_is_not_upgraded() {
    let runtime_version = Version::parse("0.1.0").unwrap();

    // Actual: timezone 1.4.0 Running
    let mut actual = ActualRuntimeState::new();
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-timezone"),
        installed_version: Some(Version::parse("1.4.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    });

    // Desired: timezone >=1.2.0,<2.0.0 Running
    let desired = DesiredRuntimeState::new().running_version(
        "lyxal-timezone",
        VersionReq::parse(">=1.2.0,<2.0.0").unwrap(),
    );

    // Available: 1.5.0 et 1.8.0
    let pkg_15 = make_package("lyxal-timezone", "1.5.0", vec![]);
    let pkg_18 = make_package("lyxal-timezone", "1.8.0", vec![]);
    let available = vec![pkg_15, pkg_18];

    let desc = ModuleDescriptor::new("lyxal-timezone", "1.4.0");

    let plan =
        RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[desc]).unwrap();

    // RÈGLE CTO N°1 : La version 1.4.0 satisfait déjà la contrainte, AUCUN upgrade n'est planifié !
    assert!(
        plan.actions.is_empty(),
        "Expected 0 actions when state is already compliant, got {:?}",
        plan.actions
    );
    assert!(plan.blockers.is_empty());
    assert!(plan.is_converged());
}

#[test]
fn test_installed_dependency_closure_does_not_force_running() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    // Desired: calendar = Installed (pas Running)
    let desired = DesiredRuntimeState::new().installed("lyxal-calendar");

    // calendar dépend de timezone
    let pkg_cal = make_package("lyxal-calendar", "1.0.0", vec![("lyxal-timezone", None)]);
    let pkg_tz = make_package("lyxal-timezone", "1.0.0", vec![]);
    let available = vec![pkg_cal, pkg_tz];

    let plan = RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap();

    // RÈGLE CTO N°3 : calendar Installed ne doit PAS forcer timezone à être Running !
    // Seuls des Installs doivent être prévus, AUCUN Start !
    let has_any_start = plan
        .actions
        .iter()
        .any(|a| matches!(a.kind, ActionKind::Start));
    assert!(
        !has_any_start,
        "Installed target must not produce Start actions for dependencies"
    );
    assert_eq!(plan.actions.len(), 2); // Install timezone + Install calendar
}

#[test]
fn test_stopped_explicit_dependency_conflicts_with_running_parent() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    // Desired : booking Running ET timezone Stopped (alors que booking dépend de timezone)
    let desired = DesiredRuntimeState::new()
        .running("lyxal-booking")
        .stopped("lyxal-timezone");

    let pkg_booking = make_package("lyxal-booking", "1.0.0", vec![("lyxal-calendar", None)]);
    let pkg_cal = make_package("lyxal-calendar", "1.0.0", vec![("lyxal-timezone", None)]);
    let pkg_tz = make_package("lyxal-timezone", "1.0.0", vec![]);
    let available = vec![pkg_booking, pkg_cal, pkg_tz];

    // RÈGLE CTO N°4 : Conflit entre exigence implicite (Running) et explicite (Stopped)
    let err =
        RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap_err();
    assert!(matches!(err, RuntimeError::DesiredStateConflict { .. }));
}

#[test]
fn test_explicit_absent_vs_implicit_running_conflict() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    let desired = DesiredRuntimeState::new()
        .running("lyxal-booking")
        .absent("lyxal-calendar");

    let pkg_booking = make_package("lyxal-booking", "1.0.0", vec![("lyxal-calendar", None)]);
    let pkg_cal = make_package("lyxal-calendar", "1.0.0", vec![]);
    let available = vec![pkg_booking, pkg_cal];

    let err =
        RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap_err();
    assert!(matches!(err, RuntimeError::DesiredStateConflict { .. }));
}

#[test]
fn test_registered_descriptor_used_without_available_package() {
    let runtime_version = Version::parse("0.1.0").unwrap();

    // Actual : calendar 1.0.0 et timezone 1.0.0 installés mais Stopped
    let mut actual = ActualRuntimeState::new();
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-calendar"),
        installed_version: Some(Version::parse("1.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Stopped),
        is_registered: true,
    });
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-timezone"),
        installed_version: Some(Version::parse("1.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Stopped),
        is_registered: true,
    });

    let desc_cal = ModuleDescriptor::builder("lyxal-calendar", "1.0.0")
        .dependency("lyxal-timezone")
        .build();
    let desc_tz = ModuleDescriptor::new("lyxal-timezone", "1.0.0");

    let desired = DesiredRuntimeState::new().running("lyxal-calendar");

    // AUCUN package disponible fourni
    let available: Vec<ModulePackage> = Vec::new();

    let plan = RuntimeDiffer::diff(
        &desired,
        &actual,
        &available,
        &runtime_version,
        &[desc_cal, desc_tz],
    )
    .unwrap();

    // RÈGLE CTO N°6 : Le Reconciler découvre la dépendance via le descriptor enregistré
    // et planifie le Start de timezone puis le Start de calendar !
    assert_eq!(plan.actions.len(), 2);
    assert_eq!(plan.actions[0].module_id, ModuleId::new("lyxal-timezone"));
    assert_eq!(plan.actions[0].kind, ActionKind::Start);
    assert_eq!(plan.actions[1].module_id, ModuleId::new("lyxal-calendar"));
    assert_eq!(plan.actions[1].kind, ActionKind::Start);
}

#[tokio::test]
async fn test_observer_resolves_correct_installed_release() {
    let store: Arc<dyn RuntimeStore> = Arc::new(MemoryRuntimeStore::new());
    let registry = ModuleRegistry::new();
    let lifecycle = LifecycleManager::new(RuntimeConfig::default());

    // Enregistrer l'identité du module et une release Failed v1.0.0 puis une release Installed v1.1.0
    store
        .upsert_module(&StoredModule::new("lyxal-auth", "Lyxal Auth"))
        .await
        .unwrap();
    store
        .register_release(&StoredModuleRelease::new(
            "lyxal-auth",
            "1.0.0",
            1,
            "Failed",
        ))
        .await
        .unwrap();
    store
        .register_release(&StoredModuleRelease::new(
            "lyxal-auth",
            "1.1.0",
            2,
            "Installed",
        ))
        .await
        .unwrap();

    let observer = RuntimeObserver::new(Some(&store), &registry, &lifecycle);
    let actual = observer.observe().await.unwrap();

    let auth_obs = actual
        .get(&ModuleId::new("lyxal-auth"))
        .expect("Must exist in actual");
    assert_eq!(
        auth_obs.installed_version,
        Some(Version::parse("1.1.0").unwrap())
    );
    assert_eq!(
        auth_obs.release_status,
        Some(ModuleReleaseStatus::Installed)
    );
}

#[test]
fn test_plan_contains_zero_actions_when_converged() {
    let runtime_version = Version::parse("0.1.0").unwrap();

    let mut actual = ActualRuntimeState::new();
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-timezone"),
        installed_version: Some(Version::parse("1.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    });

    let desired = DesiredRuntimeState::new().running("lyxal-timezone");
    let plan = RuntimeDiffer::diff(&desired, &actual, &[], &runtime_version, &[]).unwrap();

    assert_eq!(plan.actions.len(), 0);
    assert_eq!(plan.blockers.len(), 0);
    assert!(plan.is_converged());
}

#[test]
fn test_blockers_are_not_executable_actions() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    // Desired Running pour un module sans aucun package disponible
    let desired = DesiredRuntimeState::new().running("lyxal-missing");
    let plan = RuntimeDiffer::diff(&desired, &actual, &[], &runtime_version, &[]).unwrap();

    // RÈGLE CTO N°16 : Les blockers sont séparés des actions exécutables
    assert_eq!(plan.actions.len(), 0);
    assert_eq!(plan.blockers.len(), 1);
    assert_eq!(plan.blockers[0].kind, BlockerKind::MissingPackage);
    assert!(!plan.is_converged());
}

#[test]
fn test_highest_candidate_rejected_when_dependencies_unsatisfied() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    // A candidates :
    // - v2.0.0 -> requiert B >= 2.0.0 (non disponible)
    // - v1.5.0 -> requiert B >= 1.0.0 (disponible en v1.0.0)
    let pkg_a_20 = make_package("lyxal-a", "2.0.0", vec![("lyxal-b", Some(">=2.0.0"))]);
    let pkg_a_15 = make_package("lyxal-a", "1.5.0", vec![("lyxal-b", Some(">=1.0.0"))]);
    let pkg_b_10 = make_package("lyxal-b", "1.0.0", vec![]);

    let available = vec![pkg_a_20, pkg_a_15, pkg_b_10];

    let desired = DesiredRuntimeState::new().running("lyxal-a");

    let plan = RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap();

    // RÈGLE CTO N°25 : v2.0.0 est rejeté car sa dépendance B >= 2.0.0 est insoluble.
    // Le Reconciler sélectionne v1.5.0 !
    let install_a = plan
        .actions
        .iter()
        .find(|a| {
            a.module_id == ModuleId::new("lyxal-a") && matches!(a.kind, ActionKind::Install { .. })
        })
        .expect("Must plan Install for A");

    if let ActionKind::Install { candidate_version } = &install_a.kind {
        assert_eq!(*candidate_version, Version::parse("1.5.0").unwrap());
    } else {
        panic!("Expected Install action");
    }
}

#[test]
fn test_strict_mode_stops_unspecified_module_without_uninstall() {
    let runtime_version = Version::parse("0.1.0").unwrap();

    // Actual : timezone Running ET rogue-module Running
    let mut actual = ActualRuntimeState::new();
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-timezone"),
        installed_version: Some(Version::parse("1.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    });
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-rogue"),
        installed_version: Some(Version::parse("1.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    });

    // Desired en mode STRICT : seulement timezone
    let desired = DesiredRuntimeState::new()
        .with_strict(true)
        .running("lyxal-timezone");

    let plan = RuntimeDiffer::diff(&desired, &actual, &[], &runtime_version, &[]).unwrap();

    // rogue-module doit être arrêté et marqué inactif, mais pas désinstallé
    let rogue_stop = plan
        .actions
        .iter()
        .find(|a| a.module_id == ModuleId::new("lyxal-rogue") && a.kind == ActionKind::Stop);
    assert!(
        rogue_stop.is_some(),
        "Strict mode must plan Stop for unspecified running module"
    );

    // timezone ne doit avoir aucune action (déjà conforme)
    let timezone_action = plan
        .actions
        .iter()
        .find(|a| a.module_id == ModuleId::new("lyxal-timezone"));
    assert!(timezone_action.is_none());
}

#[test]
fn test_downgrade_produces_unsupported_downgrade_blocker() {
    let runtime_version = Version::parse("0.1.0").unwrap();

    // Actual : v2.0.0
    let mut actual = ActualRuntimeState::new();
    actual.insert(ObservedModuleState {
        module_id: ModuleId::new("lyxal-calendar"),
        installed_version: Some(Version::parse("2.0.0").unwrap()),
        release_status: Some(ModuleReleaseStatus::Installed),
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    });

    // Desired : =1.0.0 (downgrade)
    let desired = DesiredRuntimeState::new()
        .running_version("lyxal-calendar", VersionReq::parse("=1.0.0").unwrap());

    let pkg_10 = make_package("lyxal-calendar", "1.0.0", vec![]);
    let plan = RuntimeDiffer::diff(&desired, &actual, &[pkg_10], &runtime_version, &[]).unwrap();

    assert_eq!(plan.actions.len(), 0);
    assert_eq!(plan.blockers.len(), 1);
    assert_eq!(plan.blockers[0].kind, BlockerKind::UnsupportedDowngrade);
}

#[test]
fn test_runtime_incompatible_candidate_filtered() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    // Package requiert Runtime >= 2.0.0
    let pkg = make_package_with_runtime("lyxal-future", "1.0.0", ">=2.0.0");

    let desired = DesiredRuntimeState::new().running("lyxal-future");
    let plan = RuntimeDiffer::diff(&desired, &actual, &[pkg], &runtime_version, &[]).unwrap();

    assert_eq!(plan.actions.len(), 0);
    assert_eq!(plan.blockers.len(), 1);
    assert_eq!(plan.blockers[0].kind, BlockerKind::UnsatisfiedVersion);
}

#[test]
fn test_deterministic_plan_same_inputs_same_order() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    let desired = DesiredRuntimeState::new().running("lyxal-booking");

    let pkg_booking = make_package(
        "lyxal-booking",
        "1.0.0",
        vec![("lyxal-calendar", None), ("lyxal-scheduler", None)],
    );
    let pkg_cal = make_package("lyxal-calendar", "1.0.0", vec![("lyxal-timezone", None)]);
    let pkg_sched = make_package("lyxal-scheduler", "1.0.0", vec![("lyxal-timezone", None)]);
    let pkg_tz = make_package("lyxal-timezone", "1.0.0", vec![]);

    let available = vec![pkg_booking, pkg_cal, pkg_sched, pkg_tz];

    let plan1 = RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap();
    let plan2 = RuntimeDiffer::diff(&desired, &actual, &available, &runtime_version, &[]).unwrap();

    assert_eq!(
        plan1, plan2,
        "Plans generated with same inputs must be strictly equal"
    );
}

#[test]
fn test_duplicate_desired_module_id_rejected() {
    let runtime_version = Version::parse("0.1.0").unwrap();
    let actual = ActualRuntimeState::new();

    let desired = DesiredRuntimeState::new()
        .running("lyxal-timezone")
        .stopped("lyxal-timezone");

    let err = RuntimeDiffer::diff(&desired, &actual, &[], &runtime_version, &[]).unwrap_err();
    assert!(matches!(err, RuntimeError::DesiredDuplicateModule { .. }));
}
