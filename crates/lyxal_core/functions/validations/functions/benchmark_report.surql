-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_report(
    $runs: array<object>
) -> object {
    LET $summaries = array::map(
        $runs,
        |$run| fn::validation_benchmark_summary($run)
    );

    RETURN {
        generated_at: time::now(),
        run_count: array::len($runs),
        summaries: $summaries,
        total_samples: array::reduce(
            $summaries,
            |$total, $summary|
                $total + $summary.sample_count,
            0
        )
    };
}
COMMENT "
Produit un rapport regroupant plusieurs benchmarks.
"
PERMISSIONS FULL;
