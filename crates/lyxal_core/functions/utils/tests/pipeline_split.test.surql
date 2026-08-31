-- ============================================================================
-- TESTS — fn::utils_pipeline_split
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_split(
    [{name:"a"},{name:"b"},{name:"c"}],
    1
);
