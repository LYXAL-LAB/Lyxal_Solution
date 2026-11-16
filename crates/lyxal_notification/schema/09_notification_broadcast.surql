-- ============================================================================
-- TABLE  : notification_broadcast
-- MODULE : lyxal_notification
-- RÔLE   : Diffusions à un sujet ou à tous les abonnés d'une portée (décision B3)
-- ============================================================================
-- Le déclenchement enregistre la diffusion (idempotente par portée et clé) ; le worker la
-- réserve (`locked_until`, `claim_token`) et la traite par paquets de 500 abonnés au plus,
-- triés par identifiant : `cursor` est le dernier élément traité. Chaque abonné reçoit un
-- déclenchement de clé `<clé de la diffusion>/<subscriber_id>` (index unique) : une reprise
-- après arrêt ne renvoie rien deux fois. L'auteur (`actor`) est exclu sauf `exclude_actor` faux.

DEFINE TABLE OVERWRITE notification_broadcast
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create WHERE fn::notification_can({ action: "send", tenant: tenant })
        FOR update, delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Diffusions d'un parcours à un sujet ou à tous les abonnés, traitées par paquets";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_broadcast TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation (NONE : installation)";
DEFINE FIELD OVERWRITE scope_key ON TABLE notification_broadcast TYPE string VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) } COMMENT "Portée";
DEFINE FIELD OVERWRITE workflow ON TABLE notification_broadcast TYPE record<notification_workflow> READONLY COMMENT "Parcours";
DEFINE FIELD OVERWRITE idempotency_key ON TABLE notification_broadcast TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128 READONLY COMMENT "Clé d'idempotence du déclenchement";
DEFINE FIELD OVERWRITE event_id ON TABLE notification_broadcast TYPE option<string> READONLY COMMENT "Événement déclencheur";
DEFINE FIELD OVERWRITE topic ON TABLE notification_broadcast TYPE option<record<notification_topic>> REFERENCE ON DELETE UNSET COMMENT "Sujet visé (NONE : tous les abonnés de la portée)";
DEFINE FIELD OVERWRITE to_all ON TABLE notification_broadcast TYPE bool DEFAULT false READONLY COMMENT "Tous les abonnés de la portée";
DEFINE FIELD OVERWRITE actor ON TABLE notification_broadcast TYPE option<string> READONLY COMMENT "subscriber_id de l'auteur de l'action";
DEFINE FIELD OVERWRITE exclude_actor ON TABLE notification_broadcast TYPE bool DEFAULT true READONLY COMMENT "Auteur exclu de la diffusion";
DEFINE FIELD OVERWRITE payload ON TABLE notification_broadcast TYPE object DEFAULT {} READONLY COMMENT "Variables non sensibles";
DEFINE FIELD OVERWRITE payload.* ON TABLE notification_broadcast TYPE any;

DEFINE FIELD OVERWRITE status ON TABLE notification_broadcast
    TYPE string
    DEFAULT "queued"
    ASSERT $value IN ["queued", "running", "completed"]
    COMMENT "État : en attente, en cours (réservée par un worker), terminée";

DEFINE FIELD OVERWRITE cursor ON TABLE notification_broadcast TYPE option<record> COMMENT "Dernier abonné (ou abonnement) traité";
DEFINE FIELD OVERWRITE exhausted ON TABLE notification_broadcast TYPE bool DEFAULT false COMMENT "Tous les destinataires ont été traités";
DEFINE FIELD OVERWRITE processed ON TABLE notification_broadcast TYPE int DEFAULT 0 COMMENT "Destinataires examinés";
DEFINE FIELD OVERWRITE created ON TABLE notification_broadcast TYPE int DEFAULT 0 COMMENT "Déclenchements créés";
DEFINE FIELD OVERWRITE skipped ON TABLE notification_broadcast TYPE int DEFAULT 0 COMMENT "Destinataires écartés (auteur, condition, sans adresse, préférence, adresse supprimée)";
DEFINE FIELD OVERWRITE locked_until ON TABLE notification_broadcast TYPE option<datetime> COMMENT "Fin de réservation";
DEFINE FIELD OVERWRITE claim_token ON TABLE notification_broadcast TYPE option<string> COMMENT "Jeton de réservation (UUID v7)";
DEFINE FIELD OVERWRITE worker_id ON TABLE notification_broadcast TYPE option<string> COMMENT "Worker réservataire";
DEFINE FIELD OVERWRITE created_at ON TABLE notification_broadcast TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_broadcast TYPE datetime VALUE time::now() COMMENT "Dernière modification";
DEFINE FIELD OVERWRITE completed_at ON TABLE notification_broadcast TYPE option<datetime> COMMENT "Fin du traitement";
DEFINE FIELD OVERWRITE purge_after ON TABLE notification_broadcast TYPE datetime COMMENT "Date de purge (réglage retention_days_runs)";

DEFINE INDEX OVERWRITE notification_broadcast_idempotency ON TABLE notification_broadcast FIELDS scope_key, idempotency_key UNIQUE;
DEFINE INDEX OVERWRITE notification_broadcast_queue ON TABLE notification_broadcast FIELDS status;
DEFINE INDEX OVERWRITE notification_broadcast_purge ON TABLE notification_broadcast FIELDS purge_after;
