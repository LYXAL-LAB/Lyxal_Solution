-- ============================================================================
-- TESTS — fn::sanitize_date_range
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_date_range(
    d"2026-08-10T00:00:00Z",
    d"2026-08-01T00:00:00Z",
    true
);
