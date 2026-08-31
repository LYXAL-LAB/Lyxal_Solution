-- ============================================================================
-- TESTS — fn::utils_pipeline_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_validate(
    [{name:"a"},{name:"b"}],
    ["name"],
    10
);
