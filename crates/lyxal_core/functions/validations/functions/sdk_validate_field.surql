-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_validate_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_validate_field(
    $schema: object,
    $field: string,
    $value: option<any>,
    $options: option<object>
) -> object {
    LET $request = fn::validation_sdk_request(
        $schema,
        $value,
        $options
    );

    LET $compiled = fn::validation_sdk_compile(
        $schema,
        $request.options.optimize
    );

    LET $result =
        fn::validation_runtime_execute_field(
            $compiled,
            $field,
            $value,
            $request.options.max_steps
        );

    RETURN {
        sdk: fn::validation_sdk_version(),
        field: $field,
        result: $result
    };
}
COMMENT "
Valide un champ via l'API publique du SDK.
"
PERMISSIONS FULL;
