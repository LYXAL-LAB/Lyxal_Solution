-- ============================================================================
-- TESTS — fn::security_schema_registry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_schema_registry([{name:"req",version:"v1",status:"active"}]);
