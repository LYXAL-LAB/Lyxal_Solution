-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::calendar_list                                           │
-- │  Liste l'ensemble des calendriers métier.                               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::calendar_list() {
    RETURN SELECT * FROM scheduler_calendar ORDER BY id ASC;
};
