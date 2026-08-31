-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_chain
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_chain(
    $pipelines: array<array<object>>
) -> array<object> {
    RETURN array::flatten($pipelines);
}
COMMENT "Concatène une collection de pipelines."
PERMISSIONS FULL;
