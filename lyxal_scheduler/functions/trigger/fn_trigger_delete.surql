-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::trigger_delete                                          │
-- │  Supprime un déclencheur par son identifiant.                           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::trigger_delete(
    $trigger_id: string
) {
    LET $t_id = type::record('scheduler_trigger', $trigger_id);
    RETURN DELETE $t_id;
};
