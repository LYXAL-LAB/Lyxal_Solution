-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_state_get                                           │
-- │  Récupère l'état runtime d'un job planifié par sa clé.                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_state_get(
    $job_key: string
) {
    LET $id = type::record('scheduler_job', $job_key);
    RETURN (SELECT * FROM $id)[0];
};
