-- ============================================================================
-- TESTS — fn::sanitize_runtime_context
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_context(
 "user",
 "v1",
 "strict",
 {}
);
