-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline(
    $value: option<any>,
    $field: string,
    $max_steps: int
) -> array<object> {
    LET $clean_field = string::trim($field);
    IF $max_steps < 1 { THROW "SANITIZE_INVALID_MAX_STEPS"; };
    IF $value IS NONE OR type::is_null($value) OR !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_SANITIZE_PIPELINE");
    };
    IF array::len($value) > $max_steps {
        THROW string::concat($clean_field, "_TOO_MANY_STEPS");
    };
    RETURN array::map($value, |$step| fn::sanitize_step($step, string::concat($clean_field,"_STEP")));
}
COMMENT "Valide une définition ordonnée de pipeline."
PERMISSIONS FULL;
