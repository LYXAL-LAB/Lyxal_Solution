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
            app_password: { pipeline: [{ rule: "boolean" }], default: false },
            description: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true, max_length: 512 } }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    -- Mot de passe d'application : permission d'organisation exerçable sans second facteur
    IF !$report.valid OR ($report.value.app_password AND ($report.value.scope != "organization" OR $report.value.min_aal != 1)) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { app_password: ["CORE_VALIDATION_COMBINATION"] } } ELSE { $report.by_field } });
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
    LET $created = (CREATE ONLY $rid CONTENT { code: $p.code, module: $p.module, scope: $p.scope, min_aal: $p.min_aal, app_password: $p.app_password, description: $p.description });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_permission" }); };
    RETURN fn::result_ok(object::extend($created, { created: true }));
} COMMENT "Déclare une permission ({ code, module, scope, min_aal, app_password : utilisable par un mot de passe d'application (organisation, AAL 1), description }) si elle est absente ; rejouable, ne modifie jamais une permission existante (même module et portée exigés)";

-- ----------------------------------------------------------------------------
-- fn::auth_permission_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_permission_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "lyxal_permission_name" }], required: true },
            description: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true, max_length: 512 } }] },
            min_aal: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 2 } }] },
            app_password: { pipeline: [{ rule: "boolean" }] },
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
    LET $current = (SELECT scope, min_aal, app_password FROM ONLY $rid);
    IF $current == NONE { RETURN fn::error_result("AUTH_PERMISSION_UNKNOWN", $p.language, { permissions: [$p.code] }); };
    -- Mot de passe d'application : permission d'organisation exerçable sans second facteur
    IF ($p.app_password ?? $current.app_password ?? false) AND ($current.scope != "organization" OR ($p.min_aal ?? $current.min_aal ?? 1) != 1) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", $p.language, { fields: { app_password: ["CORE_VALIDATION_COMBINATION"] } });
    };
    LET $updated = (UPDATE ONLY $rid SET description = $p.description ?? description, min_aal = $p.min_aal ?? min_aal, app_password = $p.app_password ?? app_password ?? false);
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_permission" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie volontairement la description, le niveau d'assurance minimal ou l'usage par un mot de passe d'application d'une permission ({ code, description, min_aal, app_password }) ; app_password exige une permission d'organisation d'AAL 1. Permission auth.role.manage";

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
        SELECT code, module, scope, min_aal ?? 1 AS min_aal, app_password ?? false AS app_password, description FROM auth_permission
        WHERE ($p.module IS NONE OR module = $p.module) AND ($p.scope IS NONE OR scope = $p.scope)
        ORDER BY code
    );
} COMMENT "Liste les permissions déclarées ({ module, scope }) avec leur niveau d'assurance minimal et leur usage par un mot de passe d'application, triées par code";
