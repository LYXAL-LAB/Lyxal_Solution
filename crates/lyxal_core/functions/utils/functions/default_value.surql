-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_default_value
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_default_value(
    $value: option<any>,
    $default_value: any,
    $replace_null: bool
) -> any {
    RETURN IF $value IS NONE
        OR ($replace_null AND type::is_null($value))
    {
        $default_value
    } ELSE {
        $value
    };
}
COMMENT "Applique une valeur par défaut à NONE et facultativement NULL."
PERMISSIONS FULL;
