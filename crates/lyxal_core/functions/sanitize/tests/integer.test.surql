-- ============================================================================
-- TESTS — fn::sanitize_integer
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_integer(" -1 234 ","NUMBER");
