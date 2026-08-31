-- ============================================================================
-- TESTS — fn::security_schema_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_schema_compile({name:"req",version:"v1",fields:{payload:{pipeline:[{rule:"detect_payload"}]}}},10);
