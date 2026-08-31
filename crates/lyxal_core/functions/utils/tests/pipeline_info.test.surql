-- ============================================================================
-- TESTS — fn::utils_pipeline_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_info(
    [{name:"a"},{name:"b"},{name:"a"}]
);
