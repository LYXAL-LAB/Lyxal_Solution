-- ============================================================================
-- TESTS — fn::utils_pipeline_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_merge(
    [{name:"a"}],
    [{name:"b"}]
);
