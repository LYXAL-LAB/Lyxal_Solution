-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_run
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_run(
    $name: string,
    $samples: array<object>,
    $wall_duration: duration
) -> object {
    IF $wall_duration <= 0s {
        THROW "SECURITY_BENCHMARK_INVALID_WALL_DURATION";
    };

    RETURN {
        name:string::lowercase(string::trim($name)),
        samples:$samples,
        sample_count:array::len($samples),
        wall_duration:$wall_duration
    };
}
COMMENT "Construit une exécution de benchmark Security."
PERMISSIONS FULL;
