-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_compile(
    $pipeline: array<object>,
    $field: string,
    $max_steps: int
) -> object {
    LET $steps = fn::sanitize_pipeline($pipeline,$field,$max_steps);
    RETURN {
        field: string::trim($field),
        steps: $steps,
        step_count: array::len($steps),
        compiled_at: time::now()
    };
}
COMMENT "Compile une définition de pipeline en objet exécutable."
PERMISSIONS FULL;
