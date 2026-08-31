-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_percent
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_percent(
    $value: number,
    $total: number,
    $precision: int
) -> number {
    IF $total = 0 {
        THROW "UTILS_PERCENT_TOTAL_ZERO";
    };

    RETURN fn::utils_number_round(
        ($value/$total)*100,
        $precision
    );
}
COMMENT "Calcule un pourcentage à partir d'une valeur et d'un total."
PERMISSIONS FULL;
