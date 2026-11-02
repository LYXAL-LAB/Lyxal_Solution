-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_rotate.surql
-- Fonction : fn::utils_array_rotate
--
-- Effectue une rotation circulaire d'un tableau.
--
-- Paramètres
--   $value  : array<any>
--   $offset : int
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
