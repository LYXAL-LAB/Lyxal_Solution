-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_execute
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_execute($schema:object,$payload:object,$options:option<object>)->object{
 LET $request=fn::sanitize_sdk_request($schema,$payload,$options);
 LET $compiled=fn::sanitize_sdk_compile($schema,$request.options);
 LET $output=fn::sanitize_runtime_execute_object($compiled,$payload,$request.options.max_steps);
 RETURN {sdk:fn::sanitize_sdk_version(),schema_name:$schema.name,schema_version:$schema.version,input:$payload,output:$output,changed:$payload!=$output};
}
COMMENT "Compile puis exécute un schéma."
PERMISSIONS FULL;
