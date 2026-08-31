-- ============================================================================
-- TESTS — fn::security_schema_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_schema_manifest({entries:[{name:"req",version:"v1",status:"active"}]});
