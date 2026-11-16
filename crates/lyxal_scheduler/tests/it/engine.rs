//! Moteur (lot 3) en base embarquée : planificateur élu et exécuteurs conduits comme par le
//! runtime (annulation coopérative), avec des rythmes et des délais réduits. Tâches d'essai d'un
//! module fictif `lyxal_essai` : handler Rust, fonction SurrealQL, publication différée.

use crate::support::installed_client;
use async_trait::async_trait;
use jiff::{SignedDuration, Timestamp};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::lock::{NodeId, SurrealLeaderLeaseManager};
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext};
use lyxal_runtime::{ModuleContext, RuntimeError};
use lyxal_scheduler::models::*;
use lyxal_scheduler::spec::{to_datetime, to_duration, to_timestamp};
use lyxal_scheduler::{
    ExecutorTiming, HandlerRegistry, LeaderTiming, RunContext, SchedulerClient, SchedulerEngine,
    SchedulerExecutorWorker, SchedulerHealthCheck, SchedulerLeaderWorker, SchedulerStore,
    TaskFailure, TaskHandler, TaskOutput, LEADER_KEY,
};
use lyxal_surreal::{RecordId, SurrealValue, Value};
use std::future::Future;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::sync::{Notify, Semaphore};
use tokio::task::JoinHandle;

// ---------------------------------------------------------------------------------------------
// Banc
// ---------------------------------------------------------------------------------------------

struct Bench {
    client: Surreal<Any>,
    store: SchedulerStore,
    handlers: HandlerRegistry,
}

impl Bench {
    fn engine(&self, node: &str) -> SchedulerEngine {
        SchedulerEngine::new(self.store.clone(), self.handlers.clone(), NodeId::new(node))
    }

    fn executor(&self, node: &str, queue: &str, slots: u32) -> Arc<SchedulerExecutorWorker> {
        Arc::new(
            SchedulerExecutorWorker::with_timing(self.engine(node), queue, slots, exec_timing())
                .expect("exécuteur"),
        )
    }

    fn leader(&self, node: &str) -> Arc<SchedulerLeaderWorker> {
        Arc::new(
            SchedulerLeaderWorker::with_timing(
                self.engine(node),
                SurrealLeaderLeaseManager::new(self.client.clone()),
                leader_timing(),
            )
            .expect("planificateur"),
        )
    }

    async fn query<T: SurrealValue>(&self, sql: &str, run: &RecordId) -> Option<T> {
        self.client
            .query(sql)
            .bind(("run", run.clone()))
            .await
            .and_then(|mut r| r.take::<Option<T>>(0))
            .unwrap_or_else(|e| panic!("{sql} : {e}"))
    }

    async fn state(&self, run: &RecordId) -> String {
        self.query::<String>("RETURN (SELECT VALUE state FROM ONLY $run);", run)
            .await
            .unwrap_or_default()
    }

    async fn error_code(&self, run: &RecordId) -> Option<String> {
        self.query("RETURN (SELECT VALUE error.code FROM ONLY $run);", run)
            .await
    }

    async fn attempt(&self, run: &RecordId) -> i64 {
        self.query::<i64>("RETURN (SELECT VALUE attempt FROM ONLY $run);", run)
            .await
            .unwrap_or_default()
    }

    async fn enqueue(
        &self,
        task: &str,
        tenant: Option<&str>,
        args: Option<SchedulerValue>,
    ) -> RecordId {
        let mut params = RunEnqueueParams::new(task);
        params.tenant = tenant.map(|t| RecordId::new("auth_organization", t));
        params.args = args;
        self.store.run_enqueue(params).await.expect("différée").id
    }

    /// Prochaine échéance écrite comme le moteur (session système), sans bail du planificateur :
    /// le planificateur du test prend ensuite le bail lui-même.
    async fn set_next(&self, schedule: &RecordId, at: SchedulerDatetime) {
        self.client
            .query("UPDATE $s SET next_fire_at = $at;")
            .bind(("s", schedule.clone()))
            .bind(("at", at))
            .await
            .and_then(|r| r.check())
            .expect("prochaine échéance");
    }

    async fn wait_state(&self, run: &RecordId, state: &str, within: Duration) {
        let deadline = tokio::time::Instant::now() + within;
        loop {
            let current = self.state(run).await;
            if current == state {
                return;
            }
            if tokio::time::Instant::now() >= deadline {
                let error: Option<String> = self
                    .query("RETURN <string> (SELECT VALUE error FROM ONLY $run);", run)
                    .await;
                panic!("état {state} attendu, encore {current} ({error:?})");
            }
            tokio::time::sleep(Duration::from_millis(25)).await;
        }
    }
}

fn exec_timing() -> ExecutorTiming {
    ExecutorTiming {
        poll: Duration::from_millis(50),
        max_heartbeat: Duration::from_millis(300),
        shutdown_grace: Duration::from_millis(500),
        cancel_grace: Duration::from_millis(200),
    }
}

fn leader_timing() -> LeaderTiming {
    LeaderTiming {
        tick: Duration::from_millis(100),
        lease_ttl: Duration::from_secs(2),
        lease_renew: Duration::from_millis(300),
        rescue_every: Duration::from_millis(200),
        prune_every: Duration::from_secs(3600),
    }
}

async fn bench() -> Bench {
    let client = installed_client().await;
    client
        .query(
            r#"
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE scheduler_task:⟨essai.lent⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.lent", scope: "installation", timeout: 1s,
                retry: { max_attempts: 2, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };
            CREATE scheduler_task:⟨essai.court⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.court", scope: "installation", timeout: 1s,
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };
            CREATE scheduler_task:⟨essai.long⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.long", scope: "installation", timeout: 1m,
                retry: { max_attempts: 2, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };
            CREATE scheduler_task:⟨essai.purge⟩ CONTENT {
                module: "lyxal_essai", executor: "function", target: "essai_purge", scope: "installation",
                queue: scheduler_queue:maintenance,
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };
            DEFINE TABLE OVERWRITE essai_trace SCHEMALESS PERMISSIONS FULL;
            DEFINE FUNCTION OVERWRITE fn::essai_purge($params: object) {
                CREATE essai_trace CONTENT { run: $params.run, attempt: $params.attempt, tenant: $params.tenant, scheduled_for: $params.scheduled_for, args: $params.args };
                RETURN fn::result_ok({ purged: 3 });
            };
            "#,
        )
        .await
        .and_then(|r| r.check())
        .expect("tâches d'essai");
    Bench {
        store: SchedulerStore::new(client.clone()),
        client,
        handlers: HandlerRegistry::new(),
    }
}

/// Worker conduit comme par le runtime : son jeton d'annulation et sa tâche.
struct Running {
    token: CancellationToken,
    handle: JoinHandle<Result<(), RuntimeError>>,
}

fn start(worker: Arc<dyn LyxalWorker>) -> Running {
    let descriptor = worker.descriptor().clone();
    let token = CancellationToken::new();
    let context = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new(descriptor.module_id.clone()),
        token.clone(),
    );
    Running {
        token,
        handle: tokio::spawn(async move { worker.run(context).await }),
    }
}

impl Running {
    /// Arrêt demandé ; le worker doit rendre la main dans `within`.
    async fn stop(self, within: Duration) {
        self.token.cancel();
        tokio::time::timeout(within, self.handle)
            .await
            .expect("arrêt du worker dans le délai")
            .expect("tâche du worker")
            .expect("worker");
    }
}

async fn eventually<F, Fut>(what: &str, within: Duration, mut check: F)
where
    F: FnMut() -> Fut,
    Fut: Future<Output = bool>,
{
    let deadline = tokio::time::Instant::now() + within;
    while !check().await {
        assert!(tokio::time::Instant::now() < deadline, "{what}");
        tokio::time::sleep(Duration::from_millis(25)).await;
    }
}

fn now_plus_ms(ms: i64) -> SchedulerDatetime {
    to_datetime(
        Timestamp::now()
            .checked_add(SignedDuration::from_millis(ms))
            .expect("date"),
    )
    .expect("date")
}

fn object(pairs: &[(&str, &str)]) -> SchedulerValue {
    let mut object = surrealdb::types::Object::new();
    for (k, v) in pairs {
        object.insert(*k, v.to_string());
    }
    Value::Object(object)
}

/// Planification de `essai.rapport` pour alpha, toutes les minutes depuis `start_at`.
async fn every_minute(
    store: &SchedulerStore,
    name: &str,
    start_at: SchedulerDatetime,
    overlap: Overlap,
    jitter: Option<i64>,
) -> Schedule {
    let mut spec = ScheduleSpec::new("UTC");
    spec.every = vec![to_duration(SignedDuration::from_secs(60)).expect("durée")];
    spec.start_at = Some(start_at);
    spec.jitter = jitter.map(|s| to_duration(SignedDuration::from_secs(s)).expect("durée"));
    let mut params = ScheduleCreateParams::new(name, "essai.rapport", spec);
    params.tenant = Some(RecordId::new("auth_organization", "alpha"));
    params.args = Some(object(&[("format", "pdf")]));
    params.overlap = Some(overlap);
    params.catchup = Some(Catchup::All);
    store.schedule_create(params).await.expect("planification")
}

async fn runs_of(bench: &Bench, schedule: &RecordId) -> Vec<(SchedulerDatetime, String)> {
    #[derive(SurrealValue)]
    struct Row {
        scheduled_for: SchedulerDatetime,
        state: String,
    }
    let rows: Vec<Row> = bench
        .client
        .query("SELECT scheduled_for, state FROM scheduler_run WHERE schedule = $s ORDER BY scheduled_for ASC;")
        .bind(("s", schedule.clone()))
        .await
        .and_then(|mut r| r.take(0))
        .expect("exécutions");
    rows.into_iter()
        .map(|r| (r.scheduled_for, r.state))
        .collect()
}

// ---------------------------------------------------------------------------------------------
// Handlers d'essai
// ---------------------------------------------------------------------------------------------

/// Handler qui note chaque contexte reçu et réussit.
struct Recorder {
    task: &'static str,
    seen: Arc<Mutex<Vec<RunContext>>>,
}

#[async_trait]
impl TaskHandler for Recorder {
    fn task(&self) -> &str {
        self.task
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        self.seen.lock().expect("contextes").push(ctx);
        Ok(TaskOutput::with_result(object(&[("pages", "3")])))
    }
}

/// Handler qui attend l'annulation (ou une permission) et le signale.
struct Waiter {
    task: &'static str,
    started: Arc<Notify>,
    release: Arc<Semaphore>,
    cancelled: Arc<Mutex<u32>>,
}

#[async_trait]
impl TaskHandler for Waiter {
    fn task(&self) -> &str {
        self.task
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        self.started.notify_one();
        tokio::select! {
            _ = ctx.cancellation.cancelled() => {
                *self.cancelled.lock().expect("compteur") += 1;
                Err(TaskFailure::retryable("ESSAI_INTERROMPU", "annulation reçue"))
            }
            permit = self.release.acquire() => {
                if let Ok(permit) = permit {
                    permit.forget();
                }
                Ok(TaskOutput::empty())
            }
        }
    }
}

fn waiter(task: &'static str) -> (Waiter, Arc<Notify>, Arc<Semaphore>, Arc<Mutex<u32>>) {
    let started = Arc::new(Notify::new());
    let release = Arc::new(Semaphore::new(0));
    let cancelled = Arc::new(Mutex::new(0));
    (
        Waiter {
            task,
            started: started.clone(),
            release: release.clone(),
            cancelled: cancelled.clone(),
        },
        started,
        release,
        cancelled,
    )
}

/// Handler qui échoue toujours (retentable) et compte ses appels.
struct Failing {
    calls: Arc<Mutex<u32>>,
}

#[async_trait]
impl TaskHandler for Failing {
    fn task(&self) -> &str {
        "essai.lent"
    }

    async fn run(&self, _ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        *self.calls.lock().expect("compteur") += 1;
        Err(TaskFailure::retryable(
            "ESSAI_PANNE",
            "service indisponible",
        ))
    }
}

/// Handler qui ignore l'annulation (pour l'abandon à l'arrêt du nœud et le délai maximal).
struct Stubborn {
    task: &'static str,
    started: Arc<Notify>,
}

#[async_trait]
impl TaskHandler for Stubborn {
    fn task(&self) -> &str {
        self.task
    }

    async fn run(&self, _ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        self.started.notify_one();
        tokio::time::sleep(Duration::from_secs(30)).await;
        Ok(TaskOutput::empty())
    }
}

// ---------------------------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------------------------

#[tokio::test]
async fn first_deadline_elapsed_before_the_first_leader_turn_is_caught_up() {
    let mut bench = bench().await;
    let seen = Arc::new(Mutex::new(Vec::new()));
    bench
        .handlers
        .register(Arc::new(Recorder {
            task: "essai.rapport",
            seen: seen.clone(),
        }))
        .expect("handler");
    // Exécution unique dans 200 ms ; le planificateur ne démarre qu'après cette date : la
    // planification n'a jamais été traitée, sa date échue suit la politique de rattrapage
    let at = now_plus_ms(200);
    let mut spec = ScheduleSpec::new("UTC");
    spec.at = Some(at);
    let mut params = ScheduleCreateParams::new("unique", "essai.rapport", spec);
    params.tenant = Some(RecordId::new("auth_organization", "alpha"));
    params.args = Some(object(&[("format", "pdf")]));
    let schedule = bench
        .store
        .schedule_create(params)
        .await
        .expect("planification");
    tokio::time::sleep(Duration::from_millis(400)).await;
    let leader = start(bench.leader("noeud-a"));
    let executor = start(bench.executor("noeud-a", "default", 4));
    eventually(
        "exécution de la date échue avant le premier tour",
        Duration::from_secs(10),
        || async {
            runs_of(&bench, &schedule.id)
                .await
                .iter()
                .any(|(_, state)| state == "completed")
        },
    )
    .await;
    leader.stop(Duration::from_secs(5)).await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(
        runs_of(&bench, &schedule.id).await,
        vec![(at, "completed".to_string())]
    );
}

#[tokio::test]
async fn interval_schedule_fires_and_runs_its_handler() {
    let mut bench = bench().await;
    let seen = Arc::new(Mutex::new(Vec::new()));
    bench
        .handlers
        .register(Arc::new(Recorder {
            task: "essai.rapport",
            seen: seen.clone(),
        }))
        .expect("handler");
    // Toutes les minutes depuis 59,5 s : prochaine échéance une demi-seconde après maintenant
    let start_at = now_plus_ms(-59_500);
    let schedule = every_minute(&bench.store, "minute", start_at, Overlap::Skip, None).await;
    let leader = start(bench.leader("noeud-a"));
    let executor = start(bench.executor("noeud-a", "default", 4));

    eventually(
        "exécution de l'échéance",
        Duration::from_secs(10),
        || async {
            runs_of(&bench, &schedule.id)
                .await
                .iter()
                .any(|(_, state)| state == "completed")
        },
    )
    .await;
    leader.stop(Duration::from_secs(5)).await;
    executor.stop(Duration::from_secs(5)).await;

    let runs = runs_of(&bench, &schedule.id).await;
    let expected = to_datetime(
        to_timestamp("start_at", &start_at)
            .expect("date")
            .checked_add(SignedDuration::from_secs(60))
            .expect("date"),
    )
    .expect("date");
    assert_eq!(runs, vec![(expected, "completed".to_string())]);
    let seen = seen.lock().expect("contextes").clone();
    assert_eq!(seen.len(), 1);
    let ctx = &seen[0];
    assert_eq!(ctx.scheduled_for, expected);
    assert_eq!(ctx.schedule.as_ref(), Some(&schedule.id));
    assert_eq!(
        ctx.tenant,
        Some(RecordId::new("auth_organization", "alpha"))
    );
    assert_eq!((ctx.attempt, ctx.max_attempts), (1, 3));
    let run = bench
        .store
        .run_get(RunRefParams {
            run: ctx.run.clone(),
            language: None,
        })
        .await
        .expect("exécution");
    assert_eq!(run.result, Some(object(&[("pages", "3")])));
    // Le bail est rendu au leader suivant : aucun nœud ne le tient après l'arrêt
    let leases = SurrealLeaderLeaseManager::new(bench.client.clone());
    assert!(leases.inspect(LEADER_KEY).await.expect("bail").is_none());
}

#[tokio::test]
async fn function_executor_calls_the_module_function() {
    let bench = bench().await;
    let run = bench.enqueue("essai.purge", None, None).await;
    let executor = start(bench.executor("noeud-a", "maintenance", 2));
    bench
        .wait_state(&run, "completed", Duration::from_secs(10))
        .await;
    executor.stop(Duration::from_secs(5)).await;

    let traced: Option<i64> = bench
        .query(
            "RETURN (SELECT VALUE attempt FROM ONLY essai_trace WHERE run = $run LIMIT 1);",
            &run,
        )
        .await;
    assert_eq!(traced, Some(1));
    let result: Option<i64> = bench
        .query("RETURN (SELECT VALUE result.purged FROM ONLY $run);", &run)
        .await;
    assert_eq!(result, Some(3));
}

#[tokio::test]
async fn event_executor_publishes_with_the_run_end() {
    let bench = bench().await;
    let run = bench.enqueue("essai.global", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 2));
    bench
        .wait_state(&run, "completed", Duration::from_secs(10))
        .await;
    executor.stop(Duration::from_secs(5)).await;

    let published: Option<i64> = bench
        .query(
            "RETURN count(SELECT * FROM event_outbox WHERE event_type = 'essai.global.tick' AND source = $run AND producer = 'lyxal_essai');",
            &run,
        )
        .await;
    assert_eq!(published, Some(1));
    let attempt: Option<i64> = bench
        .query(
            "RETURN (SELECT VALUE metadata.attempt FROM ONLY event_outbox WHERE event_type = 'essai.global.tick' LIMIT 1);",
            &run,
        )
        .await;
    assert_eq!(attempt, Some(1));
}

#[tokio::test]
async fn two_leaders_one_lease_and_no_duplicate_runs() {
    let bench = bench().await;
    // Trois échéances manquées puis la suivante : les deux nœuds tournent en même temps
    let start_at = now_plus_ms(-150_000);
    let schedule = every_minute(&bench.store, "double", start_at, Overlap::AllowAll, None).await;
    bench.set_next(&schedule.id, start_at).await;
    let a = bench.leader("noeud-a");
    let b = bench.leader("noeud-b");
    let token = CancellationToken::new();
    let (ra, rb) = tokio::join!(a.run_once(&token), b.run_once(&token));
    let (ra, rb) = (ra.expect("tour a"), rb.expect("tour b"));
    assert!(
        ra.leader != rb.leader,
        "un seul planificateur : {ra:?} {rb:?}"
    );
    assert_eq!(ra.fired + rb.fired, 3);
    // Tours suivants des deux nœuds : aucun doublon
    for _ in 0..3 {
        let (ra, rb) = tokio::join!(a.run_once(&token), b.run_once(&token));
        assert!(ra.expect("tour a").leader != rb.expect("tour b").leader);
    }
    let runs = runs_of(&bench, &schedule.id).await;
    assert_eq!(runs.len(), 3, "{runs:?}");
    let mut dates: Vec<_> = runs.iter().map(|(d, _)| *d).collect();
    dates.dedup();
    assert_eq!(dates.len(), 3);
}

#[tokio::test]
async fn a_leader_that_loses_its_lease_stops_planning() {
    let bench = bench().await;
    let timing = LeaderTiming {
        lease_renew: Duration::ZERO,
        ..leader_timing()
    };
    let a = SchedulerLeaderWorker::with_timing(
        bench.engine("noeud-a"),
        SurrealLeaderLeaseManager::new(bench.client.clone()),
        timing,
    )
    .expect("planificateur");
    let b = SchedulerLeaderWorker::with_timing(
        bench.engine("noeud-b"),
        SurrealLeaderLeaseManager::new(bench.client.clone()),
        timing,
    )
    .expect("planificateur");
    let token = CancellationToken::new();
    assert!(a.run_once(&token).await.expect("tour").leader);
    assert!(!b.run_once(&token).await.expect("tour").leader);
    // Bail expiré (nœud a figé) : b le reprend, a cesse de planifier au tour suivant
    bench
        .client
        .query("UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'leader';")
        .await
        .and_then(|r| r.check())
        .expect("bail expiré");
    assert!(b.run_once(&token).await.expect("tour").leader);
    assert!(!a.run_once(&token).await.expect("tour").leader);
    let owner = SurrealLeaderLeaseManager::new(bench.client.clone())
        .inspect(LEADER_KEY)
        .await
        .expect("bail")
        .map(|l| l.owner);
    assert_eq!(owner, Some(NodeId::new("noeud-b")));
}

#[tokio::test]
async fn a_run_abandoned_by_a_stopped_node_is_rescued_by_another() {
    let mut bench = bench().await;
    let started = Arc::new(Notify::new());
    let mut stubborn = HandlerRegistry::new();
    stubborn
        .register(Arc::new(Stubborn {
            task: "essai.long",
            started: started.clone(),
        }))
        .expect("handler");
    let seen = Arc::new(Mutex::new(Vec::new()));
    bench
        .handlers
        .register(Arc::new(Recorder {
            task: "essai.long",
            seen: seen.clone(),
        }))
        .expect("handler");
    let run = bench.enqueue("essai.long", None, None).await;

    // Nœud a : la tentative ne rend pas la main ; arrêt du nœud → abandon après le délai d'arrêt
    let node_a = SchedulerEngine::new(bench.store.clone(), stubborn, NodeId::new("noeud-a"));
    let timing = ExecutorTiming {
        max_heartbeat: Duration::from_secs(30),
        ..exec_timing()
    };
    let a = Arc::new(
        SchedulerExecutorWorker::with_timing(node_a.clone(), "default", 1, timing)
            .expect("exécuteur"),
    );
    let worker_a = start(a);
    tokio::time::timeout(Duration::from_secs(5), started.notified())
        .await
        .expect("tentative commencée");
    assert_eq!(node_a.executors().queues(), vec!["default".to_string()]);
    worker_a.stop(Duration::from_secs(3)).await;
    assert!(node_a.executors().queues().is_empty());
    assert_eq!(bench.state(&run).await, "running");

    // Le bail expire (avancé par le test) ; le planificateur du nœud b le reprend, son exécuteur
    // exécute la deuxième tentative
    bench
        .client
        .query("UPDATE $run SET locked_until = time::now() - 1s;")
        .bind(("run", run.clone()))
        .await
        .and_then(|r| r.check())
        .expect("bail expiré");
    let leader = start(bench.leader("noeud-b"));
    let executor = start(bench.executor("noeud-b", "default", 2));
    bench
        .wait_state(&run, "completed", Duration::from_secs(10))
        .await;
    leader.stop(Duration::from_secs(5)).await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(bench.attempt(&run).await, 2);
    assert_eq!(seen.lock().expect("contextes").len(), 1);
}

#[tokio::test]
async fn timeout_cancels_the_handler_and_fails_the_attempt() {
    let mut bench = bench().await;
    let (handler, _started, _release, cancelled) = waiter("essai.court");
    bench.handlers.register(Arc::new(handler)).expect("handler");
    let run = bench.enqueue("essai.court", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 1));
    bench.wait_state(&run, "dead", Duration::from_secs(5)).await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(
        bench.error_code(&run).await.as_deref(),
        Some("SCHEDULER_RUN_TIMEOUT")
    );
    assert_eq!(*cancelled.lock().expect("compteur"), 1);
}

#[tokio::test]
async fn timeout_stops_waiting_for_a_stubborn_handler() {
    let mut bench = bench().await;
    let started = Arc::new(Notify::new());
    bench
        .handlers
        .register(Arc::new(Stubborn {
            task: "essai.court",
            started,
        }))
        .expect("handler");
    let run = bench.enqueue("essai.court", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 1));
    bench.wait_state(&run, "dead", Duration::from_secs(5)).await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(
        bench.error_code(&run).await.as_deref(),
        Some("SCHEDULER_RUN_TIMEOUT")
    );
}

#[tokio::test]
async fn requested_cancellation_reaches_the_handler() {
    let mut bench = bench().await;
    let (handler, started, _release, cancelled) = waiter("essai.rapport");
    bench.handlers.register(Arc::new(handler)).expect("handler");
    let run = bench
        .enqueue(
            "essai.rapport",
            Some("alpha"),
            Some(object(&[("format", "csv")])),
        )
        .await;
    let executor = start(bench.executor("noeud-a", "default", 1));
    tokio::time::timeout(Duration::from_secs(5), started.notified())
        .await
        .expect("tentative commencée");
    SchedulerClient::new(bench.store.clone())
        .cancel(RunCancelParams {
            run: run.clone(),
            reason: Some("essai".to_string()),
            language: None,
        })
        .await
        .expect("annulation demandée");
    bench
        .wait_state(&run, "cancelled", Duration::from_secs(5))
        .await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(*cancelled.lock().expect("compteur"), 1);
}

#[tokio::test]
async fn retries_then_dead() {
    let mut bench = bench().await;
    let calls = Arc::new(Mutex::new(0));
    bench
        .handlers
        .register(Arc::new(Failing {
            calls: calls.clone(),
        }))
        .expect("handler");
    let run = bench.enqueue("essai.lent", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 1));
    bench
        .wait_state(&run, "dead", Duration::from_secs(10))
        .await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(*calls.lock().expect("compteur"), 2);
    assert_eq!(bench.attempt(&run).await, 2);
    assert_eq!(bench.error_code(&run).await.as_deref(), Some("ESSAI_PANNE"));
}

#[tokio::test]
async fn overlap_skip_and_buffer_one_seen_by_the_engine() {
    let mut bench = bench().await;
    let seen = Arc::new(Mutex::new(Vec::new()));
    bench
        .handlers
        .register(Arc::new(Recorder {
            task: "essai.rapport",
            seen: seen.clone(),
        }))
        .expect("handler");
    let start_at = now_plus_ms(-150_000);
    let skip = every_minute(&bench.store, "skip", start_at, Overlap::Skip, None).await;
    let buffer = every_minute(&bench.store, "buffer", start_at, Overlap::BufferOne, None).await;
    for schedule in [&skip, &buffer] {
        bench.set_next(&schedule.id, start_at).await;
    }
    let leader = bench.leader("noeud-a");
    let report = leader
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!(report.fired, 6);
    let states = |runs: Vec<(SchedulerDatetime, String)>| {
        runs.into_iter().map(|(_, s)| s).collect::<Vec<_>>()
    };
    assert_eq!(
        states(runs_of(&bench, &skip.id).await),
        ["queued", "skipped", "skipped"]
    );
    assert_eq!(
        states(runs_of(&bench, &buffer.id).await),
        ["queued", "waiting", "skipped"]
    );
    // L'exécuteur termine la première ; celle qui attendait prend sa place
    let executor = start(bench.executor("noeud-a", "default", 4));
    eventually(
        "exécution en attente libérée",
        Duration::from_secs(10),
        || async {
            states(runs_of(&bench, &buffer.id).await) == ["completed", "completed", "skipped"]
        },
    )
    .await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(seen.lock().expect("contextes").len(), 3);
}

#[tokio::test]
async fn jitter_delays_availability_but_not_the_scheduled_date() {
    let bench = bench().await;
    let start_at = now_plus_ms(-90_000);
    let schedule = every_minute(
        &bench.store,
        "decale",
        start_at,
        Overlap::AllowAll,
        Some(30),
    )
    .await;
    bench.set_next(&schedule.id, start_at).await;
    let report = bench
        .leader("noeud-a")
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!(report.fired, 2);
    #[derive(SurrealValue)]
    struct Row {
        id: RecordId,
        scheduled_for: SchedulerDatetime,
        available_at: SchedulerDatetime,
    }
    let rows: Vec<Row> = bench
        .client
        .query("SELECT id, scheduled_for, available_at FROM scheduler_run WHERE schedule = $s;")
        .bind(("s", schedule.id.clone()))
        .await
        .and_then(|mut r| r.take(0))
        .expect("exécutions");
    assert_eq!(rows.len(), 2);
    for row in rows {
        let at = to_timestamp("at", &row.scheduled_for).expect("date");
        let available = to_timestamp("available_at", &row.available_at).expect("date");
        let delay = available.duration_since(at);
        assert!(
            delay > SignedDuration::ZERO && delay <= SignedDuration::from_secs(30),
            "décalage {delay:?}"
        );
    }
}

#[tokio::test]
async fn a_full_tenant_does_not_block_another() {
    let mut bench = bench().await;
    let (handler, _started, release, _cancelled) = waiter("essai.rapport");
    bench.handlers.register(Arc::new(handler)).expect("handler");
    let settings = SettingsSetParams {
        tenant_concurrency: Some(1),
        ..SettingsSetParams::default()
    };
    bench.store.settings_set(settings).await.expect("réglages");
    let format = || Some(object(&[("format", "pdf")]));
    let mut alpha = Vec::new();
    for _ in 0..3 {
        alpha.push(
            bench
                .enqueue("essai.rapport", Some("alpha"), format())
                .await,
        );
    }
    let beta = bench.enqueue("essai.rapport", Some("beta"), format()).await;
    let executor = start(bench.executor("noeud-a", "default", 4));
    bench
        .wait_state(&beta, "running", Duration::from_secs(5))
        .await;
    let mut running = 0;
    for run in &alpha {
        if bench.state(run).await == "running" {
            running += 1;
        }
    }
    assert_eq!(running, 1, "une seule place pour alpha");
    release.add_permits(10);
    for run in alpha.iter().chain([&beta]) {
        bench
            .wait_state(run, "completed", Duration::from_secs(10))
            .await;
    }
    executor.stop(Duration::from_secs(5)).await;
}

#[tokio::test]
async fn a_task_without_handler_waits_then_fails() {
    let bench = bench().await;
    let run = bench.enqueue("essai.court", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 2));
    tokio::time::sleep(Duration::from_millis(300)).await;
    assert_eq!(
        bench.state(&run).await,
        "queued",
        "laissée à un nœud qui a le code"
    );
    bench
        .wait_state(&run, "dead", Duration::from_secs(10))
        .await;
    executor.stop(Duration::from_secs(5)).await;
    assert_eq!(
        bench.error_code(&run).await.as_deref(),
        Some("SCHEDULER_HANDLER_NOT_FOUND")
    );
}

#[tokio::test]
async fn executor_stops_cleanly_and_passes_cancellation_on() {
    let mut bench = bench().await;
    let (handler, started, _release, cancelled) = waiter("essai.long");
    bench.handlers.register(Arc::new(handler)).expect("handler");
    let run = bench.enqueue("essai.long", None, None).await;
    let engine = bench.engine("noeud-a");
    let worker = Arc::new(
        SchedulerExecutorWorker::with_timing(engine.clone(), "default", 1, exec_timing())
            .expect("exécuteur"),
    );
    assert_eq!(worker.queue(), "default");
    assert_eq!(
        worker.descriptor().shutdown_timeout,
        exec_timing().shutdown_grace + Duration::from_secs(5)
    );
    let running = start(worker);
    tokio::time::timeout(Duration::from_secs(5), started.notified())
        .await
        .expect("tentative commencée");
    running.stop(Duration::from_secs(2)).await;
    assert_eq!(*cancelled.lock().expect("compteur"), 1);
    // La tentative a rendu son échec avant l'arrêt : nouvelle tentative prévue, places rendues
    assert_eq!(bench.state(&run).await, "retrying");
    assert!(engine.executors().queues().is_empty());
    let queue: Option<i64> = bench
        .query(
            "RETURN (SELECT VALUE running FROM ONLY scheduler_queue:default);",
            &run,
        )
        .await;
    assert_eq!(queue, Some(0));
}

#[tokio::test]
async fn health_reports_served_queues_and_missing_handlers() {
    let mut bench = bench().await;
    let engine = bench.engine("noeud-a");
    let check = SchedulerHealthCheck::new(engine.clone());
    let ctx = ModuleContext::new("lyxal_scheduler");
    let degraded = check.check(&ctx).await.expect("sonde");
    assert_eq!(degraded.status, HealthStatus::Degraded);
    let message = degraded.message.unwrap_or_default();
    assert!(message.contains("aucune file"), "{message}");
    assert!(message.contains("essai.rapport"), "{message}");
    assert!(!message.contains("alpha"), "{message}");

    for task in ["essai.rapport", "essai.lent", "essai.court", "essai.long"] {
        let (handler, ..) = waiter(task);
        bench.handlers.register(Arc::new(handler)).expect("handler");
    }
    let default = start(Arc::new(
        SchedulerExecutorWorker::with_timing(engine.clone(), "default", 1, exec_timing())
            .expect("exécuteur"),
    ));
    let maintenance = start(Arc::new(
        SchedulerExecutorWorker::with_timing(engine.clone(), "maintenance", 1, exec_timing())
            .expect("exécuteur"),
    ));
    eventually("files servies", Duration::from_secs(5), || async {
        engine.executors().queues().len() == 2
    })
    .await;
    let healthy = check.check(&ctx).await.expect("sonde");
    assert_eq!(
        healthy.status,
        HealthStatus::Healthy,
        "{:?}",
        healthy.message
    );
    default.stop(Duration::from_secs(5)).await;
    maintenance.stop(Duration::from_secs(5)).await;
}

#[tokio::test]
async fn a_leader_fenced_in_the_middle_of_a_turn_writes_nothing() {
    let bench = bench().await;
    // Renouvellement rare : le nœud a croit tenir le bail sans le relire avant d'écrire
    let timing = LeaderTiming {
        lease_renew: Duration::from_secs(3600),
        ..leader_timing()
    };
    let leader = |node: &str| {
        SchedulerLeaderWorker::with_timing(
            bench.engine(node),
            SurrealLeaderLeaseManager::new(bench.client.clone()),
            timing,
        )
        .expect("planificateur")
    };
    let (a, b) = (leader("noeud-a"), leader("noeud-b"));
    let token = CancellationToken::new();
    assert!(a.run_once(&token).await.expect("tour").leader);
    // Le bail de a expire (nœud figé) et b le prend : nouvelle génération
    bench
        .client
        .query("UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1 WHERE kind = 'leader';")
        .await
        .and_then(|r| r.check())
        .expect("bail expiré");
    assert!(b.run_once(&token).await.expect("tour").leader);
    // Une planification devient due : a, qui ne sait pas encore qu'il a perdu le bail, est
    // refusé par la garde de génération dès sa première écriture et n'écrit rien
    let start_at = now_plus_ms(-150_000);
    let schedule = every_minute(&bench.store, "cloture", start_at, Overlap::AllowAll, None).await;
    bench.set_next(&schedule.id, start_at).await;
    let report = a.run_once(&token).await.expect("tour");
    assert!(!report.leader, "{report:?}");
    assert_eq!((report.fired, report.failed), (0, 0));
    assert!(runs_of(&bench, &schedule.id).await.is_empty());
    // a a oublié son bail : il ne planifie plus tant que b le tient ; b planifie
    assert!(!a.run_once(&token).await.expect("tour").leader);
    let report = b.run_once(&token).await.expect("tour");
    assert_eq!(report.fired, 3, "{report:?}");
}

#[tokio::test]
async fn rules_written_directly_below_one_minute_make_the_schedule_invalid() {
    let bench = bench().await;
    // Deux échéances par minute : refusées à l'écriture par `SchedulerService` (U1), mais
    // écrites ici directement en SurrealQL (`SchedulerStore`, sans contrôle des dates)
    let mut spec = ScheduleSpec::new("UTC");
    spec.cron = vec!["0 * * * * *".to_string(), "30 * * * * *".to_string()];
    let mut params = ScheduleCreateParams::new("trente-secondes", "essai.rapport", spec);
    params.tenant = Some(RecordId::new("auth_organization", "alpha"));
    params.args = Some(object(&[("format", "pdf")]));
    let schedule = bench
        .store
        .schedule_create(params)
        .await
        .expect("planification");
    let report = bench
        .leader("noeud-a")
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!((report.invalid, report.fired), (1, 0), "{report:?}");
    let reason: Option<String> = bench
        .query(
            "RETURN (SELECT VALUE invalid_reason FROM ONLY $run WHERE state = 'invalid');",
            &schedule.id,
        )
        .await;
    assert!(
        reason
            .as_deref()
            .is_some_and(|r| r.starts_with("min_interval")),
        "{reason:?}"
    );
}

#[tokio::test]
async fn the_pending_limit_caps_the_runs_of_a_turn() {
    let bench = bench().await;
    bench
        .store
        .settings_set(SettingsSetParams {
            tenant: Some(RecordId::new("auth_organization", "alpha")),
            max_pending_runs: Some(2),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglages");
    let start_at = now_plus_ms(-150_000);
    let schedule = every_minute(&bench.store, "limite", start_at, Overlap::AllowAll, None).await;
    bench.set_next(&schedule.id, start_at).await;
    let report = bench
        .leader("noeud-a")
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!((report.fired, report.limited), (2, 1), "{report:?}");
    assert_eq!(runs_of(&bench, &schedule.id).await.len(), 2);
}

#[tokio::test]
async fn a_handler_served_by_another_node_is_not_reported_missing() {
    let mut bench = bench().await;
    // Nœud b : tous les handlers, exécuteur de la file maintenance (il s'inscrit en réservant)
    let mut handlers = HandlerRegistry::new();
    for task in ["essai.rapport", "essai.lent", "essai.court", "essai.long"] {
        let (handler, ..) = waiter(task);
        handlers.register(Arc::new(handler)).expect("handler");
    }
    let node_b = SchedulerEngine::new(bench.store.clone(), handlers, NodeId::new("noeud-b"));
    let b = start(Arc::new(
        SchedulerExecutorWorker::with_timing(node_b, "maintenance", 1, exec_timing())
            .expect("exécuteur"),
    ));
    // Nœud a : aucun handler, exécuteurs de ses deux files
    bench.handlers = HandlerRegistry::new();
    let engine = bench.engine("noeud-a");
    let check = SchedulerHealthCheck::new(engine.clone());
    let a = ["default", "maintenance"].map(|queue| {
        start(Arc::new(
            SchedulerExecutorWorker::with_timing(engine.clone(), queue, 1, exec_timing())
                .expect("exécuteur"),
        ))
    });
    eventually("files servies", Duration::from_secs(5), || async {
        engine.executors().queues().len() == 2
    })
    .await;
    let ctx = ModuleContext::new("lyxal_scheduler");
    let mut report = check.check(&ctx).await.expect("sonde");
    for _ in 0..50 {
        if report.status == HealthStatus::Healthy {
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
        report = check.check(&ctx).await.expect("sonde");
    }
    assert_eq!(report.status, HealthStatus::Healthy, "{:?}", report.message);
    let message = report.message.unwrap_or_default();
    assert!(message.contains("servis par un autre nœud"), "{message}");
    assert!(message.contains("essai.rapport"), "{message}");
    b.stop(Duration::from_secs(5)).await;
    for worker in a {
        worker.stop(Duration::from_secs(5)).await;
    }
}

#[test]
fn a_second_handler_for_a_task_is_refused() {
    let mut registry = HandlerRegistry::new();
    let (first, ..) = waiter("essai.rapport");
    let (second, ..) = waiter("essai.rapport");
    let (bad, ..) = waiter("Essai Rapport");
    registry.register(Arc::new(first)).expect("premier");
    let refused = registry.register(Arc::new(second)).expect_err("doublon");
    assert_eq!(refused.code(), "SCHEDULER_INVALID_PARAMETERS");
    assert!(registry.register(Arc::new(bad)).is_err());
    assert_eq!(registry.tasks(), vec!["essai.rapport".to_string()]);
}

/// Journaux de tout le binaire de test capturés dans un tampon. Un abonné propre au fil du test
/// (`set_default`) perd des lignes quand d'autres tests tournent en parallèle (intérêt des points
/// de journal mis en cache par les autres fils) : l'abonné est donc global, installé une fois.
#[derive(Clone, Default)]
struct Captured(Arc<Mutex<Vec<u8>>>);

impl std::io::Write for Captured {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.0.lock().expect("journal").extend_from_slice(buf);
        Ok(buf.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

impl<'a> tracing_subscriber::fmt::MakeWriter<'a> for Captured {
    type Writer = Captured;

    fn make_writer(&'a self) -> Self::Writer {
        self.clone()
    }
}

fn captured_logs() -> &'static Captured {
    static CAPTURED: std::sync::OnceLock<Captured> = std::sync::OnceLock::new();
    CAPTURED.get_or_init(|| {
        let captured = Captured::default();
        let subscriber = tracing_subscriber::fmt()
            .with_writer(captured.clone())
            .with_max_level(tracing::Level::TRACE)
            .with_ansi(false)
            .finish();
        tracing::subscriber::set_global_default(subscriber).expect("abonné global des tests");
        captured
    })
}

#[tokio::test]
async fn no_lease_token_is_ever_logged() {
    let captured = captured_logs();

    let mut bench = bench().await;
    let (handler, started, _release, _cancelled) = waiter("essai.long");
    bench.handlers.register(Arc::new(handler)).expect("handler");
    let stubborn_started = Arc::new(Notify::new());
    bench
        .handlers
        .register(Arc::new(Stubborn {
            task: "essai.court",
            started: stubborn_started.clone(),
        }))
        .expect("handler");
    let cancelled_run = bench.enqueue("essai.long", None, None).await;
    let timed_out_run = bench.enqueue("essai.court", None, None).await;
    let executor = start(bench.executor("noeud-a", "default", 4));
    tokio::time::timeout(Duration::from_secs(5), started.notified())
        .await
        .expect("tentative commencée");
    tokio::time::timeout(Duration::from_secs(5), stubborn_started.notified())
        .await
        .expect("tentative commencée");
    let mut tokens = Vec::new();
    for run in [&cancelled_run, &timed_out_run] {
        let token: Option<String> = bench
            .query("RETURN (SELECT VALUE lease FROM ONLY $run);", run)
            .await;
        tokens.push(token.expect("jeton de bail lu par la session système"));
    }
    bench
        .store
        .run_cancel(RunCancelParams {
            run: cancelled_run.clone(),
            reason: None,
            language: None,
        })
        .await
        .expect("annulation demandée");
    bench
        .wait_state(&cancelled_run, "cancelled", Duration::from_secs(5))
        .await;
    bench
        .wait_state(&timed_out_run, "dead", Duration::from_secs(5))
        .await;
    // Une fin rejouée avec un jeton périmé est refusée sans écrire le jeton
    let stale = bench
        .store
        .run_heartbeat(RunHeartbeatParams {
            run: cancelled_run.clone(),
            lease: LeaseToken::from_value(Value::String(tokens[0].clone())).expect("jeton"),
            language: None,
        })
        .await;
    assert!(stale.is_err());
    executor.stop(Duration::from_secs(5)).await;

    let logs = String::from_utf8(captured.0.lock().expect("journal").clone()).expect("texte");
    assert!(logs.contains("exécution réservée"), "{logs}");
    assert!(logs.contains("annulation demandée"), "{logs}");
    for token in tokens {
        assert_eq!(token.len(), 36);
        assert!(!logs.contains(&token), "jeton de bail dans les journaux");
    }
}
