-- ============================================================================
-- TABLES : auth_credential, auth_required_action, auth_recovery_code
-- MODULE : lyxal_auth
-- RÔLE   : Moyens d'authentification et actions imposées
-- ============================================================================
-- Modèle : Keycloak `CREDENTIAL` (partie publique / partie secrète) et required actions, Kratos
-- `identity_credentials`. La partie secrète (empreinte Argon2id d'un mot de passe avec son
-- historique, secret TOTP) est scellée par lyxal_crypto (enc:v2) et illisible hors de la session
-- système. Une passkey n'a pas de partie secrète : sa clé publique (sérialisée par webauthn-rs)
-- est dans la partie publique, écrite seulement par la session système.

DEFINE TABLE OVERWRITE auth_credential
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR create, update, delete NONE
    COMMENT "Moyens d'authentification (écriture par la session système)";

DEFINE FIELD OVERWRITE identity ON TABLE auth_credential TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Identité";
DEFINE FIELD OVERWRITE type ON TABLE auth_credential TYPE string ASSERT $value IN ["password", "totp", "passkey"] READONLY COMMENT "Type";
DEFINE FIELD OVERWRITE state ON TABLE auth_credential TYPE string DEFAULT "active" ASSERT $value IN ["pending", "active"] COMMENT "pending : TOTP en attente du premier code juste ; active";
DEFINE FIELD OVERWRITE label ON TABLE auth_credential TYPE option<string> ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 64) COMMENT "Nom donné par le titulaire (passkeys)";
DEFINE FIELD OVERWRITE credential_id ON TABLE auth_credential TYPE option<string> ASSERT $value IS NONE OR (string::len($value) >= 16 AND string::len($value) <= 1366) READONLY COMMENT "Identifiant WebAuthn de la passkey (Base64 URL), unique pour l'installation";
DEFINE FIELD OVERWRITE slot_key ON TABLE auth_credential TYPE string VALUE IF $this.type = "passkey" { "passkey:" + ($this.credential_id ?? "") } ELSE { $this.type } COMMENT "Emplacement unique par identité : password, totp, passkey:<credential_id>";
DEFINE FIELD OVERWRITE public_data ON TABLE auth_credential TYPE object DEFAULT {} COMMENT "Partie publique";
DEFINE FIELD OVERWRITE public_data.* ON TABLE auth_credential TYPE any;
DEFINE FIELD OVERWRITE secret_data ON TABLE auth_credential
    TYPE option<string>
    ASSERT $value IS NONE OR string::starts_with($value, "enc:v2:")
    PERMISSIONS FOR select NONE
    COMMENT "Partie secrète scellée (enc:v2), illisible";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_credential TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE auth_credential TYPE datetime VALUE time::now() COMMENT "Dernière modification";
DEFINE FIELD OVERWRITE last_used_at ON TABLE auth_credential TYPE option<datetime> COMMENT "Dernier usage";

DEFINE INDEX OVERWRITE auth_credential_identity_slot ON TABLE auth_credential FIELDS identity, slot_key UNIQUE;
DEFINE INDEX OVERWRITE auth_credential_passkey ON TABLE auth_credential FIELDS credential_id UNIQUE;

-- Cohérence par type : mot de passe et TOTP scellés, passkey sans secret mais identifiée
DEFINE EVENT OVERWRITE auth_credential_type_guard ON TABLE auth_credential
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    IF $after.type IN ["password", "totp"] AND $after.secret_data IS NONE { THROW "AUTH_INVALID_PARAMETERS"; };
    IF $after.type = "passkey" AND ($after.credential_id IS NONE OR $after.secret_data IS NOT NONE) { THROW "AUTH_INVALID_PARAMETERS"; };
    IF $after.type != "passkey" AND $after.credential_id IS NOT NONE { THROW "AUTH_INVALID_PARAMETERS"; };
    IF $after.type != "totp" AND $after.state = "pending" { THROW "AUTH_INVALID_PARAMETERS"; };
};

-- Niveau d'assurance atteignable de l'identité (Kratos `available_aal`) : 2 dès qu'un TOTP ou une
-- passkey actif existe, 1 avec un mot de passe seul, 0 sinon. Les codes de secours ne comptent pas.
DEFINE EVENT OVERWRITE auth_credential_available_aal ON TABLE auth_credential
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $identity = IF $event = "DELETE" { $before.identity } ELSE { $after.identity };
    IF record::exists($identity) {
        LET $kinds = (SELECT VALUE type FROM auth_credential WHERE identity = $identity AND state = "active");
        LET $aal = IF "totp" IN $kinds OR "passkey" IN $kinds { 2 } ELSE IF "password" IN $kinds { 1 } ELSE { 0 };
        UPDATE $identity SET available_aal = $aal WHERE available_aal != $aal;
    };
};

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
DEFINE FIELD OVERWRITE action ON TABLE auth_required_action TYPE string ASSERT $value IN ["verify_email", "update_password", "accept_terms", "configure_mfa"] READONLY COMMENT "Action";
DEFINE FIELD OVERWRITE reason ON TABLE auth_required_action TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 256 COMMENT "Motif";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_required_action TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE auth_required_action_unique ON TABLE auth_required_action FIELDS identity, action UNIQUE;

-- ----------------------------------------------------------------------------
-- auth_recovery_code : codes de secours (une ligne par code, écart E1 du lot 4)
-- ----------------------------------------------------------------------------
-- Empreinte HMAC-SHA256 (clé code_pepper) calculée par l'hôte ; consommation atomique par la base
-- (mise à jour conditionnelle used_at IS NONE). Une génération remplace toutes les précédentes.

DEFINE TABLE OVERWRITE auth_recovery_code
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.read" })
        FOR create, update, delete NONE
    COMMENT "Codes de secours (empreintes, écriture par la session système)";

DEFINE FIELD OVERWRITE identity ON TABLE auth_recovery_code TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Identité";
DEFINE FIELD OVERWRITE batch ON TABLE auth_recovery_code TYPE string ASSERT string::len($value) = 32 READONLY COMMENT "Génération (UUID v7 hexadécimal)";
DEFINE FIELD OVERWRITE code_hash ON TABLE auth_recovery_code
    TYPE string
    ASSERT string::len($value) = 64
    READONLY
    PERMISSIONS FOR select NONE
    COMMENT "HMAC-SHA256 du code (clé code_pepper), illisible";
DEFINE FIELD OVERWRITE used_at ON TABLE auth_recovery_code TYPE option<datetime> COMMENT "Utilisation";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_recovery_code TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE auth_recovery_code_hash ON TABLE auth_recovery_code FIELDS code_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_recovery_code_identity ON TABLE auth_recovery_code FIELDS identity, used_at;
