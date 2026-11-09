-- ============================================================================
-- TABLES : auth_application, auth_application_secret, auth_api_key
-- MODULE : lyxal_auth
-- RÔLE   : Applications clientes, comptes de service, clés d'API personnelles
-- ============================================================================
-- Modèle : Logto `applications`, `application_secrets`, `personal_access_tokens` ; Rauthy
-- `clients`, `api_keys`. Secrets et clés stockés en empreinte BLAKE3, jamais la valeur (affichée
-- une seule fois à la création). Une application `machine` reçoit des rôles (`auth_has_role`) :
-- rôles d'installation sans locataire, rôles de son organisation sinon.

DEFINE TABLE OVERWRITE auth_application
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Une session de compte de service lit sa propre application (contrôle de la session)
        FOR select WHERE ($auth IS NOT NONE AND id = $auth.application)
            OR fn::auth_has_permission({ permission: "auth.application.manage" })
            OR (tenant IS NOT NONE AND fn::auth_has_permission({ permission: "auth.organization.application.manage", tenant: tenant }))
        FOR create, update WHERE (tenant IS NONE AND fn::auth_has_permission({ permission: "auth.application.manage" }))
            OR (tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.application.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.application.manage", tenant: tenant })))
        FOR delete NONE
    COMMENT "Applications clientes et comptes de service";

DEFINE FIELD OVERWRITE tenant ON TABLE auth_application
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation propriétaire (NONE : application de l'installation)";

DEFINE FIELD OVERWRITE client_id ON TABLE auth_application
    TYPE string
    ASSERT string::len($value) >= 16 AND string::len($value) <= 64
    READONLY
    COMMENT "Identifiant public de l'application";

DEFINE FIELD OVERWRITE name ON TABLE auth_application
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE type ON TABLE auth_application
    TYPE string
    ASSERT $value IN ["spa", "native", "machine"]
    READONLY
    COMMENT "Type : navigateur, mobile ou bureau, service machine à machine";

DEFINE FIELD OVERWRITE redirect_uris ON TABLE auth_application
    TYPE array<string>
    DEFAULT []
    COMMENT "Adresses de retour autorisées";

DEFINE FIELD OVERWRITE state ON TABLE auth_application
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled"]
    COMMENT "État";

DEFINE FIELD OVERWRITE not_before ON TABLE auth_application
    TYPE option<datetime>
    COMMENT "Sessions antérieures refusées";

DEFINE FIELD OVERWRITE permissions_version ON TABLE auth_application
    TYPE int
    DEFAULT 1
    COMMENT "Version des droits (incrémentée à chaque retrait de droit)";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_application TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE auth_application TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE auth_application_client_id ON TABLE auth_application FIELDS client_id UNIQUE;

DEFINE TABLE OVERWRITE auth_application_secret
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::auth_has_permission({ permission: "auth.application.manage" })
            OR (application.tenant IS NOT NONE AND fn::auth_has_permission({ permission: "auth.organization.application.manage", tenant: application.tenant }))
        FOR create, update WHERE (application.tenant IS NONE AND fn::auth_has_permission({ permission: "auth.application.manage" }))
            OR (application.tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.application.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.application.manage", tenant: application.tenant })))
        FOR delete NONE
    COMMENT "Secrets client (empreintes), plusieurs par application";

DEFINE FIELD OVERWRITE application ON TABLE auth_application_secret TYPE record<auth_application> REFERENCE ON DELETE CASCADE READONLY COMMENT "Application";
DEFINE FIELD OVERWRITE secret_hash ON TABLE auth_application_secret TYPE string ASSERT string::len($value) = 64 READONLY PERMISSIONS FOR select NONE COMMENT "Empreinte BLAKE3 du secret (illisible)";
DEFINE FIELD OVERWRITE prefix ON TABLE auth_application_secret TYPE string ASSERT string::len($value) = 8 READONLY COMMENT "Début du secret, pour l'identifier";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_application_secret TYPE option<datetime> COMMENT "Expiration";
DEFINE FIELD OVERWRITE revoked_at ON TABLE auth_application_secret TYPE option<datetime> COMMENT "Révocation";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_application_secret TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE auth_application_secret_hash ON TABLE auth_application_secret FIELDS secret_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_application_secret_app ON TABLE auth_application_secret FIELDS application;

DEFINE TABLE OVERWRITE auth_api_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND identity = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
        -- Mêmes conditions que fn::auth_api_key_create (écriture directe comprise) : session
        -- interactive du propriétaire, authentification récente au niveau le plus haut disponible,
        -- organisation de la session, permissions incluses dans celles du jeton
        FOR create WHERE $auth IS NOT NONE AND identity = $auth.identity
            AND fn::auth_has_permission({ permission: "auth.self.manage" })
            AND fn::auth_api_key_create_allowed({ organization: organization, permissions: permissions })
        -- Le propriétaire révoque seulement (revoked_at, une fois : garde ci-dessous)
        FOR update WHERE ($auth IS NOT NONE AND identity = $auth.identity AND fn::auth_has_permission({ permission: "auth.self.manage" }))
            OR fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR delete NONE
    COMMENT "Clés d'API personnelles (empreintes), droits bornés par ceux du propriétaire";

DEFINE FIELD OVERWRITE identity ON TABLE auth_api_key TYPE record<auth_identity> REFERENCE ON DELETE CASCADE READONLY COMMENT "Propriétaire";
DEFINE FIELD OVERWRITE name ON TABLE auth_api_key TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128 READONLY COMMENT "Nom";
DEFINE FIELD OVERWRITE key_hash ON TABLE auth_api_key TYPE string ASSERT string::len($value) = 64 READONLY PERMISSIONS FOR select NONE COMMENT "Empreinte BLAKE3 de la clé (illisible)";
DEFINE FIELD OVERWRITE prefix ON TABLE auth_api_key TYPE string ASSERT string::len($value) = 8 READONLY COMMENT "Début de la clé";
DEFINE FIELD OVERWRITE permissions ON TABLE auth_api_key TYPE array<string> DEFAULT [] READONLY COMMENT "Permissions accordées (sous-ensemble de celles du propriétaire)";
DEFINE FIELD OVERWRITE organization ON TABLE auth_api_key TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation active de la clé";
DEFINE FIELD OVERWRITE expires_at ON TABLE auth_api_key TYPE option<datetime> READONLY COMMENT "Expiration";
DEFINE FIELD OVERWRITE last_used_at ON TABLE auth_api_key TYPE option<datetime> PERMISSIONS FOR create, update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" }) COMMENT "Dernier usage (écrit par la session système)";
DEFINE FIELD OVERWRITE revoked_at ON TABLE auth_api_key TYPE option<datetime> COMMENT "Révocation";
DEFINE FIELD OVERWRITE created_at ON TABLE auth_api_key TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";

DEFINE INDEX OVERWRITE auth_api_key_hash ON TABLE auth_api_key FIELDS key_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_api_key_identity ON TABLE auth_api_key FIELDS identity;

-- Révoquer un secret invalide les sessions de service ouvertes avant la révocation (la session
-- ne retient pas le secret présenté) : elles se rouvriront avec un secret valide
DEFINE EVENT OVERWRITE auth_application_secret_revocation ON TABLE auth_application_secret
WHEN $event = "UPDATE" AND $before.revoked_at IS NONE AND $after.revoked_at IS NOT NONE
THEN {
    UPDATE $after.application SET not_before = time::now();
};

-- Une clé révoquée ne revient pas
DEFINE EVENT OVERWRITE auth_api_key_revocation_guard ON TABLE auth_api_key
WHEN $event = "UPDATE" AND $before.revoked_at IS NOT NONE AND $after.revoked_at != $before.revoked_at
THEN {
    THROW "AUTH_API_KEY_INVALID";
};
