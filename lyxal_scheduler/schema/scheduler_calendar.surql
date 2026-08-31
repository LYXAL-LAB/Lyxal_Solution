-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  7. scheduler_calendar                                                  │
-- │  Calendriers métier (jours ouvrés, fériés, exclusions).                │
-- │  Record ID = calendar_id (ex: scheduler_calendar:france_business)       │
-- │  Source : Croniq calendar_definitions (migrations 003, 006)             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_calendar TYPE NORMAL SCHEMAFULL
    COMMENT "Calendrier métier : jours ouvrés, fériés, inclusions/exclusions"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS name
    ON TABLE scheduler_calendar
    TYPE string
    COMMENT "Nom humain du calendrier (ex: 'France - Jours ouvrés')";

DEFINE FIELD IF NOT EXISTS timezone
    ON TABLE scheduler_calendar
    TYPE option<string>
    COMMENT "Fuseau horaire IANA du calendrier";

DEFINE FIELD IF NOT EXISTS rules
    ON TABLE scheduler_calendar
    TYPE array<string>
    DEFAULT []
    COMMENT "Directives DSL (include/exclude sous forme de liste de chaînes)";

DEFINE FIELD IF NOT EXISTS managed_by
    ON TABLE scheduler_calendar
    TYPE string
    DEFAULT 'api'
    ASSERT $value IN ['api', 'dsl']
    COMMENT "Qui gère ce calendrier : api ou dsl";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_calendar
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_calendar
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Mis à jour automatiquement";

-- Index : filtrer les calendriers selon leur mode de gestion
DEFINE INDEX IF NOT EXISTS idx_calendar_managed_by
    ON TABLE scheduler_calendar
    FIELDS managed_by;
