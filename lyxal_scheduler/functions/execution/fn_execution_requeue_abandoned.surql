-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_requeue_abandoned                             │
-- │  Remet en file d'attente les tâches d'un runner considéré comme mort.   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_requeue_abandoned(
    $runner_id: string,
    $now: datetime
) {
    LET $r_id = type::record('scheduler_runner', $runner_id);

    RETURN (
        UPDATE scheduler_execution SET
            state      = 'queued',
            runner_id  = NONE,
            claimed_at = NONE,
            started_at = NONE,
            fire_at    = $now
        WHERE runner_id = $r_id
          AND state IN ['claimed', 'running']
        RETURN AFTER
    );
};
