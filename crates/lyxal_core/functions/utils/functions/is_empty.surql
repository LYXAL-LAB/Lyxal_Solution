-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_is_empty
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_is_empty(
    $value: option<any>
) -> bool {
    RETURN $value IS NONE
        OR type::is_null($value)
        OR (type::is_string($value) AND string::len($value)=0)
        OR (type::is_array($value) AND array::len($value)=0)
        OR (type::is_object($value) AND object::len($value)=0);
}
COMMENT "Indique si une valeur est vide."
PERMISSIONS FULL;
