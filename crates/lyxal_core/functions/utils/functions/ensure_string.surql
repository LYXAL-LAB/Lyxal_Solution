-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_ensure_string
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_ensure_string(
    $value: option<any>,
    $default_value: string
) -> string {
    RETURN IF $value IS NONE OR type::is_null($value) {
        $default_value
    } ELSE IF type::is_string($value) {
        $value
    } ELSE {
        <string>$value
    };
}
COMMENT "Normalise une valeur vers une chaîne."
PERMISSIONS FULL;
