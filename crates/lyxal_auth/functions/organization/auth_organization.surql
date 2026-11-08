-- ============================================================================
-- FONCTIONS : organisations
-- MODULE    : lyxal_auth
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::auth_organization_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            slug: { pipeline: [{ rule: "slug", options: { max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            branding: { pipeline: [{ rule: "is_object" }], default: {} },
            custom_data: { pipeline: [{ rule: "is_object" }], default: {} },
            mfa_required: { pipeline: [{ rule: "boolean" }], default: false },
            owner: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.manage" });
    };
    IF array::len(SELECT VALUE id FROM auth_organization WHERE slug = $p.slug LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_ORGANIZATION_SLUG_TAKEN", $p.language, { slug: $p.slug });
    };
    IF $p.owner IS NOT NONE AND !record::exists($p.owner) {
        RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, { identity: <string> $p.owner });
    };
    LET $created = (CREATE ONLY type::record("auth_organization", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        slug: $p.slug,
        name: $p.name,
        description: $p.description,
        branding: $p.branding,
        custom_data: $p.custom_data,
        mfa_required: $p.mfa_required
    });
    IF $created == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization" });
    };
    IF $p.owner IS NOT NONE {
        LET $admin = (SELECT VALUE id FROM ONLY auth_role WHERE scope_key = "installation" AND key = "organization_admin" LIMIT 1);
        LET $member = fn::auth_organization_member_add({ organization: <string> $created.id, identity: <string> $p.owner, roles: IF $admin IS NONE { [] } ELSE { [<string> $admin] }, language: $p.language });
        IF !$member.ok { THROW $member.error.code; };
    };
    RETURN fn::result_ok($created);
} COMMENT "Crée une organisation ({ slug, name, description, branding, custom_data, mfa_required, owner }) ; owner devient membre administrateur. Permission auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            slug: { pipeline: [{ rule: "slug", options: { max_length: 64 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.organization IS NONE AND $report.value.slug IS NONE) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $found = IF $p.organization IS NOT NONE {
        (SELECT * FROM ONLY $p.organization)
    } ELSE {
        (SELECT * FROM ONLY auth_organization WHERE slug = $p.slug LIMIT 1)
    };
    IF $found == NONE {
        RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {});
    };
    RETURN fn::result_ok($found);
} COMMENT "Lit une organisation par identifiant ou par slug ({ organization } ou { slug }), si l'appelant peut la voir";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "suspended", "deleted"], case_sensitive: true } }] },
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
    LET $rows = IF $p.state IS NONE {
        (SELECT * FROM auth_organization ORDER BY slug LIMIT $p.limit START $p.start)
    } ELSE {
        (SELECT * FROM auth_organization WHERE state = $p.state ORDER BY slug LIMIT $p.limit START $p.start)
    };
    RETURN fn::result_ok($rows);
} COMMENT "Liste les organisations visibles par l'appelant ({ state, limit, start }), triées par slug";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            branding: { pipeline: [{ rule: "is_object" }] },
            custom_data: { pipeline: [{ rule: "is_object" }] },
            mfa_required: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    LET $current = (SELECT * FROM ONLY $p.organization);
    IF $current == NONE {
        RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {});
    };
    LET $updated = (UPDATE ONLY $p.organization MERGE {
        name: $p.name ?? $current.name,
        description: IF "description" IN object::keys($params) { $p.description } ELSE { $current.description },
        branding: $p.branding ?? $current.branding,
        custom_data: $p.custom_data ?? $current.custom_data,
        mfa_required: $p.mfa_required ?? $current.mfa_required
    });
    IF $updated == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie la fiche d'une organisation ({ organization, name, description, branding, custom_data, mfa_required }). Permission auth.organization.settings.manage ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_organization_set_state
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_organization_set_state($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "suspended", "deleted"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.manage" });
    };
    LET $current = (SELECT state FROM ONLY $p.organization);
    IF $current == NONE {
        RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {});
    };
    IF $current.state = "deleted" {
        RETURN fn::error_result("AUTH_ORGANIZATION_INACTIVE", $p.language, { state: $current.state });
    };
    LET $updated = (UPDATE ONLY $p.organization SET state = $p.state);
    IF $updated == NONE {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Change l'état d'une organisation ({ organization, state } : active, suspended, deleted ; une organisation supprimée ne revient pas). Permission auth.organization.manage";
