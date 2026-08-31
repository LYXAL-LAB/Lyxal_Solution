-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_list                                        │
-- │  Liste les dead letters avec filtrage optionnel par job_key et status.  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_list(
    $job_key: option<string>,
    $status: option<string>
) {
    LET $j_id = IF $job_key != NONE THEN type::record('scheduler_job_definition', $job_key) ELSE NONE END;

    RETURN SELECT * FROM scheduler_dead_letter
        WHERE ($job_key == NONE OR job_key == $j_id)
          AND ($status == NONE OR status == $status)
        ORDER BY created_at DESC;
};
