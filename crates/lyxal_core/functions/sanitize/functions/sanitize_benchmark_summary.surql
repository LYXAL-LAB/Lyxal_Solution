-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_summary($run:object)->object{
 RETURN {name:$run.name,sample_count:array::len($run.samples),stats:fn::sanitize_benchmark_stats($run.samples),p50:fn::sanitize_benchmark_percentile($run.samples,50),p95:fn::sanitize_benchmark_percentile($run.samples,95),p99:fn::sanitize_benchmark_percentile($run.samples,99),success_rate:fn::sanitize_benchmark_success_rate($run.samples),throughput:fn::sanitize_benchmark_throughput(array::len($run.samples),$run.wall_duration)};
}
COMMENT "Produit le résumé d'un benchmark."
PERMISSIONS FULL;
