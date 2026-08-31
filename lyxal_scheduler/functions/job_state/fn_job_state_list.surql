-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_state_list                                          │
-- │  Liste l'intégralité des états runtime des jobs planifiés.             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_state_list() {
    RETURN SELECT * FROM scheduler_job ORDER BY id ASC;
};
