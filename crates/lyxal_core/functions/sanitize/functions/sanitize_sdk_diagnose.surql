-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_diagnose
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_diagnose($schema:object)->object{
 LET $compiled=fn::sanitize_schema_compile($schema,50);
 LET $optimized=fn::sanitize_optimizer_schema($compiled);
 RETURN {sdk:fn::sanitize_sdk_version(),capabilities:fn::sanitize_sdk_capabilities(),compiled:{field_count:object::len($compiled.compiled_fields)},optimizer:fn::sanitize_optimizer_report(array::flatten(array::map(object::values($compiled.compiled_fields),|$f|$f.steps)),array::flatten(array::map(object::values($optimized.compiled_fields),|$f|$f.steps)))};
}
COMMENT "Produit un diagnostic global du SDK."
PERMISSIONS FULL;
