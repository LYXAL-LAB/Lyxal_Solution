-- ============================================================================
-- TABLES : auth_flow, auth_one_time_code, auth_pending_address_change
-- MODULE : lyxal_auth
-- RÔLE   : Parcours persistés, codes et liens à usage unique, changement d'adresse
-- ============================================================================
-- Modèle : Kratos `selfservice_*_flows` et codes stockés en HMAC, Keycloak `AUTH_SESSION`.
-- Écriture et lecture par la session système de l'hôte seulement. Le code (6 chiffres) est
-- conservé en HMAC-SHA256 (clé `code_pepper`), le jeton de lien en BLAKE3 ; le secret scellé
-- destiné au message transite par le champ `delivery` (illisible), publié par l'événement de
-- création puis effacé dans la même transaction. L'état d'une cérémonie passkey (webauthn-rs) est
-- conservé scellé dans `secret_state` (illisible) et lu une seule fois.

DEFINE TABLE OVERWRITE auth_flow
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Parcours (session système seulement)";

DEFINE FIELD OVERWRITE type ON TABLE auth_flow TYPE string ASSERT $value IN ["login", "registration", "verification", "recovery", "address_change", "passkey_login", "mfa_enrollment", "reauthentication"] READONLY COMMENT "Type";
DEFINE FIELD OVERWRITE state ON TABLE auth_flow TYPE string COMMENT "État (machine par type)";
DEFINE FIELD OVERWRITE identity ON TABLE auth_flow TYPE option<record<auth_identity>> REFERENCE ON DELETE CASCADE COMMENT "Identité concernée";
DEFINE FIELD OVERWRITE organization ON TABLE auth_flow TYPE option<record<auth_organization>> COMMENT "Organisation demandée";
DEFINE FIELD OVERWRITE invitation ON TABLE auth_flow TYPE option<record<auth_organization_invitation>> COMMENT "Invitation (inscription)";
DEFINE FIELD OVERWRITE address ON TABLE auth_flow TYPE option<string> COMMENT "Adresse visée (vérification, récupération, changement)";
DEFINE FIELD OVERWRITE required_actions ON TABLE auth_flow TYPE array<string> DEFAULT [] COMMENT "Actions imposées restantes";
DEFINE FIELD OVERWRITE attempts ON TABLE auth_flow TYPE int DEFAULT 0 COMMENT "Tentatives";
DEFINE FIELD OVERWRITE methods ON TABLE auth_flow TYPE array<string> DEFAULT [] COMMENT "Seconds facteurs admis (parcours mfa_required) ou méthode d'enrôlement";
DEFINE FIELD OVERWRITE methods.* ON TABLE auth_flow TYPE string ASSERT $value IN ["password", "totp", "passkey", "recovery_code"];
DEFINE FIELD OVERWRITE session ON TABLE auth_flow TYPE option<record<auth_session>> REFERENCE ON DELETE CASCADE COMMENT "Session à l'origine du parcours (enrôlement, réauthentification)";
DEFINE FIELD OVERWRITE credential ON TABLE auth_flow TYPE option<record<auth_credential>> COMMENT "Moyen en cours d'enrôlement (TOTP en attente)";
DEFINE FIELD OVERWRITE secret_state ON TABLE auth_flow
    TYPE option<string>
    ASSERT $value IS NONE OR string::starts_with($value, "enc:v2:")
    PERMISSIONS FOR select NONE
    COMMENT "État scellé d'une cérémonie passkey (enc:v2), illisible, lu une seule fois";
DEFINE FIELD OVERWRITE client ON TABLE auth_flow TYPE object DEFAULT {} COMMENT "Appareil : { ip, user_agent }";
DEFINE FIELD OVERWRITE client.ip ON TABLE auth_flow TYPE option<string>;
DEFINE FIELD OVERWRITE client.user_agent ON TABLE auth_flow TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE auth_flow TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE auth_flow TYPE datetime VALUE time::now() COMMENT "Dernière modification";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_flow TYPE datetime COMMENT "Expiration";

DEFINE EVENT OVERWRITE auth_flow_state_guard ON TABLE auth_flow
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    IF $after.state NOT IN fn::auth_flow_states({ type: $after.type }) { THROW "AUTH_FLOW_INVALID_STATE"; };
    IF $event = "UPDATE" AND $before.state IN ["completed", "failed"] AND $after.state != $before.state { THROW "AUTH_FLOW_INVALID_STATE"; };
};

DEFINE INDEX OVERWRITE auth_flow_expires ON TABLE auth_flow FIELDS expires_at;

DEFINE TABLE OVERWRITE auth_one_time_code
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Codes et liens à usage unique (session système seulement)";

DEFINE FIELD OVERWRITE flow ON TABLE auth_one_time_code TYPE record<auth_flow> REFERENCE ON DELETE CASCADE READONLY COMMENT "Parcours";
DEFINE FIELD OVERWRITE purpose ON TABLE auth_one_time_code TYPE string ASSERT $value IN ["verification", "recovery", "address_change", "setup"] READONLY COMMENT "Usage";
DEFINE FIELD OVERWRITE channel ON TABLE auth_one_time_code TYPE string DEFAULT "email" ASSERT $value IN ["email"] READONLY COMMENT "Canal";
DEFINE FIELD OVERWRITE address ON TABLE auth_one_time_code TYPE string READONLY COMMENT "Adresse de destination";
DEFINE FIELD OVERWRITE code_hash ON TABLE auth_one_time_code TYPE option<string> READONLY COMMENT "HMAC-SHA256 du code (clé code_pepper)";
DEFINE FIELD OVERWRITE link_hash ON TABLE auth_one_time_code TYPE string ASSERT string::len($value) = 64 READONLY COMMENT "BLAKE3 du jeton de lien";
DEFINE FIELD OVERWRITE attempts ON TABLE auth_one_time_code TYPE int DEFAULT 0 COMMENT "Tentatives de code";
DEFINE FIELD OVERWRITE max_attempts ON TABLE auth_one_time_code TYPE int DEFAULT 5 READONLY COMMENT "Tentatives au plus";
DEFINE FIELD OVERWRITE consumed_at ON TABLE auth_one_time_code TYPE option<datetime> COMMENT "Utilisation";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_one_time_code TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_one_time_code TYPE datetime COMMENT "Expiration";
DEFINE FIELD OVERWRITE delivery ON TABLE auth_one_time_code
    TYPE option<object>
    PERMISSIONS FOR select NONE
    COMMENT "Transitoire : { event_id, secret } publié puis effacé (jamais conservé)";
DEFINE FIELD OVERWRITE delivery.event_id ON TABLE auth_one_time_code TYPE string;
DEFINE FIELD OVERWRITE delivery.secret ON TABLE auth_one_time_code TYPE string;
DEFINE FIELD OVERWRITE delivery.locale ON TABLE auth_one_time_code TYPE option<string>;
DEFINE FIELD OVERWRITE delivery.name ON TABLE auth_one_time_code TYPE option<string>;

DEFINE INDEX OVERWRITE auth_one_time_code_link ON TABLE auth_one_time_code FIELDS link_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_one_time_code_flow ON TABLE auth_one_time_code FIELDS flow;

DEFINE TABLE OVERWRITE auth_pending_address_change
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $auth IS NOT NONE AND identity = $auth.identity
        FOR create, update, delete NONE
    COMMENT "Changement d'adresse en attente de vérification";

DEFINE FIELD OVERWRITE identity ON TABLE auth_pending_address_change TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Identité";
DEFINE FIELD OVERWRITE new_address ON TABLE auth_pending_address_change TYPE string READONLY COMMENT "Nouvelle adresse (normalisée)";
DEFINE FIELD OVERWRITE flow ON TABLE auth_pending_address_change TYPE record<auth_flow> REFERENCE ON DELETE CASCADE READONLY COMMENT "Parcours";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_pending_address_change TYPE datetime READONLY COMMENT "Expiration";

DEFINE INDEX OVERWRITE auth_pending_address_change_identity ON TABLE auth_pending_address_change FIELDS identity UNIQUE;
