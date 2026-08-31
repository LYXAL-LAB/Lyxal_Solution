-- fn::scheduler::dead_letter_complete_as_dead
-- Marque l'exécution en 'dead' et insère l'entrée dead_letter (fonction atomique)

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_complete_as_dead(
    $execution_id: string,
    $runner_id: option<string>,
    $duration_ms: option<int>,
    $error: option<string>,
    $dead_letter_id: string,
    $job_key: string,
    $fire_at: datetime,
    $scheduled_for: option<datetime>,
    $attempt: int,
    $dead_reason: string,
    $metadata: object,
    $expires_at: option<datetime>,
    $now: datetime
) {
    LET $e_id = type::record('scheduler_execution', $execution_id);
    LET $r_id = IF $runner_id != NONE THEN type::record('scheduler_runner', $runner_id) ELSE NONE END;
    LET $dl_id = type::record('scheduler_dead_letter', $dead_letter_id);
    LET $j_id = type::record('scheduler_job_definition', $job_key);

    LET $ex = (
        UPDATE $e_id SET
            state        = 'dead',
            completed_at = $now,
            duration_ms  = $duration_ms,
            error        = $error,
            dead_reason  = $dead_reason
        WHERE (state = 'claimed' OR state = 'failed' OR state = 'running')
          AND ($runner_id == NONE OR runner_id == $r_id)
        RETURN AFTER
    );

    IF array::len($ex) > 0 {
        CREATE $dl_id SET
            execution_id  = $e_id,
            job_key       = $j_id,
            fire_at       = $fire_at,
            scheduled_for = IF $scheduled_for != NONE THEN $scheduled_for ELSE $fire_at END,
            attempt       = $attempt,
            error         = IF $error != NONE THEN $error ELSE 'Execution dead' END,
            dead_reason   = $dead_reason,
            status        = 'pending',
            metadata      = $metadata,
            created_at    = $now,
            expires_at    = $expires_at
    };

    RETURN array::len($ex) > 0;
};
