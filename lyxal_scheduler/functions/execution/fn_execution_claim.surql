-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_claim                                         │
-- │  Réserve une exécution 'queued' pour un runner (passage en 'claimed').   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_claim(
    $exec_id: string,
    $runner_id: string,
    $now: datetime
) {
    LET $e_id = type::record('scheduler_execution', $exec_id);
    LET $r_id = type::record('scheduler_runner', $runner_id);

    RETURN (
        UPDATE $e_id SET
            state      = 'claimed',
            runner_id  = $r_id,
            claimed_at = $now,
            started_at = IF started_at == NONE THEN $now ELSE started_at END
        WHERE state = 'queued'
        RETURN AFTER
    )[0];
};
