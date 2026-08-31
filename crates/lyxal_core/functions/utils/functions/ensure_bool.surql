-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_ensure_bool
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_ensure_bool(
    $value: option<any>,
    $default_value: bool
) -> bool {
    IF $value IS NONE OR type::is_null($value) {
        RETURN $default_value;
    };

    IF type::is_bool($value) {
        RETURN $value;
    };

    IF type::is_number($value) {
        RETURN $value != 0;
    };

    IF type::is_string($value) {
        LET $clean = string::lowercase(string::trim($value));

        RETURN IF $clean IN ["true","1","yes","on"] {
            true
        } ELSE IF $clean IN ["false","0","no","off"] {
            false
        } ELSE {
            THROW "UTILS_VALUE_IS_NOT_BOOL"
        };
    };

    THROW "UTILS_VALUE_IS_NOT_BOOL";
}
COMMENT "Normalise une valeur courante vers un booléen."
PERMISSIONS FULL;
