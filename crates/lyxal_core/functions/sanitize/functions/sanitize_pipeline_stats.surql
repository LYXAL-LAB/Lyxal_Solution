-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_stats(
    $pipeline: array<object>
) -> object {
    RETURN {
        step_count: array::len($pipeline),
        transformation_count: array::len(
            array::filter($pipeline, |$step| $step.rule != "default")
        ),
        has_default: array::any($pipeline, |$step| $step.rule = "default"),
        rules: array::map($pipeline, |$step| $step.rule)
    };
}
COMMENT "Calcule des statistiques structurelles sur un pipeline."
PERMISSIONS FULL;
