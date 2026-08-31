-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_run
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_run(
    $name: string,
    $samples: array<object>,
    $started_at: datetime,
    $completed_at: datetime
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF $clean_name = "" {
        THROW "VALIDATION_BENCHMARK_INVALID_NAME";
    };

    IF $completed_at < $started_at {
        THROW "VALIDATION_BENCHMARK_INVALID_TIME_RANGE";
    };

    RETURN {
        name: $clean_name,
        samples: $samples,
        sample_count: array::len($samples),
        started_at: $started_at,
        completed_at: $completed_at,
        wall_duration: $completed_at - $started_at
    };
}
COMMENT "
Construit une exécution complète de benchmark.
"
PERMISSIONS FULL;
