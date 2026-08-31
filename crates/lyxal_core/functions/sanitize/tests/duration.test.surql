-- ============================================================================
-- TESTS — fn::sanitize_duration
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_duration(1h23m45s, 1m);
