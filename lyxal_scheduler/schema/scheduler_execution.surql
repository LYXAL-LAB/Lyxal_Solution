-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  scheduler_execution                                                 │
-- │  Historique de chaque exécution de job. Table la plus sollicitée.       │
-- │  Record ID = UUID (ex: scheduler_execution:⟨550e8400-...⟩)             │
-- │  Source : Croniq executions (migrations 001, 005, 019, 021, 022)        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_execution TYPE NORMAL SCHEMAFULL
    COMMENT "Historique de chaque exécution de job (tentatives, durée, erreurs)"
    CHANGEFEED 1d
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS job_key
    ON TABLE scheduler_execution
    TYPE record<scheduler_job_definition>
    COMMENT "Lien direct vers la définition du job parent";

DEFINE FIELD IF NOT EXISTS fire_at
    ON TABLE scheduler_execution
    TYPE datetime
    COMMENT "Date de mise en file d'attente (peut changer sur retry)";

DEFINE FIELD IF NOT EXISTS scheduled_for
    ON TABLE scheduler_execution
    TYPE option<datetime>
    COMMENT "Date de tir logique d'origine (constante à travers les retries)";

DEFINE FIELD IF NOT EXISTS attempt
    ON TABLE scheduler_execution
    TYPE int
    DEFAULT 1
    COMMENT "Numéro de la tentative (1 = première, 2 = premier retry, etc.)";

DEFINE FIELD IF NOT EXISTS state
    ON TABLE scheduler_execution
    TYPE string
    DEFAULT 'queued'
    ASSERT $value IN ['queued', 'claimed', 'running', 'completed', 'failed', 'dead']
    COMMENT "État du cycle de vie : queued → claimed → running → completed|failed|dead";

DEFINE FIELD IF NOT EXISTS runner_id
    ON TABLE scheduler_execution
    TYPE option<record<scheduler_runner>>
    COMMENT "Lien direct vers le runner qui exécute cette tâche";

DEFINE FIELD IF NOT EXISTS claimed_at
    ON TABLE scheduler_execution
    TYPE option<datetime>
    COMMENT "Date de prise en charge par le runner";

DEFINE FIELD IF NOT EXISTS started_at
    ON TABLE scheduler_execution
    TYPE option<datetime>
    COMMENT "Date de début réel du traitement";

DEFINE FIELD IF NOT EXISTS completed_at
    ON TABLE scheduler_execution
    TYPE option<datetime>
    COMMENT "Date de fin (succès ou échec)";

DEFINE FIELD IF NOT EXISTS duration_ms
    ON TABLE scheduler_execution
    TYPE option<int>
    COMMENT "Durée d'exécution en millisecondes";

DEFINE FIELD IF NOT EXISTS error
    ON TABLE scheduler_execution
    TYPE option<string>
    COMMENT "Message d'erreur si échec";

DEFINE FIELD IF NOT EXISTS dead_reason
    ON TABLE scheduler_execution
    TYPE option<string>
    COMMENT "Raison de mise en dead letter (timeout, max_retries_exceeded, etc.)";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE scheduler_execution
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées libres et dynamiques (paramètres JSON, contexte d'appel)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_execution
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création de l'enregistrement";

DEFINE FIELD IF NOT EXISTS idempotency_key
    ON TABLE scheduler_execution
    TYPE option<string>
    COMMENT "Clé de déduplication pour triggers événementiels (at-least-once)";

-- Index : recherche des exécutions en attente (tick du scheduler)
DEFINE INDEX IF NOT EXISTS idx_execution_state_fire_at
    ON TABLE scheduler_execution
    FIELDS state, fire_at;

-- Index : filtrer par job
DEFINE INDEX IF NOT EXISTS idx_execution_job_key
    ON TABLE scheduler_execution
    FIELDS job_key;

-- Index : retrouver les exécutions d'un runner
DEFINE INDEX IF NOT EXISTS idx_execution_runner_id
    ON TABLE scheduler_execution
    FIELDS runner_id;

-- Index : pagination chronologique (GET /executions)
DEFINE INDEX IF NOT EXISTS idx_execution_created_at
    ON TABLE scheduler_execution
    FIELDS created_at;

-- Index : rétention (purge des anciennes exécutions terminées)
DEFINE INDEX IF NOT EXISTS idx_execution_completed_at
    ON TABLE scheduler_execution
    FIELDS completed_at;

-- Index : rétention par job (keep_last)
DEFINE INDEX IF NOT EXISTS idx_execution_job_completed
    ON TABLE scheduler_execution
    FIELDS job_key, completed_at;

-- Index : déduplication stricte par idempotency_key
DEFINE INDEX IF NOT EXISTS idx_execution_idempotency
    ON TABLE scheduler_execution
    FIELDS job_key, idempotency_key UNIQUE;