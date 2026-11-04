-- ==============================================================================
-- Tables du runtime de Lyxal OS (accès réservé au runtime : PERMISSIONS NONE)
-- ==============================================================================

DEFINE TABLE OVERWRITE runtime_module TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant l'identité canonique des modules connus du Runtime";

DEFINE TABLE OVERWRITE runtime_release TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant l'historique des releases de modules";

DEFINE TABLE OVERWRITE runtime_migration TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant l'historique des migrations de schéma appliquées";

DEFINE TABLE OVERWRITE runtime_lease TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Baux distribués du runtime (migrations, installations), échéances à l'heure de la base";

DEFINE TABLE OVERWRITE runtime_health TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant l'état de santé instantané des modules par nœud";

DEFINE TABLE OVERWRITE runtime_worker TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant l'état observable des workers par nœud";

DEFINE TABLE OVERWRITE runtime_event_journal TYPE NORMAL SCHEMAFULL PERMISSIONS NONE
    COMMENT "Table système enregistrant le journal d'audit des événements internes du Runtime";
