-- ============================================================================
-- TESTS — fn::sanitize_schedule
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schedule(
    d"2026-08-03T15:42:10Z",
    2h,
    15m
);
