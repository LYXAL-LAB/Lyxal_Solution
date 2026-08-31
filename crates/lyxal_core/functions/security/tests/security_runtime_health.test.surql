-- ============================================================================
-- TESTS — fn::security_runtime_health
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_health({entries:[{status:"active"}]},[],d"2026-08-03T12:00:00Z");
