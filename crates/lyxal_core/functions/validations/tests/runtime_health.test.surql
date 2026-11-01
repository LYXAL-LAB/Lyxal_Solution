-- ============================================================================
-- TESTS — fn::validation_runtime_health
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_health([{status:"active"}],[{expires_at:d"2026-08-03T20:00:00Z"}],d"2026-08-03T12:00:00Z");
