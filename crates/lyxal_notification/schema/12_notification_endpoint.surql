-- ============================================================================
-- TABLE  : notification_endpoint
-- MODULE : lyxal_notification
-- RÔLE   : Adresses d'un abonné pour la messagerie d'équipe et l'appel d'une adresse web
-- ============================================================================
-- Une adresse de webhook (Slack, Teams, Discord, Mattermost, Google Chat) ou une adresse web
-- donne à elle seule le droit d'écrire : c'est un secret (décision E2). Elle n'entre en base que
-- scellée (enc:v2, lyxal_crypto, contexte lié à l'organisation et à l'adresse) par l'hôte, et
-- seul le worker la lit ; la personne ne voit que l'hôte. Telegram : l'adresse ne porte que
-- l'identifiant du salon (le jeton du robot est le secret de l'intégration, dans lyxal_secrets).
-- Adresse web : clé de signature des appels scellée de même, montrée une seule fois.
-- Supprimée avec l'abonné et avec l'organisation.

DEFINE TABLE OVERWRITE notification_endpoint
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Lue par qui lit la portée, par qui déclenche (adresse présente ?) et par la personne
        -- elle-même (ses propres adresses) ; jamais l'adresse complète (permission de champ)
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
            OR fn::notification_can({ action: "send", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
        FOR create, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
        -- Le worker note le résultat du dernier appel (last_result)
        FOR update WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
            OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Adresse d'un abonné pour la messagerie (chat) ou l'appel d'une adresse web (webhook) ; adresse et clé de signature scellées, lisibles par le worker seulement";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_endpoint
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation de l'abonné (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_endpoint
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_endpoint
    TYPE record<notification_subscriber>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Abonné (l'adresse est supprimée avec lui)";

DEFINE FIELD OVERWRITE channel ON TABLE notification_endpoint
    TYPE string
    ASSERT $value IN ["chat", "webhook"]
    READONLY
    COMMENT "Canal : chat (messagerie d'équipe) ou webhook (adresse web)";

DEFINE FIELD OVERWRITE provider ON TABLE notification_endpoint
    TYPE string
    ASSERT $value IN ["slack", "teams", "discord", "mattermost", "google_chat", "telegram", "webhook"]
    READONLY
    COMMENT "Service : slack, teams, discord, mattermost, google_chat, telegram (chat) ; webhook (adresse web)";

DEFINE FIELD OVERWRITE name ON TABLE notification_endpoint
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE host ON TABLE notification_endpoint
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 253
    READONLY
    COMMENT "Hôte de l'adresse (lisible, jamais l'adresse complète) ; api.telegram.org pour Telegram";

DEFINE FIELD OVERWRITE url ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 8192)
    READONLY
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Adresse complète scellée (enc:v2) ; lue par le worker seulement (absente pour Telegram)";

DEFINE FIELD OVERWRITE chat_id ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Telegram : identifiant du salon (nombre, éventuellement négatif, ou @nom)";

DEFINE FIELD OVERWRITE signing_secret ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 8192)
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Adresse web : clé de signature des appels scellée (enc:v2), lue par le worker seulement ; renouvelable";

DEFINE FIELD OVERWRITE secret_rotated_at ON TABLE notification_endpoint
    TYPE option<datetime>
    COMMENT "Adresse web : date de la clé de signature en cours";

DEFINE FIELD OVERWRITE active ON TABLE notification_endpoint
    TYPE bool
    DEFAULT true
    COMMENT "Active : servie par les étapes de son canal";

DEFINE FIELD OVERWRITE last_result ON TABLE notification_endpoint
    TYPE option<object>
    COMMENT "Dernier appel : { at, ok, code }";
DEFINE FIELD OVERWRITE last_result.at ON TABLE notification_endpoint TYPE datetime;
DEFINE FIELD OVERWRITE last_result.ok ON TABLE notification_endpoint TYPE bool;
DEFINE FIELD OVERWRITE last_result.code ON TABLE notification_endpoint TYPE option<string>;

DEFINE FIELD OVERWRITE created_at ON TABLE notification_endpoint TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_endpoint TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_endpoint_subscriber ON TABLE notification_endpoint FIELDS subscriber, channel, active;
DEFINE INDEX OVERWRITE notification_endpoint_scope ON TABLE notification_endpoint FIELDS scope_key, channel;
