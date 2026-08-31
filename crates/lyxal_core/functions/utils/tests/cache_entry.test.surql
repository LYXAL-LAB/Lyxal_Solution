-- ============================================================================
-- TESTS — fn::utils_cache_entry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_entry(
    "scheduler:abc",
    {id:1},
    1h,
    d"2026-08-03T12:00:00Z",
    NONE
);
