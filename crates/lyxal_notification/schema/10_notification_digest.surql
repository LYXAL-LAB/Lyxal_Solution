-- ============================================================================
-- TABLES : notification_digest, notification_rate_limit
-- MODULE : lyxal_notification
-- RÔLE   : Regroupements (digest) et compteurs de limitation (throttle) des parcours
-- ============================================================================
-- Un regroupement est ouvert par le premier déclenchement d'une clé (portée, parcours, abonné,
-- étape, clé lue dans les données) ; les suivants le rejoignent (`merged`) jusqu'à la fin de sa
-- fenêtre, où le déclenchement porteur reprend avec le nombre et les données des événements.
-- `open_slot` n'est renseigné que tant qu'il est ouvert : l'index unique garantit un seul
-- regroupement ouvert par clé. Un compteur de limitation compte les messages d'une fenêtre fixe
-- (identifiant composé : portée, parcours, abonné, étape, clé, début de la fenêtre). Écrits par
-- les fonctions du module, en session de qui déclenche ou du worker ; supprimés avec
-- l'organisation et avec l'abonné.

DEFINE TABLE OVERWRITE notification_digest
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "send", tenant: tenant }) OR fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Regroupements de déclenchements (digest) : ouverts pendant leur fenêtre, puis fermés";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_digest
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_digest
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée";

DEFINE FIELD OVERWRITE workflow ON TABLE notification_digest TYPE record<notification_workflow> READONLY COMMENT "Parcours";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_digest
    TYPE option<record<notification_subscriber>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Abonné (supprimé avec lui)";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_digest TYPE string READONLY COMMENT "Étape de regroupement";
DEFINE FIELD OVERWRITE group_key ON TABLE notification_digest TYPE string READONLY COMMENT "Clé de regroupement lue dans les données (vide sans group_by)";
DEFINE FIELD OVERWRITE slot ON TABLE notification_digest TYPE string READONLY COMMENT "Portée, parcours, abonné, étape et clé";

DEFINE FIELD OVERWRITE open_slot ON TABLE notification_digest
    TYPE option<string>
    COMMENT "slot tant que le regroupement est ouvert, NONE ensuite (un seul ouvert par slot)";

DEFINE FIELD OVERWRITE carrier ON TABLE notification_digest
    TYPE record<notification_run>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Déclenchement porteur, qui enverra le message regroupé";

DEFINE FIELD OVERWRITE status ON TABLE notification_digest
    TYPE string
    DEFAULT "open"
    ASSERT $value IN ["open", "closed"]
    COMMENT "État : open (fenêtre en cours), closed";

DEFINE FIELD OVERWRITE ends_at ON TABLE notification_digest TYPE datetime COMMENT "Fin de la fenêtre";
DEFINE FIELD OVERWRITE count ON TABLE notification_digest TYPE int DEFAULT 1 COMMENT "Événements regroupés (porteur compris)";

DEFINE FIELD OVERWRITE events ON TABLE notification_digest
    TYPE array<object>
    DEFAULT []
    ASSERT array::len($value) <= 100
    COMMENT "Données des événements regroupés (100 premiers au plus) : [{ run, payload, at }]";

DEFINE FIELD OVERWRITE events.* ON TABLE notification_digest TYPE object;
DEFINE FIELD OVERWRITE events.*.run ON TABLE notification_digest TYPE record<notification_run>;
DEFINE FIELD OVERWRITE events.*.payload ON TABLE notification_digest TYPE object FLEXIBLE;
DEFINE FIELD OVERWRITE events.*.at ON TABLE notification_digest TYPE datetime;

DEFINE FIELD OVERWRITE created_at ON TABLE notification_digest TYPE datetime DEFAULT time::now() READONLY COMMENT "Ouverture";
DEFINE FIELD OVERWRITE closed_at ON TABLE notification_digest TYPE option<datetime> COMMENT "Fermeture";
DEFINE FIELD OVERWRITE purge_after ON TABLE notification_digest TYPE datetime COMMENT "Date de purge d'un regroupement fermé";

DEFINE INDEX OVERWRITE notification_digest_open ON TABLE notification_digest FIELDS open_slot UNIQUE;
DEFINE INDEX OVERWRITE notification_digest_slot ON TABLE notification_digest FIELDS slot, created_at;
DEFINE INDEX OVERWRITE notification_digest_carrier ON TABLE notification_digest FIELDS carrier;
DEFINE INDEX OVERWRITE notification_digest_purge ON TABLE notification_digest FIELDS status, purge_after;

DEFINE TABLE OVERWRITE notification_rate_limit
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "send", tenant: tenant }) OR fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Compteurs de limitation (throttle) par fenêtre fixe";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_rate_limit
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE workflow ON TABLE notification_rate_limit TYPE record<notification_workflow> COMMENT "Parcours";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_rate_limit
    TYPE option<record<notification_subscriber>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Abonné (supprimé avec lui)";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_rate_limit TYPE string COMMENT "Étape de limitation";
DEFINE FIELD OVERWRITE group_key ON TABLE notification_rate_limit TYPE string COMMENT "Clé lue dans les données (vide sans group_by)";
DEFINE FIELD OVERWRITE window_start ON TABLE notification_rate_limit TYPE datetime COMMENT "Début de la fenêtre";
DEFINE FIELD OVERWRITE count ON TABLE notification_rate_limit TYPE int DEFAULT 0 COMMENT "Messages comptés dans la fenêtre";
DEFINE FIELD OVERWRITE purge_after ON TABLE notification_rate_limit TYPE datetime COMMENT "Date de purge (fin de la fenêtre)";

DEFINE INDEX OVERWRITE notification_rate_limit_purge ON TABLE notification_rate_limit FIELDS purge_after;
