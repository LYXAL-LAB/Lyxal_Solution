-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_clear                                       │
-- │  Vide la file d'attente des dead letters (pour un job ou totalement).   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_clear(
    $job_key: option<string>
) {
    LET $j_id = IF $job_key != NONE THEN type::record('scheduler_job_definition', $job_key) ELSE NONE END;

    LET $deleted = IF $job_key != NONE THEN
        DELETE scheduler_dead_letter WHERE job_key = $j_id
    ELSE
        DELETE scheduler_dead_letter
    END;

    RETURN array::len($deleted);
};
