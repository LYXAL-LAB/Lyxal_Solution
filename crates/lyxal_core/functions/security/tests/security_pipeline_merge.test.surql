-- ============================================================================
-- TESTS — fn::security_pipeline_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_merge([{rule:"detect_payload"}],[{rule:"redact_log"}]);
