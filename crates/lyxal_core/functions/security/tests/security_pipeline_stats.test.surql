-- ============================================================================
-- TESTS — fn::security_pipeline_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_stats([{rule:"detect_payload"},{rule:"redact_log"}]);
