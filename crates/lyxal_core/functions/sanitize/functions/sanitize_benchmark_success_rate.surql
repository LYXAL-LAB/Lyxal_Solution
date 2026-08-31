-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_success_rate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_success_rate($samples:array<object>)->decimal{
 IF array::len($samples)=0{RETURN 0dec;};
 RETURN type::decimal(array::len(array::filter($samples,|$s|$s.error_code IS NONE)))/type::decimal(array::len($samples));
}
COMMENT "Calcule le taux d'exécution sans erreur."
PERMISSIONS FULL;
