-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_override_list                                     │
-- │  Liste toutes les surcharges de règles d'alerte actives.                │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_override_list() {
    RETURN SELECT * FROM scheduler_alert_override ORDER BY set_at DESC;
};
