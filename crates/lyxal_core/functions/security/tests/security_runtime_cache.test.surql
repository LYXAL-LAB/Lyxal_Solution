-- ============================================================================
-- TESTS — fn::security_runtime_cache
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_cache(
 [{key:"a",expires_at:d"2026-08-03T10:00:00Z"}],
 {key:"a",expires_at:d"2026-08-03T20:00:00Z"},
 d"2026-08-03T12:00:00Z"
);
