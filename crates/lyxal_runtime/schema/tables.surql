-- ==============================================================================
-- Tables système de Lyxal OS (V1.4)
-- ==============================================================================

DEFINE TABLE OVERWRITE system_module SCHEMAFULL
    COMMENT "Table système enregistrant l'identité canonique des modules connus du Runtime";

DEFINE TABLE OVERWRITE system_module_release SCHEMAFULL
    COMMENT "Table système enregistrant l'historique des releases de modules";

DEFINE TABLE OVERWRITE system_migration SCHEMAFULL
    COMMENT "Table système enregistrant l'historique des migrations de schéma appliquées";

DEFINE TABLE OVERWRITE system_migration_lock SCHEMAFULL
    COMMENT "Table système enregistrant les baux distribués temporaires de migration";

DEFINE TABLE OVERWRITE system_installation_lock SCHEMAFULL
    COMMENT "Table système enregistrant les baux distribués temporaires d'installation de release";

DEFINE TABLE OVERWRITE system_health SCHEMAFULL
    COMMENT "Table système enregistrant l'état de santé instantané des modules par nœud";

DEFINE TABLE OVERWRITE system_worker SCHEMAFULL
    COMMENT "Table système enregistrant l'état observable des workers par nœud";

DEFINE TABLE OVERWRITE system_runtime_event SCHEMAFULL
    COMMENT "Table système enregistrant le journal d'audit des événements internes du Runtime";
