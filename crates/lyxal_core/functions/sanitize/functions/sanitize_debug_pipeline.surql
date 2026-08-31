-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_pipeline($field:string,$input:option<any>,$output:option<any>,$pipeline:array<object>)->object{
 RETURN {field:string::trim($field),input:$input,output:$output,changed:$input!=$output,pipeline:$pipeline,stats:fn::sanitize_pipeline_stats($pipeline)};
}
COMMENT "Construit une vue debug d'un pipeline."
PERMISSIONS FULL;
