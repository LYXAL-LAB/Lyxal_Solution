-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_ensure_array
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_ensure_array(
    $value: option<any>
) -> array<any> {
    RETURN IF $value IS NONE OR type::is_null($value) {
        []
    } ELSE IF type::is_array($value) {
        $value
    } ELSE {
        [$value]
    };
}
COMMENT "Normalise une valeur vers un tableau."
PERMISSIONS FULL;
