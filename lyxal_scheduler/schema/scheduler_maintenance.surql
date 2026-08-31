-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  10. scheduler_maintenance                                              │
-- │  Table singleton (un seul enregistrement) : mode maintenance global.   │
-- │  Record ID = fixe "global" (scheduler_maintenance:global)               │
-- │  Source : Croniq maintenance (migration 020)                            │
-- │                                                                         │
-- │  Quand activé : le scheduler ne crée plus de nouvelles exécutions,     │
-- │  les runners ne reçoivent plus de travail. Les tâches en cours         │
-- │  terminent normalement. Les triggers s'accumulent et reprennent        │
-- │  à la sortie de maintenance.                                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS scheduler_maintenance TYPE NORMAL SCHEMAFULL
    COMMENT "Mode maintenance global (singleton : scheduler_maintenance:global)"
    PERMISSIONS NONE;

DEFINE FIELD IF NOT EXISTS manual_active
    ON TABLE scheduler_maintenance
    TYPE bool
    DEFAULT false
    COMMENT "true = pause manuelle immédiate, false = selon la fenêtre";

DEFINE FIELD IF NOT EXISTS window_start
    ON TABLE scheduler_maintenance
    TYPE option<datetime>
    COMMENT "Début de la fenêtre de maintenance planifiée";

DEFINE FIELD IF NOT EXISTS window_end
    ON TABLE scheduler_maintenance
    TYPE option<datetime>
    COMMENT "Fin de la fenêtre de maintenance (NULL = pas de fin automatique)";

DEFINE FIELD IF NOT EXISTS note
    ON TABLE scheduler_maintenance
    TYPE option<string>
    COMMENT "Message affiché dans le bandeau UI pendant la maintenance";

DEFINE FIELD IF NOT EXISTS updated_by
    ON TABLE scheduler_maintenance
    TYPE option<string>
    COMMENT "user_id ou api_client_id qui a modifié le switch";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE scheduler_maintenance
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date d'initialisation du switch de maintenance";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE scheduler_maintenance
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Date de dernière modification du switch";


-- ============================================================================
-- Initialisation du singleton maintenance
-- ============================================================================
-- Se fait via INSERT IGNORE pour créer la ligne à l'initialisation
-- SANS JAMAIS écraser un mode maintenance actif en cas de re-exécution.
-- ============================================================================

INSERT IGNORE INTO scheduler_maintenance {
    id: 'global',
    manual_active: false
};
