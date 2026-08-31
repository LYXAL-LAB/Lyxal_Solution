-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  1. scheduler_job                                                       │
-- │  État runtime d'un job planifié.                                        │
-- │  Record ID = job_key (ex: scheduler_job:backup_daily)                   │
-- │  Source : Croniq job_states (migration 001)                             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_job TYPE NORMAL SCHEMAFULL
    COMMENT "État runtime d'un job planifié (prochaine exécution, statut, compteurs)"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS definition
    ON TABLE scheduler_job
    TYPE option<record<scheduler_job_definition>>
    COMMENT "Lien direct vers la définition de configuration du job";

DEFINE FIELD IF NOT EXISTS next_fire_at
    ON TABLE scheduler_job
    TYPE option<datetime>
    COMMENT "Prochaine date d'exécution prévue";

DEFINE FIELD IF NOT EXISTS last_fired_at
    ON TABLE scheduler_job
    TYPE option<datetime>
    COMMENT "Date du dernier tir effectif";

DEFINE FIELD IF NOT EXISTS fire_count
    ON TABLE scheduler_job
    TYPE int
    DEFAULT 0
    COMMENT "Nombre total de tirs depuis la création";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE scheduler_job
    TYPE string
    DEFAULT 'active'
    ASSERT $value IN ['active', 'paused', 'exhausted']
    COMMENT "Statut du job : active | paused | exhausted";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_job
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date d'initialisation de l'état du job";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_job
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Mis à jour automatiquement à chaque modification";

-- Index haute performance pour le tick loop du scheduler (exécuté chaque seconde)
DEFINE INDEX IF NOT EXISTS idx_job_next_fire
    ON TABLE scheduler_job
    FIELDS status, next_fire_at;