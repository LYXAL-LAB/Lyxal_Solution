-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_batch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_batch($schema:object,$payloads:array<object>,$options:option<object>)->object{
 LET $compiled=fn::sanitize_sdk_compile($schema,$options);
 LET $max=IF $options IS NONE OR $options.max_steps IS NONE{50}ELSE{$options.max_steps};
 RETURN {sdk:fn::sanitize_sdk_version(),schema_name:$schema.name,result:fn::sanitize_runtime_batch($compiled,$payloads,$max)};
}
COMMENT "Sanitise un lot d'objets via le SDK."
PERMISSIONS FULL;
