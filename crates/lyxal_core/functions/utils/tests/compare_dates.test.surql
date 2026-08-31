-- ============================================================================
-- TESTS — fn::utils_compare_dates
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_compare_dates(
    d"2026-08-01T00:00:00Z",
    d"2026-08-03T00:00:00Z"
);
