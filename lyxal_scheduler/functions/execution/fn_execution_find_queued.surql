-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_find_queued                                  │
-- │  Recherche les tâches en attente (queued) ordonnées par fire_at.        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_find_queued(
    $limit: int
) {
    RETURN SELECT * FROM scheduler_execution
        WHERE state = 'queued'
        ORDER BY fire_at ASC
        LIMIT $limit;
};
