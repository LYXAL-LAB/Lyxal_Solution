-- ============================================================================
-- TESTS — fn::sanitize_positive
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_positive("-42.5","NUMBER");
