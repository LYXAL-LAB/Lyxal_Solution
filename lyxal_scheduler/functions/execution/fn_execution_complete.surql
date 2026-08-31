-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_complete                                      │
-- │  Compare-And-Swap (Fencing Guard) : marque une exécution terminée       │
-- │  seulement si elle est toujours 'claimed' par le runner indiqué.        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_complete(
    $exec_id: string,
    $runner_id: option<string>,
    $state: string,
    $duration_ms: option<int>,
    $error: option<string>,
    $dead_reason: option<string>,
    $now: datetime
) {
    LET $e_id = type::record('scheduler_execution', $exec_id);
    LET $r_id = IF $runner_id != NONE THEN type::record('scheduler_runner', $runner_id) ELSE NONE END;

    -- Compare-And-Swap Fencing Guard : valide l'appartenance au runner
    LET $updated = (
        UPDATE $e_id SET
            state        = $state,
            completed_at = $now,
            duration_ms  = $duration_ms,
            error        = $error,
            dead_reason  = $dead_reason
        WHERE (state = 'claimed' OR state = 'running')
          AND ($runner_id == NONE OR runner_id == $r_id)
        RETURN AFTER
    );

    -- Renvoie true si la ligne a été mise à jour (garde CAS réussie), false sinon
    RETURN array::len($updated) > 0;
};
