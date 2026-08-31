-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_trace
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_trace($field:string,$rule:string,$input:option<any>,$output:option<any>,$started_at:datetime,$completed_at:datetime)->object{
 RETURN {field:string::trim($field),rule:string::lowercase(string::trim($rule)),input:$input,output:$output,changed:$input!=$output,started_at:$started_at,completed_at:$completed_at,duration:$completed_at-$started_at};
}
COMMENT "Construit une trace de sanitation."
PERMISSIONS FULL;
