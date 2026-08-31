-- ============================================================================
-- TESTS — fn::sanitize_pipeline_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_merge(
 [{rule:"trim"}],
 [{rule:"lowercase"}],
 10
);
