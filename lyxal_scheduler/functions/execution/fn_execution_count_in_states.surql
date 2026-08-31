-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::execution_count_in_states                              │
-- │  Comptabilise les exécutions d'un job dans un ensemble d'états.        │
-- │  Utilisé par le garde de concurrence (singleton, max_concurrent).      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::execution_count_in_states(
    $job_key: string,
    $states: array<string>
) {
    LET $j_def_id = type::record('scheduler_job_definition', $job_key);

    LET $res = (
        SELECT count() AS total FROM scheduler_execution
        WHERE job_key = $j_def_id
          AND state IN $states
        GROUP ALL
    );

    RETURN IF array::len($res) > 0 THEN $res[0].total ELSE 0 END;
};
