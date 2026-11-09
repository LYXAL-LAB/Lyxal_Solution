-- ============================================================================
-- TABLE  : auth_permission
-- MODULE : lyxal_auth
-- RÔLE   : Permissions déclarées par les modules
-- ============================================================================
-- Modèle : Logto `scopes` / `organization_scopes`. L'identifiant est le code lui-même
-- (`auth_permission:⟨auth.member.read⟩`) : le contrôle des droits lit la portée d'une permission
-- par accès direct. Chaque code a une seule portée. lyxal_auth n'en connaît pas le sens.

DEFINE TABLE OVERWRITE auth_permission
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update WHERE fn::auth_has_permission({ permission: "auth.role.manage" })
        FOR delete NONE
    COMMENT "Permissions déclarées par les modules (une portée par code)";

DEFINE FIELD OVERWRITE code ON TABLE auth_permission
    TYPE string
    ASSERT string::len($value) >= 3 AND string::len($value) <= 128 AND $value == string::lowercase($value)
    READONLY
    COMMENT "Code de la permission (segments en minuscules séparés par des points), égal à la clé de l'identifiant";

DEFINE FIELD OVERWRITE module ON TABLE auth_permission
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Module déclarant";

DEFINE FIELD OVERWRITE scope ON TABLE auth_permission
    TYPE string
    ASSERT $value IN ["installation", "organization"]
    READONLY
    COMMENT "Portée : installation (identité) ou organisation (adhésion)";

DEFINE FIELD OVERWRITE min_aal ON TABLE auth_permission
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1 AND $value <= 2
    COMMENT "Niveau d'assurance minimal de la session pour exercer la permission (2 : double facteur)";

DEFINE FIELD OVERWRITE description ON TABLE auth_permission
    TYPE object
    DEFAULT {}
    COMMENT "Description par langue ({ fr, en })";

DEFINE FIELD OVERWRITE description.* ON TABLE auth_permission
    TYPE string;

DEFINE FIELD OVERWRITE created_at ON TABLE auth_permission
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_permission
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_permission_module ON TABLE auth_permission FIELDS module;

-- L'identifiant est le code
DEFINE EVENT OVERWRITE auth_permission_id_guard ON TABLE auth_permission
WHEN $event = "CREATE"
THEN {
    IF <string> record::id($after.id) != $after.code { THROW "AUTH_INVALID_PARAMETERS"; };
};
