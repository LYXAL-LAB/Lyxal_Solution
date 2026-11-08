-- ============================================================================
-- TABLE  : auth_organization
-- MODULE : lyxal_auth
-- RÔLE   : Organisations clientes (entreprises), locataires des données métier
-- ============================================================================
-- Modèle : Logto `organizations`, Keycloak `ORG`. Le locataire de toute donnée métier est une
-- organisation (`tenant` = record<auth_organization>). Pas de suppression physique : état
-- `deleted`, purge planifiée au lot 3.

DEFINE TABLE OVERWRITE auth_organization
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.read", tenant: id })
        FOR create WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
        FOR update WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: id })
        FOR delete NONE
    COMMENT "Organisations clientes : locataires des données métier de Lyxal OS";

DEFINE FIELD OVERWRITE slug ON TABLE auth_organization
    TYPE string
    ASSERT string::len($value) >= 2 AND string::len($value) <= 64 AND $value == string::lowercase($value)
    COMMENT "Identifiant lisible unique de l'organisation (minuscules, chiffres, tirets)";

DEFINE FIELD OVERWRITE name ON TABLE auth_organization
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Raison sociale ou nom affiché";

DEFINE FIELD OVERWRITE description ON TABLE auth_organization
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Description libre";

DEFINE FIELD OVERWRITE state ON TABLE auth_organization
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "suspended", "deleted"]
    COMMENT "État de l'organisation : active, suspendue ou supprimée (purge différée)";

DEFINE FIELD OVERWRITE branding ON TABLE auth_organization
    TYPE object
    DEFAULT {}
    COMMENT "Image de marque : logo, couleurs (objet libre, non sensible)";

DEFINE FIELD OVERWRITE branding.* ON TABLE auth_organization
    TYPE any;

DEFINE FIELD OVERWRITE custom_data ON TABLE auth_organization
    TYPE object
    DEFAULT {}
    COMMENT "Données libres de l'organisation (non sensibles)";

DEFINE FIELD OVERWRITE custom_data.* ON TABLE auth_organization
    TYPE any;

DEFINE FIELD OVERWRITE mfa_required ON TABLE auth_organization
    TYPE bool
    DEFAULT false
    COMMENT "Double facteur exigé pour les membres (appliqué au lot 4)";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_organization
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_organization
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_organization_slug ON TABLE auth_organization FIELDS slug UNIQUE;
DEFINE INDEX OVERWRITE auth_organization_state ON TABLE auth_organization FIELDS state;

-- Transitions d'état : une organisation supprimée ne revient pas
DEFINE EVENT OVERWRITE auth_organization_state_guard ON TABLE auth_organization
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    IF $before.state = "deleted" { THROW "AUTH_ORGANIZATION_INACTIVE"; };
};
