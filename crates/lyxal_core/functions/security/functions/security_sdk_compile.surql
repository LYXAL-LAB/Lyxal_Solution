-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_compile(
    $schema: object,
    $options: option<object>
) -> object {
    LET $request = fn::security_sdk_request($schema,{},$options);
    LET $compiled = fn::security_schema_compile(
        $schema,
        $request.options.max_steps
    );

    RETURN IF $request.options.optimize {
        fn::security_optimizer_schema($compiled)
    } ELSE {
        $compiled
    };
}
COMMENT "Compile et optimise facultativement un schéma Security."
PERMISSIONS FULL;
