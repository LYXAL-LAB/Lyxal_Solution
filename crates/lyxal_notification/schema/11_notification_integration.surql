-- ============================================================================
-- TABLES : notification_integration, notification_provider_event
-- MODULE : lyxal_notification
-- RÔLE   : Fournisseurs d'envoi par canal et par portée ; retours des fournisseurs
-- ============================================================================
-- Une intégration ne garde que le CHEMIN de ses secrets dans lyxal_secrets (dossier
-- `notification/` de sa portée), jamais une valeur. Créer ou modifier où un secret est envoyé
-- (fournisseur, réglages, chemins) exige le droit de lire ce secret : contrôlé par les fonctions
-- (fn::notification_integration_secret_check) et, pour une écriture directe dans la table, par la
-- garde notification_integration_guard. Un retour de fournisseur ne garde aucun corps.
-- Canaux : email, sms (Brevo, Twilio, Vonage), chat (un service de messagerie par intégration ;
-- seul Telegram a un secret : le jeton du robot) et webhook (adresse web : aucune valeur secrète,
-- une intégration par portée active le canal) et push (décisions G2, G6 : Web Push, Firebase
-- Cloud Messaging, Apple Push Notification service ; identifiants dans lyxal_secrets).

DEFINE TABLE OVERWRITE notification_integration
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
        FOR create, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
        -- Le worker (session système de l'hôte) note l'issue d'un essai ; la garde l'empêche de
        -- changer réglages ou chemins
        FOR update WHERE fn::notification_can({ action: "manage", tenant: tenant }) OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Intégration : fournisseur d'un canal pour une organisation ou l'installation ; chemins des secrets dans lyxal_secrets, jamais de valeur";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_integration
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation, repli de toutes les organisations)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_integration
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE key ON TABLE notification_integration TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 64 READONLY COMMENT "Clé unique dans la portée";
DEFINE FIELD OVERWRITE channel ON TABLE notification_integration TYPE string ASSERT $value IN ["email", "sms", "chat", "webhook", "push"] READONLY COMMENT "Canal";
DEFINE FIELD OVERWRITE provider ON TABLE notification_integration
    TYPE string
    ASSERT ($this.channel = "email" AND $value IN ["smtp", "brevo", "mailgun", "postmark", "resend"])
        OR ($this.channel = "sms" AND $value IN ["brevo", "twilio", "vonage"])
        OR ($this.channel = "chat" AND $value IN ["slack", "teams", "discord", "mattermost", "google_chat", "telegram"])
        OR ($this.channel = "webhook" AND $value = "webhook")
        OR ($this.channel = "push" AND $value IN ["webpush", "fcm", "apns"])
    READONLY
    COMMENT "Fournisseur, propre au canal (e-mail : smtp, brevo, mailgun, postmark, resend ; SMS : brevo, twilio, vonage ; messagerie : slack, teams, discord, mattermost, google_chat, telegram ; adresse web : webhook ; push : webpush, fcm, apns)";
DEFINE FIELD OVERWRITE name ON TABLE notification_integration TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128 COMMENT "Nom affiché";
DEFINE FIELD OVERWRITE active ON TABLE notification_integration TYPE bool DEFAULT true COMMENT "Active : éligible aux envois";
DEFINE FIELD OVERWRITE primary ON TABLE notification_integration TYPE bool DEFAULT false COMMENT "Principale de la portée pour son canal (une au plus)";
DEFINE FIELD OVERWRITE primary_slot ON TABLE notification_integration
    TYPE option<string>
    VALUE IF $this.primary { string::concat($this.scope_key, ":", $this.channel) } ELSE { NONE }
    COMMENT "Unicité de la principale par portée et canal (NONE ignoré par l'index unique)";
DEFINE FIELD OVERWRITE priority ON TABLE notification_integration TYPE int DEFAULT 100 ASSERT $value >= 0 AND $value <= 1000 COMMENT "Ordre après la principale (plus petit d'abord)";
DEFINE FIELD OVERWRITE condition ON TABLE notification_integration TYPE option<object> FLEXIBLE COMMENT "Condition lyxal_core facultative sur { workflow, subscriber, payload }";

DEFINE FIELD OVERWRITE settings ON TABLE notification_integration TYPE object DEFAULT {} COMMENT "Réglages non secrets";
DEFINE FIELD OVERWRITE settings.from_address ON TABLE notification_integration TYPE option<string> COMMENT "E-mail : adresse d'expédition";
DEFINE FIELD OVERWRITE settings.from_name ON TABLE notification_integration TYPE option<string> COMMENT "Nom d'expéditeur";
DEFINE FIELD OVERWRITE settings.reply_to ON TABLE notification_integration TYPE option<string> COMMENT "Adresse de réponse";
DEFINE FIELD OVERWRITE settings.host ON TABLE notification_integration TYPE option<string> COMMENT "SMTP : hôte du relais";
DEFINE FIELD OVERWRITE settings.port ON TABLE notification_integration TYPE option<int> COMMENT "SMTP : port";
DEFINE FIELD OVERWRITE settings.security ON TABLE notification_integration TYPE option<string> ASSERT $value IS NONE OR $value IN ["tls", "starttls", "local_plain"] COMMENT "SMTP : tls, starttls, local_plain (installation seulement, boucle locale)";
DEFINE FIELD OVERWRITE settings.domain ON TABLE notification_integration TYPE option<string> COMMENT "Mailgun : domaine d'envoi";
DEFINE FIELD OVERWRITE settings.region ON TABLE notification_integration TYPE option<string> ASSERT $value IS NONE OR $value IN ["us", "eu"] COMMENT "Mailgun : région de l'API";
DEFINE FIELD OVERWRITE settings.sender ON TABLE notification_integration TYPE option<string> COMMENT "SMS : expéditeur (numéro E.164 ou nom court de 11 caractères au plus)";
DEFINE FIELD OVERWRITE settings.vapid_subject ON TABLE notification_integration TYPE option<string> COMMENT "Web Push : contact VAPID (mailto: ou https:)";
DEFINE FIELD OVERWRITE settings.vapid_public_key ON TABLE notification_integration TYPE option<string> COMMENT "Web Push : clé publique VAPID (Base64url, point P-256 non compressé), donnée aux navigateurs ; posée par l'hôte avec une paire neuve";
DEFINE FIELD OVERWRITE settings.project_id ON TABLE notification_integration TYPE option<string> COMMENT "FCM : identifiant du projet Firebase";
DEFINE FIELD OVERWRITE settings.team_id ON TABLE notification_integration TYPE option<string> COMMENT "APNs : identifiant de l'équipe Apple (10 caractères)";
DEFINE FIELD OVERWRITE settings.bundle_id ON TABLE notification_integration TYPE option<string> COMMENT "APNs : identifiant de l'application (en-tête apns-topic)";
DEFINE FIELD OVERWRITE settings.environment ON TABLE notification_integration TYPE option<string> ASSERT $value IS NONE OR $value IN ["production", "sandbox"] COMMENT "APNs : production ou bac à sable";

DEFINE FIELD OVERWRITE credentials_path ON TABLE notification_integration TYPE option<string> ASSERT $value IS NONE OR string::starts_with($value, "notification/") COMMENT "Chemin du secret des identifiants (lyxal_secrets, même portée) : e-mail, SMS, Telegram et push (clé VAPID, compte de service Google, clé APNs) ; absent pour les autres messageries et l'adresse web";
DEFINE FIELD OVERWRITE webhook_path ON TABLE notification_integration TYPE option<string> ASSERT $value IS NONE OR string::starts_with($value, "notification/") COMMENT "Chemin facultatif du secret des retours (lyxal_secrets, même portée)";

DEFINE FIELD OVERWRITE last_test ON TABLE notification_integration TYPE option<object> COMMENT "Dernier essai (D6) : { at, ok, code }";
DEFINE FIELD OVERWRITE last_test.at ON TABLE notification_integration TYPE datetime;
DEFINE FIELD OVERWRITE last_test.ok ON TABLE notification_integration TYPE bool;
DEFINE FIELD OVERWRITE last_test.code ON TABLE notification_integration TYPE option<string>;

DEFINE FIELD OVERWRITE created_at ON TABLE notification_integration TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_integration TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_integration_key ON TABLE notification_integration FIELDS scope_key, key UNIQUE;
DEFINE INDEX OVERWRITE notification_integration_primary ON TABLE notification_integration FIELDS primary_slot UNIQUE;
DEFINE INDEX OVERWRITE notification_integration_scope ON TABLE notification_integration FIELDS scope_key, channel, active;

-- Garde d'une écriture directe : où un secret est envoyé ne change qu'avec le droit de le lire
DEFINE EVENT OVERWRITE notification_integration_guard ON TABLE notification_integration
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.settings != $after.settings OR $before.credentials_path != $after.credentials_path OR $before.webhook_path != $after.webhook_path))
THEN {
    LET $refusal = fn::notification_integration_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE TABLE OVERWRITE notification_provider_event
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
        FOR create, delete WHERE fn::notification_can({ action: "worker", tenant: tenant })
        -- Rattachement d'un retour arrivé avant l'enregistrement de son message
        FOR update WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Retour normalisé d'un fournisseur (délivré, rejeté, plainte), dédoublonné ; aucun corps";

DEFINE FIELD OVERWRITE integration ON TABLE notification_provider_event TYPE record<notification_integration> REFERENCE ON DELETE CASCADE READONLY COMMENT "Intégration qui a reçu le retour";
DEFINE FIELD OVERWRITE tenant ON TABLE notification_provider_event TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation du message (sinon de l'intégration)";
DEFINE FIELD OVERWRITE provider_event_id ON TABLE notification_provider_event TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 256 READONLY COMMENT "Identifiant de l'événement chez le fournisseur";
DEFINE FIELD OVERWRITE type ON TABLE notification_provider_event TYPE string ASSERT $value IN ["delivered", "bounced", "soft_bounced", "complained"] READONLY COMMENT "Type normalisé";
DEFINE FIELD OVERWRITE message ON TABLE notification_provider_event TYPE option<record<notification_message>> REFERENCE ON DELETE UNSET COMMENT "Message lié (NONE : message inconnu)";
DEFINE FIELD OVERWRITE provider_message_id ON TABLE notification_provider_event TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 READONLY COMMENT "Identifiant du message chez le fournisseur : un retour arrivé avant l'enregistrement de l'envoi est rapproché du message à sa création";
DEFINE FIELD OVERWRITE address ON TABLE notification_provider_event TYPE option<string> COMMENT "Adresse du message (suppression)";
DEFINE FIELD OVERWRITE occurred_at ON TABLE notification_provider_event TYPE datetime READONLY COMMENT "Date de l'événement chez le fournisseur";
DEFINE FIELD OVERWRITE received_at ON TABLE notification_provider_event TYPE datetime DEFAULT time::now() READONLY COMMENT "Réception";
DEFINE FIELD OVERWRITE purge_after ON TABLE notification_provider_event TYPE datetime READONLY COMMENT "Date de purge (réglage retention_days_log)";

DEFINE INDEX OVERWRITE notification_provider_event_unique ON TABLE notification_provider_event FIELDS integration, provider_event_id UNIQUE;
DEFINE INDEX OVERWRITE notification_provider_event_pending ON TABLE notification_provider_event FIELDS integration, provider_message_id;
DEFINE INDEX OVERWRITE notification_provider_event_purge ON TABLE notification_provider_event FIELDS purge_after;
