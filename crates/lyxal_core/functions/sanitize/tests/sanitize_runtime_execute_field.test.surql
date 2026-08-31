-- ============================================================================
-- TESTS — fn::sanitize_runtime_execute_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_execute_field(
 {field:"NAME",steps:[{rule:"trim"}]},
 " Lyxal ",
 10
);
