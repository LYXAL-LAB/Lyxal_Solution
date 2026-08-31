-- fn::scheduler::dead_letter_replay
-- Transaction atomique : marque la dead letter 'replayed' et crée la nouvelle exécution

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_replay(
    $dead_letter_id: string,
    $new_execution_id: string,
    $job_key: string,
    $fire_at: datetime,
    $scheduled_for: option<datetime>,
    $attempt: int,
    $metadata: object,
    $replayed_by: option<string>
) {
    LET $dl_id = type::record('scheduler_dead_letter', $dead_letter_id);
    LET $new_e_id = type::record('scheduler_execution', $new_execution_id);
    LET $j_id = type::record('scheduler_job_definition', $job_key);

    UPDATE $dl_id SET
        status      = 'replayed',
        replayed_at = time::now(),
        replayed_by = $replayed_by;

    CREATE $new_e_id SET
        job_key       = $j_id,
        fire_at       = $fire_at,
        scheduled_for = IF $scheduled_for != NONE THEN $scheduled_for ELSE $fire_at END,
        attempt       = $attempt,
        state         = 'queued',
        metadata      = $metadata,
        created_at    = time::now();

    RETURN true;
};
