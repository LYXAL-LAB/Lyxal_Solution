-- ============================================================================
-- TESTS — fn::sanitize_rfc3339
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_rfc3339(
    d"2026-08-03T15:42:10Z"
);
