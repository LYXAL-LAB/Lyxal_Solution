-- ============================================================================
-- TESTS — fn::validation_compile_field_rule
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compile_field_rule(
 "slug",
 {required:true,trim:true,lowercase:true,min_length:3}
);
