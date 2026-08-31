-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  8. scheduler_execution_log                                             │
-- │  Logs ligne par ligne de chaque exécution (stdout, stderr, events).    │
-- │  Record ID = UUID (ex: scheduler_execution_log:⟨uuid⟩)                │
-- │  Source : Croniq execution_logs (migrations 003, 010)                   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_execution_log TYPE NORMAL SCHEMAFULL
    COMMENT "Logs ligne par ligne de chaque exécution de job"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS execution_id
    ON TABLE scheduler_execution_log
    TYPE record<scheduler_execution>
    COMMENT "Lien direct vers l'exécution parent";

DEFINE FIELD IF NOT EXISTS timestamp
    ON TABLE scheduler_execution_log
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Horodatage de l'événement";

DEFINE FIELD IF NOT EXISTS level
    ON TABLE scheduler_execution_log
    TYPE string
    DEFAULT 'info'
    ASSERT $value IN ['debug', 'info', 'warn', 'error']
    COMMENT "Niveau de log : debug | info | warn | error";

DEFINE FIELD IF NOT EXISTS message
    ON TABLE scheduler_execution_log
    TYPE string
    COMMENT "Contenu du message de log";

DEFINE FIELD IF NOT EXISTS fields
    ON TABLE scheduler_execution_log
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées structurées du log (clé/valeur libre dynamique)";

DEFINE FIELD IF NOT EXISTS seq
    ON TABLE scheduler_execution_log
    TYPE int
    DEFAULT 0
    COMMENT "Séquence monotone par exécution (ordre garanti même si même ms)";

-- Index : retrouver tous les logs d'une exécution
DEFINE INDEX IF NOT EXISTS idx_exec_log_execution_id
    ON TABLE scheduler_execution_log
    FIELDS execution_id;

-- Index : filtrer par timestamp (pour purges ou analyses temporelles)
DEFINE INDEX IF NOT EXISTS idx_exec_log_timestamp
    ON TABLE scheduler_execution_log
    FIELDS timestamp;

-- Index : tri par (execution_id, seq) pour le streaming ordonné des logs
DEFINE INDEX IF NOT EXISTS idx_exec_log_execution_seq
    ON TABLE scheduler_execution_log
    FIELDS execution_id, seq;
