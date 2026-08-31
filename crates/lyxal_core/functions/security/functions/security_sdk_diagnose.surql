-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_diagnose
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_diagnose(
    $schema: object
) -> object {
    LET $compiled = fn::security_schema_compile($schema,50);
    LET $optimized = fn::security_optimizer_schema($compiled);

    RETURN {
        sdk:fn::security_sdk_version(),
        capabilities:fn::security_sdk_capabilities(),
        compiled:{
            field_count:object::len($compiled.compiled_fields)
        },
        optimizer:fn::security_optimizer_stats($optimized)
    };
}
COMMENT "Produit un diagnostic global du Security SDK."
PERMISSIONS FULL;
