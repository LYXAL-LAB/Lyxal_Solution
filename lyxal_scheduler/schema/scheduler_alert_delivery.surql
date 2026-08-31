-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  12. scheduler_alert_delivery                                           │
-- │  Historique des livraisons d'alertes (webhooks, email, Slack).          │
-- │  Record ID = UUID (ex: scheduler_alert_delivery:⟨uuid⟩)               │
-- │  Source : Croniq alert_deliveries (migration 017)                      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_alert_delivery TYPE NORMAL SCHEMAFULL
    COMMENT "Historique des livraisons d'alertes (webhooks, email, Slack)"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS rule_name
    ON TABLE scheduler_alert_delivery
    TYPE string
    COMMENT "Nom de la règle d'alerte déclenchée";

DEFINE FIELD IF NOT EXISTS channel_name
    ON TABLE scheduler_alert_delivery
    TYPE string
    COMMENT "Nom du canal de notification (ex: 'webhook', 'email', 'slack')";

DEFINE FIELD IF NOT EXISTS job_key
    ON TABLE scheduler_alert_delivery
    TYPE record<scheduler_job_definition>
    COMMENT "Lien direct vers la définition du job concerné";

DEFINE FIELD IF NOT EXISTS execution_id
    ON TABLE scheduler_alert_delivery
    TYPE option<record<scheduler_execution>>
    COMMENT "Lien direct vers l'exécution qui a généré l'alerte";

DEFINE FIELD IF NOT EXISTS state
    ON TABLE scheduler_alert_delivery
    TYPE string
    ASSERT $value IN ['delivered', 'failed', 'throttled']
    COMMENT "État de livraison : delivered | failed | throttled";

DEFINE FIELD IF NOT EXISTS error
    ON TABLE scheduler_alert_delivery
    TYPE option<string>
    COMMENT "Message d'erreur en cas d'échec de livraison";

DEFINE FIELD IF NOT EXISTS fired_at
    ON TABLE scheduler_alert_delivery
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de déclenchement de l'alerte";

DEFINE FIELD IF NOT EXISTS delivered_at
    ON TABLE scheduler_alert_delivery
    TYPE option<datetime>
    COMMENT "Date de livraison effective";

-- Index : filtrer par job
DEFINE INDEX IF NOT EXISTS idx_alert_delivery_job_key
    ON TABLE scheduler_alert_delivery
    FIELDS job_key;

-- Index : tri chronologique
DEFINE INDEX IF NOT EXISTS idx_alert_delivery_fired_at
    ON TABLE scheduler_alert_delivery
    FIELDS fired_at;

-- Index : filtrer par règle d'alerte
DEFINE INDEX IF NOT EXISTS idx_alert_delivery_rule_name
    ON TABLE scheduler_alert_delivery
    FIELDS rule_name;
