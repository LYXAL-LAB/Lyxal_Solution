-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_report($original:array<object>,$optimized:array<object>)->object{
 RETURN {original_steps:array::len($original),optimized_steps:array::len($optimized),original_cost:fn::sanitize_optimizer_cost($original),optimized_cost:fn::sanitize_optimizer_cost($optimized),saved_steps:array::len($original)-array::len($optimized),generated_at:time::now()};
}
COMMENT "Produit un rapport d'optimisation."
PERMISSIONS FULL;
