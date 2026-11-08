-- ============================================================================
-- TABLE  : auth_session
-- MODULE : lyxal_auth
-- RÔLE   : Sessions des identités, relues à chaque contrôle des droits
-- ============================================================================
-- Modèle : Kratos `sessions`, Rauthy. Le jeton d'accès désigne la session (`$auth`, claim `sid`) ;
-- fn::auth_context et fn::auth_has_permission la relisent à chaque appel : une session révoquée
-- perd ses droits dès l'opération suivante, même sur une connexion restée ouverte. Création,
-- renouvellement et révocation : fonctions du lot 3 (écriture par la session système seulement).

DEFINE TABLE OVERWRITE auth_session
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND id = $auth)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR create, update, delete NONE
    COMMENT "Sessions des identités (écriture réservée à la session système)";

DEFINE FIELD OVERWRITE identity ON TABLE auth_session
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Identité de la session";

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
