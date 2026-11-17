-- ============================================================================
-- TABLE  : notification_endpoint
-- MODULE : lyxal_notification
-- RÔLE   : Adresses d'un abonné pour la messagerie d'équipe et l'appel d'une adresse web ;
--          appareils push
-- ============================================================================
-- Une adresse de webhook (Slack, Teams, Discord, Mattermost, Google Chat) ou une adresse web
-- donne à elle seule le droit d'écrire : c'est un secret (décision E2). Elle n'entre en base que
-- scellée (enc:v2, lyxal_crypto, contexte lié à l'organisation et à l'adresse) par l'hôte, et
-- seul le worker la lit ; la personne ne voit que l'hôte. Telegram : l'adresse ne porte que
-- l'identifiant du salon (le jeton du robot est le secret de l'intégration, dans lyxal_secrets).
-- Adresse web : clé de signature des appels scellée de même, montrée une seule fois.
-- Appareils push (décision G1, canal `push`, services webpush, fcm, apns) : inscrits par la
-- personne elle-même ; le jeton de l'appareil (Web Push : l'adresse du service push) et les clés
-- du navigateur (p256dh, auth) n'entrent en base que scellés par l'hôte, sous un contexte lié à
-- l'organisation et à l'empreinte du jeton (SHA-256, lyxal_crypto) ; une même inscription
-- renvoyée retrouve l'appareil par cette empreinte. Seul le worker lit les valeurs scellées ; un
-- gestionnaire ne voit que le type d'appareil et sa date d'inscription. Retiré par le worker
-- quand le service le déclare invalide (décision G5).
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
        FOR create WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
        -- Le worker retire un appareil push que le service déclare invalide (décision G5)
        FOR delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
            OR (channel = "push" AND fn::notification_can({ action: "worker", tenant: tenant }))
        -- Le worker note le résultat du dernier appel (last_result)
        FOR update WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
            OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Adresse d'un abonné pour la messagerie (chat), l'appel d'une adresse web (webhook) ou un appareil push (push) ; adresse, clé de signature, jeton et clés de l'appareil scellés, lisibles par le worker seulement";

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
    ASSERT $value IN ["chat", "webhook", "push"]
    READONLY
    COMMENT "Canal : chat (messagerie d'équipe), webhook (adresse web) ou push (appareil)";

DEFINE FIELD OVERWRITE provider ON TABLE notification_endpoint
    TYPE string
    ASSERT $value IN ["slack", "teams", "discord", "mattermost", "google_chat", "telegram", "webhook", "webpush", "fcm", "apns"]
    READONLY
    COMMENT "Service : slack, teams, discord, mattermost, google_chat, telegram (chat) ; webhook (adresse web) ; webpush, fcm, apns (push)";

DEFINE FIELD OVERWRITE name ON TABLE notification_endpoint
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    -- Appareil push : nom donné par la personne, invisible d'un gestionnaire (type et date seulement)
    PERMISSIONS FOR select WHERE channel != "push"
        OR fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
        OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE host ON TABLE notification_endpoint
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 253
    READONLY
    COMMENT "Hôte de l'adresse (lisible, jamais l'adresse complète) ; api.telegram.org pour Telegram ; appareil push : hôte du service push (Web Push : hôte de l'adresse du navigateur)";

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

DEFINE FIELD OVERWRITE platform ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT ($this.channel = "push") = ($value IS NOT NONE) AND ($value IS NONE OR $value IN ["web", "android", "ios"])
    COMMENT "Appareil push : plateforme (web, android, ios)";

DEFINE FIELD OVERWRITE fingerprint ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT ($this.channel = "push") = ($value IS NOT NONE)
    READONLY
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity })
        OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Appareil push : empreinte SHA-256 du jeton (hexadécimal, lyxal_crypto), jamais le jeton ; retrouve une inscription renvoyée ; contexte de scellement";

DEFINE FIELD OVERWRITE device_slot ON TABLE notification_endpoint
    TYPE option<string>
    VALUE IF $this.fingerprint IS NONE { NONE } ELSE { string::concat(<string> $this.subscriber, ":", $this.fingerprint) }
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Unicité d'un appareil par abonné (NONE ignoré par l'index unique)";

DEFINE FIELD OVERWRITE token ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT ($this.channel = "push") = ($value IS NOT NONE) AND ($value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 8192))
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Appareil push : jeton scellé (enc:v2 ; Web Push : adresse du service push), lu par le worker seulement";

DEFINE FIELD OVERWRITE p256dh ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 8192)
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Web Push : clé publique du navigateur (p256dh) scellée, lue par le worker seulement";

DEFINE FIELD OVERWRITE auth ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 8192)
    PERMISSIONS FOR select WHERE fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Web Push : secret d'authentification du navigateur (auth) scellé, lu par le worker seulement";

DEFINE FIELD OVERWRITE registered_at ON TABLE notification_endpoint
    TYPE option<datetime>
    COMMENT "Appareil push : dernière inscription (une inscription renvoyée la met à jour)";

DEFINE FIELD OVERWRITE removed_reason ON TABLE notification_endpoint
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Appareil push : motif du retrait par le worker (posé juste avant la suppression : événement notification.endpoint.removed)";

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
DEFINE INDEX OVERWRITE notification_endpoint_device ON TABLE notification_endpoint FIELDS device_slot UNIQUE;
