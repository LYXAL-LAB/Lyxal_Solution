-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::runner_update_poll                                     │
-- │  Mise à jour du heartbeat et des exécutions en cours (inflight).        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::runner_update_poll(
    $runner_id: string,
    $inflight_ids: array<string>,
    $now: datetime
) {
    LET $r_id = type::record('scheduler_runner', $runner_id);

    -- Conversion des ID d'exécutions en Record Links
    LET $inflight_links = (
        SELECT VALUE type::record('scheduler_execution', $this) FROM $inflight_ids
    );

    RETURN (
        UPDATE $r_id SET
            last_poll_at = $now,
            inflight     = $inflight_links,
            updated_at   = time::now()
        RETURN AFTER
    )[0];
};
