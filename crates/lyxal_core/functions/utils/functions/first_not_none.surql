-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_first_not_none
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_first_not_none(
    $values: array<any>
) -> option<any> {
    LET $matches = array::filter(
        $values,
        |$value|$value IS NOT NONE
    );

    RETURN IF array::len($matches)=0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "Retourne la première valeur différente de NONE."
PERMISSIONS FULL;
