-- ============================================================================
-- TESTS — fn::sanitize_debug_session
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_session("req-001","user",true);
