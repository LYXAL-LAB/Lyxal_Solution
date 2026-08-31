-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_sample
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_sample(
    $name: string,
    $duration: duration,
    $blocked: bool,
    $score: int,
    $metadata: option<object>
) -> object {
    IF string::trim($name) = "" {
        THROW "SECURITY_BENCHMARK_INVALID_NAME";
    };

    IF $duration < 0s {
        THROW "SECURITY_BENCHMARK_INVALID_DURATION";
    };

    RETURN {
        name:string::lowercase(string::trim($name)),
        duration:$duration,
        blocked:$blocked,
        score:$score,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
    };
}
COMMENT "Construit un échantillon de benchmark Security."
PERMISSIONS FULL;
