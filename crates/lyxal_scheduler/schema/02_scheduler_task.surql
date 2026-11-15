-- ============================================================================
-- TABLE  : scheduler_task
-- MODULE : lyxal_scheduler
-- RÔLE   : Types d'action exécutables, déclarés par les modules propriétaires
-- ============================================================================
-- Une tâche est déclarée par le seed de son module (IF !record::exists(scheduler_task:⟨m.a⟩)
-- THEN (CREATE …) END;), jamais par une personne. Identifiant ⟨module.action⟩ en minuscules ;
-- module = lyxal_<module>. Seule la session système écrit (PERMISSIONS NONE pour toute autre
-- session) et, après création, seulement l'état (garde scheduler_task_guard). Les personnes
-- créent librement leurs planifications et exécutions différées d'une tâche active pour laquelle
-- elles ont la permission propre de la tâche.

DEFINE TABLE OVERWRITE scheduler_task
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "catalog" })
        FOR create, update, delete NONE
    COMMENT "Types d'action exécutables, déclarés par les modules propriétaires (seed)";

DEFINE FIELD OVERWRITE module ON TABLE scheduler_task
    TYPE string
    ASSERT string::len($value) >= 7 AND string::len($value) <= 64
    COMMENT "Module propriétaire (lyxal_<module>), dont le nom court préfixe l'identifiant";

DEFINE FIELD OVERWRITE description ON TABLE scheduler_task
    TYPE object
    DEFAULT {}
    COMMENT "Description par langue ({ fr, en })";

DEFINE FIELD OVERWRITE description.* ON TABLE scheduler_task
    TYPE string
    ASSERT string::len($value) <= 1024;

DEFINE FIELD OVERWRITE executor ON TABLE scheduler_task
    TYPE string
    ASSERT $value IN ["handler", "function", "event"]
    COMMENT "Exécuteur : handler (code Rust inscrit), function (fonction SurrealQL du module), event (publication différée)";

DEFINE FIELD OVERWRITE target ON TABLE scheduler_task
    TYPE string
    ASSERT string::len($value) >= 3 AND string::len($value) <= 128
    COMMENT "Cible : nom du handler (<module>.<action>), fonction <module>_<action> du même module, ou type d'événement préfixé par le module";

DEFINE FIELD OVERWRITE permission ON TABLE scheduler_task
    TYPE option<string>
    COMMENT "Permission lyxal_auth exigée pour planifier la tâche (contrôlée à la création et à chaque modification) ; NONE : droits du planificateur seulement";

DEFINE FIELD OVERWRITE args_schema ON TABLE scheduler_task
    TYPE option<object>
    FLEXIBLE
    COMMENT "Schéma des arguments pour fn::validation_object_execute ; NONE : aucun argument";

DEFINE FIELD OVERWRITE queue ON TABLE scheduler_task
    TYPE record<scheduler_queue>
    DEFAULT scheduler_queue:default
    COMMENT "File d'exécution";

DEFINE FIELD OVERWRITE priority ON TABLE scheduler_task
    TYPE int
    DEFAULT 5
    ASSERT $value >= 0 AND $value <= 9
    COMMENT "Priorité par défaut (0 : la plus haute, 9 : la plus basse)";

DEFINE FIELD OVERWRITE retry ON TABLE scheduler_task
    TYPE object
    DEFAULT { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 1h }
    COMMENT "Politique de tentatives (fn::validation_retry_policy : 10 tentatives et 24 h au plus)";

DEFINE FIELD OVERWRITE retry.max_attempts ON TABLE scheduler_task TYPE int;
DEFINE FIELD OVERWRITE retry.strategy ON TABLE scheduler_task TYPE string;
DEFINE FIELD OVERWRITE retry.initial_delay ON TABLE scheduler_task TYPE duration;
DEFINE FIELD OVERWRITE retry.max_delay ON TABLE scheduler_task TYPE duration;

DEFINE FIELD OVERWRITE timeout ON TABLE scheduler_task
    TYPE duration
    DEFAULT 5m
    ASSERT $value >= 1s AND $value <= 24h
    COMMENT "Délai maximal d'une tentative (1 s à 24 h) ; le bail dure ce délai plus une marge";

DEFINE FIELD OVERWRITE unique_for ON TABLE scheduler_task
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1s AND $value <= 366d)
    COMMENT "Unicité des exécutions différées : une seconde exécution de même clé est refusée tant qu'une exécution non terminée de moins de cette durée existe";

DEFINE FIELD OVERWRITE scope ON TABLE scheduler_task
    TYPE string
    DEFAULT "organization"
    ASSERT $value IN ["organization", "installation"]
    COMMENT "Portée : organization (planifiée pour une organisation) ou installation";

DEFINE FIELD OVERWRITE state ON TABLE scheduler_task
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled"]
    COMMENT "État : active, disabled (aucune nouvelle planification ni exécution, rien n'est réservé)";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_task
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Déclaration";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_task
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_task_module ON TABLE scheduler_task FIELDS module;
