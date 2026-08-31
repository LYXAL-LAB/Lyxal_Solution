-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_ensure_number
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_ensure_number(
    $value: option<any>,
    $default_value: number
) -> number {
    RETURN IF $value IS NONE OR type::is_null($value) {
        $default_value
    } ELSE IF type::is_number($value) {
        $value
    } ELSE IF type::is_string($value)
        AND string::matches(string::trim($value),"^-?[0-9]+(?:\\.[0-9]+)?$")
    {
        <number>string::trim($value)
    } ELSE {
        THROW "UTILS_VALUE_IS_NOT_NUMBER"
    };
}
COMMENT "Normalise une valeur vers un nombre."
PERMISSIONS FULL;
