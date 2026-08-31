-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_compare
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_compare(
    $baseline: object,
    $candidate: object
) -> object {
    LET $baseline_stats =
        fn::validation_benchmark_duration_stats(
            $baseline.samples
        );

    LET $candidate_stats =
        fn::validation_benchmark_duration_stats(
            $candidate.samples
        );

    LET $delta = IF $baseline_stats.average IS NONE
        OR $candidate_stats.average IS NONE
    {
        NONE
    } ELSE {
        $candidate_stats.average - $baseline_stats.average
    };

    RETURN {
        baseline: $baseline.name,
        candidate: $candidate.name,
        baseline_average: $baseline_stats.average,
        candidate_average: $candidate_stats.average,
        average_delta: $delta,
        faster: IF $delta IS NONE {
            NONE
        } ELSE IF $delta < 0s {
            "candidate"
        } ELSE IF $delta > 0s {
            "baseline"
        } ELSE {
            "equal"
        }
    };
}
COMMENT "
Compare les durées moyennes de deux benchmarks.
"
PERMISSIONS FULL;
