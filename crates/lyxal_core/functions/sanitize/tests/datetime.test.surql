-- ============================================================================
-- TESTS — fn::sanitize_datetime
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_datetime(
    d"2026-08-03T15:42:10.987Z",
    1s
);
