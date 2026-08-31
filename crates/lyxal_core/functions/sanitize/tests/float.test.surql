-- ============================================================================
-- TESTS — fn::sanitize_float
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_float(" -1 234,56 ","NUMBER",",");
