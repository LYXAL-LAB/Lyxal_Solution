-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_is_blank
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_is_blank(
    $value: option<any>
) -> bool {
    RETURN $value IS NONE
        OR type::is_null($value)
        OR (
            type::is_string($value)
            AND string::trim($value)=""
        );
}
COMMENT "Indique si une valeur textuelle est blanche."
PERMISSIONS FULL;
