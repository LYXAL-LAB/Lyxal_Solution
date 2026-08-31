-- ============================================================================
-- TESTS — fn::sanitize_pipeline_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_validate(
 [{rule:"trim"},{rule:"lowercase"}],
 "PIPELINE",
 10
);
RETURN fn::sanitize_pipeline_validate(
 [{rule:"lowercase"},{rule:"uppercase"}],
 "PIPELINE",
 10
);
