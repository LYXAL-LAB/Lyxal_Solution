-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_flatten
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_flatten(
    $value: array<any>
) -> array<any> {
    RETURN array::flatten($value);
}
COMMENT "Aplatit un niveau d'imbrication d'un tableau."
PERMISSIONS FULL;
