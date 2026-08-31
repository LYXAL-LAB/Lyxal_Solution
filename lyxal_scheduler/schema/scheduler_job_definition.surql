-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  5. scheduler_job_definition                                            │
-- │  Définition d'un job (configuration, politique de retry, metadata).     │
-- │  Record ID = job_key (ex: scheduler_job_definition:backup_daily)        │
-- │  Source : Croniq job_definitions (migrations 003, 004, 008, 023)        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_job_definition TYPE NORMAL SCHEMAFULL
    COMMENT "Définition d'un job : configuration, politique de retry, tags"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS description
    ON TABLE scheduler_job_definition
    TYPE option<string>
    COMMENT "Description humaine du job";

DEFINE FIELD IF NOT EXISTS assigned_runner_id
    ON TABLE scheduler_job_definition
    TYPE option<record<scheduler_runner>>
    COMMENT "Runner assigné en dur (routage fixe, NULL = round-robin)";

DEFINE FIELD IF NOT EXISTS is_active
    ON TABLE scheduler_job_definition
    TYPE bool
    DEFAULT true
    COMMENT "true = actif, false = désactivé";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE scheduler_job_definition
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Paramètres libres et dynamiques du job (payload, config d'exécution, etc.)";

DEFINE FIELD IF NOT EXISTS tags
    ON TABLE scheduler_job_definition
    TYPE array<string>
    DEFAULT []
    COMMENT "Tags de filtrage (ex: ['env=prod', 'team=ops']). Pas de routage.";

-- Politique d'exécution (migration 004) — NULL = défaut système
DEFINE FIELD IF NOT EXISTS timeout
    ON TABLE scheduler_job_definition
    TYPE option<string>
    COMMENT "Durée max d'exécution (ex: '5m', '1h'). NULL = défaut système (5min)";

DEFINE FIELD IF NOT EXISTS max_retries
    ON TABLE scheduler_job_definition
    TYPE option<int>
    COMMENT "Nombre max de retries. NULL = défaut système (3)";

DEFINE FIELD IF NOT EXISTS dead_letter_enabled
    ON TABLE scheduler_job_definition
    TYPE option<bool>
    COMMENT "Activer la dead letter queue. NULL = défaut (true)";

-- Politique dead letter avancée (migration 023)
DEFINE FIELD IF NOT EXISTS dead_letter_retention
    ON TABLE scheduler_job_definition
    TYPE option<string>
    COMMENT "Rétention des dead letters (ex: '30d'). NULL = défaut système";

DEFINE FIELD IF NOT EXISTS dead_letter_operator_hint
    ON TABLE scheduler_job_definition
    TYPE option<string>
    COMMENT "Message contextuel pour l'opérateur en cas de dead letter";

DEFINE FIELD IF NOT EXISTS dead_letter_replay_max_age
    ON TABLE scheduler_job_definition
    TYPE option<string>
    COMMENT "Garde anti-rejeu périmé (ex: '7d'). Rejeu refusé si trop vieux.";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_job_definition
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_job_definition
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Mis à jour automatiquement à chaque modification";

-- Index pour la recherche des jobs actifs lors du rechargement
DEFINE INDEX IF NOT EXISTS idx_job_def_is_active
    ON TABLE scheduler_job_definition
    FIELDS is_active;
