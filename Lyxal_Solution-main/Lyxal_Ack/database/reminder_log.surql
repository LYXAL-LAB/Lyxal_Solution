-- ============================================================
-- ENTITY: reminder_log
-- DESCRIPTION: Audit de communication
-- ============================================================

DEFINE TABLE IF NOT EXISTS reminder_log TYPE NORMAL SCHEMAFULL
    COMMENT "Historique et statut des notifications de rappel envoyées"
    PERMISSIONS
        FOR select WHERE $auth.id = recipient OR $auth.admin = true
        FOR create, update, delete WHERE $auth.admin = true;

DEFINE FIELD IF NOT EXISTS document           ON TABLE reminder_log TYPE record<document>
    COMMENT "Référence du document associé au rappel";
DEFINE FIELD IF NOT EXISTS recipient          ON TABLE reminder_log TYPE record<user>
    COMMENT "Référence de l'utilisateur destinataire du rappel";
DEFINE FIELD IF NOT EXISTS sent_by            ON TABLE reminder_log TYPE record<user>
    COMMENT "Référence de l'administrateur ou du système ayant déclenché l'envoi";
DEFINE FIELD IF NOT EXISTS template_used      ON TABLE reminder_log TYPE string
    COMMENT "Nom du modèle de message (template) utilisé pour cet envoi";
DEFINE FIELD IF NOT EXISTS status             ON TABLE reminder_log TYPE string 
    ASSERT $value INSIDE ['sent', 'failed', 'queued', 'bounced']
    COMMENT "État actuel de l'envoi du rappel (ex: envoyé, échec, en attente)";
DEFINE FIELD IF NOT EXISTS error_message      ON TABLE reminder_log TYPE option<string>
    COMMENT "Message d'erreur technique en cas d'échec de l'envoi";
DEFINE FIELD IF NOT EXISTS sent_at            ON TABLE reminder_log TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de l'envoi ou de la tentative d'envoi";

