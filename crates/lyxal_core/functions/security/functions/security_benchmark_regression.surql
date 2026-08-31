-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_regression
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_regression(
    $baseline: object,
    $candidate: object,
    $max_ratio: decimal
) -> object {
    IF $max_ratio < 0dec {
        THROW "SECURITY_BENCHMARK_INVALID_RATIO";
    };

    LET $base_stats = fn::security_benchmark_stats($baseline.samples);
    LET $candidate_stats = fn::security_benchmark_stats($candidate.samples);

    IF $base_stats.average IS NONE
        OR $candidate_stats.average IS NONE
    {
        RETURN {regression:false,ratio:NONE};
    };

    LET $ratio =
        type::decimal(duration::nanos($candidate_stats.average))
        / type::decimal(duration::nanos($base_stats.average));

    RETURN {
        regression:$ratio > 1dec+$max_ratio,
        ratio:$ratio,
        threshold:1dec+$max_ratio
    };
}
COMMENT "Détecte une régression de performance Security."
PERMISSIONS FULL;
