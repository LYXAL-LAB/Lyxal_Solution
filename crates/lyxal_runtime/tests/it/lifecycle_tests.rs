use async_trait::async_trait;
use lyxal_runtime::{
    LifecycleManager, LyxalModule, ModuleContext, ModuleDescriptor, ModuleId, ModuleState,
    RuntimeConfig, RuntimeError,
};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;

struct TestModule {
    descriptor: ModuleDescriptor,
    fail_install: AtomicBool,
    fail_start: AtomicBool,
    fail_stop: AtomicBool,
    hang_duration: Option<Duration>,
}

impl TestModule {
    fn new(id: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, "1.0.0"),
            fail_install: AtomicBool::new(false),
            fail_start: AtomicBool::new(false),
            fail_stop: AtomicBool::new(false),
            hang_duration: None,
        }
    }

    fn with_hang(id: &str, duration: Duration) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, "1.0.0"),
            fail_install: AtomicBool::new(false),
            fail_start: AtomicBool::new(false),
            fail_stop: AtomicBool::new(false),
            hang_duration: Some(duration),
        }
    }
}

#[async_trait]
impl LyxalModule for TestModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        if let Some(dur) = self.hang_duration {
            tokio::time::sleep(dur).await;
        }
        if self.fail_install.load(Ordering::SeqCst) {
            return Err(RuntimeError::Internal {
                code: "MOCK_INSTALL_ERROR",
                message: "Simulated install failure".to_string(),
            });
        }
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        if let Some(dur) = self.hang_duration {
            tokio::time::sleep(dur).await;
        }
        if self.fail_start.load(Ordering::SeqCst) {
            return Err(RuntimeError::Internal {
                code: "MOCK_START_ERROR",
                message: "Simulated start failure".to_string(),
            });
        }
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        if let Some(dur) = self.hang_duration {
            tokio::time::sleep(dur).await;
        }
        if self.fail_stop.load(Ordering::SeqCst) {
            return Err(RuntimeError::Internal {
                code: "MOCK_STOP_ERROR",
                message: "Simulated stop failure".to_string(),
            });
        }
        Ok(())
    }
}

#[tokio::test]
async fn test_lifecycle_success_path() {
    let config = RuntimeConfig::default();
    let manager = LifecycleManager::new(config);
    let module: Arc<dyn LyxalModule> = Arc::new(TestModule::new("app_module"));
    let ctx = ModuleContext::new("app_module");

    // 1. Initial registered
    manager.register_state(ModuleId::new("app_module"));
    assert_eq!(
        manager.get_state(&ModuleId::new("app_module")),
        Some(ModuleState::Registered)
    );

    // 2. Install
    assert!(manager.install_module(&module, &ctx).await.is_ok());
    assert_eq!(
        manager.get_state(&ModuleId::new("app_module")),
        Some(ModuleState::Installed)
    );

    // 3. Start
    assert!(manager.start_module(&module, &ctx).await.is_ok());
    assert_eq!(
        manager.get_state(&ModuleId::new("app_module")),
        Some(ModuleState::Running)
    );

    // 4. Stop
    assert!(manager.stop_module(&module, &ctx).await.is_ok());
    assert_eq!(
        manager.get_state(&ModuleId::new("app_module")),
        Some(ModuleState::Stopped)
    );
}

#[tokio::test]
async fn test_lifecycle_install_failure() {
    let config = RuntimeConfig::default();
    let manager = LifecycleManager::new(config);
    let test_mod = Arc::new(TestModule::new("faulty_install"));
    test_mod.fail_install.store(true, Ordering::SeqCst);
    let module: Arc<dyn LyxalModule> = test_mod;
    let ctx = ModuleContext::new("faulty_install");

    manager.register_state(ModuleId::new("faulty_install"));
    let err = manager.install_module(&module, &ctx).await.unwrap_err();

    assert!(matches!(err, RuntimeError::InstallFailure { .. }));
    assert_eq!(err.code(), "RUNTIME_INSTALL_FAILURE");

    let state = manager.get_state(&ModuleId::new("faulty_install")).unwrap();
    assert!(state.is_failed());
}

#[tokio::test]
async fn test_lifecycle_start_failure() {
    let config = RuntimeConfig::default();
    let manager = LifecycleManager::new(config);
    let test_mod = Arc::new(TestModule::new("faulty_start"));
    let module: Arc<dyn LyxalModule> = test_mod.clone();
    let ctx = ModuleContext::new("faulty_start");

    manager.register_state(ModuleId::new("faulty_start"));
    manager.install_module(&module, &ctx).await.unwrap();

    test_mod.fail_start.store(true, Ordering::SeqCst);
    let err = manager.start_module(&module, &ctx).await.unwrap_err();

    assert!(matches!(err, RuntimeError::StartFailure { .. }));
    assert_eq!(err.code(), "RUNTIME_START_FAILURE");

    let state = manager.get_state(&ModuleId::new("faulty_start")).unwrap();
    assert!(state.is_failed());
}

#[tokio::test]
async fn test_lifecycle_stop_failure() {
    let config = RuntimeConfig::default();
    let manager = LifecycleManager::new(config);
    let test_mod = Arc::new(TestModule::new("faulty_stop"));
    let module: Arc<dyn LyxalModule> = test_mod.clone();
    let ctx = ModuleContext::new("faulty_stop");

    manager.register_state(ModuleId::new("faulty_stop"));
    manager.install_module(&module, &ctx).await.unwrap();
    manager.start_module(&module, &ctx).await.unwrap();

    test_mod.fail_stop.store(true, Ordering::SeqCst);
    let err = manager.stop_module(&module, &ctx).await.unwrap_err();

    assert!(matches!(err, RuntimeError::StopFailure { .. }));
    assert_eq!(err.code(), "RUNTIME_STOP_FAILURE");

    let state = manager.get_state(&ModuleId::new("faulty_stop")).unwrap();
    assert!(state.is_failed());
}

#[tokio::test]
async fn test_lifecycle_timeout_on_start() {
    let config = RuntimeConfig::new().with_start_timeout(Duration::from_millis(50));
    let manager = LifecycleManager::new(config);

    let test_mod = Arc::new(TestModule::with_hang(
        "hanging_mod",
        Duration::from_millis(200),
    ));
    let module: Arc<dyn LyxalModule> = test_mod;
    let ctx = ModuleContext::new("hanging_mod");

    manager.register_state(ModuleId::new("hanging_mod"));
    manager.install_module(&module, &ctx).await.unwrap();

    let err = manager.start_module(&module, &ctx).await.unwrap_err();

    assert!(matches!(
        err,
        RuntimeError::Timeout {
            operation: "start",
            ..
        }
    ));
    assert_eq!(err.code(), "RUNTIME_OPERATION_TIMEOUT");

    let state = manager.get_state(&ModuleId::new("hanging_mod")).unwrap();
    assert!(state.is_failed());
}

#[tokio::test]
async fn test_lifecycle_invalid_state_transition() {
    let config = RuntimeConfig::default();
    let manager = LifecycleManager::new(config);
    let module: Arc<dyn LyxalModule> = Arc::new(TestModule::new("transition_test"));
    let ctx = ModuleContext::new("transition_test");

    manager.register_state(ModuleId::new("transition_test"));
    // Le module est en Registered, tenter un stop direct doit échouer
    let err = manager.stop_module(&module, &ctx).await.unwrap_err();

    assert!(matches!(err, RuntimeError::InvalidStateTransition { .. }));
    assert_eq!(err.code(), "RUNTIME_INVALID_STATE_TRANSITION");
}

#[test]
fn test_error_conversion_to_lyxal_error() {
    let err = RuntimeError::MissingDependency {
        module: ModuleId::new("booking"),
        dependency: ModuleId::new("scheduler"),
    };

    let lyxal_err = err.to_lyxal_error();
    assert_eq!(lyxal_err.code, "RUNTIME_MISSING_DEPENDENCY");
    assert_eq!(lyxal_err.category, "runtime");
    assert_eq!(lyxal_err.http_status, Some(500));
    assert_eq!(lyxal_err.details["missing_dependency"], "scheduler");

    let res: lyxal_error::LyxalResult<String> = err.into_lyxal_result();
    assert!(!res.ok);
    assert_eq!(res.error.unwrap().code, "RUNTIME_MISSING_DEPENDENCY");
}
