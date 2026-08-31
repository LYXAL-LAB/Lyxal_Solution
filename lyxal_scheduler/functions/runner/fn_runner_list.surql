-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::runner_list                                             │
-- │  Liste l'ensemble des runners enregistrés.                              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::runner_list() {
    RETURN SELECT * FROM scheduler_runner ORDER BY id ASC;
};
