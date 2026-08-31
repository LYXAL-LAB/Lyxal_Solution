-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_def_list                                            │
-- │  Liste l'ensemble des définitions de jobs enregistrées.                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_def_list() {
    RETURN SELECT * FROM scheduler_job_definition ORDER BY id ASC;
};
