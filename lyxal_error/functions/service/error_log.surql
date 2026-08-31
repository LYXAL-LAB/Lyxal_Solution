-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_log                                                           │
-- │  Crée une occurrence technique immuable dans error_occurrence           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_log(
    $code: option<string>,
    $source_module: option<string>,
    $operation: option<string>,
    $source: option<record>,
    $actor: option<record>,
    $technical_message: option<string>,
    $context: option<object>,
    $trace_id: option<string>,
    $correlation_id: option<string>,
    $environment: option<string>
) {
    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN NONE;
    };

    LET $clean_code = string::uppercase(string::trim($code));
    LET $definition = fn::error_get($clean_code);

    IF $definition != NONE AND $definition.log_occurrence == false {
        RETURN NONE;
    };

    LET $def_id = IF $definition != NONE { $definition.id } ELSE { NONE };
    LET $env = IF $environment != NONE { string::trim($environment) } ELSE { "production" };
    LET $sev = IF $definition != NONE { $definition.severity } ELSE { "error" };
    LET $ctx = IF $context != NONE { $context } ELSE { {} };
    LET $mod = IF $source_module != NONE { string::lowercase(string::trim($source_module)) } ELSE { "core" };

    LET $occ = CREATE ONLY error_occurrence CONTENT {
        definition: $def_id,
        code: $clean_code,
        source_module: $mod,
        operation: $operation,
        source: $source,
        actor: $actor,
        technical_message: $technical_message,
        context: $ctx,
        trace_id: $trace_id,
        correlation_id: $correlation_id,
        environment: $env,
        severity: $sev,
        occurred_at: time::now()
    };

    RETURN $occ;
} COMMENT "Journalise une occurrence d'erreur technique dans la table error_occurrence";
