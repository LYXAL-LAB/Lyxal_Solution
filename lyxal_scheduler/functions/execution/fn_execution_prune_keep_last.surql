-- fn::scheduler::execution_prune_keep_last
-- Purge les exécutions d'un job au-delà de la limite keep_last

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_prune_keep_last(
    $job_key: string,
    $keep_last: int,
    $limit: int
) {
    LET $job_id = type::record('scheduler_job_definition', $job_key);

    LET $targets = (
        SELECT id, completed_at FROM scheduler_execution
        WHERE job_key = $job_id
          AND state IN ['completed', 'failed']
        ORDER BY completed_at DESC
        START $keep_last
        LIMIT $limit
    );

    IF array::len($targets) > 0 {
        FOR $item IN $targets {
            DELETE scheduler_execution_log WHERE execution_id = $item.id;
            DELETE $item.id;
        }
    };

    RETURN array::len($targets);
};
