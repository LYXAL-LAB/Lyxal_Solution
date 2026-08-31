-- ============================================================================
-- TESTS — fn::utils_pipeline_chain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_chain(
    [
        [{name:"a"}],
        [{name:"b"},{name:"c"}]
    ]
);
