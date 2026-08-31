-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_limit
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_limit(
    $value: array<any>,
    $limit: int
) -> array<any> {
    IF $limit < 0 {
        THROW "SANITIZE_INVALID_ARRAY_LIMIT";
    };
    RETURN array::slice($value, 0, $limit);
}
COMMENT "Limite un tableau à un nombre maximal d'éléments."
PERMISSIONS FULL;
