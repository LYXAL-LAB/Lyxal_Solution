-- ============================================================================
-- TESTS — fn::security_pipeline_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_compile([{rule:"detect_payload"}],"request_security","v1",10);
