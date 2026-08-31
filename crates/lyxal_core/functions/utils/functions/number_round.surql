-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_round
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_round(
    $value: number,
    $precision: int
) -> number {
    IF $precision < 0 {
        THROW "UTILS_INVALID_PRECISION";
    };

    LET $factor = math::pow(10,$precision);

    RETURN math::round($value*$factor)/$factor;
}
COMMENT "Arrondit un nombre à une précision décimale."
PERMISSIONS FULL;
