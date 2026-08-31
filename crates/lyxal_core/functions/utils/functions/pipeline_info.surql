-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_info(
    $pipeline: array<object>
) -> object {
    RETURN {
        step_count:array::len($pipeline),
        names:array::map(
            $pipeline,
            |$step|$step.name
        ),
        unique_names:array::distinct(
            array::map($pipeline,|$step|$step.name)
        )
    };
}
COMMENT "Retourne les informations générales d'un pipeline."
PERMISSIONS FULL;
