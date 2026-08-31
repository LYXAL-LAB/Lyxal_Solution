-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_rotate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_rotate(
    $value: array<any>,
    $offset: int
) -> array<any> {
    LET $length = array::len($value);

    IF $length = 0 {
        RETURN [];
    };

    LET $normalized = (($offset % $length) + $length) % $length;

    RETURN array::concat(
        array::slice($value,$normalized,$length),
        array::slice($value,0,$normalized)
    );
}
COMMENT "Effectue une rotation circulaire d'un tableau."
PERMISSIONS FULL;
