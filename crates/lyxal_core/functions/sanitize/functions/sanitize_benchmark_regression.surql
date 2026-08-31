-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_regression
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_regression($baseline:object,$candidate:object,$max_ratio:decimal)->object{
 IF $max_ratio<0dec{THROW "SANITIZE_BENCHMARK_INVALID_RATIO";};
 LET $b=fn::sanitize_benchmark_stats($baseline.samples);
 LET $c=fn::sanitize_benchmark_stats($candidate.samples);
 IF $b.average IS NONE OR $c.average IS NONE{RETURN {regression:false,ratio:NONE};};
 LET $ratio=type::decimal(duration::nanos($c.average))/type::decimal(duration::nanos($b.average));
 RETURN {regression:$ratio>1dec+$max_ratio,ratio:$ratio,threshold:1dec+$max_ratio};
}
COMMENT "Détecte une régression de performance."
PERMISSIONS FULL;
