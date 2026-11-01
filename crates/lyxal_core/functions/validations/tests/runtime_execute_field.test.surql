-- ============================================================================
-- TESTS — fn::validation_runtime_execute_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_execute_field({fields:{name:[{rule:"trim"}]}},"name"," LYXAL ",10);
