-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  6. scheduler_trigger                                                   │
-- │  Configuration des déclencheurs (cron, timezone, fenêtre, calendrier). │
-- │  Record ID = trigger_id UUID (ex: scheduler_trigger:⟨uuid⟩)           │
-- │  Source : Croniq trigger_definitions (migration 003)                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_trigger TYPE NORMAL SCHEMAFULL
    COMMENT "Déclencheur lié à un job : expression Cron, timezone, fenêtre"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS job_key
    ON TABLE scheduler_trigger
    TYPE record<scheduler_job_definition>
    COMMENT "Lien direct vers la définition du job associé";

DEFINE FIELD IF NOT EXISTS cron_expression
    ON TABLE scheduler_trigger
    TYPE option<string>
    COMMENT "Expression Cron (ex: '0 9 * * 1-5' = 9h du lundi au vendredi)";

DEFINE FIELD IF NOT EXISTS timezone
    ON TABLE scheduler_trigger
    TYPE option<string>
    COMMENT "Fuseau horaire IANA (ex: 'Europe/Paris', 'America/New_York')";

DEFINE FIELD IF NOT EXISTS calendar
    ON TABLE scheduler_trigger
    TYPE option<record<scheduler_calendar>>
    COMMENT "Lien direct vers le calendrier métier (jours fériés, etc.)";

DEFINE FIELD IF NOT EXISTS window
    ON TABLE scheduler_trigger
    TYPE option<string>
    COMMENT "Fenêtre d'exécution autorisée (ex: '09:00-18:00')";

DEFINE FIELD IF NOT EXISTS not_before
    ON TABLE scheduler_trigger
    TYPE option<datetime>
    COMMENT "Ne pas tirer avant cette date";

DEFINE FIELD IF NOT EXISTS not_after
    ON TABLE scheduler_trigger
    TYPE option<datetime>
    COMMENT "Ne plus tirer après cette date";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE scheduler_trigger
    TYPE bool
    DEFAULT true
    COMMENT "true = trigger actif";

DEFINE FIELD IF NOT EXISTS managed_by
    ON TABLE scheduler_trigger
    TYPE string
    DEFAULT 'api'
    ASSERT $value IN ['api', 'dsl']
    COMMENT "Qui gère ce trigger : api (CRUD) ou dsl (Croniqfile)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_trigger
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_trigger
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Mis à jour automatiquement";

-- Index : retrouver tous les triggers d'un job
DEFINE INDEX IF NOT EXISTS idx_trigger_job_key
    ON TABLE scheduler_trigger
    FIELDS job_key;

-- Index composite : évaluation rapide des déclencheurs actifs par job
DEFINE INDEX IF NOT EXISTS idx_trigger_enabled_job
    ON TABLE scheduler_trigger
    FIELDS enabled, job_key;
