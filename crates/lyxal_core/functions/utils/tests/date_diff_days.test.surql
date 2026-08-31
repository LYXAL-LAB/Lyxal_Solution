-- ============================================================================
-- TESTS — fn::utils_date_diff_days
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_date_diff_days(
    d"2026-08-01T00:00:00Z",
    d"2026-08-03T12:00:00Z"
);
