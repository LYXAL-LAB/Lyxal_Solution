use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::health::check::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::health::engine::{HealthConfig, HealthEngine};
use lyxal_runtime::health::registry::HealthRegistry;
use lyxal_runtime::health::snapshot::HealthSnapshot;
use lyxal_runtime::health::status::{GlobalHealthStatus, HealthStatus};
use lyxal_runtime::reconciler::actual::{ActualRuntimeState, ObservedModuleState};
use lyxal_runtime::types::{ModuleId, ModuleState};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;

struct MockHealthChecker {
    module_id: ModuleId,
    should_fail: Arc<AtomicBool>,
    delay: Duration,
}

impl MockHealthChecker {
    fn new(id: &str, should_fail: bool, delay: Duration) -> Self {
        Self {
            module_id: ModuleId::new(id),
            should_fail: Arc::new(AtomicBool::new(should_fail)),
            delay,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for MockHealthChecker {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        if self.delay > Duration::ZERO {
            tokio::time::sleep(self.delay).await;
        }

        if self.should_fail.load(Ordering::SeqCst) {
            Err(RuntimeError::Internal {
                code: "MOCK_HEALTH_CHECK_FAILED",
                message: "Simulated internal health check failure".to_string(),
            })
        } else {
            Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                self.delay.as_millis() as u64,
                Some("All systems nominal".to_string()),
            ))
        }
    }
}

#[test]
fn test_health_status_serialization_and_deserialization() {
    let statuses = vec![
        HealthStatus::Healthy,
        HealthStatus::Degraded,
        HealthStatus::Unhealthy,
        HealthStatus::Unknown,
        HealthStatus::NotApplicable,
    ];

    for s in statuses {
        let json = serde_json::to_string(&s).unwrap();
        let de: HealthStatus = serde_json::from_str(&json).unwrap();
        assert_eq!(s, de);
        assert_eq!(s.as_str(), json.trim_matches('"'));
    }
}

#[test]
fn test_global_health_status_aggregation_matrix() {
    // Tous Healthy -> Healthy
    assert_eq!(
        GlobalHealthStatus::from_statuses(&[HealthStatus::Healthy, HealthStatus::Healthy]),
        GlobalHealthStatus::Healthy
    );

    // Healthy + Unknown -> Degraded
    assert_eq!(
        GlobalHealthStatus::from_statuses(&[HealthStatus::Healthy, HealthStatus::Unknown]),
        GlobalHealthStatus::Degraded
    );

    // Healthy + Degraded -> Degraded
    assert_eq!(
        GlobalHealthStatus::from_statuses(&[HealthStatus::Healthy, HealthStatus::Degraded]),
        GlobalHealthStatus::Degraded
    );

    // Degraded + Unknown -> Degraded
    assert_eq!(
        GlobalHealthStatus::from_statuses(&[HealthStatus::Degraded, HealthStatus::Unknown]),
        GlobalHealthStatus::Degraded
    );

    // Unhealthy écrase tout -> Unhealthy
    assert_eq!(
        GlobalHealthStatus::from_statuses(&[
            HealthStatus::Healthy,
            HealthStatus::Degraded,
            HealthStatus::Unknown,
            HealthStatus::Unhealthy,
        ]),
        GlobalHealthStatus::Unhealthy
    );

    // Vide -> Healthy
    let empty: Vec<HealthStatus> = Vec::new();
    assert_eq!(
        GlobalHealthStatus::from_statuses(empty.iter()),
        GlobalHealthStatus::Healthy
    );
}

#[test]
fn test_stopped_module_does_not_degrade_global_health() {
    // Un module Running/Healthy et un module Stopped/NotApplicable
    let statuses = [HealthStatus::Healthy, HealthStatus::NotApplicable];
    assert_eq!(
        GlobalHealthStatus::from_statuses(statuses.iter()),
        GlobalHealthStatus::Healthy,
        "NotApplicable modules must never degrade the global health status"
    );
}

#[test]
fn test_not_applicable_health_aggregation() {
    // Uniquement des modules NotApplicable -> Healthy (aucun module actif en panne)
    let statuses = [HealthStatus::NotApplicable, HealthStatus::NotApplicable];
    assert_eq!(
        GlobalHealthStatus::from_statuses(statuses.iter()),
        GlobalHealthStatus::Healthy
    );
}

#[test]
fn test_health_registry_register_and_lookup() {
    let registry = HealthRegistry::new();
    let checker = Arc::new(MockHealthChecker::new("lyxal-auth", false, Duration::ZERO));

    assert!(!registry.has_check(&ModuleId::new("lyxal-auth")));
    registry.register_check(checker).unwrap();
    assert!(registry.has_check(&ModuleId::new("lyxal-auth")));
    assert_eq!(registry.list_checkers(), vec![ModuleId::new("lyxal-auth")]);
}

#[test]
fn test_health_registry_rejects_duplicate_checker() {
    let registry = HealthRegistry::new();
    let checker1 = Arc::new(MockHealthChecker::new("lyxal-auth", false, Duration::ZERO));
    let checker2 = Arc::new(MockHealthChecker::new("lyxal-auth", true, Duration::ZERO));

    registry.register_check(checker1).unwrap();
    let res = registry.register_check(checker2);
    assert!(res.is_err());
}

#[tokio::test]
async fn test_health_engine_successful_check() {
    let registry = HealthRegistry::new();
    let checker = Arc::new(MockHealthChecker::new(
        "lyxal-timezone",
        false,
        Duration::from_millis(5),
    ));
    registry.register_check(checker).unwrap();

    let engine = HealthEngine::new(registry, HealthConfig::default());
    let ctx = ModuleContext::new("test");
    let res = engine
        .check_module(&ModuleId::new("lyxal-timezone"), &ctx)
        .await;

    assert_eq!(res.status, HealthStatus::Healthy);
    assert!(res.latency_ms.is_some());
    assert_eq!(res.message.as_deref(), Some("All systems nominal"));
}

#[tokio::test]
async fn test_health_engine_failed_check_produces_unhealthy() {
    let registry = HealthRegistry::new();
    let checker = Arc::new(MockHealthChecker::new(
        "lyxal-calendar",
        true,
        Duration::ZERO,
    ));
    registry.register_check(checker).unwrap();

    let engine = HealthEngine::new(registry, HealthConfig::default());
    let ctx = ModuleContext::new("test");
    let res = engine
        .check_module(&ModuleId::new("lyxal-calendar"), &ctx)
        .await;

    assert_eq!(res.status, HealthStatus::Unhealthy);
    assert!(res.message.unwrap().contains("Health check failed"));
}

#[tokio::test]
async fn test_health_engine_timeout_produces_unhealthy() {
    let registry = HealthRegistry::new();
    // Delay de 100ms avec un timeout configuré à 20ms
    let checker = Arc::new(MockHealthChecker::new(
        "lyxal-booking",
        false,
        Duration::from_millis(100),
    ));
    registry.register_check(checker).unwrap();

    let config = HealthConfig {
        check_timeout: Duration::from_millis(20),
        max_concurrency: 4,
    };
    let engine = HealthEngine::new(registry, config);
    let ctx = ModuleContext::new("test");
    let res = engine
        .check_module(&ModuleId::new("lyxal-booking"), &ctx)
        .await;

    assert_eq!(res.status, HealthStatus::Unhealthy);
    assert!(res.message.unwrap().contains("timed out"));
}

#[tokio::test]
async fn test_running_module_without_checker_produces_unknown() {
    let registry = HealthRegistry::new();
    let engine = HealthEngine::new(registry, HealthConfig::default());

    let mut actual_state = ActualRuntimeState::empty();
    let running_obs = ObservedModuleState {
        module_id: ModuleId::new("lyxal-legacy"),
        installed_version: Some(semver::Version::parse("1.0.0").unwrap()),
        release_status: None,
        runtime_state: Some(ModuleState::Running),
        is_registered: true,
    };
    actual_state.set(ModuleId::new("lyxal-legacy"), running_obs);

    let ctx = ModuleContext::new("test");
    let snapshot = engine.check_all(&actual_state, &ctx).await;

    let res = snapshot
        .modules
        .get(&ModuleId::new("lyxal-legacy"))
        .expect("Must exist");
    assert_eq!(res.status, HealthStatus::Unknown);
    assert_eq!(snapshot.global_status, GlobalHealthStatus::Degraded);
}

#[tokio::test]
async fn test_health_snapshot_transition_detection() {
    let res1 = vec![
        HealthCheckResult::healthy(ModuleId::new("lyxal-auth"), 5, None),
        HealthCheckResult::healthy(ModuleId::new("lyxal-booking"), 10, None),
    ];
    let snapshot1 = HealthSnapshot::new(res1);

    // auth devient Unhealthy, booking reste Healthy
    let res2 = vec![
        HealthCheckResult::unhealthy(
            ModuleId::new("lyxal-auth"),
            Some(5),
            Some("DB Down".to_string()),
        ),
        HealthCheckResult::healthy(ModuleId::new("lyxal-booking"), 8, None),
    ];
    let snapshot2 = HealthSnapshot::new(res2);

    let transitions = snapshot2.transitions_from(&snapshot1);
    assert_eq!(transitions.len(), 1);
    assert_eq!(transitions[0].module_id, ModuleId::new("lyxal-auth"));
    assert_eq!(transitions[0].from, HealthStatus::Healthy);
    assert_eq!(transitions[0].to, HealthStatus::Unhealthy);
}
