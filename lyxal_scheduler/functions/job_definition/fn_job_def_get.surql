-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_def_get                                             │
-- │  Récupère la définition de configuration d'un job par sa clé.           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_def_get(
    $job_key: string
) {
    LET $id = type::record('scheduler_job_definition', $job_key);
    RETURN (SELECT * FROM $id)[0];
};
