-- ============================================================================
-- TESTS — fn::validation_compile_object_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compile_object_schema({
 name:{required:true,trim:true},
 age:{required:true}
});
