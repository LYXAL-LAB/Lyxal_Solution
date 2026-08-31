-- ============================================================================
-- TESTS — fn::security_runtime_context
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_context("api_request","v1","enforce",{});
