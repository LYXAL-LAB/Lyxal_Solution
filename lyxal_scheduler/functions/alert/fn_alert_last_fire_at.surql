-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_last_fire_at                                      │
-- │  Trouve la dernière date de tir d'une règle d'alerte pour un job.       │
-- │  Utilisé par l'évaluateur pour réensemencer la carte de limitation.     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_last_fire_at(
    $rule_name: string,
    $job_key: string
) {
    LET $j_id = type::record('scheduler_job_definition', $job_key);

    LET $res = (
        SELECT VALUE fired_at FROM scheduler_alert_delivery
        WHERE rule_name = $rule_name
          AND job_key   = $j_id
        ORDER BY fired_at DESC
        LIMIT 1
    );

    RETURN IF array::len($res) > 0 THEN $res[0] ELSE NONE END;
};
