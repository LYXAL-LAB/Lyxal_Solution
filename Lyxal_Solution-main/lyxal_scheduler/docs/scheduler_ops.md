# Scheduler Operations Guide

## Configuration

The scheduler is embedded within SurrealDB and is fully native.

### General

-   **Scheduler Lifecycle**: Schedulers are created, enabled, and disabled exclusively via the `DEFINE SCHEDULER` statement.
    ```sql
    -- Create and enable a scheduler
    DEFINE SCHEDULER my_scheduler ON DATABASE ACTION "fn::process_job";

    -- Disable a scheduler
    DEFINE SCHEDULER my_scheduler ON DATABASE DISABLED ACTION "fn::process_job";
    ```
    There are no environment variables for mounting schedulers. The state is persisted in the System Catalog.

### Operational Safety & Tuning (Environment Variables)

-   **SURREAL_SCHEDULER_LEASE_TTL**: Duration (seconds) for which a job lease is acquired. Should be at least 2x the job execution timeout.
    -   *Default*: `60`
    -   *Warning*: If set too low (< 2x timeout), a warning will be logged at startup.

-   **SURREAL_SCHEDULER_TICK_JITTER_MAX_MS**: Maximum random delay (jitter) added before each scheduler tick to prevent thundering herd in a cluster.
    -   *Default*: `500` (milliseconds).

-   **SURREAL_SCHEDULER_MAX_CONCURRENT_JOBS**: Hard limit on the total number of jobs actively running on this node across all instances.
    -   *Default*: `1000`.

-   **SURREAL_SCHEDULER_BACKPRESSURE_CPU_LIMIT**: CPU usage percentage threshold above which backpressure is applied.
    -   *Default*: `80.0`.

-   **SURREAL_SCHEDULER_BACKPRESSURE_MEM_LIMIT**: Memory usage percentage threshold above which backpressure is applied.
    -   *Default*: `90.0`.

-   **SURREAL_SCHEDULER_HISTORY_TTL_DAYS**: Number of days to keep job history records. Dead letters are kept 4x longer.
    -   *Default*: `7`.

-   **SURREAL_SCHEDULER_CIRCUIT_THRESHOLD**: Number of consecutive failures before an action's circuit breaker trips.
    -   *Default*: `5`.

-   **SURREAL_SCHEDULER_TOTAL_SHARDS**: Total number of logical shards for job distribution. Set to > 1 for large clusters.
    -   *Default*: `1`.

-   **SURREAL_SCHEDULER_DRAIN_TIMEOUT**: Graceful shutdown timeout (seconds) to wait for active jobs to finish.
    -   *Default*: `30`.

-   **SURREAL_SCHEDULER_MAX_ESTIMATED_LOAD**: Maximum aggregate estimated duration (ms) of running jobs before new jobs are deferred (Predictive Scheduling).
    -   *Default*: `10000` (10 seconds).

## Governance (Priorities & Quotas)

### Job Priorities

Jobs can have a `priority` (integer, default `0`).
-   Range: Typically `-10` (low) to `+10` (high).
-   Behavior: Jobs are processed in three tiers: HIGH (>0), MEDIUM (0), LOW (<0). Higher priority jobs within a tier are executed first.
-   Usage: Set via `schedule::add(..., priority, ...)`.

### Instance Quotas & Plans

Quotas and plans can be defined per instance in the `system::scheduler_quota` and `system::scheduler_plan` tables.

```sql
-- Set quotas for an instance
UPDATE system::scheduler_quota SET
    max_concurrency = 5,      -- Max parallel workers for this instance
    max_jobs_per_tick = 50    -- Max jobs fetched per tick
    WHERE instance_id = 'ns:db';

-- Set a plan for an instance (SaaS governance)
UPDATE system::scheduler_subscription SET
    plan = system::scheduler_plan:gold,
    active = true
    WHERE instance_id = 'ns:db';
```

## SQL Developer API (`schedule::*`)

Official kernel functions for job management:

-   `schedule::add(name, cron, action, payload, priority?, max_retries?, instance_id?, run_as?, on_success?, on_failure?, one_shot?, idempotency_key?, timezone?)`: Adds a new job.
-   `schedule::add_many(jobs[])`: Bulk insert of jobs in a single transaction.
-   `schedule::once(datetime, action, payload, priority?)`: Schedules a one-shot job.
-   `schedule::pause(job_id)` / `schedule::resume(job_id)`: Controls job execution.
-   `schedule::remove(job_id)`: Deletes a job.
-   `schedule::list(instance_id?, limit?, start?, filters?)`: Paginated list of jobs.
-   `schedule::history(job_id)`: Fetches execution history for a job.
-   `schedule::progress(percent, job_id?)`: Updates job progression (0-100).
-   `schedule::retry(dead_letter_id)` / `schedule::discard(dead_letter_id)`: Manages failed jobs.
-   `schedule::test(action, payload)`: Dry-run execution simulation.
-   `schedule::explain(job_id)`: Shows execution plan, dependencies, and cost analysis.
-   `schedule::reset_circuit(action)`: Manually resets a tripped circuit breaker.
-   `schedule::checkpoint(state, job_id?)`: Saves intermediate state for long-running jobs (Saga pattern).
-   `schedule::stats()`: Returns aggregated scheduler statistics for monitoring dashboards.

## Advanced Features

### Directed Acyclic Graph (DAG)
Jobs can depend on other jobs using the `depends_on` field. A job will only be executed if all its dependencies have successfully finished.

### Multi-Timezone & DST
The `timezone` field (IANA format, e.g., `Europe/Paris`) ensures jobs run at the correct local time, respecting Daylight Saving Time transitions.

### Locality-Aware Scheduling
Using the `preferred_node` field, jobs can be pinned to specific cluster nodes to optimize for data locality or specialized hardware.

### Advanced Retry Strategies
Jobs support configurable retry strategies:
-   `retry_strategy`: `"linear"` (default) or `"exponential"`.
-   `retry_base_delay`: Initial delay (e.g., `1m`).
-   `retry_max_delay`: Maximum delay cap (e.g., `1h`).
Automatic jitter is applied to prevent thundering herd.

### Saga Pattern / Persistent State
Long-running jobs can save their progress using `schedule::checkpoint(state)`. The state is persisted in `scheduler::task` and can be retrieved upon resumption.

### Network Isolation (Egress Control)
Jobs can be sandboxed to prevent network access using the `allow_egress` flag (default `false` for secure-by-default execution).

### Payload Encryption (Security+)
Sensitive payloads can be encrypted at rest (`encrypted: true`). They are automatically decrypted in memory only during execution.

### Predictive Scheduling
The scheduler estimates job duration based on history. If the total estimated load exceeds `SURREAL_SCHEDULER_MAX_ESTIMATED_LOAD`, heavy jobs are deferred to smooth performance.

### History Archiving
Job history older than 30 days is automatically moved to `scheduler::history_archive`.
> **Note**: Requires `SURREAL_SCHEDULER_HISTORY_TTL_DAYS` to be set > 30 (default is 7).

## Observability

### Metrics (OpenTelemetry)

-   `surrealdb.scheduler.jobs.executed`: Total jobs executed.
-   `surrealdb.scheduler.jobs.failed`: Total jobs failed.
-   `surrealdb.scheduler.job.duration`: Histogram of job duration (ms).

### Live Events
Use `LIVE SELECT * FROM scheduler::history` to monitor job status changes (started, finished, failed) in real-time.

## Troubleshooting

-   **Circuit Breaker**: If an action consistently fails, its circuit trips (`system::scheduler_circuit`). Use `schedule::reset_circuit(action)` to recover.
-   **Backpressure**: If node resources (CPU/RAM) are high, the scheduler reduces its concurrency automatically. Check logs for `scheduler.backpressure`.
-   **Drain Mode**: During shutdown, the node enters drain mode. Check `SURREAL_SCHEDULER_DRAIN_TIMEOUT` if jobs are being aborted prematurely.
