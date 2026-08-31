-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_regression
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_regression(
    $baseline: object,
    $candidate: object,
    $max_regression_ratio: decimal
) -> object {
    IF $max_regression_ratio < 0dec {
        THROW "VALIDATION_BENCHMARK_INVALID_REGRESSION_RATIO";
    };

    LET $baseline_stats =
        fn::validation_benchmark_duration_stats(
            $baseline.samples
        );

    LET $candidate_stats =
        fn::validation_benchmark_duration_stats(
            $candidate.samples
        );

    IF $baseline_stats.average IS NONE
        OR $candidate_stats.average IS NONE
    {
        RETURN {
            regression: false,
            ratio: NONE
        };
    };

    LET $ratio =
        type::decimal(duration::nanos($candidate_stats.average))
        / type::decimal(duration::nanos($baseline_stats.average));

    RETURN {
        regression: $ratio > 1dec + $max_regression_ratio,
        ratio: $ratio,
        threshold: 1dec + $max_regression_ratio
    };
}
COMMENT "
Détecte une régression de performance au-delà d'un seuil relatif.
"
PERMISSIONS FULL;
