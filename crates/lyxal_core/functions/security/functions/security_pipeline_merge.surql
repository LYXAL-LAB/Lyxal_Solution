-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_merge(
    $left: array<object>,
    $right: array<object>
) -> array<object> {
    RETURN array::concat($left,$right);
}
COMMENT "Fusionne deux pipelines Security."
PERMISSIONS FULL;
