-- ============================================================================
-- TABLES : auth_credential, auth_required_action
-- MODULE : lyxal_auth
-- RÔLE   : Moyens d'authentification et actions imposées
-- ============================================================================
-- Modèle : Keycloak `CREDENTIAL` (partie publique / partie secrète) et required actions, Kratos
-- `identity_credentials`. La partie secrète (empreinte Argon2id d'un mot de passe, avec
-- l'historique) est scellée par lyxal_crypto (enc:v2) et illisible hors de la session système.

DEFINE TABLE OVERWRITE auth_credential
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR create, update, delete NONE
    COMMENT "Moyens d'authentification (écriture par la session système)";

DEFINE FIELD OVERWRITE identity ON TABLE auth_credential TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Identité";
DEFINE FIELD OVERWRITE type ON TABLE auth_credential TYPE string ASSERT $value IN ["password"] READONLY COMMENT "Type (lot 4 : totp, passkey, recovery_code)";
DEFINE FIELD OVERWRITE public_data ON TABLE auth_credential TYPE object DEFAULT {} COMMENT "Partie publique";
DEFINE FIELD OVERWRITE public_data.* ON TABLE auth_credential TYPE any;
DEFINE FIELD OVERWRITE secret_data ON TABLE auth_credential
    TYPE string
    ASSERT string::starts_with($value, "enc:v2:")
    PERMISSIONS FOR select NONE
    COMMENT "Partie secrète scellée (enc:v2), illisible";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_credential TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE auth_credential TYPE datetime VALUE time::now() COMMENT "Dernière modification";
DEFINE FIELD OVERWRITE last_used_at ON TABLE auth_credential TYPE option<datetime> COMMENT "Dernier usage";

DEFINE INDEX OVERWRITE auth_credential_identity_type ON TABLE auth_credential FIELDS identity, type UNIQUE;

DEFINE TABLE OVERWRITE auth_required_action
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.read" })
        FOR create, delete WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR update NONE
    COMMENT "Actions imposées avant toute session";

DEFINE FIELD OVERWRITE identity ON TABLE auth_required_action TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Identité";
DEFINE FIELD OVERWRITE action ON TABLE auth_required_action TYPE string ASSERT $value IN ["verify_email", "update_password", "accept_terms"] READONLY COMMENT "Action (lot 4 : configure_mfa)";
DEFINE FIELD OVERWRITE reason ON TABLE auth_required_action TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 256 COMMENT "Motif";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_required_action TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE auth_required_action_unique ON TABLE auth_required_action FIELDS identity, action UNIQUE;
