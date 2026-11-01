-- ============================================================================
-- TESTS — fn::validation_runtime_execute_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_execute_object({fields:{name:[{rule:"trim"}]}},{name:" LYXAL "},10);
