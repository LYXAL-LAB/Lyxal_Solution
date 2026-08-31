-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::runner_remove                                           │
-- │  Supprime un runner du registre.                                        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::runner_remove(
    $runner_id: string
) {
    LET $r_id = type::record('scheduler_runner', $runner_id);
    RETURN DELETE $r_id;
};
