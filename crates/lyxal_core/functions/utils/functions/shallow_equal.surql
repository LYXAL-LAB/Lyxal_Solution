-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_shallow_equal
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_shallow_equal(
    $left: object,
    $right: object
) -> bool {
    LET $left_keys = array::sort::asc(object::keys($left));
    LET $right_keys = array::sort::asc(object::keys($right));

    IF $left_keys != $right_keys {
        RETURN false;
    };

    RETURN array::all(
        $left_keys,
        |$key| $left[$key] = $right[$key]
    );
}
COMMENT "Compare deux objets au premier niveau."
PERMISSIONS FULL;
