-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_list_claimed_older_than                       │
-- │  Recherche les tâches 'claimed' plus anciennes que le cutoff            │
-- │  pour la détection des blocages par le Watchdog SLA.                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_list_claimed_older_than(
    $cutoff: datetime,
    $limit: int
) {
    RETURN SELECT * FROM scheduler_execution
        WHERE state = 'claimed'
          AND (claimed_at <= $cutoff OR claimed_at == NONE)
        ORDER BY claimed_at ASC
        LIMIT $limit;
};
