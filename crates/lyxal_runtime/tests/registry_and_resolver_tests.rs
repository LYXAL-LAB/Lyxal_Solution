use async_trait::async_trait;
use lyxal_runtime::{
    DependencyResolver, LyxalModule, ModuleDescriptor, ModuleId, ModuleRegistry, RuntimeError,
};
use std::sync::Arc;

struct MockModule {
    descriptor: ModuleDescriptor,
}

impl MockModule {
    fn new(id: &str, deps: &[&str]) -> Self {
        let desc = ModuleDescriptor::builder(id, "1.0.0")
            .dependencies(deps.iter().map(|&d| ModuleId::new(d)))
            .build();
        Self { descriptor: desc }
    }
}

#[async_trait]
impl LyxalModule for MockModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }
}

#[test]
fn test_registry_register_and_lookup() {
    let registry = ModuleRegistry::new();
    assert!(registry.is_empty());
    assert_eq!(registry.len(), 0);

    let module = Arc::new(MockModule::new("test_mod", &[]));
    assert!(registry.register(module.clone()).is_ok());

    assert!(!registry.is_empty());
    assert_eq!(registry.len(), 1);
    assert!(registry.contains(&ModuleId::new("test_mod")));

    let retrieved = registry.get(&ModuleId::new("test_mod"));
    assert!(retrieved.is_some());
    assert_eq!(retrieved.unwrap().id().as_str(), "test_mod");

    let desc = registry.get_descriptor(&ModuleId::new("test_mod"));
    assert!(desc.is_some());
    assert_eq!(desc.unwrap().version, "1.0.0");
}

#[test]
fn test_registry_rejects_duplicate() {
    let registry = ModuleRegistry::new();
    let mod1 = Arc::new(MockModule::new("duplicate_mod", &[]));
    let mod2 = Arc::new(MockModule::new("duplicate_mod", &[]));

    assert!(registry.register(mod1).is_ok());
    let err = registry.register(mod2).unwrap_err();

    assert!(
        matches!(err, RuntimeError::DuplicateModule { ref id } if id.as_str() == "duplicate_mod")
    );
    assert_eq!(err.code(), "RUNTIME_DUPLICATE_MODULE");
}

#[test]
fn test_resolver_single_module_no_dependencies() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("standalone", &[])))
        .unwrap();

    let order = DependencyResolver::resolve(&registry).unwrap();
    assert_eq!(order, vec![ModuleId::new("standalone")]);
}

#[test]
fn test_resolver_simple_dependency() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("core", &[])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("app", &["core"])))
        .unwrap();

    let order = DependencyResolver::resolve(&registry).unwrap();
    assert_eq!(order, vec![ModuleId::new("core"), ModuleId::new("app")]);
}

#[test]
fn test_resolver_multiple_dependencies() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("db", &[])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("auth", &["db"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("backend", &["db"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("frontend", &["backend", "auth"])))
        .unwrap();

    let order = DependencyResolver::resolve(&registry).unwrap();

    let pos = |name: &str| order.iter().position(|id| id.as_str() == name).unwrap();

    assert!(pos("db") < pos("backend"));
    assert!(pos("db") < pos("auth"));
    assert!(pos("backend") < pos("frontend"));
    assert!(pos("auth") < pos("frontend"));
}

#[test]
fn test_resolver_disconnected_graph() {
    // Deux sous-graphes complètement indépendants: (a -> b) et (x -> y)
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("a", &[])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("b", &["a"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("x", &[])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("y", &["x"])))
        .unwrap();

    let order = DependencyResolver::resolve(&registry).unwrap();
    let pos = |name: &str| order.iter().position(|id| id.as_str() == name).unwrap();

    assert!(pos("a") < pos("b"));
    assert!(pos("x") < pos("y"));
    assert_eq!(order.len(), 4);
}

#[test]
fn test_resolver_long_dependency_chain() {
    // Chaîne linéaire m1 -> m2 -> m3 -> m4 -> m5
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("m1", &[])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("m2", &["m1"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("m3", &["m2"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("m4", &["m3"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("m5", &["m4"])))
        .unwrap();

    let order = DependencyResolver::resolve(&registry).unwrap();
    assert_eq!(
        order,
        vec![
            ModuleId::new("m1"),
            ModuleId::new("m2"),
            ModuleId::new("m3"),
            ModuleId::new("m4"),
            ModuleId::new("m5"),
        ]
    );
}

#[test]
fn test_resolver_missing_dependency() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("booking", &["calendar"])))
        .unwrap();

    let err = DependencyResolver::resolve(&registry).unwrap_err();
    assert!(
        matches!(err, RuntimeError::MissingDependency { ref module, ref dependency }
            if module.as_str() == "booking" && dependency.as_str() == "calendar")
    );
    assert_eq!(err.code(), "RUNTIME_MISSING_DEPENDENCY");
}

#[test]
fn test_resolver_direct_cycle() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("a", &["b"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("b", &["a"])))
        .unwrap();

    let err = DependencyResolver::resolve(&registry).unwrap_err();
    assert!(matches!(err, RuntimeError::DependencyCycle { .. }));
    assert_eq!(err.code(), "RUNTIME_DEPENDENCY_CYCLE");
}

#[test]
fn test_resolver_indirect_cycle() {
    let registry = ModuleRegistry::new();
    registry
        .register(Arc::new(MockModule::new("a", &["b"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("b", &["c"])))
        .unwrap();
    registry
        .register(Arc::new(MockModule::new("c", &["a"])))
        .unwrap();

    let err = DependencyResolver::resolve(&registry).unwrap_err();
    assert!(matches!(err, RuntimeError::DependencyCycle { .. }));
}

#[test]
fn test_resolver_deterministic_ordering() {
    let descs = vec![
        ModuleDescriptor::new("z", "1.0.0"),
        ModuleDescriptor::new("y", "1.0.0"),
        ModuleDescriptor::new("x", "1.0.0"),
        ModuleDescriptor::new("w", "1.0.0"),
    ];

    let order1 = DependencyResolver::resolve_descriptors(&descs).unwrap();

    // Répéter 100 fois pour vérifier le déterminisme absolu
    for _ in 0..100 {
        let order = DependencyResolver::resolve_descriptors(&descs).unwrap();
        assert_eq!(order1, order);
    }

    assert_eq!(
        order1,
        vec![
            ModuleId::new("z"),
            ModuleId::new("y"),
            ModuleId::new("x"),
            ModuleId::new("w")
        ]
    );
}
