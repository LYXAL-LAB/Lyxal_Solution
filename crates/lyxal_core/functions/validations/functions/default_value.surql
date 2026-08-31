-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_default_value
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_default_value(
    $value: option<any>,
    $default_value: any
) -> any {
    RETURN IF $value IS NONE { $default_value } ELSE { $value };
}
COMMENT "Applique une valeur par défaut uniquement à NONE."
PERMISSIONS FULL;
