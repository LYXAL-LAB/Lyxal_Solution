-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_sdk_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_sdk_compile($schema:object,$options:option<object>)->object{
 LET $request=fn::sanitize_sdk_request($schema,{},$options);
 LET $compiled=fn::sanitize_schema_compile($schema,$request.options.max_steps);
 RETURN IF $request.options.optimize{fn::sanitize_optimizer_schema($compiled)}ELSE{$compiled};
}
COMMENT "Compile et optimise facultativement un schéma."
PERMISSIONS FULL;
