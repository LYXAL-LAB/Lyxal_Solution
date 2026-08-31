-- ============================================================================
-- TESTS — fn::sanitize_schema_registry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schema_registry(
 [{name:"user",version:"v1",status:"active"}]
);
