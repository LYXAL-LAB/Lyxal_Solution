-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_snake_case
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_snake_case(
    $value: string
) -> string {
    LET $result = string::replace(
        string::trim($value),
        <regex>"([a-z0-9])([A-Z])",
        "$1_$2"
    );
    LET $result = string::lowercase($result);
    LET $result = string::replace(
        $result,
        <regex>"[^a-z0-9]+",
        "_"
    );
    LET $result = string::replace(
        $result,
        <regex>"^_+",
        ""
    );
    RETURN string::replace(
        $result,
        <regex>"_+$",
        ""
    );
}
COMMENT "Transforme une chaîne en snake_case."
PERMISSIONS FULL;
