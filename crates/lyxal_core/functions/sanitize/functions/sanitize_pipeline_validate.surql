-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_validate(
    $pipeline: array<object>,
    $field: string,
    $max_steps: int
) -> array<object> {
    LET $steps = fn::sanitize_pipeline($pipeline,$field,$max_steps);
    IF array::any($steps, |$step| $step.rule = "lowercase")
       AND array::any($steps, |$step| $step.rule = "uppercase") {
        THROW "SANITIZE_PIPELINE_CONFLICTING_CASE_RULES";
    };
    RETURN $steps;
}
COMMENT "Vérifie la cohérence d'un pipeline."
PERMISSIONS FULL;
