-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_validate(
    $pipeline: array<object>,
    $required_keys: array<string>,
    $max_steps: int
) -> object {
    IF $max_steps < 0 {
        THROW "UTILS_INVALID_PIPELINE_MAX_STEPS";
    };

    LET $invalid = array::filter(
        $pipeline,
        |$step| !array::all(
            $required_keys,
            |$key|$step[$key] IS NOT NONE
        )
    );

    RETURN {
        valid:array::len($pipeline) <= $max_steps
            AND array::len($invalid)=0,
        step_count:array::len($pipeline),
        invalid_steps:$invalid,
        exceeds_limit:array::len($pipeline)>$max_steps
    };
}
COMMENT "Vérifie la structure minimale d'un pipeline."
PERMISSIONS FULL;
