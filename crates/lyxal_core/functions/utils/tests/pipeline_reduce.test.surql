-- ============================================================================
-- TESTS — fn::utils_pipeline_reduce
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_reduce(
    [{cost:2},{cost:3},{name:"x"}],
    "cost",
    0
);
