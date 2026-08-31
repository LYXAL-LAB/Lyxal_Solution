-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_objects
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_objects(
    $left: object,
    $right: object
) -> object {
    RETURN fn::utils_object_diff($left,$right);
}
COMMENT "Compare deux objets et retourne leurs différences de premier niveau."
PERMISSIONS FULL;
