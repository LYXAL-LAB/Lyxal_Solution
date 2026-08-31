-- ============================================================================
-- TESTS — fn::validation_compiled_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_schema(
 {name:"user",version:"v1",definition:{}},
 {name:[{rule:"required"}]}
);
