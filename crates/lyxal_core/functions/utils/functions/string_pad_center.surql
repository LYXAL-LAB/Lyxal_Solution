-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_pad_center.surql
-- Fonction : fn::utils_string_pad_center
--
-- Centre une chaîne dans une largeur donnée.
--
-- Paramètres
--   $value  : string
--   $length : int
--   $pad    : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $length < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_pad_center(
    $value: string,
    $length: int,
    $pad: string
) -> string {
    IF $length < 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $current = string::len($value);

    IF $current >= $length {
        RETURN $value;
    };

    LET $pad_value = IF string::len($pad) = 0 {
        " "
    } ELSE {
        string::slice($pad,0,1)
    };

    LET $remaining = $length-$current;
    LET $left = math::floor($remaining/2);
    LET $right = $remaining-$left;

    RETURN string::concat(
        string::repeat($pad_value,type::int($left)),
        $value,
        string::repeat($pad_value,type::int($right))
    );
}
COMMENT "Centre une chaîne dans une largeur donnée."
PERMISSIONS FULL;
