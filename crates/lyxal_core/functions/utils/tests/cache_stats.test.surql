-- ============================================================================
-- TESTS — fn::utils_cache_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_stats(
    [
        {expires_at:d"2026-08-03T10:00:00Z",hits:1},
        {expires_at:d"2026-08-03T20:00:00Z",hits:2}
    ],
    d"2026-08-03T12:00:00Z"
);
