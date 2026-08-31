-- ============================================================================
-- TESTS — fn::utils_pipeline_map
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_map(
    [{name:"a"},{name:"b"}],
    "name"
);
