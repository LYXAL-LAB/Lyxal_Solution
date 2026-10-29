-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_difference
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_difference(
    $left: array<any>,
    $right: array<any>
) -> array<any> {
    RETURN array::filter(
        $left,
        |$item| !(($right) CONTAINS ($item))
    );
}
COMMENT "Retourne les éléments du premier tableau absents du second."
PERMISSIONS FULL;
