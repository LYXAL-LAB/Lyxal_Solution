-- ============================================================================
-- TESTS — fn::security_pipeline_execute
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_execute(
 "Authorization: Bearer abc",
 [{rule:"redact_log"}],
 {}
);
