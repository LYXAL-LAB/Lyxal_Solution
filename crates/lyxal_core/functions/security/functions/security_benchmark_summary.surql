-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_summary(
    $run: object
) -> object {
    RETURN {
        name:$run.name,
        sample_count:array::len($run.samples),
        stats:fn::security_benchmark_stats($run.samples),
        p50:fn::security_benchmark_percentile($run.samples,50),
        p95:fn::security_benchmark_percentile($run.samples,95),
        p99:fn::security_benchmark_percentile($run.samples,99),
        block_rate:fn::security_benchmark_block_rate($run.samples),
        throughput:fn::security_benchmark_throughput(
            array::len($run.samples),
            $run.wall_duration
        )
    };
}
COMMENT "Produit le résumé d'un benchmark Security."
PERMISSIONS FULL;
