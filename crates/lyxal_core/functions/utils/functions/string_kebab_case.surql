-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_kebab_case
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_kebab_case(
    $value: string
) -> string {
    LET $result = string::replace(
        string::trim($value),
        <regex>"([a-z0-9])([A-Z])",
        "$1-$2"
    );
    LET $result = string::lowercase($result);
    LET $result = string::replace(
        $result,
        <regex>"[^a-z0-9]+",
        "-"
    );
    LET $result = string::replace(
        $result,
        <regex>"^-+",
        ""
    );
    RETURN string::replace(
        $result,
        <regex>"-+$",
        ""
    );
}
COMMENT "Transforme une chaîne en kebab-case."
PERMISSIONS FULL;
