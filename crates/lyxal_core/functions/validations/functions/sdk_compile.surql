-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_compile(
    $schema: object,
    $optimize: bool
) -> object {
    LET $compiled = fn::validation_schema_compile(
        $schema.name,
        $schema.version,
        $schema.schema
    );

    RETURN IF $optimize {
        fn::validation_optimizer_schema($compiled)
    } ELSE {
        $compiled
    };
}
COMMENT "
Compile et optimise facultativement un schéma via le SDK.
"
PERMISSIONS FULL;
