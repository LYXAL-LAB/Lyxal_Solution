-- ============================================================================
-- TESTS — fn::security_debug_session
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_session("req-1","api_request",true);
