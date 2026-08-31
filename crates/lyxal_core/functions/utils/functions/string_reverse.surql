-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_reverse
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_reverse(
    $value: string
) -> string {
    RETURN array::join(
        array::reverse(
            string::split($value,"")
        ),
        ""
    );
}
COMMENT "Inverse les caractères d'une chaîne."
PERMISSIONS FULL;
