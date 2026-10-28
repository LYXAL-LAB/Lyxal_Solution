-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_log                                                           │
-- │  Crée une occurrence technique immuable dans error_occurrence           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_log(
    $params: object
) {
    LET $code = $params.code;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code" });
    };

    LET $clean_code = string::uppercase(string::trim($code));
    LET $definition = fn::error_get($clean_code);

    IF $definition != NONE AND $definition.log_occurrence == false {
        RETURN fn::result_ok(NONE);
    };

    LET $def_id = IF $definition != NONE { $definition.id } ELSE { NONE };
    LET $env = IF $params.environment != NONE { string::trim($params.environment) } ELSE { "production" };
    LET $sev = IF $definition != NONE { $definition.severity } ELSE IF $params.severity != NONE { $params.severity } ELSE { "error" };
    LET $ctx = IF $params.context != NONE { $params.context } ELSE { {} };
    LET $mod = IF $params.source_module != NONE { string::lowercase(string::trim($params.source_module)) } ELSE { "core" };

    LET $occ = CREATE ONLY error_occurrence CONTENT {
        definition: $def_id,
        code: $clean_code,
        source_module: $mod,
        operation: $params.operation,
        source: $params.source,
        actor: $params.actor,
        technical_message: $params.technical_message,
        context: $ctx,
        trace_id: $params.trace_id,
        correlation_id: $params.correlation_id,
        environment: $env,
        severity: $sev,
        occurred_at: time::now()
    };

    RETURN fn::result_ok($occ);
} COMMENT "Journalise une occurrence d'erreur technique dans la table error_occurrence";
