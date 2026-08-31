-- ============================================================================
-- TESTS — fn::sanitize_pipeline_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_compile(
 [{rule:"trim"},{rule:"lowercase"}],
 "NAME",
 10
);
