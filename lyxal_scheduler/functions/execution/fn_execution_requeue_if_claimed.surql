-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_requeue_if_claimed                            │
-- │  Remet une exécution en 'queued' si elle est toujours 'claimed'.        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_requeue_if_claimed(
    $exec_id: string,
    $now: datetime
) {
    LET $e_id = type::record('scheduler_execution', $exec_id);

    LET $updated = (
        UPDATE $e_id SET
            state      = 'queued',
            runner_id  = NONE,
            claimed_at = NONE,
            started_at = NONE,
            fire_at    = $now
        WHERE state = 'claimed'
        RETURN AFTER
    );

    RETURN array::len($updated) > 0;
};
