-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_dates
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_dates(
    $left: datetime,
    $right: datetime
) -> int {
    RETURN IF $left = $right {
        0
    } ELSE IF $left < $right {
        -1
    } ELSE {
        1
    };
}
COMMENT "Compare deux dates."
PERMISSIONS FULL;
