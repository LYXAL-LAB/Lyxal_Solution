-- ============================================================================
-- TESTS — fn::sanitize_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline(
 [{rule:"trim"},{rule:"lowercase"}],
 "PIPELINE",
 10
);
