-- ============================================================================
-- TESTS — fn::utils_pipeline_filter
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_pipeline_filter(
    [
        {name:"a",enabled:true},
        {name:"b",enabled:false}
    ],
    "enabled",
    true
);
