-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_conditional_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_conditional_schema(
    $condition: bool,
    $when_true: object,
    $when_false: option<object>
) -> object {
    RETURN IF $condition {
        $when_true
    } ELSE IF $when_false IS NONE {
        {}
    } ELSE {
        $when_false
    };
}
COMMENT "Sélectionne un schéma selon une condition."
PERMISSIONS FULL;
