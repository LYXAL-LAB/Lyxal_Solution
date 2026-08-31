-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_ensure_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_ensure_object(
    $value: option<any>
) -> object {
    IF $value IS NONE OR type::is_null($value) {
        RETURN {};
    };

    IF !type::is_object($value) {
        THROW "UTILS_VALUE_IS_NOT_OBJECT";
    };

    RETURN $value;
}
COMMENT "Normalise NONE ou NULL vers un objet vide."
PERMISSIONS FULL;
