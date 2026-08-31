-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  scheduler_runner                                                    │
-- │  Registre des runners (workers) connectés au scheduler.                │
-- │  Record ID = runner_id (ex: scheduler_runner:worker_01)                │
-- │  Source : Croniq runners (migration 001)                               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_runner TYPE NORMAL SCHEMAFULL
    COMMENT "Registre des runners (workers) qui exécutent les tâches"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS capabilities
    ON TABLE scheduler_runner
    TYPE array<string>
    DEFAULT []
    COMMENT "Capacités du runner (ex: ['shell', 'http', 'surrealql'])";

DEFINE FIELD IF NOT EXISTS max_inflight
    ON TABLE scheduler_runner
    TYPE int
    DEFAULT 1
    COMMENT "Nombre maximum de tâches simultanées";

DEFINE FIELD IF NOT EXISTS last_poll_at
    ON TABLE scheduler_runner
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Dernier poll du runner (heartbeat)";

DEFINE FIELD IF NOT EXISTS inflight
    ON TABLE scheduler_runner
    TYPE array<record<scheduler_execution>>
    DEFAULT []
    COMMENT "Liste des exécutions actuellement en traitement";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE scheduler_runner
    TYPE string
    DEFAULT 'online'
    ASSERT $value IN ['online', 'offline', 'draining']
    COMMENT "Statut : online | offline | draining";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE scheduler_runner
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Infos système de l'hôte (hostname, version, IP, OS)";

DEFINE FIELD IF NOT EXISTS registered_at
    ON TABLE scheduler_runner
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date d'inscription du runner";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_runner
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Mis à jour automatiquement à chaque modification";

-- Index pour le balayage Heartbeat du Watchdog (détection des runners déconnectés)
DEFINE INDEX IF NOT EXISTS idx_runner_heartbeat
    ON TABLE scheduler_runner
    FIELDS status, last_poll_at;