-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_between
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_between(
    $value: number,
    $minimum: number,
    $maximum: number,
    $inclusive: bool
) -> bool {
    IF $minimum > $maximum {
        THROW "UTILS_INVALID_BETWEEN_RANGE";
    };

    RETURN IF $inclusive {
        $value >= $minimum AND $value <= $maximum
    } ELSE {
        $value > $minimum AND $value < $maximum
    };
}
COMMENT "Indique si un nombre appartient à un intervalle."
PERMISSIONS FULL;
