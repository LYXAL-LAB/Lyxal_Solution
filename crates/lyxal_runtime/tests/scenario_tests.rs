use async_trait::async_trait;
use lyxal_runtime::{
    LyxalModule, LyxalRuntime, ModuleContext, ModuleDescriptor, ModuleId, ModuleState,
    RuntimeConfig, RuntimeError,
};
use std::sync::{Arc, Mutex};

/// Module de test instrumenté enregistrant toutes les étapes du cycle de vie dans un journal partagé.
struct InstrumentedModule {
    descriptor: ModuleDescriptor,
    event_log: Arc<Mutex<Vec<String>>>,
}

impl InstrumentedModule {
    fn new(id: &str, deps: &[&str], log: Arc<Mutex<Vec<String>>>) -> Self {
        let desc = ModuleDescriptor::builder(id, "1.0.0")
            .dependencies(deps.iter().map(|&d| ModuleId::new(d)))
            .build();
        Self {
            descriptor: desc,
            event_log: log,
        }
    }

    fn record_event(&self, event: &str) {
        let mut log = self.event_log.lock().unwrap();
        log.push(format!("{}:{}", self.descriptor.id.as_str(), event));
    }
}

#[async_trait]
impl LyxalModule for InstrumentedModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.record_event("install");
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.record_event("start");
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.record_event("stop");
        Ok(())
    }
}

#[tokio::test]
async fn test_full_lyxal_scenario_dag_and_lifecycle() {
    let event_log = Arc::new(Mutex::new(Vec::new()));
    let runtime = LyxalRuntime::new(RuntimeConfig::default());

    // Scénario canonique officiel :
    // timezone (0 dép)
    // scheduler (0 dép)
    // calendar -> timezone
    // booking -> calendar + scheduler
    let mod_timezone = Arc::new(InstrumentedModule::new("timezone", &[], event_log.clone()));
    let mod_scheduler = Arc::new(InstrumentedModule::new("scheduler", &[], event_log.clone()));
    let mod_calendar = Arc::new(InstrumentedModule::new(
        "calendar",
        &["timezone"],
        event_log.clone(),
    ));
    let mod_booking = Arc::new(InstrumentedModule::new(
        "booking",
        &["calendar", "scheduler"],
        event_log.clone(),
    ));

    // Enregistrement dans l'ordre de définition
    runtime.register(mod_timezone).unwrap();
    runtime.register(mod_scheduler).unwrap();
    runtime.register(mod_calendar).unwrap();
    runtime.register(mod_booking).unwrap();

    assert_eq!(runtime.modules().len(), 4);

    // 1. Validation de l'ordre topologique déterministe
    let start_order = runtime.start_order().unwrap();
    let order_names: Vec<&str> = start_order.iter().map(|id| id.as_str()).collect();

    assert_eq!(
        order_names,
        vec!["timezone", "scheduler", "calendar", "booking"],
        "Start order must strictly match DAG requirements and registration determinism"
    );

    // 2. Installation ordonnée
    runtime.install_all().await.unwrap();

    let states = runtime.all_states();
    for id in &start_order {
        assert_eq!(states.get(id), Some(&ModuleState::Installed));
    }

    // 3. Démarrage ordonné
    runtime.start_all().await.unwrap();

    let states_running = runtime.all_states();
    for id in &start_order {
        assert_eq!(states_running.get(id), Some(&ModuleState::Running));
    }

    // 4. Arrêt ordonné dans l'ordre strictement inverse
    runtime.stop_all().await.unwrap();

    let states_stopped = runtime.all_states();
    for id in &start_order {
        assert_eq!(states_stopped.get(id), Some(&ModuleState::Stopped));
    }

    // 5. Vérification explicite et stricte des événements exécutés
    let recorded = event_log.lock().unwrap().clone();

    let start_events: Vec<&str> = recorded
        .iter()
        .filter(|e| e.ends_with(":start"))
        .map(|s| s.as_str())
        .collect();

    let stop_events: Vec<&str> = recorded
        .iter()
        .filter(|e| e.ends_with(":stop"))
        .map(|s| s.as_str())
        .collect();

    assert_eq!(
        start_events,
        vec![
            "timezone:start",
            "scheduler:start",
            "calendar:start",
            "booking:start"
        ],
        "Start sequence must strictly execute in calculated DAG start order"
    );

    assert_eq!(
        stop_events,
        vec![
            "booking:stop",
            "calendar:stop",
            "scheduler:stop",
            "timezone:stop"
        ],
        "Stop sequence must strictly execute in exact reverse of start order"
    );
}

#[tokio::test]
async fn test_full_scenario_registered_in_reverse_order() {
    let event_log = Arc::new(Mutex::new(Vec::new()));
    let runtime = LyxalRuntime::new(RuntimeConfig::default());

    let mod_booking = Arc::new(InstrumentedModule::new(
        "booking",
        &["calendar", "scheduler"],
        event_log.clone(),
    ));
    let mod_calendar = Arc::new(InstrumentedModule::new(
        "calendar",
        &["timezone"],
        event_log.clone(),
    ));
    let mod_scheduler = Arc::new(InstrumentedModule::new("scheduler", &[], event_log.clone()));
    let mod_timezone = Arc::new(InstrumentedModule::new("timezone", &[], event_log.clone()));

    // Enregistrement inversé (booking en premier)
    runtime.register(mod_booking).unwrap();
    runtime.register(mod_calendar).unwrap();
    runtime.register(mod_scheduler).unwrap();
    runtime.register(mod_timezone).unwrap();

    let start_order = runtime.start_order().unwrap();
    let start_names: Vec<&str> = start_order.iter().map(|id| id.as_str()).collect();

    let pos = |name: &str| start_names.iter().position(|&x| x == name).unwrap();
    assert!(pos("timezone") < pos("calendar"));
    assert!(pos("calendar") < pos("booking"));
    assert!(pos("scheduler") < pos("booking"));

    runtime.install_all().await.unwrap();
    runtime.start_all().await.unwrap();
    runtime.stop_all().await.unwrap();

    let recorded = event_log.lock().unwrap().clone();
    let stop_events: Vec<String> = recorded
        .iter()
        .filter(|e| e.ends_with(":stop"))
        .map(|s| s.replace(":stop", ""))
        .collect();

    let mut expected_stop = start_names.clone();
    expected_stop.reverse();

    assert_eq!(
        stop_events, expected_stop,
        "Stop order must always strictly reverse the validated start order regardless of registration order"
    );
}
