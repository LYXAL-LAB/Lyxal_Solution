-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array(
    $value: option<any>
) -> array<any> {
    IF $value IS NONE OR type::is_null($value) {
        RETURN [];
    };
    RETURN IF type::is_array($value) {
        $value
    } ELSE {
        [$value]
    };
}
COMMENT "Normalise une valeur vers un tableau."
PERMISSIONS FULL;
