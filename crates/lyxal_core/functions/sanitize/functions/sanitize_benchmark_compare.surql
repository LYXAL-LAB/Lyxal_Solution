-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_compare
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_compare($baseline:object,$candidate:object)->object{
 LET $b=fn::sanitize_benchmark_stats($baseline.samples);
 LET $c=fn::sanitize_benchmark_stats($candidate.samples);
 LET $delta=IF $b.average IS NONE OR $c.average IS NONE{NONE}ELSE{$c.average-$b.average};
 RETURN {baseline:$baseline.name,candidate:$candidate.name,baseline_average:$b.average,candidate_average:$c.average,delta:$delta,faster:IF $delta IS NONE{NONE}ELSE IF $delta<0s{"candidate"}ELSE IF $delta>0s{"baseline"}ELSE{"equal"}};
}
COMMENT "Compare deux benchmarks."
PERMISSIONS FULL;
