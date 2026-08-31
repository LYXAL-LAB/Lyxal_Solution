-- ============================================================================
-- TESTS — fn::validation_compiled_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_field(
 {fields:{name:[{rule:"required"}]}},
 "name"
);
