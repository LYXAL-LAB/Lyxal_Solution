-- ============================================================================
-- TESTS — fn::utils_cache_touch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_touch(
    {
        expires_at:d"2026-08-03T13:00:00Z",
        hits:2
    },
    d"2026-08-03T12:00:00Z",
    2h
);
