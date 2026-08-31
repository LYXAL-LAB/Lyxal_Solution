-- fn::scheduler::execution_create_and_advance_job
-- Crée l'exécution ET avance l'état du job (fonction atomique)

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_create_and_advance_job(
    $exec_id: string,
    $job_key: string,
    $fire_at: datetime,
    $scheduled_for: option<datetime>,
    $attempt: int,
    $metadata: object,
    $idempotency_key: option<string>,
    $next_fire_at: option<datetime>,
    $last_fired_at: option<datetime>,
    $fire_count: int,
    $job_status: string
) {
    LET $e_id = type::record('scheduler_execution', $exec_id);
    LET $j_def_id = type::record('scheduler_job_definition', $job_key);
    LET $j_state_id = type::record('scheduler_job', $job_key);

    CREATE $e_id SET
        job_key         = $j_def_id,
        fire_at         = $fire_at,
        scheduled_for   = IF $scheduled_for != NONE THEN $scheduled_for ELSE $fire_at END,
        attempt         = $attempt,
        state           = 'queued',
        metadata        = $metadata,
        idempotency_key = $idempotency_key,
        created_at      = time::now();

    UPSERT $j_state_id SET
        definition    = $j_def_id,
        next_fire_at  = $next_fire_at,
        last_fired_at = $last_fired_at,
        fire_count    = $fire_count,
        status        = $job_status,
        updated_at    = time::now();

    RETURN true;
};
