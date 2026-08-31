-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_flatten
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_flatten(
    $value: array<any>
) -> array<any> {
    RETURN array::flatten($value);
}
COMMENT "Aplatit un niveau de tableaux imbriqués."
PERMISSIONS FULL;
