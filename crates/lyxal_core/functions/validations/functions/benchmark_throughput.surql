-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_throughput
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_throughput(
    $sample_count: int,
    $wall_duration: duration
) -> decimal {
    IF $sample_count < 0 {
        THROW "VALIDATION_BENCHMARK_INVALID_SAMPLE_COUNT";
    };

    IF $wall_duration <= 0s {
        THROW "VALIDATION_BENCHMARK_INVALID_WALL_DURATION";
    };

    RETURN type::decimal($sample_count)
        / type::decimal(duration::secs($wall_duration));
}
COMMENT "
Calcule le débit moyen d'exécutions par seconde.
"
PERMISSIONS FULL;
