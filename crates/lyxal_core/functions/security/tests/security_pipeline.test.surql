-- ============================================================================
-- TESTS — fn::security_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline([{rule:"detect_payload"}],"PIPELINE",10);
