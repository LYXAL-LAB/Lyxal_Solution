-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_duration_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_duration_stats(
    $samples: array<object>
) -> object {
    IF array::len($samples) = 0 {
        RETURN {
            count: 0,
            min: NONE,
            max: NONE,
            average: NONE,
            total: 0s
        };
    };

    LET $durations = array::map(
        $samples,
        |$sample| $sample.duration
    );

    LET $total = array::reduce(
        $durations,
        |$sum, $duration| $sum + $duration,
        0s
    );

    RETURN {
        count: array::len($durations),
        min: math::min($durations),
        max: math::max($durations),
        average: $total / array::len($durations),
        total: $total
    };
}
COMMENT "
Calcule les statistiques de durée d'un benchmark.
"
PERMISSIONS FULL;
