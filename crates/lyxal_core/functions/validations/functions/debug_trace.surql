-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_trace
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_trace($field:string,$rule:string,$input:option<any>,$output:option<any>,$success:bool,$error_code:option<string>,$started_at:datetime,$completed_at:datetime)->object{
 RETURN {field:string::trim($field),rule:string::lowercase(string::trim($rule)),input:$input,output:$output,success:$success,error_code:$error_code,started_at:$started_at,completed_at:$completed_at,duration:$completed_at-$started_at};
}
COMMENT "Construit une trace d'exécution."
PERMISSIONS FULL;
