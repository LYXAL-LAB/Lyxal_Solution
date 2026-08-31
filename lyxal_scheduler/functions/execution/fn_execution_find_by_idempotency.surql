-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_find_by_idempotency                          │
-- │  Recherche une exécution récente par sa clé d'idempotence.             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_find_by_idempotency(
    $job_key: string,
    $idempotency_key: string,
    $window_start: datetime
) {
    LET $job_id = type::record('scheduler_job_definition', $job_key);

    RETURN (
        SELECT * FROM scheduler_execution
        WHERE job_key = $job_id
          AND idempotency_key = $idempotency_key
          AND (state IN ['queued', 'claimed', 'running'] OR created_at >= $window_start)
        ORDER BY created_at DESC
        LIMIT 1
    )[0];
};
