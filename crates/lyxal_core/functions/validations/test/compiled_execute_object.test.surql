-- ============================================================================
-- TESTS — fn::validation_compiled_execute_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_execute_object(
 {fields:{name:[{rule:"trim"}]}},
 {name:" Lyxal "},
 10
);
