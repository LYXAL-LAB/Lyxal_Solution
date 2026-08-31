-- ============================================================================
-- TESTS — fn::sanitize_conditional_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_conditional_schema(
 true,
 {name:"company"},
 {name:"person"}
);
