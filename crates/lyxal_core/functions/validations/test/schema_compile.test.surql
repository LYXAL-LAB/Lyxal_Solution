-- ============================================================================
-- TESTS — fn::validation_schema_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_compile(
 "user","v1",
 {name:{required:true,trim:true,min_length:2}}
);
