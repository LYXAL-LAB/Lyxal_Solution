-- ============================================================================
-- TESTS — fn::sanitize_timezone
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_timezone("UTC");
RETURN fn::sanitize_timezone("Z");
