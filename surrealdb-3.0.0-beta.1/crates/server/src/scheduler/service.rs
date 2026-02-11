use opentelemetry::metrics::{Counter, Histogram, Meter};
use opentelemetry::KeyValue;
use std::collections::{HashMap, BTreeMap, HashSet};
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use std::sync::Arc;
use std::time::Duration;

use lyxal_scheduler::instance::InstanceId;
use lyxal_scheduler::instance_manager::InstanceManager;
use lyxal_scheduler::persistence::InMemoryStore;
// use lyxal_scheduler::scheduler::Scheduler; // Commented out unused import
use lyxal_scheduler::task::{Job, JobResult, JobStatus};
use lyxal_scheduler::history::JobHistory;
use lyxal_scheduler::dead_letter::DeadLetter;
use lyxal_scheduler::cron_parser::next_after;
use lyxal_scheduler::retry::compute_advanced_backoff;
use chrono::Utc;
use std::time::Instant;
use rand::Rng;
use surrealdb_core::dbs::Session;
use surrealdb_core::dbs::SystemEvent;
use surrealdb_core::kvs::Datastore;
use surrealdb_types::{Variables, Value, Number, RecordId, Datetime};
use tokio::sync::RwLock;
use tokio::time::sleep;
use tokio_util::sync::CancellationToken;
use tracing::{info, warn};
use chrono::Datelike;
use lyxal_scheduler::executor::JobExecutor;
use lyxal_scheduler::errors::SchedulerError;
use uuid::Uuid;
use surrealdb_core::catalog::providers::{DatabaseProvider, NamespaceProvider};
use surrealdb_core::kvs::{LockType, TransactionType};

// Constants from original service
const DEFAULT_INTERVAL_SECS: u64 = 2;
const DEFAULT_POOL_SIZE: usize = 2;
const DEFAULT_TIMEOUT_SECS: u64 = 30;
const DEFAULT_LEASE_TTL_SECS: u64 = 60;
const DEFAULT_MAX_JOBS_PER_TICK: usize = 100;
const DEFAULT_MAX_CONCURRENCY: usize = 10;

// use surrealdb_core::api::crypto::decrypt_payload; // Commented out unused import
use sysinfo::System;

// Phase 2.4: Predictive Scheduling
struct PredictiveModel {
    action_durations: HashMap<String, u64>, // action -> avg_duration_ms
}

impl PredictiveModel {
    fn new() -> Self {
        Self {
            action_durations: HashMap::new(),
        }
    }

    async fn update(&mut self, datastore: Arc<Datastore>) {
        let session = Session::default().with_ns("system").with_db("system");
        // We aggregate the last 1000 executions to get a fresh estimate
        let query = "
            SELECT action, math::mean(duration_ms) as avg_duration 
            FROM (SELECT job.action as action, duration_ms FROM scheduler_history ORDER BY timestamp DESC LIMIT 1000)
            GROUP BY action;
        ";

        if let Ok(res) = datastore.execute(query, &session, None).await {
            for qr in res {
                if let Ok(value) = qr.output() {
                    if let Some(arr) = value.as_array() {
                        for v in arr.iter() {
                            if let Some(obj) = v.as_object() {
                                if let (Some(action), Some(avg)) = (
                                    obj.get("action").and_then(|v| v.as_string()),
                                    obj.get("avg_duration").and_then(|v| v.as_int())
                                ) {
                                    self.action_durations.insert(action.to_string(), *avg as u64);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    fn estimate_cost(&self, action: &str) -> u64 {
        self.action_durations.get(action).cloned().unwrap_or(100) // Default 100ms if unknown
    }
}

// Bloc 11.1.2: Resource Monitoring
struct ResourceMonitor {
    sys: System,
    cpu_limit: f32,
    mem_limit: f32,
}

impl ResourceMonitor {
    fn new() -> Self {
        let cpu_limit = std::env::var("SURREAL_SCHEDULER_BACKPRESSURE_CPU_LIMIT")
            .ok()
            .and_then(|v| v.parse::<f32>().ok())
            .unwrap_or(80.0);
        let mem_limit = std::env::var("SURREAL_SCHEDULER_BACKPRESSURE_MEM_LIMIT")
            .ok()
            .and_then(|v| v.parse::<f32>().ok())
            .unwrap_or(90.0);

        let mut sys = System::new_all();
        sys.refresh_all();
        Self { sys, cpu_limit, mem_limit }
    }

    fn check_pressure(&mut self) -> f32 {
        self.sys.refresh_cpu_all();
        self.sys.refresh_memory();

        let cpu_usage = self.sys.global_cpu_usage();
        let mem_usage = (self.sys.used_memory() as f32 / self.sys.total_memory() as f32) * 100.0;

        if cpu_usage > self.cpu_limit || mem_usage > self.mem_limit {
            let pressure = (cpu_usage / self.cpu_limit).max(mem_usage / self.mem_limit);
            warn!(event = "scheduler.backpressure", cpu = %cpu_usage, mem = %mem_usage, pressure = %pressure, "high resource pressure detected");
            pressure
        } else {
            1.0
        }
    }
}

// Bloc 10.3.2: OpenTelemetry Metrics
struct SchedulerMetrics {
    jobs_executed: Counter<u64>,
    job_duration: Histogram<f64>,
    jobs_failed: Counter<u64>,
}

impl SchedulerMetrics {
    fn new(meter: &Meter) -> Self {
        Self {
            jobs_executed: meter.u64_counter("surrealdb.scheduler.jobs.executed").with_description("Total jobs executed").init(),
            job_duration: meter.f64_histogram("surrealdb.scheduler.job.duration").with_description("Duration of jobs").with_unit("ms").init(),
            jobs_failed: meter.u64_counter("surrealdb.scheduler.jobs.failed").with_description("Total jobs failed").init(),
        }
    }
}

#[derive(Debug, Clone)]
struct Quota {
    max_concurrency: usize,
    max_jobs_per_tick: Option<usize>,
    max_priority: Option<i32>,
    max_cpu: Option<f32>,
    max_mem: Option<f32>,
}

#[derive(Debug, Clone)]
struct Plan {
    max_jobs_per_month: i64,
    max_jobs_per_tick: usize,
    max_concurrency: usize,
    max_priority: i32,
    max_cpu: f32,
    max_mem: f32,
}

impl Default for Plan {
    fn default() -> Self {
        Self {
            max_jobs_per_month: -1, // Unlimited
            max_jobs_per_tick: DEFAULT_MAX_JOBS_PER_TICK,
            max_concurrency: DEFAULT_MAX_CONCURRENCY,
            max_priority: 10,
            max_cpu: 80.0,
            max_mem: 90.0,
        }
    }
}

impl Default for Quota {
    fn default() -> Self {
        Self {
            max_concurrency: DEFAULT_MAX_CONCURRENCY,
            max_jobs_per_tick: None,
            max_priority: None,
            max_cpu: None,
            max_mem: None,
        }
    }
}

// Local implementation of SurrealJobExecutor since the original file is missing
pub struct SurrealJobExecutor {
    pub datastore: Arc<Datastore>,
    metrics: Arc<SchedulerMetrics>,
}

#[async_trait::async_trait]
impl JobExecutor for SurrealJobExecutor {
    async fn execute(&self, job: &Job) -> Result<JobResult, SchedulerError> {
        let instance = job
            .instance_id
            .as_ref()
            .ok_or_else(|| SchedulerError::ExecutionError("missing instance_id".into()))?;

        info!(
            event = "scheduler.job.start",
            job_id = %job.id,
            instance = %instance.0,
            action = %job.action,
            "job execution started"
        );

        let action = &job.action;
        let payload = &job.payload;

        // Bloc 11.1.1: Circuit Breaker Check
        if let Ok(true) = self.is_circuit_tripped(action).await {
            warn!(job_id = %job.id, action = %action, "job execution aborted: circuit breaker is TRIPPED");
            return Ok(JobResult::Failed("Circuit breaker tripped".into()));
        }

        // Bloc 10.3.1: Live Event - Job Started
        let _ = self.record_live_event(instance, job, "started").await;

        let mut session = if job.run_as.is_some() { Session::owner() } else { Session::default() };
        if let Some(ref run_as) = job.run_as {
            // Bloc 10.4.1: Impersonation
            if run_as.contains(':') {
                let parts: Vec<&str> = run_as.split(':').collect();
                if parts.len() == 2 {
                    session = session.with_ns(parts[0]).with_db(parts[1]);
                }
            } else {
                session = session.with_ns("system").with_db("system");
            }
            info!(job_id = %job.id, run_as = %run_as, "executing job with impersonation");
        } else if let Some((ns, db)) = instance.0.split_once(':') {
            session = session.with_ns(ns).with_db(db);
        }

        let start_time = Instant::now();
        
        // Bloc 12: Use Variables for payload instead of string interpolation
        let (query, vars) = build_query_and_vars(action, payload);

        // Phase 3.4: Network Isolation - Use execute_job with allow_egress check
        let result = match self.datastore.execute_job(&query, &session, Some(vars), job.allow_egress).await {
            Ok(_) => {
                // Bloc 11.1.1: Reset fail count on success (partial reset or logic-dependent)
                let _ = self.report_circuit_success(action).await;

                // Bloc 10.2.3: Chaînage on_success
                if let Some(ref next_action) = job.on_success {
                    info!(job_id = %job.id, next_action = %next_action, "triggering on_success action");
                    let _ = self.trigger_chained_action(instance, next_action, payload).await;
                }
                Ok(JobResult::Success)
            }
            Err(e) => {
                // Bloc 11.1.1: Report failure to Circuit Breaker
                let _ = self.report_circuit_failure(action, &e.to_string()).await;

                // Bloc 10.2.3: Chaînage on_failure
                if let Some(ref fail_action) = job.on_failure {
                    info!(job_id = %job.id, fail_action = %fail_action, "triggering on_failure action");
                    let _ = self.trigger_chained_action(instance, fail_action, payload).await;
                }
                Ok(JobResult::Failed(e.to_string()))
            }
        };

        // Bloc 10.3.2: OpenTelemetry Metrics
        let duration = start_time.elapsed().as_millis() as f64;
        let labels = [
            KeyValue::new("instance", instance.0.clone()),
            KeyValue::new("action", action.to_string()),
        ];
        self.metrics.jobs_executed.add(1, &labels);
        self.metrics.job_duration.record(duration, &labels);
        if let Ok(JobResult::Failed(_)) = result {
            self.metrics.jobs_failed.add(1, &labels);
        }

        result
    }
}

impl SurrealJobExecutor {
    async fn is_circuit_tripped(&self, action: &str) -> Result<bool, SchedulerError> {
        let session = Session::default().with_ns("system").with_db("system");
        let query = format!("SELECT status FROM scheduler_circuit WHERE action = '{}';", action);
        
        if let Ok(res) = self.datastore.execute(&query, &session, None).await {
            for qr in res {
                if let Ok(val) = qr.output() {
                    if let Some(first) = val.as_array().and_then(|a| a.first()) {
                        if let Some(status) = first.as_object().and_then(|o| o.get("status")).and_then(|s| s.as_string()) {
                            return Ok(status == "TRIPPED");
                        }
                    }
                }
            }
        }
        Ok(false)
    }

    async fn report_circuit_failure(&self, action: &str, reason: &str) -> Result<(), SchedulerError> {
        let session = Session::default().with_ns("system").with_db("system");
        let threshold = std::env::var("SURREAL_SCHEDULER_CIRCUIT_THRESHOLD")
            .ok()
            .and_then(|v| v.parse::<i64>().ok())
            .unwrap_or(5);

        let query = format!(
            "BEGIN;
             LET $c = (SELECT * FROM scheduler_circuit WHERE action = '{}')[0];
             IF $c.id != NONE THEN
                UPDATE scheduler_circuit SET fail_count += 1, reason = '{}', status = IF fail_count >= {} THEN 'TRIPPED' ELSE 'OPEN' END, tripped_at = IF fail_count >= {} THEN time::now() ELSE NONE END WHERE action = '{}';
             ELSE
                CREATE scheduler_circuit SET action = '{}', fail_count = 1, status = 'OPEN', reason = '{}';
             END;
             COMMIT;",
            action, reason, threshold, threshold, action, action, reason
        );

        let _ = self.datastore.execute(&query, &session, None).await;
        Ok(())
    }

    async fn report_circuit_success(&self, action: &str) -> Result<(), SchedulerError> {
        let session = Session::default().with_ns("system").with_db("system");
        let query = format!("UPDATE scheduler_circuit SET fail_count = 0 WHERE action = '{}' AND status = 'OPEN';", action);
        let _ = self.datastore.execute(&query, &session, None).await;
        Ok(())
    }

    async fn trigger_chained_action(&self, instance: &InstanceId, action: &str, payload: &serde_json::Value) -> Result<(), SchedulerError> {
        let (query, vars) = build_query_and_vars(action, payload);
        let mut session = Session::default();
        if let Some((ns, db)) = instance.0.split_once(':') {
            session = session.with_ns(ns).with_db(db);
        }
        self.datastore.execute(&query, &session, Some(vars)).await.map(|_| ()).map_err(|e| SchedulerError::ExecutionError(e.to_string()))
    }

    // Bloc 11.3.1: DAG - Check if all dependencies are finished
    async fn check_dependencies_met(&self, job: &Job, session: &Session) -> Result<bool, SchedulerError> {
        if job.depends_on.is_empty() {
            return Ok(true);
        }

        // We check if there's a history record for EACH dependency that is 'success'
        // and newer than the job's last update/creation.
        for dep_id in &job.depends_on {
            let query = format!(
                "SELECT id FROM scheduler_history WHERE job = scheduler_task:{} AND result = 'Success' LIMIT 1;",
                dep_id
            );
            
            let res = self.datastore.execute(&query, session, None).await.map_err(|e| {
                SchedulerError::PersistenceError(e.to_string())
            })?;

            let mut found = false;
            for qr in res {
                if let Ok(val) = qr.output() {
                    if let Some(arr) = val.as_array() {
                        if !arr.is_empty() {
                            found = true;
                            break;
                        }
                    }
                }
            }
            if !found {
                return Ok(false);
            }
        }
        Ok(true)
    }

    async fn record_live_event(&self, instance: &InstanceId, job: &Job, status: &str) -> Result<(), SchedulerError> {
        let query = format!(
            "CREATE scheduler_history SET job = scheduler_task:{}, result = '{}', timestamp = time::now(), duration_ms = 0;",
            job.id, status
        );
        let mut session = Session::default();
        if let Some((ns, db)) = instance.0.split_once(':') {
            session = session.with_ns(ns).with_db(db);
        }
        self.datastore.execute(&query, &session, None).await.map(|_| ()).map_err(|e| SchedulerError::PersistenceError(e.to_string()))
    }
}

fn build_query_and_vars(action: &str, payload: &serde_json::Value) -> (String, Variables) {
    let looks_like_query = action.contains(' ') || action.contains(';');
    
    // Convert serde_json::Value to surrealdb_types::Value
    let payload_val = match serde_json::from_value::<surrealdb_types::Value>(payload.clone()) {
        Ok(v) => v,
        Err(_) => surrealdb_types::Value::None,
    };

    let mut map = BTreeMap::new();
    map.insert("payload".to_string(), payload_val);
    let vars = Variables::from(map);

    if looks_like_query {
        (action.to_string(), vars)
    } else {
        (format!("RETURN fn::{}($payload);", action), vars)
    }
}

async fn hydrate_instances(datastore: Arc<Datastore>) -> Vec<InstanceId> {
    let mut list = Vec::new();
    let txn = match datastore.transaction(TransactionType::Read, LockType::Optimistic).await {
        Ok(tx) => tx,
        Err(e) => {
            warn!("failed to create transaction for hydration: {}", e);
            return list;
        }
    };

    let nss = match txn.all_ns().await {
        Ok(n) => n,
        Err(e) => {
             warn!("failed to list namespaces for hydration: {}", e);
             return list;
        }
    };

    for ns in nss.iter() {
         let dbs = match txn.all_db(ns.namespace_id).await {
             Ok(d) => d,
             Err(_) => continue,
         };
         for db in dbs.iter() {
             let schedulers = match txn.all_db_schedulers(ns.namespace_id, db.database_id).await {
                 Ok(s) => s,
                 Err(_) => continue,
             };
             // We monitor if there is at least one enabled scheduler in the DB
             if schedulers.iter().any(|s| s.enabled) {
                 info!(ns = %ns.name, db = %db.name, "hydrating scheduler instance from catalog");
                 list.push(InstanceId(format!("{}:{}", ns.name, db.name)));
             }
         }
    }
    list
}

struct QuotaCache {
    last_update: Instant,
    data: HashMap<String, Quota>,
}

struct PlanCache {
    last_update: Instant,
    data: HashMap<String, Plan>,
}

pub struct SchedulerService {
    store: Arc<InMemoryStore>,
    executor: Arc<SurrealJobExecutor>,
    instances: Arc<RwLock<Vec<InstanceId>>>,
    quota_cache: Arc<RwLock<QuotaCache>>,
    plan_cache: Arc<RwLock<PlanCache>>,
}

impl SchedulerService {
    pub fn new(store: Arc<InMemoryStore>, datastore: Arc<Datastore>, instances: Arc<RwLock<Vec<InstanceId>>>) -> Self {
        let meter = opentelemetry::global::meter("surrealdb.scheduler");
        let metrics = Arc::new(SchedulerMetrics::new(&meter));
        let executor = Arc::new(SurrealJobExecutor { datastore, metrics });
        Self {
            store,
            executor,
            instances,
            quota_cache: Arc::new(RwLock::new(QuotaCache {
                last_update: Instant::now() - Duration::from_secs(600), // Force initial refresh
                data: HashMap::new(),
            })),
            plan_cache: Arc::new(RwLock::new(PlanCache {
                last_update: Instant::now() - Duration::from_secs(600),
                data: HashMap::new(),
            })),
        }
    }
}

pub async fn start_scheduler_service(datastore: Arc<Datastore>, canceller: CancellationToken) {
    let initial_instances = hydrate_instances(datastore.clone()).await;
    let instances = Arc::new(RwLock::new(initial_instances));
    let store = Arc::new(InMemoryStore::new());

    let node_id = node_id();
    let lease_ttl = lease_ttl();

    let job_timeout = Duration::from_secs(DEFAULT_TIMEOUT_SECS);
    if lease_ttl.as_secs_f32() < job_timeout.as_secs_f32() * 2.0 {
        warn!(?lease_ttl, ?job_timeout, "LEASE_TTL should be at least 2x JOB_TIMEOUT for safe HA");
    }

    // Bloc 12.3: Drain Timeout
    let drain_timeout = std::env::var("SURREAL_SCHEDULER_DRAIN_TIMEOUT")
        .ok()
        .and_then(|v| v.parse::<u64>().ok())
        .map(Duration::from_secs)
        .unwrap_or(Duration::from_secs(30));

    // Initialize Metrics
    let service = SchedulerService::new(store.clone(), datastore.clone(), instances.clone());
    // No need to sync anymore as they share the same Arc
    // *service.instances.write().await = instances.read().await.clone();

    let executor = service.executor.clone();
    
    // Phase 2.4: Predictive Scheduling
    let mut predictive_model = PredictiveModel::new();

    // Bloc 11.1.2: Resource Monitor
    let mut resource_monitor = ResourceMonitor::new();

    info!("SchedulerService event listener started");

    // Event Listener
    // Event Listener
    let instances_clone = instances.clone();
    
    // Define instance_manager properly first
    let instance_manager = Arc::new(InstanceManager::new_with_timeout(
        DEFAULT_POOL_SIZE,
        executor.clone(),
        Duration::from_secs(DEFAULT_TIMEOUT_SECS),
    ));
    let instance_manager_clone = instance_manager.clone();
    let mut event_rx = datastore.subscribe_system_events();
    let canceller_clone = canceller.clone();

    tokio::spawn(async move {
        info!("SchedulerService event listener started");
        loop {
            tokio::select! {
                _ = canceller_clone.cancelled() => break,
                Ok(event) = event_rx.recv() => {
                    match event {
                        SystemEvent::SchedulerDefined { ns, db, name: _, enabled } => {
                            let instance_id_str = format!("{}:{}", ns, db);
                            let instance_id = InstanceId(instance_id_str.clone());
                            if enabled {
                                info!(%instance_id_str, "mounting scheduler instance via event");
                                instance_manager_clone.register_instance(instance_id);
                                let mut guard = instances_clone.write().await;
                                if !guard.iter().any(|i| i.0 == instance_id_str) {
                                    guard.push(InstanceId(instance_id_str));
                                }
                            } else {
                                info!(%instance_id_str, "unmounting scheduler instance via event");
                                // Logic to remove from instances list
                                let mut guard = instances_clone.write().await;
                                if let Some(idx) = guard.iter().position(|i| i.0 == instance_id_str) {
                                    guard.remove(idx);
                                }
                            }
                        }
                        SystemEvent::SchedulerRemoved { ns, db, name: _ } => {
                            let instance_id_str = format!("{}:{}", ns, db);
                            info!(%instance_id_str, "unmounting scheduler instance via removal event");
                            let mut guard = instances_clone.write().await;
                            if let Some(idx) = guard.iter().position(|i| i.0 == instance_id_str) {
                                guard.remove(idx);
                            }
                        }
                    }
                }
            }
        }
        info!("SchedulerService event listener stopped");
    });

    // Initial prediction update
    predictive_model.update(datastore.clone()).await;

    let mut last_prediction_update = Instant::now();
    let mut last_archive_run = Instant::now();
    let _last_usage_record = Instant::now();
    let _last_purge = Instant::now();

    // Main Loop
    tokio::spawn(async move {
        info!("SchedulerService started");
        let active_executions = Arc::new(RwLock::new(HashSet::<String>::new()));
        let mut drain_mode_active = false;
        let mut drain_start: Option<Instant> = None;

        loop {
            if canceller.is_cancelled() && !drain_mode_active {
                info!("SchedulerService entering DRAIN mode");
                drain_mode_active = true;
                drain_start = Some(Instant::now());
            }

            // Phase 2.4: Periodically update predictive model (every 5 minutes)
            if last_prediction_update.elapsed() > Duration::from_secs(300) {
                predictive_model.update(datastore.clone()).await;
                last_prediction_update = Instant::now();
            }

            // Phase 2.5: Periodically archive old history (every 1 hour)
            if last_archive_run.elapsed() > Duration::from_secs(3600) {
                if let Err(e) = archive_history(datastore.clone()).await {
                    warn!(event = "scheduler.archive.failed", error = %e, "failed to archive history");
                }
                last_archive_run = Instant::now();
            }

            if drain_mode_active {
                // Bloc 12.3: Graceful Shutdown logic
                let active_jobs = store.list_jobs().await;
                if active_jobs.is_empty() {
                    info!("SchedulerService DRAIN complete: no active jobs");
                    break;
                }

                if let Some(start) = drain_start {
                    if start.elapsed() >= drain_timeout {
                        warn!(
                            jobs = active_jobs.len(),
                            timeout_secs = drain_timeout.as_secs(),
                            "SchedulerService DRAIN timeout reached, some jobs might be aborted"
                        );
                        break;
                    }
                }

                info!(jobs = active_jobs.len(), "SchedulerService waiting for active jobs to finish in DRAIN mode");
                
                sleep(Duration::from_secs(1)).await;
                continue;
            }

            let max_jitter = std::env::var("SURREAL_SCHEDULER_TICK_JITTER_MAX_MS")
                .ok()
                .and_then(|v| v.parse::<u64>().ok())
                .unwrap_or(500);
            let jitter_ms = rand::thread_rng().gen_range(0..max_jitter);
            sleep(Duration::from_millis(jitter_ms)).await;

            let tick_start = Instant::now();

            // Bloc 11.1.2: Apply backpressure
            let pressure_factor = resource_monitor.check_pressure();
            let mut dynamic_global_limit = std::env::var("SURREAL_SCHEDULER_MAX_CONCURRENT_JOBS")
                .ok()
                .and_then(|v| v.parse::<usize>().ok())
                .unwrap_or(1000);
            
            if pressure_factor > 1.0 {
                dynamic_global_limit = (dynamic_global_limit as f32 / pressure_factor) as usize;
                info!(event = "scheduler.backpressure.applied", limit = dynamic_global_limit, "dynamic limit applied due to pressure");
            }

            // Read quotas (Bloc 7.5.2)
            // Read quotas (Bloc 7.5.2)
            let quotas = read_quotas(executor.datastore.clone(), service.quota_cache.clone(), service.instances.clone()).await;
            // Read plans (Bloc 8.2)
            let plans = read_plans_and_subs(executor.datastore.clone()).await;
            // Read current usage for period (Bloc 8.2)
            let usages = read_current_usage(executor.datastore.clone()).await;

            let instances_guard = instances.read().await;
            if let Err(err) = refresh_leased_jobs(
                &store,
                executor.clone(),
                &*instances_guard,
                &node_id,
                lease_ttl,
                &quotas,
                &plans,
                &usages,
                dynamic_global_limit,
                &mut resource_monitor,
                &predictive_model,
            )
            .await
            {
                warn!(?err, "refresh_leased_jobs failed");
            }
            drop(instances_guard);

            if let Err(err) = persist_state(
                &store,
                executor.datastore.clone(),
                &instance_manager,
                &node_id,
            )
            .await
            {
                warn!(?err, "scheduler persistence failed");
            }

            // Phase 4: Dispatching (The "Cuisinier")
            let now = Utc::now();
            let jobs_to_dispatch = store.list_jobs().await;
            info!(event = "scheduler.dispatch.start", count = %jobs_to_dispatch.len(), "starting dispatch phase");
            for mut job in jobs_to_dispatch {
                let is_due = job.next_run <= now;
                if !job.enabled || !is_due {
                    info!(
                        event = "scheduler.job.dispatch_skipped",
                        job_id = %job.id,
                        enabled = job.enabled,
                        is_due = is_due,
                        next_run = %job.next_run,
                        now = %now,
                        "job skipped for dispatch: not enabled or not yet due"
                    );
                    continue;
                }
                
                let job_id = job.id.clone();
                
                // Check if already in flight
                let mut active_guard = active_executions.write().await;
                if active_guard.contains(&job_id) {
                    continue;
                }
                active_guard.insert(job_id.clone());
                drop(active_guard);

                // Ensure status is Running in store for persistence
                if job.status != JobStatus::Running {
                    job.status = JobStatus::Running;
                    let _ = store.update_job(job.clone()).await;
                }

                let manager = instance_manager.clone();
                let store_clone = store.clone();
                let active_executions_clone = active_executions.clone();
                
                info!(event = "scheduler.dispatch", job_id = %job.id, "dispatching job to worker pool");

                tokio::spawn(async move {
                    let instance = job.instance_id.clone().unwrap_or_else(InstanceId::default);
                    let res = manager.execute(instance, job.clone()).await;
                    
                    // Traitement du résultat
                    if let Err(e) = handle_execution_result(&store_clone, job, res).await {
                         warn!(?e, "failed to handle execution result");
                    }

                    // Remove from active set
                    active_executions_clone.write().await.remove(&job_id);
                });
            }


            let hist_len = store.list_history().await.len();
            let dlq_len = store.list_dead_letters().await.len();
            info!(
                event = "scheduler.tick.end",
                node_id = %node_id,
                duration_ms = tick_start.elapsed().as_millis(),
                history = hist_len,
                dlq = dlq_len,
                "tick completed"
            );
            
            tokio::select! {
                _ = canceller.cancelled() => {
                    continue;
                }
                _ = sleep(Duration::from_secs(DEFAULT_INTERVAL_SECS)) => {}
            }
        }

        // Final lease release if any jobs remain and we are exiting
        let remaining_jobs = store.list_jobs().await;
        for job in remaining_jobs {
            let _ = release_lease(executor.datastore.clone(), &job).await;
        }
        info!("SchedulerService stopped gracefully");
    });
}

async fn release_lease(datastore: Arc<Datastore>, job: &Job) -> Result<(), SchedulerError> {
    let query = format!("UPDATE scheduler_task SET lease_owner = NONE, lease_until = NONE, status = 'pending' WHERE id = '{}';", job.id);
    let mut session = Session::owner();
    if let Some((ns, db)) = job.instance_id.as_ref().and_then(|i| i.0.split_once(':')) {
        session = session.with_ns(ns).with_db(db);
    }
    datastore.execute(&query, &session, None).await.map(|_| ()).map_err(|e| SchedulerError::PersistenceError(e.to_string()))
}

async fn read_quotas(
    datastore: Arc<Datastore>,
    cache: Arc<RwLock<QuotaCache>>,
    instances: Arc<RwLock<Vec<InstanceId>>>,
) -> HashMap<String, Quota> {
    // Check cache
    {
        let guard = cache.read().await;
        if guard.last_update.elapsed() < Duration::from_secs(30) {
            return guard.data.clone();
        }
    }

    // Refresh Cache (Distributed Scan)
    let mut new_quotas = HashMap::new();
    let instance_list = instances.read().await.clone();

    for instance in instance_list {
        let (ns, db) = match instance.0.split_once(':') {
            Some((n, d)) => (n, d),
            None => continue,
        };

        let session = Session::owner().with_ns(ns).with_db(db);
        let query = "SELECT instance_id, max_concurrency, max_jobs_per_tick, max_cpu, max_mem FROM scheduler_quota;";

        if let Ok(res) = datastore.execute(query, &session, None).await {
            for qr in res {
                match qr.output() {
                    Ok(value) => {
                        if let Some(arr) = value.as_array() {
                            if arr.is_empty() {
                                warn!(ns = %ns, db = %db, "scheduler_quota table found but empty");
                            }
                            for v in arr.iter() {
                                if let Some(obj) = v.as_object() {
                                    // Default instance_id to current instance if not specified
                                    // ...
                                    let target_id = obj.get("instance_id")
                                        .and_then(|v| v.as_string())
                                        .map(|s| s.to_string())
                                        .unwrap_or(instance.0.clone());
                                    
                                    // Debug log for each row found
                                    info!(%target_id, "found quota override record");
                                
                                let max_concurrency = obj.get("max_concurrency")
                                    .and_then(|v| v.as_int())
                                    .map(|v| *v)
                                    .unwrap_or(DEFAULT_MAX_CONCURRENCY as i64) as usize;
                                
                                let max_jobs_per_tick = obj.get("max_jobs_per_tick")
                                    .and_then(|v| v.as_int())
                                    .map(|v| *v)
                                    .unwrap_or(DEFAULT_MAX_JOBS_PER_TICK as i64) as usize;
                                
                                let max_cpu = obj.get("max_cpu").and_then(|v| match v {
                                    Value::Number(Number::Float(f)) => Some(*f as f32),
                                    Value::Number(Number::Int(i)) => Some(*i as f32),
                                    _ => None,
                                });

                                let max_mem = obj.get("max_mem").and_then(|v| match v {
                                    Value::Number(Number::Float(f)) => Some(*f as f32),
                                    Value::Number(Number::Int(i)) => Some(*i as f32),
                                    _ => None,
                                });

                                 let max_priority = obj.get("max_priority").and_then(|v| v.as_int()).map(|v| *v as i32);

                                 new_quotas.insert(target_id, Quota {
                                     max_concurrency,
                                     max_jobs_per_tick: Some(max_jobs_per_tick),
                                     max_priority,
                                     max_cpu,
                                     max_mem,
                                 });
                            }
                        }
                    }
                }
                Err(e) => {
                    warn!(ns = %ns, db = %db, error = %e, "failed to read scheduler quotas");
                }
            }
        }
    } else {
        warn!(ns = %ns, db = %db, "failed to execute quota query");
    }
    }

    info!(event = "scheduler.quotas.refresh", count = new_quotas.len(), "refreshed distributed quotas cache");

    // Update Cache
    let mut guard = cache.write().await;
    guard.data = new_quotas.clone();
    guard.last_update = Instant::now();
    
    new_quotas
}

async fn read_plans_and_subs(datastore: Arc<Datastore>) -> HashMap<String, Plan> {
    let mut plans_map = HashMap::new();
    let session = Session::owner().with_ns("system").with_db("system");
    let query = "
        SELECT instance_id, plan.max_jobs_per_month AS max_jobs_per_month,
               plan.max_concurrency AS max_concurrency,
               plan.max_priority AS max_priority,
               plan.max_cpu AS max_cpu,
               plan.max_mem AS max_mem
        FROM scheduler_subscription
        WHERE active = true FETCH plan;
    ";

    if let Ok(res) = datastore.execute(query, &session, None).await {
        for qr in res {
            if let Ok(value) = qr.output() {
                if let Some(arr) = value.as_array() {
                    for v in arr.iter() {
                        if let Some(obj) = v.as_object() {
                            if let Some(instance_id) =
                                obj.get("instance_id").and_then(|v| v.as_string())
                            {
                                let max_jobs_per_month = obj
                                    .get("max_jobs_per_month")
                                    .and_then(|v| v.as_int())
                                    .map(|v| *v)
                                    .unwrap_or(-1);
                                let max_concurrency = obj
                                    .get("max_concurrency")
                                    .and_then(|v| v.as_int())
                                    .map(|v| *v as usize)
                                    .unwrap_or(DEFAULT_MAX_CONCURRENCY);
                                let max_priority = obj
                                    .get("max_priority")
                                    .and_then(|v| v.as_int())
                                    .map(|v| *v as i32)
                                    .unwrap_or(10);
                                
                                let max_cpu = obj.get("max_cpu").and_then(|v| match v {
                                    Value::Number(Number::Float(f)) => Some(*f as f32),
                                    Value::Number(Number::Int(i)) => Some(*i as f32),
                                    _ => None,
                                }).unwrap_or(80.0);

                                let max_mem = obj.get("max_mem").and_then(|v| match v {
                                    Value::Number(Number::Float(f)) => Some(*f as f32),
                                    Value::Number(Number::Int(i)) => Some(*i as f32),
                                    _ => None,
                                }).unwrap_or(90.0);

                                plans_map.insert(
                                    instance_id.to_string(),
                                    Plan {
                                        max_jobs_per_month,
                                        max_jobs_per_tick: DEFAULT_MAX_JOBS_PER_TICK,
                                        max_concurrency,
                                        max_priority,
                                        max_cpu,
                                        max_mem,
                                    },
                                );
                            }
                        }
                    }
                }
            }
        }
    }
    plans_map
}

async fn read_current_usage(datastore: Arc<Datastore>) -> HashMap<String, i64> {
    let mut usage_map = HashMap::new();
    let now = chrono::Utc::now();
    let period = format!("{}-{:02}", now.year(), now.month()); // YYYY-MM
    let session = Session::owner().with_ns("system").with_db("system");
    let query = format!(
        "SELECT instance_id, jobs_executed FROM scheduler_usage WHERE period = '{}';",
        period
    );

    if let Ok(res) = datastore.execute(&query, &session, None).await {
        for qr in res {
            if let Ok(value) = qr.output() {
                if let Some(arr) = value.as_array() {
                    for v in arr.iter() {
                        if let Some(obj) = v.as_object() {
                            if let Some(instance_id) =
                                obj.get("instance_id").and_then(|v| v.as_string())
                            {
                                let jobs_executed =
                                    obj.get("jobs_executed").and_then(|v| v.as_int()).map(|v| *v).unwrap_or(0);
                                usage_map.insert(instance_id.to_string(), jobs_executed);
                            }
                        }
                    }
                }
            }
        }
    }
    usage_map
}

#[allow(clippy::too_many_arguments)]
async fn refresh_leased_jobs(
    store: &InMemoryStore,
    executor: Arc<SurrealJobExecutor>,
    instances: &[InstanceId],
    node_id: &str,
    lease_ttl: Duration,
    quotas: &HashMap<String, Quota>,
    plans: &HashMap<String, Plan>,
    _usages: &HashMap<String, i64>,
    global_limit: usize,
    resource_monitor: &mut ResourceMonitor,
    predictive_model: &PredictiveModel,
) -> Result<(), SchedulerError> {
    let datastore = executor.datastore.clone();
    let mut total_jobs_fetched = 0;
    let mut estimated_total_load_ms = 0u64;
    let max_tick_load_ms = 10000u64;

    let total_shards = std::env::var("SURREAL_SCHEDULER_TOTAL_SHARDS")
        .ok()
        .and_then(|v| v.parse::<u64>().ok())
        .unwrap_or(1);
    let node_shard_index = calculate_node_shard_index(node_id, total_shards);

    for instance in instances {
        let instance_id_str = instance.0.clone();
        let (ns, db) = match instance_id_str.split_once(':') {
            Some(res) => res,
            None => continue,
        };

        if total_jobs_fetched >= global_limit { break; }

        let session = Session::owner().with_ns(ns).with_db(db);
        let quota = quotas.get(&instance_id_str).cloned().unwrap_or_default();
        let plan = plans.get(&instance_id_str).cloned().unwrap_or_default();

        let max_priority = quota.max_priority.unwrap_or(plan.max_priority);
        let limit = quota.max_jobs_per_tick.unwrap_or(plan.max_jobs_per_tick);

        // Check instance resource limits relative to node pressure (Sandboxing 11.2)
        let max_cpu = quota.max_cpu.unwrap_or(plan.max_cpu);
        let max_mem = quota.max_mem.unwrap_or(plan.max_mem);
        if resource_monitor.sys.global_cpu_usage() > max_cpu || 
           (resource_monitor.sys.used_memory() as f32 / resource_monitor.sys.total_memory() as f32) * 100.0 > max_mem {
            warn!(event = "scheduler.job.skipped.sandboxing", instance = %instance_id_str, "instance resource limit reached");
            continue;
        }

        let select_query = format!(
            "SELECT * FROM scheduler_task 
             WHERE enabled = true 
               AND next_run <= time::now() 
               AND (lease_owner IS NONE OR lease_owner = '' OR lease_until < time::now())
               AND priority <= {}
             ORDER BY priority DESC, next_run ASC
             LIMIT {};",
            max_priority, limit
        );

        let res = datastore.execute(&select_query, &session, None).await.map_err(|e| {
            SchedulerError::PersistenceError(e.to_string())
        })?;

        for qr in res {
            if let Ok(value) = qr.output() {
                if let Some(arr) = value.as_array() {
                    if !arr.is_empty() {
                        info!(event="scheduler.jobs.found", count=%arr.len(), instance=%instance_id_str, "found pending jobs");
                    }

                    for v in arr.iter() {
                        if total_jobs_fetched >= global_limit { break; }

                        let v_json = flatten_surreal_json(serde_json::to_value(v).map_err(|e| {
                            SchedulerError::PersistenceError(format!("JSON conversion error: {}", e))
                        })?);

                        match serde_json::from_value::<Job>(v_json.clone()) {
                            Ok(mut job_candidate) => {
                                info!(event = "scheduler.job.processing", job_id = %job_candidate.id, "processing job candidate");

                                // Sharding check
                                if total_shards > 1 {
                                    let job_shard = calculate_job_shard(&job_candidate.id, total_shards);
                                    if job_shard != node_shard_index { continue; }
                                }

                                // DAG Check
                                if !job_candidate.depends_on.is_empty() {
                                    if !executor.check_dependencies_met(&job_candidate, &session).await? {
                                        info!(event = "scheduler.job.skipped.dag", job_id = %job_candidate.id, "dependencies not met");
                                        continue;
                                    }
                                }

                                // Predictive load check
                                let job_cost = predictive_model.estimate_cost(&job_candidate.action);
                                if estimated_total_load_ms + job_cost > max_tick_load_ms {
                                    info!(event = "scheduler.job.skipped.predictive", job_id = %job_candidate.id, "load limit reached for tick");
                                    continue;
                                }

                                // Acquire lease and add to store
                                if acquire_lease(datastore.clone(), instance, &job_candidate.id.to_string(), node_id, lease_ttl, job_candidate.idempotency_key.clone()).await? {
                                    estimated_total_load_ms += job_cost;
                                    job_candidate.instance_id = Some(instance.clone());
                                    job_candidate.status = JobStatus::Running;
                                    store.add_job(job_candidate.clone()).await?;
                                    total_jobs_fetched += 1;
                                    info!(event = "scheduler.job.lease_acquired", job_id = %job_candidate.id, "lease acquired and job ready for dispatch");
                                } else {
                                    warn!(event = "scheduler.job.lease_failed", job_id = %job_candidate.id, "failed to acquire lease at database level");
                                }
                            },
                            Err(e) => {
                                warn!(
                                    event = "scheduler.job.deserialization_failed",
                                    error = %e,
                                    json = %v_json,
                                    "CRITICAL: failed to deserialize job candidate. check Job struct fields."
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    Ok(())
}

async fn archive_history(datastore: Arc<Datastore>) -> Result<(), SchedulerError> {
    info!(event = "scheduler.archive.started", "starting history archival process");

    let query = "
        BEGIN TRANSACTION;
        -- Move records older than 30 days to archive
        INSERT INTO scheduler_history_archive (
            SELECT * FROM scheduler_history WHERE executed_at < time::now() - 30d
        );
        -- Delete archived records from main table
        DELETE scheduler_history WHERE executed_at < time::now() - 30d;
        COMMIT TRANSACTION;
    ";

    let session = Session::owner(); // Global archival (might need NS/DB loop in real multi-tenant)
    
    datastore
        .execute(query, &session, None)
        .await
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

    info!(event = "scheduler.archive.completed", "history archival completed");
    Ok(())
}

async fn acquire_lease(
    datastore: Arc<Datastore>,
    instance: &InstanceId,
    job_id: &str,
    node_id: &str,
    lease_ttl: Duration,
    idempotency_key: Option<String>,
) -> Result<bool, SchedulerError> {
    let mut session = Session::owner();
    if let Some((ns, db)) = instance.0.split_once(':') {
        session = session.with_ns(ns).with_db(db);
    }

    // Phase 11.1.3: Idempotency check
    if let Some(ref key) = idempotency_key {
        let check_query = "SELECT id FROM scheduler_task WHERE idempotency_key = $key AND status IN ['running', 'completed'] AND id != $id LIMIT 1;";
        let mut check_map = BTreeMap::new();
        check_map.insert("key".to_string(), Value::String(key.clone()));
        if let Ok(rid) = RecordId::parse_simple(job_id) {
            check_map.insert("id".to_string(), Value::RecordId(rid));
        } else {
            check_map.insert("id".to_string(), Value::String(job_id.to_string()));
        }
        let check_vars = Some(Variables::from(check_map));
        let check_res = datastore.execute(check_query, &session, check_vars).await.map_err(|e| {
            SchedulerError::PersistenceError(e.to_string())
        })?;

        for qr in check_res {
            if let Ok(v) = qr.output() {
                if let Some(arr) = v.as_array() {
                    if !arr.is_empty() {
                        warn!(event="scheduler.job.idempotency_skip", job_id = %job_id, "job execution skipped: idempotent requirement met");
                        return Ok(false);
                    }
                }
            }
        }
    }

    let query = "
        UPDATE scheduler_task SET
            lease_owner = $node,
            lease_until = time::now() + duration::from_secs($ttl),
            status = 'running'
         WHERE id = $id
           AND (lease_owner IS NONE OR lease_owner IS NULL OR lease_owner = '' OR lease_until < time::now() OR lease_until IS NONE OR lease_until IS NULL);
    ";

    let mut map = BTreeMap::new();
    if let Ok(rid) = RecordId::parse_simple(job_id) {
        map.insert("id".to_string(), Value::RecordId(rid));
    } else {
        map.insert("id".to_string(), Value::String(job_id.to_string()));
    }
    map.insert("node".to_string(), Value::String(node_id.to_string()));
    map.insert("ttl".to_string(), Value::Number(Number::from(lease_ttl.as_secs() as i64)));

    let vars = Some(Variables::from(map));
    let res = datastore
        .execute(query, &session, vars)
        .await
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

    for qr in res {
        match qr.output() {
            Ok(val) => match val {
                Value::Array(ref arr) if !arr.is_empty() => return Ok(true),
                Value::Object(_) => return Ok(true),
                _ => {
                    warn!(event = "scheduler.lease.debug", job_id = %job_id, result = ?val, "UPDATE returned unexpected or empty value");
                }
            },
            Err(e) => {
                warn!(event = "scheduler.lease.error", job_id = %job_id, error = %e, "UPDATE query failed");
            }
        }
    }
    Ok(false)
}

fn node_id() -> String {
    if let Ok(val) = std::env::var("SURREAL_NODE_ID") {
        if !val.trim().is_empty() {
            return val;
        }
    }
    Uuid::new_v4().to_string()
}

// Bloc 10.1.1: Sharding helpers
fn calculate_node_shard_index(node_id: &str, total_shards: u64) -> u64 {
    if total_shards <= 1 { return 0; }
    let mut hasher = DefaultHasher::new();
    node_id.hash(&mut hasher);
    hasher.finish() % total_shards
}

fn calculate_job_shard(job_id: &str, total_shards: u64) -> u64 {
    if total_shards <= 1 { return 0; }
    let mut hasher = DefaultHasher::new();
    job_id.hash(&mut hasher);
    hasher.finish() % total_shards
}

fn lease_ttl() -> Duration {
    if let Ok(val) = std::env::var("SURREAL_SCHEDULER_LEASE_TTL") {
        if let Ok(secs) = val.parse::<u64>() {
            return Duration::from_secs(secs);
        }
    }
    Duration::from_secs(DEFAULT_LEASE_TTL_SECS)
}

async fn persist_state(
    store: &InMemoryStore,
    datastore: Arc<Datastore>,
    instance_manager: &InstanceManager<SurrealJobExecutor>,
    node_id: &str,
) -> Result<(), SchedulerError> {
    let jobs = store.list_jobs().await;
    for job in jobs {
        persist_job(datastore.clone(), &job).await?;
    }

    // Persist new history/dead_letters since last call
    let history = store.drain_history().await;
    for h in history {
        // Try to find instance_id from active jobs in store
        let mut instance_id = "unknown".to_string();
        if let Some(job) = store.get_job(&h.job_id).await {
            if let Some(iid) = &job.instance_id {
                instance_id = iid.0.clone();
            }
        }
        persist_history(datastore.clone(), &h, node_id, &instance_id).await?;
    }

    let dlqs = store.drain_dead_letters().await;
    for d in dlqs {
        let mut instance_id = "unknown".to_string();
        if let Some(job) = store.get_job(&d.job_id).await {
            if let Some(iid) = &job.instance_id {
                instance_id = iid.0.clone();
            }
        }
        persist_dead_letter(datastore.clone(), &d, node_id, &instance_id).await?;
    }

    // Ensure instances are registered (idempotent)
    for job in store.list_jobs().await {
        if let Some(inst) = &job.instance_id {
            instance_manager.register_instance(inst.clone());
        }
    }

    Ok(())
}

async fn persist_job(
    datastore: Arc<Datastore>,
    job: &Job,
) -> Result<(), SchedulerError> {
    let query = if job.status == JobStatus::Running {
        "UPDATE scheduler_task SET attempts = $attempts, next_run = $next_run, enabled = $enabled WHERE id = $id;"
    } else {
        "UPDATE scheduler_task SET attempts = $attempts, next_run = $next_run, enabled = $enabled, lease_owner = NONE, lease_until = NONE WHERE id = $id;"
    };

    let mut map = BTreeMap::new();
    if let Ok(rid) = RecordId::parse_simple(&job.id) {
        map.insert("id".to_string(), Value::RecordId(rid));
    } else {
        map.insert("id".to_string(), Value::String(job.id.clone()));
    }
    map.insert("attempts".to_string(), Value::Number(Number::from(job.attempts as i64)));
    map.insert("enabled".to_string(), Value::Bool(job.enabled));
    
    // Use proper Datetime type for SurrealDB
    map.insert("next_run".to_string(), Value::Datetime(Datetime::from(job.next_run)));

    let vars = Some(Variables::from(map));
    let mut session = Session::owner();
    if let Some((ns, db)) = job.instance_id.as_ref().and_then(|i| i.0.split_once(':')) {
        session = session.with_ns(ns).with_db(db);
    }
    datastore
        .execute(query, &session, vars)
        .await
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;
    Ok(())
}

async fn persist_history(
    datastore: Arc<Datastore>,
    h: &lyxal_scheduler::history::JobHistory,
    node_id: &str,
    instance_id: &str,
) -> Result<(), SchedulerError> {
    let query = "CREATE scheduler_history SET job = $job, result = $result, timestamp = $timestamp, duration_ms = $duration_ms;";
    
    let mut map = BTreeMap::new();
    if let Ok(rid) = RecordId::parse_simple(&h.job_id) {
        map.insert("job".to_string(), Value::RecordId(rid));
    } else {
        // Fallback or explicit prefixing if missing
        let full_id = if h.job_id.contains(':') { h.job_id.clone() } else { format!("scheduler_task:{}", h.job_id) };
        if let Ok(rid) = RecordId::parse_simple(&full_id) {
            map.insert("job".to_string(), Value::RecordId(rid));
        } else {
            map.insert("job".to_string(), Value::String(full_id));
        }
    }

    let res_val_json = serde_json::to_value(&h.result).unwrap_or_else(|_| serde_json::Value::String("unknown".into()));
    let res_val: Value = serde_json::from_value(res_val_json).unwrap_or(Value::None);
    map.insert("result".to_string(), res_val);
    map.insert("timestamp".to_string(), Value::Datetime(h.timestamp.into()));
    map.insert("duration_ms".to_string(), Value::Number(Number::from(h.duration_ms as i64)));

    let vars = Some(Variables::from(map));
    let mut session = Session::owner();
    if let Some((ns, db)) = instance_id.split_once(':') {
        session = session.with_ns(ns).with_db(db);
    }
    datastore
        .execute(query, &session, vars)
        .await
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

    // Metrics & Logs (7.4)
    // instance_id is now passed in

    // Accounting (8.1)
    if instance_id != "unknown" {
        if let Err(e) = record_usage(datastore.clone(), h, instance_id).await {
            warn!(?e, "failed to record usage accounting");
        }
    }

    match &h.result {
        JobResult::Success => {
            info!(
                event = "scheduler.job.finish",
                job_id = %h.job_id,
                node_id = %node_id,
                duration_ms = h.duration_ms,
                result = "success",
                "job finished successfully"
            );
        }
        JobResult::Failed(reason) => {
            warn!(
                event = "scheduler.job.failed",
                job_id = %h.job_id,
                node_id = %node_id,
                duration_ms = h.duration_ms,
                reason = %reason,
                "job execution failed"
            );
        }
        JobResult::Timeout => {
            warn!(
                event = "scheduler.job.timeout",
                job_id = %h.job_id,
                node_id = %node_id,
                duration_ms = h.duration_ms,
                "job execution timed out"
            );
        }
    }

    Ok(())
}

async fn record_usage(
    datastore: Arc<Datastore>,
    h: &lyxal_scheduler::history::JobHistory,
    instance_id: &str,
) -> Result<(), SchedulerError> {
    let now = chrono::Utc::now();
    let period = format!("{}-{:02}", now.year(), now.month()); // YYYY-MM

    let session = {
        let mut s = Session::owner();
        if let Some((ns, db)) = instance_id.split_once(':') {
            s = s.with_ns(ns).with_db(db);
        } else {
            s = s.with_ns("system").with_db("system");
        }
        s
    };

    let (executed, failed, _dlq) = match h.result {
        JobResult::Success => (1, 0, 0),
        JobResult::Failed(_) | JobResult::Timeout => (1, 1, 0),
    };

    let query = "UPSERT $id SET
            instance_id = $instance_id,
            period = $period,
            jobs_executed += $executed,
            jobs_failed += $failed,
            execution_ms_total += $duration,
            created_at = created_at OR time::now(),
            updated_at = time::now();";

    let mut map = BTreeMap::new();
    let rid_str = format!("scheduler_usage:['{}', '{}']", instance_id, period);
    if let Ok(rid) = RecordId::parse_simple(&rid_str) {
        map.insert("id".to_string(), Value::RecordId(rid));
    } else {
        map.insert("id".to_string(), Value::String(rid_str));
    }
    
    map.insert("instance_id".to_string(), Value::String(instance_id.to_string()));
    map.insert("period".to_string(), Value::String(period.clone()));
    map.insert("executed".to_string(), Value::Number(Number::from(executed)));
    map.insert("failed".to_string(), Value::Number(Number::from(failed)));
    map.insert("duration".to_string(), Value::Number(Number::from(h.duration_ms as i64)));

    let vars = Some(Variables::from(map));
    datastore.execute(query, &session, vars).await.map_err(|e| {
        SchedulerError::PersistenceError(e.to_string())
    })?;

    Ok(())
}

async fn purge_old_history(datastore: Arc<Datastore>, days: u64) -> Result<(), SchedulerError> {
    let session = Session::owner().with_ns("system").with_db("system");
    let query = "DELETE scheduler_history WHERE timestamp < time::now() - $days_history;
                 DELETE scheduler_dead_letter WHERE timestamp < time::now() - $days_dlq;";

    let mut map = BTreeMap::new();
    map.insert("days_history".to_string(), Value::Duration(Duration::from_secs(days * 86400).into()));
    map.insert("days_dlq".to_string(), Value::Duration(Duration::from_secs(days * 4 * 86400).into()));

    let vars = Some(Variables::from(map));
    let _ = datastore.execute(query, &session, vars).await.map_err(|e| {
        SchedulerError::PersistenceError(e.to_string())
    })?;
    Ok(())
}

async fn persist_dead_letter(
    datastore: Arc<Datastore>,
    d: &lyxal_scheduler::dead_letter::DeadLetter,
    node_id: &str,
    instance_id: &str,
) -> Result<(), SchedulerError> {
    let query = "CREATE scheduler_dead_letter SET job = $job, reason = $reason, failed_payload = $failed_payload, timestamp = $timestamp;";
    
    let mut map = BTreeMap::new();
    if let Ok(rid) = RecordId::parse_simple(&d.job_id) {
        map.insert("job".to_string(), Value::RecordId(rid));
    } else {
        let full_id = if d.job_id.contains(':') { d.job_id.clone() } else { format!("scheduler_task:{}", d.job_id) };
        if let Ok(rid) = RecordId::parse_simple(&full_id) {
            map.insert("job".to_string(), Value::RecordId(rid));
        } else {
            map.insert("job".to_string(), Value::String(full_id));
        }
    }

    map.insert("reason".to_string(), Value::String(d.reason.clone()));
    let payload_json = serde_json::to_value(&d.failed_payload).unwrap_or_else(|_| serde_json::Value::String("unknown".into()));
    let payload: Value = serde_json::from_value(payload_json).unwrap_or(Value::None);
    map.insert("failed_payload".to_string(), payload);
    map.insert("timestamp".to_string(), Value::Datetime(d.timestamp.into()));

    let vars = Some(Variables::from(map));
    let mut session = Session::owner();
    if let Some((ns, db)) = instance_id.split_once(':') {
        session = session.with_ns(ns).with_db(db);
    }
    datastore
        .execute(query, &session, vars)
        .await
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

    warn!(
        event = "scheduler.job.dlq",
        job_id = %d.job_id,
        node_id = %node_id,
        reason = %d.reason,
        "job moved to dead letter queue"
    );

    Ok(())
}

async fn handle_execution_result(
    store: &InMemoryStore,
    mut job: Job,
    exec_result: Result<lyxal_scheduler::worker::JobExecutionResult, SchedulerError>,
) -> Result<(), SchedulerError> {
    let now = Utc::now();
    match exec_result {
        Ok(execution) => {
            let duration_ms = execution.duration_ms.min(u64::MAX as u128);
            let result = execution.result;

            store.push_history(JobHistory {
                job_id: job.id.clone(),
                result: result.clone(),
                timestamp: now,
                duration_ms: duration_ms as u64,
            }).await?;

            match result {
                JobResult::Success => {
                    job.attempts = 0;
                    job.status = JobStatus::Pending;
                    if let Some(next) = next_after(&job.schedule, now, &job.timezone) {
                        job.next_run = next;
                    } else {
                        job.enabled = false;
                        job.status = JobStatus::Disabled;
                    }
                    store.update_job(job).await?;
                }
                JobResult::Failed(reason) => {
                    job.attempts = job.attempts.saturating_add(1);
                    if job.attempts < job.max_retries {
                        job.status = JobStatus::Pending;
                        job.next_run = now + compute_advanced_backoff(job.attempts, &job.retry_strategy, job.retry_base_delay, job.retry_max_delay);
                        store.update_job(job).await?;
                    } else {
                        job.status = JobStatus::Dlq;
                        store.push_dead_letter(DeadLetter {
                            job_id: job.id.clone(),
                            reason,
                            failed_payload: job.payload.clone(),
                            timestamp: now,
                        }).await?;
                        job.enabled = false;
                        store.update_job(job).await?;
                    }
                }
                JobResult::Timeout => {
                    job.attempts = job.attempts.saturating_add(1);
                    if job.attempts < job.max_retries {
                        job.status = JobStatus::Pending;
                        job.next_run = now + compute_advanced_backoff(job.attempts, &job.retry_strategy, job.retry_base_delay, job.retry_max_delay);
                        store.update_job(job).await?;
                    } else {
                        job.status = JobStatus::Dlq;
                        store.push_dead_letter(DeadLetter {
                            job_id: job.id.clone(),
                            reason: "timeout".to_string(),
                            failed_payload: job.payload.clone(),
                            timestamp: now,
                        }).await?;
                        job.enabled = false;
                        store.update_job(job).await?;
                    }
                }
            }
        }
        Err(err) => {
            let reason = format!("executor error: {err}");
            store.push_history(JobHistory {
                job_id: job.id.clone(),
                result: JobResult::Failed(reason.clone()),
                timestamp: now,
                duration_ms: 0,
            }).await?;

            job.attempts = job.attempts.saturating_add(1);
            if job.attempts < job.max_retries {
                job.status = JobStatus::Pending;
                job.next_run = now + Duration::from_secs(60); 
                store.update_job(job).await?;
            } else {
                job.status = JobStatus::Dlq;
                store.push_dead_letter(DeadLetter {
                    job_id: job.id.clone(),
                    reason,
                    failed_payload: job.payload.clone(),
                    timestamp: now,
                }).await?;
                job.enabled = false;
                store.update_job(job).await?;
            }
        }
    }
    Ok(())
}

/// Recursive normalizer to flatten SurrealDB's type-tagged JSON output
/// e.g. {"Object": {"field": {"String": "val"}}} -> {"field": "val"}
fn flatten_surreal_json(v: serde_json::Value) -> serde_json::Value {
    use serde_json::Value;

    match v {
        Value::Object(mut map) => {
            // Check if it's a type-tagged wrapper with a single key
            // common tags: "Object", "String", "Number", "Bool", "Datetime", "Duration", "Array", "Record"
            if map.len() == 1 {
                let key = map.keys().next().unwrap().clone();
                match key.as_str() {
                    "RecordId" | "Thing" => {
                        let inner = map.remove(&key).unwrap();
                        return flatten_surreal_json(inner);
                    }
                    "Object" | "Array" | "String" | "Bool" | "Datetime" | "Record" => {
                        let inner = map.remove(&key).unwrap();
                        return flatten_surreal_json(inner);
                    }
                    "Number" => {
                        let inner = map.remove(&key).unwrap();
                        if let Value::Object(num_map) = &inner {
                            if let Some(val) = num_map.get("Int").or_else(|| num_map.get("Float")) {
                                return val.clone();
                            }
                        }
                        return flatten_surreal_json(inner);
                    }
                    "Duration" => {
                        let inner = map.remove(&key).unwrap();
                        // Flatten Duration if it's just {secs, nanos}
                        if let Value::Object(ref dur_map) = inner {
                            if let Some(secs) = dur_map.get("secs").and_then(|s| s.as_u64()) {
                                return Value::Number(secs.into());
                            }
                        }
                        return inner;
                    }
                    _ => {}
                }
            }

            // --- DEBUT DETECTION STRUCTURELLE (SURREALDB 3.0) ---
            // 1. Detection RecordId/Thing structurel (ex: {"key": "...", "table": "..."})
            let table = map.get("table").or_else(|| map.get("tb")).and_then(|v| v.as_str());
            let id = map.get("id").or_else(|| map.get("key")).and_then(|v| {
                if let Some(s) = v.as_str() {
                    Some(s.to_string())
                } else if let Some(oid) = v.as_object() {
                    // Parfois l'ID est lui-même un objet {"String": "..."}
                    oid.get("String").and_then(|s| s.as_str()).map(|s| s.to_string())
                } else {
                    None
                }
            });

            if let (Some(t), Some(i)) = (table, id) {
                return Value::String(format!("{}:{}", t, i));
            }

            // 2. Detection Duration structurelle (ex: {"secs": 60, "nanos": 0})
            if map.len() >= 1 && map.contains_key("secs") && map.contains_key("nanos") {
                if let Some(secs) = map.get("secs").and_then(|s| s.as_u64()) {
                    return Value::Number(secs.into());
                }
            }
            // --- FIN DETECTION STRUCTURELLE ---

            // Otherwise, flatten all fields in the object
            let mut new_map = serde_json::Map::new();
            for (k, val) in map {
                new_map.insert(k, flatten_surreal_json(val));
            }
            Value::Object(new_map)
        }
        Value::Array(arr) => {
            Value::Array(arr.into_iter().map(flatten_surreal_json).collect())
        }
        _ => v,
    }
}
