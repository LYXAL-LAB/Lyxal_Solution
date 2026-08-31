-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_cancel                                       │
-- │  Annule une exécution en cours ou en attente.                           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_cancel(
    $exec_id: string,
    $now: datetime
) {
    LET $e_id = type::record('scheduler_execution', $exec_id);

    RETURN (
        UPDATE $e_id SET
            state        = 'failed',
            error        = 'Execution cancelled by user or system',
            dead_reason  = 'cancelled',
            completed_at = $now
        WHERE state IN ['queued', 'claimed', 'running']
        RETURN AFTER
    )[0];
};
