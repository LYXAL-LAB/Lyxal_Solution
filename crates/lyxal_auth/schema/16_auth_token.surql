-- ============================================================================
-- TABLES : auth_refresh_token, auth_signing_key, auth_login_failure
-- MODULE : lyxal_auth
-- RÔLE   : Jetons de renouvellement, clés de signature, compteurs d'échecs
-- ============================================================================
-- Modèle : Rauthy `refresh_tokens` (usage unique, rotation, révocation de la famille à la
-- réutilisation) et `jwks` ; Keycloak `LOGIN_FAILURE`. Aucune valeur en clair : jetons en
-- BLAKE3, clés scellées par lyxal_crypto, identifiants et adresses IP en BLAKE3. Session
-- système seulement.

DEFINE TABLE OVERWRITE auth_refresh_token
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Jetons de renouvellement (empreintes, session système seulement)";

DEFINE FIELD OVERWRITE session ON TABLE auth_refresh_token TYPE record<auth_session> REFERENCE ON DELETE CASCADE READONLY COMMENT "Session";
DEFINE FIELD OVERWRITE token_hash ON TABLE auth_refresh_token TYPE string ASSERT string::len($value) = 64 READONLY COMMENT "BLAKE3 du jeton";
DEFINE FIELD OVERWRITE state ON TABLE auth_refresh_token TYPE string DEFAULT "active" ASSERT $value IN ["active", "used", "revoked"] COMMENT "État";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_refresh_token TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE used_at ON TABLE auth_refresh_token TYPE option<datetime> COMMENT "Utilisation";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_refresh_token TYPE datetime READONLY COMMENT "Expiration";

DEFINE INDEX OVERWRITE auth_refresh_token_hash ON TABLE auth_refresh_token FIELDS token_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_refresh_token_session ON TABLE auth_refresh_token FIELDS session, state;

DEFINE TABLE OVERWRITE auth_signing_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Clés de signature et de condensation (scellées, session système seulement)";

DEFINE FIELD OVERWRITE purpose ON TABLE auth_signing_key TYPE string ASSERT $value IN ["access_token", "code_pepper"] READONLY COMMENT "Usage";
DEFINE FIELD OVERWRITE slot ON TABLE auth_signing_key TYPE option<string> ASSERT $value IS NONE OR $value IN ["a", "b"] READONLY COMMENT "Emplacement (accès lyxal_auth_a ou lyxal_auth_b) pour access_token";
DEFINE FIELD OVERWRITE secret ON TABLE auth_signing_key TYPE string ASSERT string::starts_with($value, "enc:v2:") COMMENT "Clé scellée (enc:v2, SecretContext::global)";
DEFINE FIELD OVERWRITE state ON TABLE auth_signing_key TYPE string ASSERT $value IN ["active", "previous"] COMMENT "État";
DEFINE FIELD OVERWRITE activated_at ON TABLE auth_signing_key TYPE datetime COMMENT "Activation";
DEFINE FIELD OVERWRITE deactivated_at ON TABLE auth_signing_key TYPE option<datetime> COMMENT "Désactivation";
DEFINE FIELD OVERWRITE reusable_after ON TABLE auth_signing_key TYPE option<datetime> COMMENT "Emplacement réutilisable après cette date (jetons émis avec lui expirés)";

DEFINE INDEX OVERWRITE auth_signing_key_slot ON TABLE auth_signing_key FIELDS purpose, slot UNIQUE;

DEFINE TABLE OVERWRITE auth_login_failure
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Compteurs d'échecs de connexion (empreintes, session système seulement)";

DEFINE FIELD OVERWRITE kind ON TABLE auth_login_failure TYPE string ASSERT $value IN ["identifier", "ip", "mfa"] READONLY COMMENT "Clé comptée (mfa : échecs du second facteur par identité)";
DEFINE FIELD OVERWRITE key_hash ON TABLE auth_login_failure TYPE string ASSERT string::len($value) = 64 READONLY COMMENT "BLAKE3 de l'identifiant normalisé, de l'adresse IP ou de l'identité (mfa)";
DEFINE FIELD OVERWRITE failures ON TABLE auth_login_failure TYPE int DEFAULT 0 COMMENT "Échecs dans la fenêtre";
DEFINE FIELD OVERWRITE window_start ON TABLE auth_login_failure TYPE datetime DEFAULT time::now() COMMENT "Début de la fenêtre";
DEFINE FIELD OVERWRITE locked_until ON TABLE auth_login_failure TYPE option<datetime> COMMENT "Verrouillage";
DEFINE FIELD OVERWRITE updated_at ON TABLE auth_login_failure TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE auth_login_failure_key ON TABLE auth_login_failure FIELDS kind, key_hash UNIQUE;
