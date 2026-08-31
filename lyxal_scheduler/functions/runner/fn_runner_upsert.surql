-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::runner_upsert                                           │
-- │  Enregistre ou met à jour un runner.                                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::runner_upsert(
    $runner_id: string,
    $capabilities: array<string>,
    $max_inflight: int,
    $status: string,
    $metadata: object
) {
    LET $r_id = type::record('scheduler_runner', $runner_id);

    RETURN (
        UPSERT $r_id SET
            capabilities  = $capabilities,
            max_inflight  = $max_inflight,
            status        = $status,
            metadata      = $metadata,
            last_poll_at  = time::now(),
            updated_at    = time::now()
    )[0];
};
