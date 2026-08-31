-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::maintenance_get                                         │
-- │  Lit l'état du switch global de maintenance.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::maintenance_get() {
    RETURN (SELECT * FROM scheduler_maintenance:global)[0];
};
