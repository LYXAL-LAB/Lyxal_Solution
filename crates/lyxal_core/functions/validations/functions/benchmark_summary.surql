-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_summary(
    $run: object
) -> object {
    LET $duration_stats =
        fn::validation_benchmark_duration_stats(
            $run.samples
        );

    RETURN {
        name: $run.name,
        sample_count: array::len($run.samples),
        success_rate:
            fn::validation_benchmark_success_rate(
                $run.samples
            ),
        durations: $duration_stats,
        p50: fn::validation_benchmark_percentile(
            $run.samples,
            50
        ),
        p95: fn::validation_benchmark_percentile(
            $run.samples,
            95
        ),
        p99: fn::validation_benchmark_percentile(
            $run.samples,
            99
        ),
        throughput:
            fn::validation_benchmark_throughput(
                array::len($run.samples),
                $run.wall_duration
            )
    };
}
COMMENT "
Produit le résumé complet d'une exécution de benchmark.
"
PERMISSIONS FULL;
