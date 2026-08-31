-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_report($session:object)->object{
 LET $count=array::len($session.traces);
 RETURN {summary:fn::sanitize_debug_summary($session),slowest:IF $count=0{[]}ELSE{fn::sanitize_debug_slowest($session,IF $count<5{$count}ELSE{5})},traces:$session.traces,generated_at:time::now()};
}
COMMENT "Produit le rapport complet de debug."
PERMISSIONS FULL;
