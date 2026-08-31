-- ============================================================================
-- TESTS — fn::utils_date_range
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_date_range(
    d"2026-08-01T00:00:00Z",
    d"2026-08-05T00:00:00Z",
    1d,
    true
);
