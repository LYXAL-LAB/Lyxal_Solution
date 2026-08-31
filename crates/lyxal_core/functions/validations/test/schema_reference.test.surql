-- ============================================================================
-- TESTS — fn::validation_schema_reference
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_reference("user::profile@v1","SCHEMA_REF");
RETURN fn::validation_schema_reference("user/profile","SCHEMA_REF");
