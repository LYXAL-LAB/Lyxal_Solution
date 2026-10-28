-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_create                                            │
-- │  Création d'une nouvelle définition d'erreur canonique (Admin)          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_create(
    $params: object
) {
    LET $code = $params.code;
    LET $module = IF $params.module != NONE AND string::len(string::trim($params.module)) > 0 {
        $params.module
    } ELSE IF $code != NONE AND string::contains($code, "_") {
        string::lowercase(string::split($code, "_")[0])
    } ELSE {
        "error"
    };
    LET $domain = $params.domain;
    LET $category = $params.category;
    LET $severity = $params.severity;
    LET $message = $params.message;
    LET $http_status = $params.http_status;
    LET $translations = $params.translations;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code" });
    };
    IF $message == NONE OR string::len(string::trim($message)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "message" });
    };

    LET $clean_code = string::uppercase(string::trim($code));
    LET $clean_module = string::lowercase(string::trim($module));
    LET $clean_domain = IF $domain != NONE { string::lowercase(string::trim($domain)) } ELSE { NONE };
    LET $cat = IF $category != NONE { string::lowercase(string::trim($category)) } ELSE { "business" };
    LET $sev = IF $severity != NONE { string::lowercase(string::trim($severity)) } ELSE { "error" };
    LET $trans = IF $translations != NONE { $translations } ELSE { {} };

    LET $existing = SELECT VALUE id FROM error_definition WHERE code = $clean_code LIMIT 1;
    IF array::len($existing) > 0 {
        RETURN fn::error_result("ERROR_DEFINITION_ALREADY_EXISTS", $language, { field: "code", code: $clean_code });
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
