-- ============================================================================
-- TESTS — fn::sanitize_port
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_port(" :8080 ","PORT");
