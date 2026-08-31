-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_title_case
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_title_case(
    $value: string
) -> string {
    RETURN string::capitalize(
        string::lowercase($value)
    );
}
COMMENT "Transforme une chaîne en casse de titre."
PERMISSIONS FULL;
