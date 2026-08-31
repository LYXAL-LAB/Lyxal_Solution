-- ============================================================================
-- TESTS — fn::sanitize_pipeline_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_stats(
 [{rule:"default",value:"x"},{rule:"trim"}]
);
