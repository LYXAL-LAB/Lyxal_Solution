-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::trigger_get                                             │
-- │  Récupère un déclencheur par son identifiant.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::trigger_get(
    $trigger_id: string
) {
    LET $t_id = type::record('scheduler_trigger', $trigger_id);
    RETURN (SELECT * FROM $t_id)[0];
};
