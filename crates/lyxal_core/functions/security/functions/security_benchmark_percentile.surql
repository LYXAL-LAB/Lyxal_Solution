-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_percentile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_percentile(
    $samples: array<object>,
    $percentile: int
) -> option<duration> {
    IF $percentile < 0 OR $percentile > 100 {
        THROW "SECURITY_BENCHMARK_INVALID_PERCENTILE";
    };

    IF array::len($samples) = 0 {
        RETURN NONE;
    };

    LET $durations = array::sort::asc(
        array::map($samples,|$sample|$sample.duration)
    );

    LET $index = type::int(
        math::floor(
            type::float(array::len($durations)-1)
            * type::float($percentile)
            / 100f
        )
    );

    RETURN $durations[$index];
}
COMMENT "Calcule un percentile discret sur les durées Security."
PERMISSIONS FULL;
