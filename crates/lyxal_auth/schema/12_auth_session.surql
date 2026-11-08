-- ============================================================================
-- TABLE  : auth_session
-- MODULE : lyxal_auth
-- RÔLE   : Sessions des identités, relues à chaque contrôle des droits
-- ============================================================================
-- Modèle : Kratos `sessions`, Rauthy. Le jeton d'accès désigne la session (`$auth`, claim `sid`) ;
-- fn::auth_context et fn::auth_has_permission la relisent à chaque appel : une session révoquée
-- perd ses droits dès l'opération suivante, même sur une connexion restée ouverte. Sujet : une
-- identité (session interactive ou clé d'API) ou une application (compte de service). Écriture
-- par les fonctions système seulement (création, renouvellement, révocation).

DEFINE TABLE OVERWRITE auth_session
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND id = $auth)
            OR ($auth IS NOT NONE AND identity IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
            OR (organization IS NOT NONE AND fn::auth_has_permission({ permission: "auth.session.manage", tenant: organization }))
        FOR create, update, delete NONE
    COMMENT "Sessions des identités (écriture réservée à la session système)";

DEFINE FIELD OVERWRITE identity ON TABLE auth_session
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE CASCADE
    READONLY
    ASSERT ($value IS NONE) != ($this.application IS NONE)
    COMMENT "Identité de la session (ou application)";

DEFINE FIELD OVERWRITE application ON TABLE auth_session
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Application d'un compte de service (ou identité)";

DEFINE FIELD OVERWRITE kind ON TABLE auth_session
    TYPE string
    DEFAULT "interactive"
    ASSERT $value IN ["interactive", "service", "api_key"]
    READONLY
    COMMENT "Nature : interactive, compte de service, clé d'API";

DEFINE FIELD OVERWRITE api_key ON TABLE auth_session
    TYPE option<record<auth_api_key>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Clé d'API à l'origine d'une session api_key";

DEFINE FIELD OVERWRITE client ON TABLE auth_session
    TYPE object
    DEFAULT {}
    COMMENT "Appareil : { ip, user_agent }";

DEFINE FIELD OVERWRITE client.ip ON TABLE auth_session TYPE option<string>;
DEFINE FIELD OVERWRITE client.user_agent ON TABLE auth_session TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512;

DEFINE FIELD OVERWRITE access_slot ON TABLE auth_session
    TYPE string
    DEFAULT "a"
    ASSERT $value IN ["a", "b"]
    COMMENT "Accès SurrealDB du dernier jeton émis";

DEFINE FIELD OVERWRITE organization ON TABLE auth_session
    TYPE option<record<auth_organization>>
    COMMENT "Organisation active (NONE : session de l'installation)";

DEFINE FIELD OVERWRITE state ON TABLE auth_session
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "revoked", "expired"]
    COMMENT "État de la session";

DEFINE FIELD OVERWRITE aal ON TABLE auth_session
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1 AND $value <= 2
    COMMENT "Niveau d'assurance atteint";

DEFINE FIELD OVERWRITE amr ON TABLE auth_session
    TYPE array<object>
    DEFAULT []
    COMMENT "Méthodes d'authentification utilisées : [{ method, at }]";

DEFINE FIELD OVERWRITE amr.* ON TABLE auth_session
    TYPE object;

DEFINE FIELD OVERWRITE amr.*.method ON TABLE auth_session
    TYPE string;

DEFINE FIELD OVERWRITE amr.*.at ON TABLE auth_session
    TYPE datetime;

DEFINE FIELD OVERWRITE permissions_version ON TABLE auth_session
    TYPE int
    DEFAULT 1
    COMMENT "Version des droits de l'identité au moment de l'émission";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_session
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE last_seen_at ON TABLE auth_session
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Dernière activité (renouvellement)";

DEFINE FIELD OVERWRITE idle_expires_at ON TABLE auth_session
    TYPE datetime
    COMMENT "Expiration par inactivité";

DEFINE FIELD OVERWRITE expires_at ON TABLE auth_session
    TYPE datetime
    COMMENT "Expiration absolue";

DEFINE FIELD OVERWRITE revoked_at ON TABLE auth_session
    TYPE option<datetime>
    COMMENT "Date de révocation";

DEFINE FIELD OVERWRITE revoked_reason ON TABLE auth_session
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Motif de révocation";

DEFINE INDEX OVERWRITE auth_session_identity ON TABLE auth_session FIELDS identity, state;
DEFINE INDEX OVERWRITE auth_session_expires ON TABLE auth_session FIELDS expires_at;
