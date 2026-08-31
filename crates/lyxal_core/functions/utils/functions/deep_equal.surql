-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_deep_equal
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_deep_equal(
    $left: any,
    $right: any
) -> bool {
    RETURN encoding::json::encode($left)
        = encoding::json::encode($right);
}
COMMENT "Compare profondément deux valeurs via leur représentation JSON."
PERMISSIONS FULL;
