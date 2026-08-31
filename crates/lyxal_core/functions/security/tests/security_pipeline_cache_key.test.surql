-- ============================================================================
-- TESTS — fn::security_pipeline_cache_key
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_cache_key("request_security","v1",[{rule:"detect_payload"}]);
