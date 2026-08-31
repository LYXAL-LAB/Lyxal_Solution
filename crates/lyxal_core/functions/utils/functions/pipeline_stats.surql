-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_stats(
    $pipeline: array<object>
) -> object {
    LET $enabled = array::filter(
        $pipeline,
        |$step|$step.enabled IS NONE OR $step.enabled=true
    );

    LET $disabled = array::filter(
        $pipeline,
        |$step|$step.enabled=false
    );

    RETURN {
        total:array::len($pipeline),
        enabled:array::len($enabled),
        disabled:array::len($disabled),
        duplicate_names:array::len($pipeline)
            - array::len(
                array::distinct(
                    array::map($pipeline,|$step|$step.name)
                )
            )
    };
}
COMMENT "Calcule les statistiques d'un pipeline générique."
PERMISSIONS FULL;
