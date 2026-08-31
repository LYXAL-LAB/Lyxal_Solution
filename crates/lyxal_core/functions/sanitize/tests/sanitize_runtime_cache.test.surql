-- ============================================================================
-- TESTS — fn::sanitize_runtime_cache
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_cache(
 [{key:"user@v1",expires_at:d"2026-08-03T10:00:00Z"}],
 {key:"user@v1",expires_at:d"2026-08-03T20:00:00Z"},
 d"2026-08-03T12:00:00Z"
);
