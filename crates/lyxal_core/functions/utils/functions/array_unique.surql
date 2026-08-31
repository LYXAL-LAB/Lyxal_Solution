-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_unique
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_unique(
    $value: array<any>
) -> array<any> {
    RETURN array::distinct($value);
}
COMMENT "Supprime les doublons d'un tableau."
PERMISSIONS FULL;
