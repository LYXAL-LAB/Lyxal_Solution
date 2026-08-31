-- ============================================================================
-- TESTS — fn::utils_pipeline_step
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_step(
    "trim",
    {enabled:true},
    NONE
);
