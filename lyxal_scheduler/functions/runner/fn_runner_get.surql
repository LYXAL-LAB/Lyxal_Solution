-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::runner_get                                              │
-- │  Récupère un runner par son identifiant.                                │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::runner_get(
    $runner_id: string
) {
    LET $r_id = type::record('scheduler_runner', $runner_id);
    RETURN (SELECT * FROM $r_id)[0];
};
