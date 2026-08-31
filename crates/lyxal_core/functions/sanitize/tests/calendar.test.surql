-- ============================================================================
-- TESTS — fn::sanitize_calendar
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_calendar(
    d"2026-08-03T15:42:10Z",
    "day"
);
