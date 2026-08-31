-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_response
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_response(
 $request:object,$execution:object,$cache_hit:bool,$completed_at:datetime
) -> object {
 RETURN {request_id:$request.request_id,schema_name:$request.context.schema_name,schema_version:$request.context.schema_version,mode:$request.context.mode,valid:$execution.valid,value:$execution.value,errors:$execution.errors,warnings:$execution.warnings,cache_hit:$cache_hit,started_at:$request.context.started_at,completed_at:$completed_at};
}
COMMENT "Construit la réponse du Validation Runtime."
PERMISSIONS FULL;
