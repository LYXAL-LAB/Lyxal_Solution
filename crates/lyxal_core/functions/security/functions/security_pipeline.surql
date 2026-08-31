-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline(
    $value: option<any>,
    $field: string,
    $max_steps: int
) -> array<object> {
    IF $max_steps < 1 { THROW "SECURITY_INVALID_MAX_STEPS"; };
    IF $value IS NONE OR !type::is_array($value) {
        THROW string::concat(string::trim($field),"_INVALID_SECURITY_PIPELINE");
    };
    IF array::len($value) > $max_steps {
        THROW string::concat(string::trim($field),"_TOO_MANY_STEPS");
    };
    RETURN array::map(
        $value,
        |$step| fn::security_step($step,string::concat(string::trim($field),"_STEP"))
    );
}
COMMENT "Valide un pipeline Security fermé."
PERMISSIONS FULL;
