-- ============================================================================
-- TESTS — fn::utils_date_age
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_date_age(
    d"1980-09-10T00:00:00Z",
    d"2026-08-03T00:00:00Z"
);
