-- ============================================================================
-- FONCTIONS : rôles, permissions accordées, rôles composites, attributions
-- MODULE    : lyxal_auth
-- ============================================================================
-- Rôles de l'installation : auth.role.manage. Rôles propres à une organisation et attributions
-- dans une organisation : auth.organization.role.manage (ou auth.organization.manage).
-- Les rôles système (socle) ne sont modifiés que par la session système (seeds des modules).

-- ----------------------------------------------------------------------------
-- fn::auth_role_can_manage : l'appelant peut-il gérer ce rôle (ou un rôle de cette portée) ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_can_manage($params: object) -> bool {
    IF $params.tenant IS NONE { RETURN fn::auth_has_permission({ permission: "auth.role.manage" }); };
    RETURN fn::auth_has_permission({ permission: "auth.organization.manage" })
        OR fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: $params.tenant });
} COMMENT "Vrai si l'appelant gère les rôles de la portée ({ tenant } : NONE pour l'installation)";

-- ----------------------------------------------------------------------------
-- fn::auth_role_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "lyxal_role_name", options: { min_length: 2, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            scope: { pipeline: [{ rule: "enum", options: { allowed: ["installation", "organization"], case_sensitive: true } }], required: true },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["user", "service"], case_sensitive: true } }], default: "user" },
            is_default: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_role_can_manage({ tenant: $p.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $p.tenant IS NONE { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    IF ($p.tenant IS NOT NONE OR $p.is_default) AND $p.scope != "organization" {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    IF $p.tenant IS NOT NONE AND !record::exists($p.tenant) {
        RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {});
    };
    LET $scope_key = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    IF array::len(SELECT VALUE id FROM auth_role WHERE scope_key = $scope_key AND key = $p.key LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_ROLE_KEY_TAKEN", $p.language, { key: $p.key });
    };
    LET $created = (CREATE ONLY type::record("auth_role", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        tenant: $p.tenant,
        key: $p.key,
        name: $p.name,
        description: $p.description,
        scope: $p.scope,
        kind: $p.kind,
        is_default: $p.is_default
    });
    IF $created == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_role" });
    };
    RETURN fn::result_ok($created);
} COMMENT "Crée un rôle ({ tenant, key, name, description, scope, kind, is_default }) ; tenant absent : rôle de l'installation. Permission auth.role.manage, ou auth.organization.role.manage pour un rôle d'organisation";

-- ----------------------------------------------------------------------------
-- fn::auth_role_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            is_default: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = (SELECT * FROM ONLY $p.role);
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: $role.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $role.tenant IS NONE { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    IF $role.system AND !fn::auth_session_valid({}).system {
        RETURN fn::error_result("AUTH_ROLE_SYSTEM", $p.language, { key: $role.key });
    };
    IF ($p.is_default ?? false) AND $role.scope != "organization" {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    LET $updated = (UPDATE ONLY $p.role MERGE {
        name: $p.name ?? $role.name,
        description: IF "description" IN object::keys($params) { $p.description } ELSE { $role.description },
        is_default: $p.is_default ?? $role.is_default
    });
    IF $updated == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_role" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie le nom, la description ou l'attribution par défaut d'un rôle ({ role, name, description, is_default }) ; rôle système : session système seulement";

-- ----------------------------------------------------------------------------
-- fn::auth_role_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            scope: { pipeline: [{ rule: "enum", options: { allowed: ["installation", "organization"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $rows = (
        SELECT *, ->auth_role_grants->auth_permission.code AS permissions, ->auth_role_includes->auth_role AS includes
        FROM auth_role
        WHERE (tenant IS NONE OR tenant = $p.tenant) AND ($p.scope IS NONE OR scope = $p.scope)
        ORDER BY scope, key
    );
    RETURN fn::result_ok($rows);
} COMMENT "Liste les rôles de l'installation et, si tenant est donné, ceux de cette organisation ({ tenant, scope }), avec leurs permissions et rôles inclus";

-- ----------------------------------------------------------------------------
-- fn::auth_role_permission_set : remplace les permissions accordées par un rôle
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_permission_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }], required: true },
            permissions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = (SELECT id, tenant, scope, system, key FROM ONLY $p.role);
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: $role.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $role.tenant IS NONE { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    IF $role.system AND !fn::auth_session_valid({}).system {
        RETURN fn::error_result("AUTH_ROLE_SYSTEM", $p.language, { key: $role.key });
    };
    LET $codes = array::distinct($p.permissions);
    LET $known = (SELECT code, scope FROM auth_permission WHERE id IN array::map($codes, |$c| type::record("auth_permission", $c)));
    IF array::len($known) != array::len($codes) {
        RETURN fn::error_result("AUTH_PERMISSION_UNKNOWN", $p.language, { permissions: array::complement($codes, $known.code) });
    };
    IF array::any($known, |$k| $k.scope != $role.scope) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    LET $rid = $role.id;
    LET $targets = array::map($codes, |$c| type::record("auth_permission", $c));
    DELETE auth_role_grants WHERE in = $rid AND out NOTINSIDE $targets;
    LET $current = (SELECT VALUE out FROM auth_role_grants WHERE in = $rid);
    FOR $target IN array::complement($targets, $current) {
        LET $granted = (RELATE ONLY $rid->auth_role_grants->$target);
        IF $granted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    LET $after = (SELECT VALUE out.code FROM auth_role_grants WHERE in = $rid);
    IF array::len($after) != array::len($codes) { THROW "AUTH_WRITE_FORBIDDEN"; };
    fn::auth_role_bump_holders({ role: $rid });
    RETURN fn::result_ok({ role: $rid, permissions: array::sort($after) });
} COMMENT "Remplace les permissions accordées par un rôle ({ role, permissions : codes }) ; même portée que le rôle ; les titulaires doivent renouveler leur session";

-- ----------------------------------------------------------------------------
-- fn::auth_role_permission_grant : ajoute des permissions à un rôle (rejouable, seeds)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_permission_grant($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] },
            role_key: { pipeline: [{ rule: "lyxal_role_name", options: { min_length: 2, max_length: 64 } }] },
            permissions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.role IS NONE AND $report.value.role_key IS NONE) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = IF $p.role IS NOT NONE {
        (SELECT id, tenant, scope, system, key FROM ONLY $p.role)
    } ELSE {
        (SELECT id, tenant, scope, system, key FROM ONLY auth_role WHERE scope_key = "installation" AND key = $p.role_key LIMIT 1)
    };
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: $role.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.role.manage" });
    };
    IF $role.system AND !fn::auth_session_valid({}).system {
        RETURN fn::error_result("AUTH_ROLE_SYSTEM", $p.language, { key: $role.key });
    };
    LET $codes = array::distinct($p.permissions);
    LET $known = (SELECT code, scope FROM auth_permission WHERE id IN array::map($codes, |$c| type::record("auth_permission", $c)));
    IF array::len($known) != array::len($codes) {
        RETURN fn::error_result("AUTH_PERMISSION_UNKNOWN", $p.language, { permissions: array::complement($codes, $known.code) });
    };
    IF array::any($known, |$k| $k.scope != $role.scope) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    LET $rid = $role.id;
    LET $current = (SELECT VALUE out FROM auth_role_grants WHERE in = $rid);
    FOR $target IN array::complement(array::map($codes, |$c| type::record("auth_permission", $c)), $current) {
        LET $granted = (RELATE ONLY $rid->auth_role_grants->$target);
        IF $granted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    RETURN fn::result_ok({ role: $rid, permissions: array::sort(SELECT VALUE out.code FROM auth_role_grants WHERE in = $rid) });
} COMMENT "Ajoute des permissions à un rôle ({ role } ou { role_key } de l'installation, permissions) sans retirer les autres ; rejouable (seeds des modules)";

-- ----------------------------------------------------------------------------
-- fn::auth_role_include_set : remplace les rôles inclus (rôles composites)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_include_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }], required: true },
            includes: { pipeline: [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = (SELECT id, tenant, scope, system, key FROM ONLY $p.role);
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: $role.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $role.tenant IS NONE { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    IF $role.system AND !fn::auth_session_valid({}).system {
        RETURN fn::error_result("AUTH_ROLE_SYSTEM", $p.language, { key: $role.key });
    };
    LET $targets = array::distinct($p.includes);
    LET $found = (SELECT id, scope, tenant FROM auth_role WHERE id IN $targets);
    IF array::len($found) != array::len($targets) { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF array::any($found, |$r| $r.scope != $role.scope OR ($r.tenant IS NOT NONE AND $r.tenant != $role.tenant)) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    LET $rid = $role.id;
    IF $rid IN $targets OR array::any($targets, |$t| $rid IN array::flatten($t.{..8+collect}(->auth_role_includes->auth_role))) {
        RETURN fn::error_result("AUTH_ROLE_CYCLE", $p.language, {});
    };
    DELETE auth_role_includes WHERE in = $rid AND out NOTINSIDE $targets;
    LET $current = (SELECT VALUE out FROM auth_role_includes WHERE in = $rid);
    FOR $target IN array::complement($targets, $current) {
        LET $linked = (RELATE ONLY $rid->auth_role_includes->$target);
        IF $linked == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    fn::auth_role_bump_holders({ role: $rid });
    RETURN fn::result_ok({ role: $rid, includes: (SELECT VALUE out FROM auth_role_includes WHERE in = $rid) });
} COMMENT "Remplace les rôles inclus par un rôle ({ role, includes }) ; même portée, sans cycle ; les titulaires doivent renouveler leur session";

-- ----------------------------------------------------------------------------
-- fn::auth_role_bump_holders : version des droits incrémentée pour les titulaires d'un rôle
-- (directs ou par un rôle qui l'inclut)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_bump_holders($params: object) -> int {
    IF !type::is_record($params.role, "auth_role") { RETURN 0; };
    IF !fn::auth_role_can_manage({ tenant: (SELECT VALUE tenant FROM ONLY $params.role) }) { RETURN 0; };
    LET $roles = array::distinct(array::flatten([$params.role, $params.role.{..8+collect}(<-auth_role_includes<-auth_role)]));
    LET $holders = (SELECT VALUE in FROM auth_has_role WHERE out IN $roles);
    LET $identities = array::distinct(array::map($holders, |$h| IF record::tb($h) = "auth_member_of" { $h.in } ELSE { $h }));
    FOR $identity IN $identities {
        LET $bumped = (UPDATE ONLY $identity SET permissions_version += 1);
        IF $bumped == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    };
    RETURN array::len($identities);
} COMMENT "Incrémente la version des droits des titulaires d'un rôle ({ role }), directs ou par inclusion, si l'appelant gère ce rôle ; renvoie le nombre d'identités concernées";

-- ----------------------------------------------------------------------------
-- fn::auth_role_assign / fn::auth_role_unassign
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_assign($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = (SELECT id, scope, tenant FROM ONLY $p.role);
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF !record::exists($p.identity) { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $target = fn::auth_role_target({ role: $role, identity: $p.identity, organization: $p.organization });
    IF $target.code IS NOT NONE { RETURN fn::error_result($target.code, $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: IF $role.scope = "installation" { NONE } ELSE { $p.organization } }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $role.scope = "installation" { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    LET $from = $target.holder;
    LET $to = $role.id;
    IF array::len(SELECT VALUE id FROM auth_has_role WHERE in = $from AND out = $to LIMIT 1) > 0 {
        RETURN fn::result_ok({ holder: $from, role: $to, assigned: false });
    };
    LET $caller = IF $auth != NONE AND type::is_record($auth, "auth_session") { (SELECT VALUE identity FROM ONLY $auth) } ELSE { NONE };
    LET $granted = (RELATE ONLY $from->auth_has_role->$to CONTENT { granted_by: $caller });
    IF $granted == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_has_role" }); };
    RETURN fn::result_ok({ holder: $from, role: $to, assigned: true });
} COMMENT "Attribue un rôle ({ role, identity, organization }) : rôle d'installation à l'identité, rôle d'organisation à son adhésion ; rejouable";

DEFINE FUNCTION OVERWRITE fn::auth_role_unassign($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            role: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $role = (SELECT id, scope, tenant, key FROM ONLY $p.role);
    IF $role == NONE { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    LET $target = fn::auth_role_target({ role: $role, identity: $p.identity, organization: $p.organization });
    IF $target.code IS NOT NONE { RETURN fn::error_result($target.code, $p.language, {}); };
    IF !fn::auth_role_can_manage({ tenant: IF $role.scope = "installation" { NONE } ELSE { $p.organization } }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $role.scope = "installation" { "auth.role.manage" } ELSE { "auth.organization.role.manage" } });
    };
    LET $edge = (SELECT VALUE id FROM ONLY auth_has_role WHERE in = $target.holder AND out = $role.id LIMIT 1);
    IF $edge IS NONE { RETURN fn::result_ok({ holder: $target.holder, role: $role.id, unassigned: false }); };
    IF $role.key = "organization_admin" AND $role.tenant IS NONE AND fn::auth_is_last_admin({ membership: $target.holder }) {
        RETURN fn::error_result("AUTH_LAST_ADMIN", $p.language, {});
    };
    LET $bumped = (UPDATE ONLY $p.identity SET permissions_version += 1);
    IF $bumped == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_identity" }); };
    LET $deleted = (DELETE ONLY $edge RETURN BEFORE);
    IF $deleted == NONE { THROW "AUTH_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ holder: $target.holder, role: $role.id, unassigned: true });
} COMMENT "Retire un rôle ({ role, identity, organization }) ; refus pour le dernier administrateur d'une organisation ; les sessions de l'identité doivent être renouvelées";

-- ----------------------------------------------------------------------------
-- fn::auth_role_target : titulaire d'un rôle (identité ou adhésion) selon sa portée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_role_target($params: object) -> object {
    IF $params.role.scope = "installation" {
        IF $params.organization IS NOT NONE { RETURN { holder: NONE, code: "AUTH_ROLE_SCOPE_MISMATCH" }; };
        RETURN { holder: $params.identity, code: NONE };
    };
    IF $params.organization IS NONE { RETURN { holder: NONE, code: "AUTH_ROLE_SCOPE_MISMATCH" }; };
    IF $params.role.tenant IS NOT NONE AND $params.role.tenant != $params.organization { RETURN { holder: NONE, code: "AUTH_ROLE_SCOPE_MISMATCH" }; };
    LET $membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $params.identity AND out = $params.organization LIMIT 1);
    IF $membership IS NONE { RETURN { holder: NONE, code: "AUTH_NOT_A_MEMBER" }; };
    RETURN { holder: $membership, code: NONE };
} COMMENT "Titulaire d'un rôle ({ role, identity, organization }) : l'identité pour un rôle d'installation, son adhésion pour un rôle d'organisation ; { holder, code }";

-- ----------------------------------------------------------------------------
-- fn::auth_identity_permissions : permissions effectives (graphe des rôles)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_identity_permissions($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $self = $auth != NONE AND type::is_record($auth, "auth_session") AND (SELECT VALUE identity FROM ONLY $auth) = $p.identity;
    IF !$self AND !fn::auth_has_permission({ permission: "auth.identity.read" }) AND !fn::auth_shares_organization({ identity: $p.identity, permission: "auth.member.read" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.read" });
    };
    LET $identity = (SELECT id, state, permissions_version FROM ONLY $p.identity);
    IF $identity == NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $iid = $identity.id;
    LET $installation_roles = (SELECT VALUE out FROM auth_has_role WHERE in = $iid);
    LET $membership = IF $p.organization IS NONE { NONE } ELSE {
        (SELECT id, state FROM ONLY auth_member_of WHERE in = $iid AND out = $p.organization LIMIT 1)
    };
    IF $p.organization IS NOT NONE AND ($membership == NONE OR $membership.state != "active") {
        RETURN fn::error_result("AUTH_NOT_A_MEMBER", $p.language, {});
    };
    LET $organization_roles = IF $membership == NONE { [] } ELSE { (SELECT VALUE out FROM auth_has_role WHERE in = $membership.id) };
    LET $expand = |$roles: array| array::distinct(array::flatten(array::map($roles, |$r| array::flatten([$r, $r.{..8+collect}(->auth_role_includes->auth_role)]))));
    LET $installation = array::sort(array::distinct(SELECT VALUE out.code FROM auth_role_grants WHERE in IN $expand($installation_roles)));
    LET $organization = array::sort(array::distinct(SELECT VALUE out.code FROM auth_role_grants WHERE in IN $expand($organization_roles)));
    RETURN fn::result_ok({
        identity: $iid,
        organization: $p.organization,
        installation: $installation,
        organization_permissions: $organization,
        permissions: array::sort(array::distinct(array::concat($installation, $organization))),
        version: $identity.permissions_version
    });
} COMMENT "Permissions effectives d'une identité ({ identity, organization }) : rôles d'installation et, si organization est donné, rôles de l'adhésion active, rôles inclus compris ; version des droits";
