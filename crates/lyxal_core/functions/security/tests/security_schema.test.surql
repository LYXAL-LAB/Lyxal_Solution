-- ============================================================================
-- TESTS — fn::security_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_schema("api_request","v1",{payload:{pipeline:[{rule:"detect_payload"}]}},"review");
