-- ============================================================================
-- TESTS — fn::security_runtime_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_request({schema_name:"req"}, {payload:"x"}, "req-1", NONE);
