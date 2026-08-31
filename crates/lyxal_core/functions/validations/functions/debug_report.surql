-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_report($session:object)->object{
 LET $count=array::len($session.traces);
 RETURN {summary:fn::validation_debug_summary($session),failures:array::map(fn::validation_debug_failed_traces($session),|$t|fn::validation_debug_explain_failure($t)),slowest:IF $count=0{[]}ELSE{fn::validation_debug_slowest_traces($session,IF $count<5{$count}ELSE{5})},traces:$session.traces};
}
COMMENT "Produit le rapport complet de debug."
PERMISSIONS FULL;
