-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_execution_time
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_execution_time(
    $started_at: datetime,
    $completed_at: datetime
) -> duration {
    IF $completed_at < $started_at {
        THROW "UTILS_INVALID_RUNTIME_TIME_RANGE";
    };

    RETURN $completed_at-$started_at;
}
COMMENT "Calcule la durée totale d'une exécution."
PERMISSIONS FULL;
