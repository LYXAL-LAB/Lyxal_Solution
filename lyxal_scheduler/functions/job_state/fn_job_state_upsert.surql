-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_state_upsert                                        │
-- │  Crée ou met à jour l'état runtime d'un job.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_state_upsert(
    $job_key: string,
    $next_fire_at: option<datetime>,
    $last_fired_at: option<datetime>,
    $fire_count: int,
    $status: string
) {
    LET $id = type::record('scheduler_job', $job_key);
    LET $def_id = type::record('scheduler_job_definition', $job_key);

    RETURN (
        UPSERT $id SET
            definition   = $def_id,
            next_fire_at = $next_fire_at,
            last_fired_at = $last_fired_at,
            fire_count   = $fire_count,
            status       = $status,
            updated_at   = time::now()
    )[0];
};
