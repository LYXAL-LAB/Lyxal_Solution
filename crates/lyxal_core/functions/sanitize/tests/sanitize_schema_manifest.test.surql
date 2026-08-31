-- ============================================================================
-- TESTS — fn::sanitize_schema_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schema_manifest({
 entries:[{name:"user",version:"v1",status:"active"}]
});
