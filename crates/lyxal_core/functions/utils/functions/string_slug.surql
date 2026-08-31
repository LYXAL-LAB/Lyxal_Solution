-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_slug
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_slug(
    $value: string,
    $separator: string
) -> string {
    LET $sep = IF $separator = "" { "-" } ELSE { $separator };
    LET $result = string::lowercase(string::trim($value));
    LET $result = string::replace(
        $result,
        <regex>"[^a-z0-9]+",
        $sep
    );
    LET $result = string::replace(
        $result,
        <regex>string::concat("^",<string>$sep,"+"),
        ""
    );
    RETURN string::replace(
        $result,
        <regex>string::concat(<string>$sep,"+$"),
        ""
    );
}
COMMENT "Transforme une chaîne en slug ASCII simple."
PERMISSIONS FULL;
