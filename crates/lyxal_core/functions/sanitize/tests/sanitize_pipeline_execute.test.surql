-- ============================================================================
-- TESTS — fn::sanitize_pipeline_execute
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_execute(
 "  LYXAL OS  ",
 "NAME",
 [{rule:"trim"},{rule:"lowercase"},{rule:"slug",value:"-"}],
 10
);
