-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_session
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_session($request_id:string,$schema_name:string,$enabled:bool)->object{
 LET $id=string::trim($request_id);
 IF $id=""{THROW "VALIDATION_DEBUG_INVALID_REQUEST_ID";};
 RETURN {request_id:$id,schema_name:string::lowercase(string::trim($schema_name)),enabled:$enabled,started_at:time::now(),traces:[]};
}
COMMENT "Crée une session de debug."
PERMISSIONS FULL;
