-- ============================================================================
-- TESTS — fn::sanitize_pipeline_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_report(
 "NAME",
 " LYXAL ",
 "lyxal",
 [{rule:"trim"},{rule:"lowercase"}]
);
