# Scheduler Operations Guide

## Configuration

The scheduler is embedded within SurrealDB and is fully native.

### General

-   **Scheduler Lifecycle**: Schedulers are created, enabled, and disabled exclusively via the `DEFINE SCHEDULER` statement.
    ```sql
    -- Create and enable a scheduler
    DEFINE SCHEDULER my_scheduler ON DATABASE ENABLED;

    -- Disable a scheduler
    DEFINE SCHEDULER my_scheduler ON DATABASE DISABLED;
    ```
    There are no environment variables for mounting schedulers. The state is persisted in the System Catalog.

### Operational Safety & Tuning

-   **SURREAL_SCHEDULER_LEASE_TTL**: Duration for which a job lease is acquired. Should be at least 2x the job execution timeout.
    -   *Default*: `60s`
    -   *Format*: Human-readable duration (e.g., `60s`, `2m`).
    -   *Warning*: If set too low (< 2x timeout), a warning will be logged at startup.

-   **SURREAL_SCHEDULER_TICK_JITTER_MAX_MS**: Maximum random delay (jitter) added before each scheduler tick to prevent thundering herd in a cluster.
    -   *Default*: `500` (milliseconds).

-   **SURREAL_SCHEDULER_MAX_JOBS_PER_TICK**: Maximum number of jobs to fetch and process in a single tick per instance (default fallback).
    -   *Default*: `100`.

-   **SURREAL_SCHEDULER_MAX_CONCURRENT_JOBS**: Hard limit on the total number of jobs actively running on this node across all instances.
    -   *Default*: `1000`.

## Governance (Priorities & Quotas)

### Job Priorities

Jobs can have a `priority` (integer, default `0`).
-   Range: Typically `-10` (low) to `+10` (high).
-   Behavior: Jobs with higher priority are leased and executed first.
-   Usage: `schedule::create_job(..., priority)` or update via `scheduler::task`.

### Instance Quotas

Quotas can be defined per instance in the `system::scheduler_quota` table.

```sql
UPDATE system::scheduler_quota:my_instance SET
    max_concurrency = 5,      -- Max parallel workers for this instance
    max_jobs_per_tick = 50;   -- Max jobs fetched per tick
```

-   **max_concurrency**: Limits effective parallelism (batch size per tick).
-   **max_jobs_per_tick**: Limits load on the datastore during lease acquisition.

If quotas are reached, remaining eligible jobs are deferred to the next tick (back-pressure).

## Observability

### Metrics

The scheduler exposes internal metrics via OpenTelemetry (if enabled in SurrealDB).

-   **scheduler.jobs.executed.total**: Counter of total jobs executed.
    -   Labels: `node_id`, `instance_id`.
-   **scheduler.jobs.failed.total**: Counter of total jobs failed.
    -   Labels: `node_id`, `instance_id`.
-   **scheduler.jobs.dlq.total**: Counter of jobs moved to Dead Letter Queue.
    -   Labels: `node_id`, `instance_id`.
-   **scheduler.leases.acquired.total**: Counter of successful lease acquisitions.
    -   Labels: `node_id`, `instance_id`.
-   **scheduler.job.duration**: Histogram of job execution duration in milliseconds.
    -   Labels: `node_id`, `instance_id`.

### Logs

Structured JSON logs are emitted for key events:

-   `scheduler.job.start`: Job execution started.
-   `scheduler.job.finish`: Job completed successfully.
-   `scheduler.job.failed`: Job failed (will be retried if retries remain).
-   `scheduler.job.timeout`: Job execution timed out (hard timeout).
-   `scheduler.job.dlq`: Job moved to Dead Letter Queue after max retries.
-   `scheduler.job.lease_acquired`: Node acquired a lease for a job.
-   `scheduler.job.skipped.quota.global`: Global node limit reached.
-   `scheduler.tick.end`: Summary of a scheduler tick (duration, history length).

## Troubleshooting

-   **Job not running**: Check if the scheduler is defined and enabled (`DEFINE SCHEDULER ... ENABLED`). Check `enabled` field on the job. Check `next_run` is in the past. Check priorities and quotas.
-   **Double execution**: Verify `SURREAL_SCHEDULER_LEASE_TTL` is sufficient and clock synchronization between nodes.
-   **Performance issues**: Tune `SURREAL_SCHEDULER_MAX_JOBS_PER_TICK` or instance quotas if database load is too high during scans.
