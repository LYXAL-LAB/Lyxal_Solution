-- ============================================================================
-- RELATIONS : auth_member_of, auth_has_role, auth_role_includes, auth_role_grants
-- MODULE    : lyxal_auth
-- RÔLE      : Graphe des adhésions, des rôles et des permissions
-- ============================================================================
-- Tables de relation `ENFORCED` (les deux extrémités doivent exister), uniques par (in, out).
-- Comportements vérifiés sur SurrealDB 3.3.4 : une arête peut partir d'une arête (rôle dans une
-- organisation = adhésion → auth_has_role → rôle) ; supprimer l'adhésion supprime ses rôles.

-- ----------------------------------------------------------------------------
-- auth_member_of : identité → organisation
-- ----------------------------------------------------------------------------

DEFINE TABLE OVERWRITE auth_member_of
    TYPE RELATION IN auth_identity OUT auth_organization ENFORCED
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND in = $auth.identity)
            OR fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.read", tenant: out })
        FOR create WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: out })
            OR ($auth IS NOT NONE AND in = $auth.identity AND fn::auth_invitation_pending({ organization: out }))
        FOR update, delete WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: out })
    COMMENT "Adhésion d'une identité à une organisation";

DEFINE FIELD OVERWRITE state ON TABLE auth_member_of
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "suspended"]
    COMMENT "État de l'adhésion";

DEFINE FIELD OVERWRITE invited_by ON TABLE auth_member_of
    TYPE option<record<auth_identity>>
    COMMENT "Identité à l'origine de l'adhésion";

DEFINE FIELD OVERWRITE joined_at ON TABLE auth_member_of
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date d'adhésion";

DEFINE INDEX OVERWRITE auth_member_of_unique ON TABLE auth_member_of FIELDS in, out UNIQUE;
DEFINE INDEX OVERWRITE auth_member_of_out ON TABLE auth_member_of FIELDS out;

-- ----------------------------------------------------------------------------
-- auth_has_role : identité (rôle d'installation) ou adhésion (rôle d'organisation) → rôle
-- ----------------------------------------------------------------------------

DEFINE TABLE OVERWRITE auth_has_role
    TYPE RELATION IN auth_identity | auth_member_of OUT auth_role ENFORCED
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE ($auth IS NOT NONE AND (in = $auth.identity OR (record::tb(in) = "auth_member_of" AND in.in = $auth.identity)))
            OR fn::auth_has_permission({ permission: "auth.role.manage" })
            OR (record::tb(in) = "auth_member_of" AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.member.read", tenant: in.out })))
        FOR create, delete WHERE (record::tb(in) = "auth_identity" AND fn::auth_has_permission({ permission: "auth.role.manage" }))
            OR (record::tb(in) = "auth_member_of" AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: in.out })
                OR (out.is_default AND fn::auth_has_permission({ permission: "auth.member.manage", tenant: in.out }))
                OR ($auth IS NOT NONE AND in.in = $auth.identity AND (
                    (out.is_default AND fn::auth_invitation_pending({ organization: in.out }))
                    OR fn::auth_invitation_pending({ organization: in.out, role: out })))))
        FOR update NONE
    COMMENT "Rôle attribué à une identité (installation) ou à une adhésion (organisation)";

DEFINE FIELD OVERWRITE granted_by ON TABLE auth_has_role
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Identité qui a attribué le rôle (NONE : session système ou rôle par défaut)";

DEFINE FIELD OVERWRITE granted_at ON TABLE auth_has_role
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date d'attribution";

DEFINE INDEX OVERWRITE auth_has_role_unique ON TABLE auth_has_role FIELDS in, out UNIQUE;
DEFINE INDEX OVERWRITE auth_has_role_out ON TABLE auth_has_role FIELDS out;

-- Portée : rôle d'installation depuis une identité, rôle d'organisation depuis une adhésion, et
-- rôle propre à une organisation seulement sur une adhésion à cette organisation
DEFINE EVENT OVERWRITE auth_has_role_guard ON TABLE auth_has_role
WHEN $event = "CREATE"
THEN {
    LET $role = (SELECT scope, tenant FROM ONLY $after.out);
    IF record::tb($after.in) = "auth_identity" AND $role.scope != "installation" { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
    IF record::tb($after.in) = "auth_member_of" {
        IF $role.scope != "organization" { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
        IF $role.tenant IS NOT NONE AND $role.tenant != $after.in.out { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
    };
};

-- ----------------------------------------------------------------------------
-- auth_role_includes : rôle → rôle inclus (rôles composites)
-- ----------------------------------------------------------------------------

DEFINE TABLE OVERWRITE auth_role_includes
    TYPE RELATION IN auth_role OUT auth_role ENFORCED
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, delete WHERE (in.tenant IS NONE AND fn::auth_has_permission({ permission: "auth.role.manage" }))
            OR (in.tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: in.tenant })))
        FOR update NONE
    COMMENT "Rôles composites : un rôle inclut les permissions d'un autre";

DEFINE INDEX OVERWRITE auth_role_includes_unique ON TABLE auth_role_includes FIELDS in, out UNIQUE;

-- Même portée, rôle inclus visible depuis l'organisation, et aucun cycle (parcours borné à 8)
DEFINE EVENT OVERWRITE auth_role_includes_guard ON TABLE auth_role_includes
WHEN $event = "CREATE"
THEN {
    LET $parent = (SELECT scope, tenant FROM ONLY $after.in);
    LET $child = (SELECT scope, tenant FROM ONLY $after.out);
    IF $parent.scope != $child.scope { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
    IF $child.tenant IS NOT NONE AND $child.tenant != $parent.tenant { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
    IF $after.in = $after.out { THROW "AUTH_ROLE_CYCLE"; };
    LET $descendants = array::flatten($after.out.{..8+collect}(->auth_role_includes->auth_role));
    IF $after.in IN $descendants { THROW "AUTH_ROLE_CYCLE"; };
};

-- ----------------------------------------------------------------------------
-- auth_role_grants : rôle → permission
-- ----------------------------------------------------------------------------

DEFINE TABLE OVERWRITE auth_role_grants
    TYPE RELATION IN auth_role OUT auth_permission ENFORCED
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, delete WHERE (in.tenant IS NONE AND fn::auth_has_permission({ permission: "auth.role.manage" }))
            OR (in.tenant IS NOT NONE AND (fn::auth_has_permission({ permission: "auth.organization.manage" })
                OR fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: in.tenant })))
        FOR update NONE
    COMMENT "Permissions accordées par un rôle";

DEFINE INDEX OVERWRITE auth_role_grants_unique ON TABLE auth_role_grants FIELDS in, out UNIQUE;

-- La portée de la permission est celle du rôle
DEFINE EVENT OVERWRITE auth_role_grants_guard ON TABLE auth_role_grants
WHEN $event = "CREATE"
THEN {
    IF (SELECT VALUE scope FROM ONLY $after.in) != (SELECT VALUE scope FROM ONLY $after.out) { THROW "AUTH_ROLE_SCOPE_MISMATCH"; };
};
