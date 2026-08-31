-- ============================================================================
-- TESTS — fn::sanitize_debug_trace
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_trace("name","trim"," A ","A",d"2026-08-03T12:00:00Z",d"2026-08-03T12:00:01Z");
