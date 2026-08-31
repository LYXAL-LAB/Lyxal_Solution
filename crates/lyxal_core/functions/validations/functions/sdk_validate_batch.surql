-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_validate_batch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_validate_batch(
    $schema: object,
    $payloads: array<object>,
    $options: option<object>
) -> object {
    LET $request = fn::validation_sdk_request(
        $schema,
        $payloads,
        $options
    );

    LET $compiled = fn::validation_sdk_compile(
        $schema,
        $request.options.optimize
    );

    RETURN {
        sdk: fn::validation_sdk_version(),
        schema_name: $schema.name,
        schema_version: $schema.version,
        result: fn::validation_runtime_batch(
            $compiled,
            $payloads,
            $request.options.max_steps
        )
    };
}
COMMENT "
Valide un lot d'objets via l'API publique du SDK.
"
PERMISSIONS FULL;
