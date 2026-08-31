-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_add                                         │
-- │  Ajoute une entrée dans la file d'attente des échecs (Dead Letter).    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_add(
    $id: string,
    $execution_id: string,
    $job_key: string,
    $fire_at: datetime,
    $scheduled_for: option<datetime>,
    $attempt: int,
    $error: string,
    $dead_reason: string,
    $metadata: object,
    $expires_at: option<datetime>
) {
    LET $dl_id = type::record('scheduler_dead_letter', $id);
    LET $e_id = type::record('scheduler_execution', $execution_id);
    LET $j_id = type::record('scheduler_job_definition', $job_key);

    RETURN (
        CREATE $dl_id SET
            execution_id  = $e_id,
            job_key       = $j_id,
            fire_at       = $fire_at,
            scheduled_for = IF $scheduled_for != NONE THEN $scheduled_for ELSE $fire_at END,
            attempt       = $attempt,
            error         = $error,
            dead_reason   = $dead_reason,
            status        = 'pending',
            metadata      = $metadata,
            created_at    = time::now(),
            expires_at    = $expires_at
    )[0];
};
