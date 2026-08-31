-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_info(
    $compiled: object
) -> object {
    RETURN {
        field: $compiled.field,
        step_count: array::len($compiled.steps),
        rules: array::map($compiled.steps, |$step| $step.rule),
        compiled_at: $compiled.compiled_at
    };
}
COMMENT "Retourne les métadonnées d'un pipeline compilé."
PERMISSIONS FULL;
