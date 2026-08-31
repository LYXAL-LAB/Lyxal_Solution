-- ============================================================================
-- TESTS — fn::utils_pipeline_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_stats(
    [
        {name:"a",enabled:true},
        {name:"b",enabled:false},
        {name:"a",enabled:true}
    ]
);
