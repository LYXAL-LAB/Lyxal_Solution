-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_coalesce
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_coalesce(
    $values: array<any>
) -> option<any> {
    LET $matches = array::filter(
        $values,
        |$value|$value IS NOT NONE AND !type::is_null($value)
    );

    RETURN IF array::len($matches)=0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "Retourne la première valeur ni NONE ni NULL."
PERMISSIONS FULL;
