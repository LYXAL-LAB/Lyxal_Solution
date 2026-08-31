-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_numbers
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_numbers(
    $left: number,
    $right: number,
    $tolerance: number
) -> int {
    IF $tolerance < 0 {
        THROW "UTILS_INVALID_NUMBER_TOLERANCE";
    };

    RETURN IF math::abs($left-$right) <= $tolerance {
        0
    } ELSE IF $left < $right {
        -1
    } ELSE {
        1
    };
}
COMMENT "Compare deux nombres avec une tolérance."
PERMISSIONS FULL;
