-- fn::scheduler::execution_prune_older_than
-- Purge les anciennes exécutions terminées plus anciennes que le cutoff

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_prune_older_than(
    $cutoff: datetime,
    $limit: int
) {
    LET $targets = (
        SELECT id, completed_at FROM scheduler_execution
        WHERE state IN ['completed', 'failed']
          AND completed_at <= $cutoff
        ORDER BY completed_at ASC
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
