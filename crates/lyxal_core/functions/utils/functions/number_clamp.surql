-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_clamp
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_clamp(
    $value: number,
    $minimum: number,
    $maximum: number
) -> number {
    IF $minimum > $maximum {
        THROW "UTILS_INVALID_CLAMP_RANGE";
    };

    RETURN IF $value < $minimum {
        $minimum
    } ELSE IF $value > $maximum {
        $maximum
    } ELSE {
        $value
    };
}
COMMENT "Borne une valeur numérique entre un minimum et un maximum."
PERMISSIONS FULL;
