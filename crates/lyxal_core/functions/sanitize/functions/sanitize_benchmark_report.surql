-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_report($runs:array<object>)->object{
 LET $summaries=array::map($runs,|$run|fn::sanitize_benchmark_summary($run));
 RETURN {generated_at:time::now(),run_count:array::len($runs),summaries:$summaries,total_samples:array::fold($summaries,0,|$n,$s|$n+$s.sample_count)};
}
COMMENT "Produit un rapport regroupant plusieurs benchmarks."
PERMISSIONS FULL;
