-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_override_delete                                   │
-- │  Supprime la surcharge d'une règle d'alerte.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_override_delete(
    $rule_name: string
) {
    LET $o_id = type::record('scheduler_alert_override', $rule_name);
    LET $deleted = DELETE $o_id;
    RETURN array::len($deleted) > 0;
};
