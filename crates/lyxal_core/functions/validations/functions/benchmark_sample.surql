-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_sample
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_sample(
    $name: string,
    $duration: duration,
    $success: bool,
    $metadata: option<object>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF $clean_name = "" {
        THROW "VALIDATION_BENCHMARK_INVALID_NAME";
    };

    IF $duration < 0s {
        THROW "VALIDATION_BENCHMARK_INVALID_DURATION";
    };

    RETURN {
        name: $clean_name,
        duration: $duration,
        success: $success,
        metadata: IF $metadata IS NONE { {} } ELSE { $metadata }
    };
}
COMMENT "
Construit un échantillon élémentaire de benchmark.
"
PERMISSIONS FULL;
