-- ============================================================================
-- TABLES : notification_message, notification_delivery_log, notification_suppression
-- MODULE : lyxal_notification
-- RÔLE   : Messages envoyés, journal de livraison, liste de suppression
-- ============================================================================
-- Aucun corps rendu n'est conservé ; l'objet est omis pour un parcours sensible. Le journal ne
-- contient jamais de secret.

DEFINE TABLE OVERWRITE notification_message
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant })
        FOR create, update, delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Messages envoyés par canal";

DEFINE FIELD OVERWRITE run ON TABLE notification_message TYPE record<notification_run> REFERENCE ON DELETE CASCADE READONLY COMMENT "Déclenchement";
DEFINE FIELD OVERWRITE job ON TABLE notification_message TYPE record<notification_job> REFERENCE ON DELETE CASCADE READONLY COMMENT "Étape";
DEFINE FIELD OVERWRITE channel ON TABLE notification_message TYPE string ASSERT $value IN ["email", "sms", "chat", "webhook"] READONLY COMMENT "Canal";
DEFINE FIELD OVERWRITE to ON TABLE notification_message TYPE string READONLY COMMENT "Destinataire : adresse e-mail, téléphone (E.164), ou hôte de l'adresse de messagerie ou web (jamais l'adresse complète)";
DEFINE FIELD OVERWRITE endpoint ON TABLE notification_message TYPE option<record<notification_endpoint>> REFERENCE ON DELETE UNSET READONLY COMMENT "Adresse de messagerie ou web servie (retirée si elle est supprimée)";
DEFINE FIELD OVERWRITE parts ON TABLE notification_message TYPE option<int> ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10) READONLY COMMENT "SMS : nombre de parties (décision E5)";
DEFINE FIELD OVERWRITE subject ON TABLE notification_message TYPE option<string> COMMENT "Objet (absent pour un parcours sensible)";
DEFINE FIELD OVERWRITE integration ON TABLE notification_message TYPE option<record<notification_integration>> REFERENCE ON DELETE UNSET COMMENT "Intégration qui a envoyé le message (retirée si elle est supprimée)";
DEFINE FIELD OVERWRITE provider ON TABLE notification_message TYPE option<string> ASSERT $value IS NONE OR $value IN ["smtp", "brevo", "mailgun", "postmark", "resend", "twilio", "vonage", "slack", "teams", "discord", "mattermost", "google_chat", "telegram", "webhook"] READONLY COMMENT "Fournisseur de l'envoi (service de l'adresse pour la messagerie)";
DEFINE FIELD OVERWRITE provider_message_id ON TABLE notification_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 READONLY COMMENT "Identifiant du message chez le fournisseur (unique par intégration)";
DEFINE FIELD OVERWRITE status ON TABLE notification_message TYPE string ASSERT $value IN ["sent", "delivered", "bounced", "complained"] COMMENT "État : envoyé, puis d'après les retours du fournisseur";
DEFINE FIELD OVERWRITE sent_at ON TABLE notification_message TYPE datetime DEFAULT time::now() COMMENT "Envoi";
DEFINE FIELD OVERWRITE status_at ON TABLE notification_message TYPE option<datetime> COMMENT "Dernier retour du fournisseur";

DEFINE INDEX OVERWRITE notification_message_run ON TABLE notification_message FIELDS run;
DEFINE INDEX OVERWRITE notification_message_provider ON TABLE notification_message FIELDS integration, provider_message_id UNIQUE;

DEFINE TABLE OVERWRITE notification_delivery_log
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant })
        FOR create, delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
        FOR update NONE
    COMMENT "Journal de livraison (ajout seul)";

DEFINE FIELD OVERWRITE run ON TABLE notification_delivery_log TYPE record<notification_run> REFERENCE ON DELETE CASCADE READONLY COMMENT "Déclenchement";
DEFINE FIELD OVERWRITE job ON TABLE notification_delivery_log TYPE record<notification_job> REFERENCE ON DELETE CASCADE READONLY COMMENT "Étape";
DEFINE FIELD OVERWRITE attempt ON TABLE notification_delivery_log TYPE int READONLY COMMENT "Tentative";
DEFINE FIELD OVERWRITE status ON TABLE notification_delivery_log TYPE string ASSERT $value IN ["sent", "retry", "failed", "skipped"] READONLY COMMENT "Issue";
DEFINE FIELD OVERWRITE code ON TABLE notification_delivery_log TYPE option<string> READONLY COMMENT "Code (SMTP ou NOTIFICATION_*)";
DEFINE FIELD OVERWRITE detail ON TABLE notification_delivery_log TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 READONLY COMMENT "Détail, jamais de secret ni de corps";
DEFINE FIELD OVERWRITE at ON TABLE notification_delivery_log TYPE datetime DEFAULT time::now() READONLY COMMENT "Date";
DEFINE FIELD OVERWRITE purge_after ON TABLE notification_delivery_log TYPE datetime READONLY COMMENT "Date de purge (réglage retention_days_log)";

DEFINE INDEX OVERWRITE notification_delivery_log_run ON TABLE notification_delivery_log FIELDS run;
DEFINE INDEX OVERWRITE notification_delivery_log_purge ON TABLE notification_delivery_log FIELDS purge_after;

DEFINE TABLE OVERWRITE notification_suppression
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Lue par qui déclenche (contrôle au déclenchement) ; la liste de l'installation s'applique
        -- à toutes les organisations
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
        FOR create WHERE fn::notification_can({ action: "manage", tenant: tenant }) OR fn::notification_can({ action: "worker", tenant: tenant })
        FOR update, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
    COMMENT "Adresses et numéros à ne plus contacter (rejet définitif, plainte ou désinscription chez l'opérateur, blocage manuel)";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_suppression TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation (NONE : installation)";
DEFINE FIELD OVERWRITE scope_key ON TABLE notification_suppression TYPE string VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) } COMMENT "Portée d'unicité";
DEFINE FIELD OVERWRITE channel ON TABLE notification_suppression TYPE string ASSERT $value IN ["email", "sms"] READONLY COMMENT "Canal : email (adresse) ou sms (numéro E.164)";
DEFINE FIELD OVERWRITE address ON TABLE notification_suppression TYPE string ASSERT string::len($value) >= 3 AND string::len($value) <= 254 AND $value == string::lowercase($value) READONLY COMMENT "Adresse normalisée (e-mail en minuscules, ou numéro E.164)";
DEFINE FIELD OVERWRITE reason ON TABLE notification_suppression TYPE string ASSERT $value IN ["hard_bounce", "complaint", "manual"] COMMENT "Motif";
DEFINE FIELD OVERWRITE source ON TABLE notification_suppression TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 256 COMMENT "Origine (code SMTP, administrateur…)";
DEFINE FIELD OVERWRITE created_at ON TABLE notification_suppression TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE keep_until ON TABLE notification_suppression TYPE option<datetime> COMMENT "Fin de la suppression (NONE : sans limite)";

DEFINE INDEX OVERWRITE notification_suppression_unique ON TABLE notification_suppression FIELDS scope_key, channel, address UNIQUE;
