-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_distinct
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_distinct(
    $value: array<any>
) -> array<any> {
    RETURN array::distinct($value);
}
COMMENT "Supprime les doublons d'une collection."
PERMISSIONS FULL;
