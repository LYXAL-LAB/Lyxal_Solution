-- ============================================================================
-- FONCTIONS : registre des permissions déclarées par les modules
-- MODULE    : lyxal_auth
-- ============================================================================
-- Chaque module déclare ses permissions par son seed (session système), rejouable et non
-- destructif : une permission existante n'est jamais modifiée par l'enregistrement (§5.5) ;
-- la modification volontaire d'une description passe par fn::auth_permission_update.

-- ----------------------------------------------------------------------------
-- fn::auth_permission_register
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_permission_register($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "lyxal_permission_name" }], required: true },
            module: { pipeline: [{ rule: "lyxal_module_name", options: { min_length: 3, max_length: 64 } }], required: true },
            scope: { pipeline: [{ rule: "enum", options: { allowed: ["installation", "organization"], case_sensitive: true } }], required: true },
            min_aal: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 2 } }], default: 1 },
            description: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true, max_length: 512 } }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.role.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.role.manage" });
    };
    LET $rid = type::record("auth_permission", $p.code);
    LET $existing = (SELECT * FROM ONLY $rid);
    IF $existing != NONE {
        IF $existing.scope != $p.scope OR $existing.module != $p.module {
            RETURN fn::error_result("AUTH_PERMISSION_CONFLICT", $p.language, { code: $p.code });
        };
        RETURN fn::result_ok(object::extend($existing, { created: false }));
    };
    LET $created = (CREATE ONLY $rid CONTENT { code: $p.code, module: $p.module, scope: $p.scope, min_aal: $p.min_aal, description: $p.description });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_permission" }); };
    RETURN fn::result_ok(object::extend($created, { created: true }));
} COMMENT "Déclare une permission ({ code, module, scope, min_aal, description }) si elle est absente ; rejouable, ne modifie jamais une permission existante (même module et portée exigés)";

-- ----------------------------------------------------------------------------
-- fn::auth_permission_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_permission_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "lyxal_permission_name" }], required: true },
            description: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true, max_length: 512 } }] },
            min_aal: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 2 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.role.manage" }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.role.manage" });
    };
    LET $rid = type::record("auth_permission", $p.code);
    IF !record::exists($rid) { RETURN fn::error_result("AUTH_PERMISSION_UNKNOWN", $p.language, { permissions: [$p.code] }); };
    LET $updated = (UPDATE ONLY $rid SET description = $p.description ?? description, min_aal = $p.min_aal ?? min_aal);
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_permission" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie volontairement la description ou le niveau d'assurance minimal d'une permission ({ code, description, min_aal }). Permission auth.role.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_permission_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_permission_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            module: { pipeline: [{ rule: "lyxal_module_name", options: { min_length: 3, max_length: 64 } }] },
            scope: { pipeline: [{ rule: "enum", options: { allowed: ["installation", "organization"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    RETURN fn::result_ok(
        SELECT code, module, scope, description FROM auth_permission
        WHERE ($p.module IS NONE OR module = $p.module) AND ($p.scope IS NONE OR scope = $p.scope)
        ORDER BY code
    );
} COMMENT "Liste les permissions déclarées ({ module, scope }), triées par code";
