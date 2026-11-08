-- ============================================================================
-- FONCTIONS : membres d'une organisation (relation auth_member_of)
-- MODULE    : lyxal_auth
-- ============================================================================
-- Une nouvelle adhésion reçoit les rôles d'organisation par défaut (is_default) de
-- l'installation et de l'organisation. Attribuer d'autres rôles exige
-- auth.organization.role.manage. Retirer un droit (adhésion supprimée ou suspendue) incrémente
-- la version des droits de l'identité : ses sessions deviennent obsolètes (AUTH_SESSION_STALE).

-- ----------------------------------------------------------------------------
-- fn::auth_organization_member_add
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_member_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            roles: { pipeline: [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $platform = fn::auth_has_permission({ permission: "auth.organization.manage" });
    IF !$platform AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    IF array::len($p.roles) > 0 AND !$platform AND !fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.role.manage" });
    };
    LET $organization = (SELECT state FROM ONLY $p.organization);
    IF $organization == NONE { RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {}); };
    IF $organization.state != "active" { RETURN fn::error_result("AUTH_ORGANIZATION_INACTIVE", $p.language, { state: $organization.state }); };
    LET $identity = (SELECT state FROM ONLY $p.identity);
    IF $identity == NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    IF $identity.state = "deleted" { RETURN fn::error_result("AUTH_IDENTITY_INACTIVE", $p.language, { state: $identity.state }); };
    IF array::len(SELECT VALUE id FROM auth_member_of WHERE in = $p.identity AND out = $p.organization LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_ALREADY_A_MEMBER", $p.language, {});
    };
    LET $roles = (SELECT id, scope, tenant FROM auth_role WHERE id IN $p.roles);
    IF array::len($roles) != array::len(array::distinct($p.roles)) {
        RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {});
    };
    IF array::any($roles, |$r| $r.scope != "organization" OR ($r.tenant IS NOT NONE AND $r.tenant != $p.organization)) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    LET $caller = IF $auth != NONE AND type::is_record($auth, "auth_session") { (SELECT VALUE identity FROM ONLY $auth) } ELSE { NONE };
    LET $joined = fn::auth_membership_create({ identity: $p.identity, organization: $p.organization, roles: $p.roles, by: $caller });
    IF $joined.code IS NOT NONE {
        RETURN fn::error_result($joined.code, $p.language, { table: "auth_member_of" });
    };
    RETURN fn::result_ok({ membership: $joined.membership, roles: $joined.roles });
} COMMENT "Ajoute une identité à une organisation ({ organization, identity, roles }) avec les rôles par défaut et les rôles demandés. Permissions auth.member.manage (+ auth.organization.role.manage pour des rôles) ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_member_remove
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_member_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    LET $membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $p.identity AND out = $p.organization LIMIT 1);
    IF $membership IS NONE { RETURN fn::error_result("AUTH_NOT_A_MEMBER", $p.language, {}); };
    IF fn::auth_is_last_admin({ membership: $membership }) {
        RETURN fn::error_result("AUTH_LAST_ADMIN", $p.language, {});
    };
    -- Version des droits incrémentée avant la suppression (l'identité partage encore l'organisation)
    LET $bumped = (UPDATE ONLY $p.identity SET permissions_version += 1);
    IF $bumped == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity" }); };
    LET $deleted = (DELETE ONLY $membership RETURN BEFORE);
    IF $deleted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ removed: true, membership: $membership });
} COMMENT "Retire une identité d'une organisation ({ organization, identity }) ; ses rôles d'organisation sont supprimés avec l'adhésion ; refus pour le dernier administrateur. Permission auth.member.manage ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_member_set_state
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_member_set_state($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "suspended"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    LET $membership = (SELECT id, state FROM ONLY auth_member_of WHERE in = $p.identity AND out = $p.organization LIMIT 1);
    IF $membership IS NONE { RETURN fn::error_result("AUTH_NOT_A_MEMBER", $p.language, {}); };
    IF $p.state = "suspended" AND $membership.state = "active" {
        IF fn::auth_is_last_admin({ membership: $membership.id }) { RETURN fn::error_result("AUTH_LAST_ADMIN", $p.language, {}); };
        LET $bumped = (UPDATE ONLY $p.identity SET permissions_version += 1);
        IF $bumped == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity" }); };
    };
    LET $updated = (UPDATE ONLY $membership.id SET state = $p.state);
    IF $updated == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok($updated);
} COMMENT "Suspend ou réactive une adhésion ({ organization, identity, state }) ; suspendre le dernier administrateur est refusé. Permission auth.member.manage ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_member_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_member_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.member.read", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.read" });
    };
    RETURN fn::result_ok(
        SELECT in AS identity, state, joined_at, ->auth_has_role->auth_role.key AS roles
        FROM auth_member_of WHERE out = $p.organization ORDER BY joined_at LIMIT $p.limit START $p.start
    );
} COMMENT "Liste les membres d'une organisation avec leurs rôles ({ organization, limit, start }). Permission auth.member.read ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_is_last_admin : l'adhésion est-elle la dernière adhésion active administratrice ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_is_last_admin($params: object) -> bool {
    IF !type::is_record($params.membership, "auth_member_of") { RETURN false; };
    LET $admin = (SELECT VALUE id FROM ONLY auth_role WHERE scope_key = "installation" AND key = "organization_admin" LIMIT 1);
    IF $admin IS NONE { RETURN false; };
    LET $organization = (SELECT VALUE out FROM ONLY $params.membership);
    IF $params.membership NOTINSIDE (SELECT VALUE in FROM auth_has_role WHERE out = $admin) { RETURN false; };
    LET $admins = (SELECT VALUE in FROM auth_has_role WHERE out = $admin AND record::tb(in) = "auth_member_of" AND in.out = $organization AND in.state = "active");
    RETURN array::len($admins) <= 1;
} COMMENT "Vrai si l'adhésion ({ membership }) est la dernière adhésion active portant le rôle organization_admin de son organisation";

-- ----------------------------------------------------------------------------
-- fn::auth_membership_create : adhésion et rôles (par défaut + demandés), sans contrôle d'accès
-- propre ; les permissions des tables s'appliquent. Utilisée par l'ajout de membre, la création
-- d'une identité dans une organisation et l'acceptation d'une invitation.
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_membership_create($params: object) -> object {
    LET $from = $params.identity;
    LET $to = $params.organization;
    LET $membership = (RELATE ONLY $from->auth_member_of->$to CONTENT { invited_by: $params.by });
    IF $membership == NONE { RETURN { membership: NONE, roles: [], code: "AUTH_WRITE_FORBIDDEN" }; };
    LET $mid = $membership.id;
    LET $defaults = (SELECT VALUE id FROM auth_role WHERE scope = "organization" AND is_default = true AND (tenant IS NONE OR tenant = $to));
    FOR $role IN array::distinct(array::concat($defaults, $params.roles ?? [])) {
        LET $granted = (RELATE ONLY $mid->auth_has_role->$role CONTENT { granted_by: $params.by });
        IF $granted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    RETURN { membership: $mid, roles: (SELECT VALUE out FROM auth_has_role WHERE in = $mid), code: NONE };
} COMMENT "Crée l'adhésion d'une identité ({ identity, organization, roles, by }) avec les rôles par défaut et les rôles demandés ; { membership, roles, code } (permissions des tables appliquées)";
