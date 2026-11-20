-- ============================================================================
-- TABLES : auth_app_password, auth_app_password_use
-- MODULE : lyxal_auth
-- RÔLE   : Mots de passe d'application des logiciels de courrier, d'agenda et de contacts
-- ============================================================================
-- Modèle (comportement seulement) : mots de passe d'application de Stalwart et jetons
-- d'application de RustiCal. Un mot de passe tiré au hasard par l'hôte (environ 99 bits),
-- propre à un appareil, limité à quelques permissions d'une organisation, révocable. Seule son
-- empreinte HMAC-SHA256 (clé `code_pepper`) est conservée, illisible hors session système.
-- Création, révocation et journal : fonctions de la session système seulement (aucune écriture
-- directe, même par le titulaire). Le journal des connexions est regroupé : une ligne par mot
-- de passe, protocole et adresse IP (écart E1 du lot 1).

DEFINE TABLE OVERWRITE auth_app_password
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
        FOR create, update, delete NONE
    COMMENT "Mots de passe d'application (empreintes), écriture par la session système seulement";

DEFINE FIELD OVERWRITE identity ON TABLE auth_app_password
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Titulaire";

DEFINE FIELD OVERWRITE organization ON TABLE auth_app_password
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation dont le mot de passe porte des permissions";

DEFINE FIELD OVERWRITE name ON TABLE auth_app_password
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Nom de l'appareil ou du logiciel";

DEFINE FIELD OVERWRITE password_hash ON TABLE auth_app_password
    TYPE string
    ASSERT string::len($value) = 64
    READONLY
    PERMISSIONS FOR select NONE
    COMMENT "HMAC-SHA256 (clé code_pepper) de la forme normalisée du mot de passe (illisible)";

DEFINE FIELD OVERWRITE permissions ON TABLE auth_app_password
    TYPE array<string>
    READONLY
    COMMENT "Permissions choisies à la création (déclarées utilisables par un mot de passe d'application)";

DEFINE FIELD OVERWRITE expires_at ON TABLE auth_app_password
    TYPE option<datetime>
    READONLY
    COMMENT "Expiration (NONE : aucune)";

DEFINE FIELD OVERWRITE last_used_at ON TABLE auth_app_password TYPE option<datetime> COMMENT "Dernière connexion vérifiée";
DEFINE FIELD OVERWRITE last_used_protocol ON TABLE auth_app_password
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["smtp", "imap", "pop3", "managesieve", "dav", "jmap"]
    COMMENT "Protocole de la dernière connexion";
DEFINE FIELD OVERWRITE last_used_ip ON TABLE auth_app_password
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 64
    COMMENT "Adresse IP de la dernière connexion";

DEFINE FIELD OVERWRITE revoked_at ON TABLE auth_app_password TYPE option<datetime> COMMENT "Révocation (définitive)";
DEFINE FIELD OVERWRITE revoked_reason ON TABLE auth_app_password
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["owner", "admin", "recovery", "mfa_reset", "membership_removed"]
    COMMENT "Motif : titulaire, administrateur, récupération du compte, remise à zéro du double facteur, sortie de l'organisation";
DEFINE FIELD OVERWRITE revoked_by ON TABLE auth_app_password
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Auteur de la révocation (titulaire ou administrateur)";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_app_password
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE INDEX OVERWRITE auth_app_password_hash ON TABLE auth_app_password FIELDS password_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_app_password_identity ON TABLE auth_app_password FIELDS identity, organization;

-- Une révocation est définitive
DEFINE EVENT OVERWRITE auth_app_password_revocation_guard ON TABLE auth_app_password
WHEN $event = "UPDATE" AND $before.revoked_at IS NOT NONE AND $after.revoked_at != $before.revoked_at
THEN {
    THROW "AUTH_APP_PASSWORD_INVALID";
};

DEFINE TABLE OVERWRITE auth_app_password_use
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
        FOR create, update, delete NONE
    COMMENT "Journal regroupé des connexions par mot de passe d'application, protocole et adresse IP";

DEFINE FIELD OVERWRITE app_password ON TABLE auth_app_password_use
    TYPE record<auth_app_password>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Mot de passe d'application";

DEFINE FIELD OVERWRITE identity ON TABLE auth_app_password_use
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Titulaire (listes et purge)";

DEFINE FIELD OVERWRITE organization ON TABLE auth_app_password_use
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du mot de passe";

DEFINE FIELD OVERWRITE protocol ON TABLE auth_app_password_use
    TYPE string
    ASSERT $value IN ["smtp", "imap", "pop3", "managesieve", "dav", "jmap"]
    READONLY
    COMMENT "Protocole";

DEFINE FIELD OVERWRITE ip ON TABLE auth_app_password_use
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Adresse IP du client (en clair, comme les sessions)";

DEFINE FIELD OVERWRITE client_name ON TABLE auth_app_password_use
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Logiciel (en-tête User-Agent ou commande IMAP ID), dernier connu";

DEFINE FIELD OVERWRITE first_seen_at ON TABLE auth_app_password_use TYPE datetime DEFAULT time::now() READONLY COMMENT "Première connexion";
DEFINE FIELD OVERWRITE last_seen_at ON TABLE auth_app_password_use TYPE datetime DEFAULT time::now() COMMENT "Dernière connexion";
DEFINE FIELD OVERWRITE count ON TABLE auth_app_password_use TYPE int DEFAULT 0 ASSERT $value >= 0 COMMENT "Nombre de connexions vérifiées";

DEFINE INDEX OVERWRITE auth_app_password_use_key ON TABLE auth_app_password_use FIELDS app_password, protocol, ip UNIQUE;
DEFINE INDEX OVERWRITE auth_app_password_use_seen ON TABLE auth_app_password_use FIELDS last_seen_at;
