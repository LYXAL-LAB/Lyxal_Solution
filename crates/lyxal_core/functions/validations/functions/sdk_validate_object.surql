-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_validate_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_validate_object(
    $schema: object,
    $payload: object,
    $options: option<object>
) -> object {
    LET $request = fn::validation_sdk_request(
        $schema,
        $payload,
        $options
    );

    LET $compiled = fn::validation_sdk_compile(
        $schema,
        $request.options.optimize
    );

    LET $execution =
        fn::validation_runtime_execute_object(
            $compiled,
            $payload,
            $request.options.max_steps
        );

    RETURN {
        sdk: fn::validation_sdk_version(),
        schema_name: $schema.name,
        schema_version: $schema.version,
        result: $execution
    };
}
COMMENT "
Valide un objet via l'API publique du SDK.
"
PERMISSIONS FULL;
