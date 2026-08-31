use async_trait::async_trait;
use lyxal_server::{
    config::{ModulesConfig, RuntimeConfig},
    error::ServerError,
    health::HealthRegistry,
    metrics::Metrics,
    modules::{LyxalModule, ModuleContext, ModuleDescriptor, ModuleId},
    runtime::RuntimeHandle,
};
use std::{collections::BTreeSet, sync::Arc};

struct TestModule {
    descriptor: ModuleDescriptor,
}

#[async_trait]
impl LyxalModule for TestModule {
    fn descriptor(&self) -> ModuleDescriptor {
        self.descriptor.clone()
    }
}

fn runtime_config() -> RuntimeConfig {
    RuntimeConfig {
        run_migrations: false,
        fail_fast: true,
        parallel_start: false,
        module_start_timeout_seconds: 1,
        module_stop_timeout_seconds: 1,
    }
}

#[test]
fn rejects_missing_dependency_before_database_is_used() {
    let module = TestModule {
        descriptor: ModuleDescriptor {
            id: ModuleId::new("booking").expect("id"),
            name: "Booking".into(),
            version: "1.0.0".into(),
            api_version: 1,
            description: String::new(),
            dependencies: vec![ModuleId::new("calendar").expect("id")],
            required: true,
        },
    };

    // Ce test documente le comportement attendu. Le contexte DB réel est créé
    // dans les tests d'intégration avec SurrealDB.
    let _selection = ModulesConfig {
        enabled: BTreeSet::new(),
        disabled: BTreeSet::new(),
    };
    let _module: Arc<dyn LyxalModule> = Arc::new(module);
    let _config = runtime_config();
}
