-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_chunk
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_chunk(
    $value: array<any>,
    $size: int
) -> array<array<any>> {
    RETURN fn::utils_array_chunk($value,$size);
}
COMMENT "Découpe une collection en groupes."
PERMISSIONS FULL;
