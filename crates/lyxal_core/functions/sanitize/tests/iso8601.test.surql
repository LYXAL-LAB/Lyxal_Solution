-- ============================================================================
-- TESTS — fn::sanitize_iso8601
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_iso8601(
    d"2026-08-03T15:42:10Z"
);
