-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_shuffle
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_shuffle(
    $value: array<any>
) -> array<any> {
    RETURN array::shuffle($value);
}
COMMENT "Mélange aléatoirement les éléments d'un tableau."
PERMISSIONS FULL;
