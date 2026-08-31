-- ============================================================================
-- TESTS — fn::security_scope
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_scope("scheduler:read");
