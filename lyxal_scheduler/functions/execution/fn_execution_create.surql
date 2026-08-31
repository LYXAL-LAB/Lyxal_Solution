-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_create                                        │
-- │  Crée une nouvelle exécution en file d'attente (queued).                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_create(
    $id: string,
    $job_key: string,
    $fire_at: datetime,
    $scheduled_for: option<datetime>,
    $attempt: int,
    $metadata: object,
    $idempotency_key: option<string>
) {
    LET $exec_id = type::record('scheduler_execution', $id);
    LET $job_id = type::record('scheduler_job_definition', $job_key);

    RETURN (
        CREATE $exec_id SET
            job_key         = $job_id,
            fire_at         = $fire_at,
            scheduled_for   = IF $scheduled_for != NONE THEN $scheduled_for ELSE $fire_at END,
            attempt         = $attempt,
            state           = 'queued',
            metadata        = $metadata,
            idempotency_key = $idempotency_key,
            created_at      = time::now()
    )[0];
};
