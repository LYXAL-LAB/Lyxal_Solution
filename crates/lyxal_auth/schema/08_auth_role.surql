-- ============================================================================
-- TABLE  : auth_role
-- MODULE : lyxal_auth
-- RÔLE   : Rôles (ensembles de permissions), de l'installation ou d'une organisation
-- ============================================================================
-- Modèle : Logto `roles` / `organization_roles`, rôles composites Keycloak. `scope` dit à quoi le
-- rôle s'attribue : `installation` (à une identité) ou `organization` (à une adhésion).
-- `tenant` absent : rôle défini par l'installation (disponible dans toutes les organisations
-- pour un rôle d'organisation) ; présent : rôle propre à une organisation.

DEFINE TABLE OVERWRITE auth_role
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE
            OR fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.read", tenant: tenant })
        FOR create, update WHERE (tenant IS NONE AND fn::auth_has_permission({ permission: "auth.role.manage" }))
            OR (tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: tenant })))
        FOR delete NONE
    COMMENT "Rôles de l'installation ou propres à une organisation";

DEFINE FIELD OVERWRITE tenant ON TABLE auth_role
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation propriétaire (NONE : rôle défini par l'installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE auth_role
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation (un index unique ignore NONE)";

DEFINE FIELD OVERWRITE key ON TABLE auth_role
    TYPE string
    ASSERT string::len($value) >= 2 AND string::len($value) <= 64 AND $value == string::lowercase($value)
    READONLY
    COMMENT "Clé du rôle (règle lyxal_role_name), unique dans sa portée";

DEFINE FIELD OVERWRITE name ON TABLE auth_role
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE description ON TABLE auth_role
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Description";

DEFINE FIELD OVERWRITE scope ON TABLE auth_role
    TYPE string
    ASSERT $value IN ["installation", "organization"]
    READONLY
    COMMENT "Attribution : installation (à une identité) ou organisation (à une adhésion)";

DEFINE FIELD OVERWRITE kind ON TABLE auth_role
    TYPE string
    DEFAULT "user"
    ASSERT $value IN ["user", "service"]
    READONLY
    COMMENT "Rôle de personne ou de compte de service";

DEFINE FIELD OVERWRITE is_default ON TABLE auth_role
    TYPE bool
    DEFAULT false
    COMMENT "Attribué automatiquement à toute nouvelle adhésion (rôle d'organisation seulement)";

DEFINE FIELD OVERWRITE system ON TABLE auth_role
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Rôle du socle : ni renommé ni modifié par les fonctions publiques";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_role
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_role
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_role_scope_key ON TABLE auth_role FIELDS scope_key, key UNIQUE;
DEFINE INDEX OVERWRITE auth_role_tenant ON TABLE auth_role FIELDS tenant;

-- Cohérence : un rôle propre à une organisation est un rôle d'organisation ; seul un rôle
-- d'organisation est attribué par défaut
DEFINE EVENT OVERWRITE auth_role_guard ON TABLE auth_role
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    IF $after.tenant IS NOT NONE AND $after.scope != "organization" { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
    IF $after.is_default AND $after.scope != "organization" { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
};
