-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  13. scheduler_alert_override                                           │
-- │  Surcharges opérationnelles temporaires des règles d'alerte (snooze).   │
-- │  Record ID = rule_name (ex: scheduler_alert_override:slack_on_failure)  │
-- │  Source : Croniq alert_rule_overrides (migration 018)                   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_alert_override TYPE NORMAL SCHEMAFULL
    COMMENT "Surcharges opérationnelles temporaires des règles d'alerte (snooze, pause)"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE scheduler_alert_override
    TYPE option<bool>
    COMMENT "NULL = défaut DSL, false = désactivé de force, true = activé de force";

DEFINE FIELD IF NOT EXISTS snooze_until
    ON TABLE scheduler_alert_override
    TYPE option<datetime>
    COMMENT "Alerte mise en sourdine jusqu'à cette date";

DEFINE FIELD IF NOT EXISTS throttle_secs
    ON TABLE scheduler_alert_override
    TYPE option<int>
    COMMENT "Fenêtre de limitation temporaire en secondes";

DEFINE FIELD IF NOT EXISTS note
    ON TABLE scheduler_alert_override
    TYPE string
    COMMENT "Raison/Contexte obligatoire fourni par l'opérateur";

DEFINE FIELD IF NOT EXISTS set_by
    ON TABLE scheduler_alert_override
    TYPE string
    COMMENT "user_id ou api_client_id ayant posé la surcharge";

DEFINE FIELD IF NOT EXISTS set_at
    ON TABLE scheduler_alert_override
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création de la surcharge";

DEFINE FIELD IF NOT EXISTS expires_at
    ON TABLE scheduler_alert_override
    TYPE option<datetime>
    COMMENT "Date de nettoyage automatique par le Watchdog";

-- Index : balayage d'expiration par le Watchdog
DEFINE INDEX IF NOT EXISTS idx_alert_override_expires_at
    ON TABLE scheduler_alert_override
    FIELDS expires_at;
