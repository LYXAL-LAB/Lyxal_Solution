-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_stats(
    $samples: array<object>
) -> object {
    IF array::len($samples) = 0 {
        RETURN {
            count:0,
            min:NONE,
            max:NONE,
            average:NONE,
            total:0s
        };
    };

    LET $durations = array::map($samples,|$sample|$sample.duration);
    LET $total = array::fold(
        $durations,
        0s,
        |$sum,$duration|$sum+$duration
    );

    RETURN {
        count:array::len($durations),
        min:math::min($durations),
        max:math::max($durations),
        average:$total/array::len($durations),
        total:$total
    };
}
COMMENT "Calcule les statistiques de durée Security."
PERMISSIONS FULL;
