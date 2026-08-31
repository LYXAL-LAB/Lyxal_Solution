-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_pad_center
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_pad_center(
    $value: string,
    $length: int,
    $pad: string
) -> string {
    IF $length < 0 {
        THROW "UTILS_INVALID_PAD_LENGTH";
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
