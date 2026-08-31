-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_create                                            │
-- │  Création d'une nouvelle définition d'erreur canonique (Admin)          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_definition_create(
    $code: option<string>,
    $module: option<string>,
    $domain: option<string>,
    $category: option<string>,
    $severity: option<string>,
    $message: option<string>,
    $http_status: option<int>,
    $translations: option<object>
) {
    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "code" });
    };
    IF $module == NONE OR string::len(string::trim($module)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "module" });
    };
    IF $message == NONE OR string::len(string::trim($message)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "message" });
    };

    LET $clean_code = string::uppercase(string::trim($code));
    LET $clean_module = string::lowercase(string::trim($module));
    LET $clean_domain = IF $domain != NONE { string::lowercase(string::trim($domain)) } ELSE { NONE };
    LET $cat = IF $category != NONE { string::lowercase(string::trim($category)) } ELSE { "business" };
    LET $sev = IF $severity != NONE { string::lowercase(string::trim($severity)) } ELSE { "error" };
    LET $trans = IF $translations != NONE { $translations } ELSE { {} };

    LET $existing = SELECT VALUE id FROM error_definition WHERE code = $clean_code LIMIT 1;
    IF array::len($existing) > 0 {
        RETURN fn::result_error("BOOKING_SLOT_ALREADY_TAKEN", "fr", { field: "code", reason: "Error code already exists" });
    };

    LET $created = CREATE ONLY error_definition CONTENT {
        code: $clean_code,
        module: $clean_module,
        domain: $clean_domain,
        category: $cat,
        severity: $sev,
        message: string::trim($message),
        http_status: $http_status,
        translations: $trans,
        default_language: "en",
        enabled: true,
        created_at: time::now()
    };

    RETURN fn::result_ok($created);
} COMMENT "Crée une nouvelle définition d'erreur canonique dans le catalogue";
