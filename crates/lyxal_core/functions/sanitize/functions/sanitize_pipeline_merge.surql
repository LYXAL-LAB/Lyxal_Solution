-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_merge(
    $left: array<object>,
    $right: array<object>,
    $max_steps: int
) -> array<object> {
    LET $merged = array::concat($left,$right);
    IF array::len($merged) > $max_steps { THROW "SANITIZE_PIPELINE_TOO_MANY_STEPS"; };
    RETURN $merged;
}
COMMENT "Fusionne deux pipelines en conservant leur ordre."
PERMISSIONS FULL;
