-- ============================================================================
-- TESTS — fn::sanitize_safe_extension
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_safe_extension(".PDF!","VALUE");
