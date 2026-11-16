-- ============================================================================
-- TABLES : notification_subscriber, notification_topic, notification_topic_member
-- MODULE : lyxal_notification
-- RÔLE   : Abonnés (destinataires), sujets et abonnements aux sujets
-- ============================================================================
-- Un abonné a un identifiant stable choisi par l'application (`subscriber_id`), unique dans sa
-- portée (installation ou organisation) : `auth:<clé de l'identité>` pour une personne qui a un
-- compte lyxal_auth (lié par `identity`), `email:<adresse>` pour une personne invitée sans
-- compte. Sa clé d'enregistrement est aléatoire : les événements ne portent que des
-- identifiants, jamais l'adresse. Données personnelles : supprimer un abonné supprime ses
-- préférences et ses abonnements ; supprimer son compte ou son organisation le supprime.

DEFINE TABLE OVERWRITE notification_subscriber
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Lu par qui gère, lit ou déclenche dans la portée, et par la personne elle-même
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
            OR fn::notification_can({ action: "send", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: identity })
        -- Créé par qui gère, à la volée par qui déclenche, ou par la personne pour ses préférences
        FOR create WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "send", tenant: tenant })
            OR fn::notification_can({ action: "self", tenant: tenant, identity: identity })
        FOR update WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR fn::notification_can({ action: "send", tenant: tenant })
        FOR delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
    COMMENT "Abonnés : destinataires des notifications, par organisation ou pour l'installation";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_subscriber
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_subscriber
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité";

DEFINE FIELD OVERWRITE subscriber_id ON TABLE notification_subscriber
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 264
    READONLY
    COMMENT "Identifiant stable choisi par l'application, unique dans sa portée (auth:<identité>, email:<adresse>…)";

DEFINE FIELD OVERWRITE identity ON TABLE notification_subscriber
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte lyxal_auth lié (abonné auth:<identité> seulement, gardé par notification_subscriber_changed_event) ; l'abonné est supprimé avec lui";

DEFINE FIELD OVERWRITE email ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 3 AND string::len($value) <= 254 AND $value == string::lowercase($value))
    COMMENT "Adresse e-mail normalisée";

DEFINE FIELD OVERWRITE phone ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 16
    COMMENT "Téléphone au format E.164";

DEFINE FIELD OVERWRITE first_name ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Prénom";

DEFINE FIELD OVERWRITE last_name ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Nom";

DEFINE FIELD OVERWRITE locale ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 35
    COMMENT "Langue préférée (BCP 47)";

DEFINE FIELD OVERWRITE timezone ON TABLE notification_subscriber
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Fuseau horaire IANA (heures calmes)";

DEFINE FIELD OVERWRITE data ON TABLE notification_subscriber
    TYPE object
    FLEXIBLE
    DEFAULT {}
    COMMENT "Données libres de l'application (8 Kio au plus), lisibles par les conditions d'abonnement";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_subscriber TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_subscriber TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_subscriber_key ON TABLE notification_subscriber FIELDS scope_key, subscriber_id UNIQUE;
DEFINE INDEX OVERWRITE notification_subscriber_identity ON TABLE notification_subscriber FIELDS identity;
DEFINE INDEX OVERWRITE notification_subscriber_email ON TABLE notification_subscriber FIELDS scope_key, email;

-- ----------------------------------------------------------------------------
-- Sujets
-- ----------------------------------------------------------------------------

DEFINE TABLE OVERWRITE notification_topic
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) OR fn::notification_can({ action: "send", tenant: tenant })
        FOR create, update, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
    COMMENT "Sujets : groupes d'abonnés visés par une diffusion";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_topic TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation (NONE : installation)";
DEFINE FIELD OVERWRITE scope_key ON TABLE notification_topic TYPE string VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) } COMMENT "Portée d'unicité";
DEFINE FIELD OVERWRITE key ON TABLE notification_topic TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 64 READONLY COMMENT "Clé, unique dans sa portée";
DEFINE FIELD OVERWRITE name ON TABLE notification_topic TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128 COMMENT "Nom affiché";
DEFINE FIELD OVERWRITE description ON TABLE notification_topic TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 COMMENT "Description";
DEFINE FIELD OVERWRITE data ON TABLE notification_topic TYPE object FLEXIBLE DEFAULT {} COMMENT "Données libres";
DEFINE FIELD OVERWRITE created_at ON TABLE notification_topic TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_topic TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_topic_key ON TABLE notification_topic FIELDS scope_key, key UNIQUE;

DEFINE TABLE OVERWRITE notification_topic_member
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: topic.tenant }) OR fn::notification_can({ action: "send", tenant: topic.tenant })
        FOR create, update, delete WHERE fn::notification_can({ action: "manage", tenant: topic.tenant })
    COMMENT "Abonnement d'un abonné à un sujet, avec condition facultative";

DEFINE FIELD OVERWRITE topic ON TABLE notification_topic_member TYPE record<notification_topic> REFERENCE ON DELETE CASCADE READONLY COMMENT "Sujet";
DEFINE FIELD OVERWRITE subscriber ON TABLE notification_topic_member TYPE record<notification_subscriber> REFERENCE ON DELETE CASCADE READONLY COMMENT "Abonné";

DEFINE FIELD OVERWRITE condition ON TABLE notification_topic_member
    TYPE option<object>
    FLEXIBLE
    COMMENT "Condition lyxal_core (fn::utils_condition_evaluate) sur { subscriber, payload } : l'abonné ne reçoit que les diffusions qui la remplissent";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_topic_member TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE notification_topic_member_unique ON TABLE notification_topic_member FIELDS topic, subscriber UNIQUE;
DEFINE INDEX OVERWRITE notification_topic_member_subscriber ON TABLE notification_topic_member FIELDS subscriber;
