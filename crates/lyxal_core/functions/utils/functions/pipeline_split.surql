-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_split
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_split(
    $pipeline: array<object>,
    $index: int
) -> object {
    IF $index < 0 OR $index > array::len($pipeline) {
        THROW "UTILS_INVALID_PIPELINE_SPLIT_INDEX";
    };

    RETURN {
        left:array::slice($pipeline,0,$index),
        right:array::slice($pipeline,$index,array::len($pipeline))
    };
}
COMMENT "Découpe un pipeline à un index donné."
PERMISSIONS FULL;
