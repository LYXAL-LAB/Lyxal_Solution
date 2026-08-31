-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_state_delete                                        │
-- │  Supprime l'état runtime d'un job planifié.                             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_state_delete(
    $job_key: string
) {
    LET $id = type::record('scheduler_job', $job_key);
    RETURN DELETE $id;
};
