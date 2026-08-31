-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object(
    $value: option<any>
) -> object {
    IF $value IS NONE OR type::is_null($value) {
        RETURN {};
    };
    IF !type::is_object($value) {
        THROW "SANITIZE_INVALID_OBJECT_TYPE";
    };
    RETURN $value;
}
COMMENT "Normalise NONE ou NULL vers un objet vide."
PERMISSIONS FULL;
