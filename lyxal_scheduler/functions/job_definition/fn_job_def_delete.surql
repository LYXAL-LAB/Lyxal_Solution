-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_def_delete                                          │
-- │  Supprime la définition de configuration d'un job.                     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_def_delete(
    $job_key: string
) {
    LET $id = type::record('scheduler_job_definition', $job_key);
    RETURN DELETE $id;
};
