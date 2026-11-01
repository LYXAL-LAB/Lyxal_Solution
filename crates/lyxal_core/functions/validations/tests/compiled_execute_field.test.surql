-- ============================================================================
-- TESTS — fn::validation_compiled_execute_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_execute_field(
 {fields:{slug:[{rule:"trim"},{rule:"lowercase"}]}},
 "slug",
 " LYXAL ",
 10
);
