-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_validate(
    $schema:object,
    $payload:object,
    $mode:string,
    $max_steps:int,
    $request_id:option<string>
)->object{
 LET $context=fn::security_runtime_context($schema.name,$schema.version,$mode,{});
 LET $request=fn::security_runtime_request($context,$payload,$request_id,{});
 LET $compiled=fn::security_schema_compile($schema,$max_steps);
 LET $execution=fn::security_runtime_execute_object($compiled,$payload,$context);
 RETURN fn::security_runtime_response($request,$execution,time::now());
}
COMMENT "Exécute le cycle complet du Security Runtime."
PERMISSIONS FULL;
