-- ============================================================================
-- TESTS — fn::sanitize_decimal
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_decimal(" -1.234,56 ","NUMBER");
