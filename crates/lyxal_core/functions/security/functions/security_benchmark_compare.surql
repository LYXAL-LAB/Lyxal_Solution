-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_compare
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_compare(
    $baseline: object,
    $candidate: object
) -> object {
    LET $base_stats = fn::security_benchmark_stats($baseline.samples);
    LET $candidate_stats = fn::security_benchmark_stats($candidate.samples);

    LET $delta = IF $base_stats.average IS NONE
        OR $candidate_stats.average IS NONE
    {
        NONE
    } ELSE {
        $candidate_stats.average-$base_stats.average
    };

    RETURN {
        baseline:$baseline.name,
        candidate:$candidate.name,
        baseline_average:$base_stats.average,
        candidate_average:$candidate_stats.average,
        delta:$delta,
        faster:IF $delta IS NONE {
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
COMMENT "Compare deux benchmarks Security."
PERMISSIONS FULL;
