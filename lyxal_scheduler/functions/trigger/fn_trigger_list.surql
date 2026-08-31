-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::trigger_list                                            │
-- │  Liste les déclencheurs (globaux ou filtrés par job_key).               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::trigger_list(
    $job_key: option<string>
) {
    LET $j_id = IF $job_key != NONE THEN type::record('scheduler_job_definition', $job_key) ELSE NONE END;

    RETURN SELECT * FROM scheduler_trigger
        WHERE $job_key == NONE OR job_key = $j_id
        ORDER BY created_at DESC;
};
